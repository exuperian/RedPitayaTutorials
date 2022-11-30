# ODDR for DAC output

As described in the [Signal Generator tutorial](), the two Digital to Analog Converters (DACs) on the Red Pitaya are controlled by a single output on the FPGA. You must combine your two signals into a single channel which oscillates between the two. In a Verilog block, we do this using a construct called *ODDR*, which stands for *Output Dual Data Rate*. In this section we'll describe what these are, and how to use them.

## What is Dual Data Rate?

The clock on an FPGA creates a signal which oscillates between zero and one at a constant rate. Typically data is transferred once per clock cycle, on the *rising edge* when the signal transitions from zero to one. In *Dual Data Rate (DDR)* however data is transferred on both the rising and falling edge:

![A square wave representing the clock signal. Arrows represent data transmission on rising edges (SDR) and all edges (DDR)](img_SDRvsDDR.png)

The obvious advantage of DDR is that you can transfer twice the data in the same amount of time. Why not just double the clock signal? As discussed [here](https://electronics.stackexchange.com/questions/381825/why-use-ddr-instead-of-increasing-clock-speed), any physical wire has a [limit](https://electronics.stackexchange.com/questions/100155/bandwidth-and-wire-parameters) on how large a frequency it can carry, which limits the speed of the clock signal that can pass through it. However DDR is more complicated to design, and synchronisation is harder. *ODDR* handles these .

## The ODDR block

The FPGA has dedicated hardware to handle DDR output, called *ODDR*. This has inputs *D1, D2, CE, C, S/R*, and one output *Q*.

![Block with inputs D1 D2 CE C on the left, SR on the bottom, and output Q on the right](img_ODDRBlock.png)

* *Q* is the output, in DDR.
* *D1* and *D2* are the two Single Data Rate signals that we want to combine into DDR.
* *C* stands for clock. The ODDR needs the clock signal to time the output signals.
* *CE* stands for *Clock Enable*. Output will flow out of *Q* when *CE* is *1*, and be disabled when *CE* is 0.
* *S/R* stand for *Set* and *Reset*. Setting *S=1* forces the output to be 1, while setting *R=1* forces the output to be 0. The two are combined because the ODDR will only have one of these.

For most applications we only need to care about the clock signal *C*, the two data inputs *D1,D2*, and the output *Q*.

**Note that all inputs and outputs are only one bit in size**. The DAC on the Red Pitaya takes signals fourteen bits wide, so we will need to initialise fourteen *ODDRs* to carry this.

## ODDR Modes

The ODDR can be used in two modes, depending on when the FPGA sends data to the ODDR.

* *OPPOSITE_EDGE*: The FPGA sends *D1* to the *ODDR* on rising edges, and *D2* on falling edges. This is the default.
* *SAME_EDGE*: The FPGA sends both data inputs to the ODDR only on the rising clock edges. This makes the the FPGA logic simpler and saves resources. The *ODDR* stores both signals, and releases DDR output through Q.

### Creating an ODDR in Verilog

You instantiate an *ODDR* block like you would any other module:

```verilog
ODDR ODDR_data(.Q(q_out), .D1(d1_in), .D2(d2_in), .C(clk), .CE(1'b1), .R(1'b0), .S(1'b0))
```

* *ODDR_data* is the name we've decided to give the module. This is arbitrary.
* The syntax `.Q(q_out)` connects the `Q` port of the *ODDR* to a wire *q_out* that you've defined in Verilog. Similarly for *D1,D2,C*.
* We have set *CE*, *R*, and *S* to static values of 1, 0, and 0 respectively, which ensure the *ODDR* will always transmit data. You can set these to some wires you've defined if you want to do something more complicated.

## Further reading

* [This stackexchange post](https://electronics.stackexchange.com/questions/381825/why-use-ddr-instead-of-increasing-clock-speed) has a detailed discussion on the pros and cons of doubling the clock speed vs using DDR.

- The Xilinx documentation on ODDR can be found in pages 126-133 of the [7-series FPGAs SelectIO Resources User Guide UG471](https://docs.xilinx.com/v/u/en-US/ug471_7Series_SelectIO).
  - See Figures 2-18 and 2-19 for more details on the difference between *OPPOSITE_EDGE* and *SAME_EDGE*.
- [This ZipCPU post](https://zipcpu.com/blog/2020/08/22/oddr.html) follows someone trying to build their own *ODDR* block, and all the timing challenges this entails.