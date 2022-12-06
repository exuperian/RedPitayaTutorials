# Pavel's AXIS ADC Core

Here we'll describe a core that converts data from the Analog to Digital converter to an AXI Stream. This is based on Pavel Denim's [AXIS ADC Core v1](https://github.com/pavel-demin/red-pitaya-notes/blob/master/cores/axis_red_pitaya_adc_v1_0/axis_red_pitaya_adc.v), with very minor modifications. You can download the Vivado file *axis_red_pitaya_adc.v* from this folder. We'll assume you've read through the explanation for the [DAC core](/Tutorials/CORE_DAC_AXIS), in which case this should be straightforward. 

Unlike the DAC, which had a single input which took Dual Data Rate input, the Red Pitya's ADCs provide two separate channels running at the standard data rate, making our job a bit easier. However while the DAC took a clock signal which it used to time when it wrote data, the ADC has it's own clock signal which we need to read. This clock signal is delivered as [the difference between two voltages](https://en.wikipedia.org/wiki/Differential_signalling), and we will use a Vivado module called *IBUFGDS* to convert this to a single clock signal.

It will help to read our tutorial on [negative numbers in binary](/Tutorials/FPGA_NegativeBinary). The ADC output comes in offset binary, which is then converted to the more common two's complement encoding. 

## Inputs and outputs

As before the module has two parameters:

*  `ADC_DATA_WIDTH` giving the size of the DAC output, which is 14 for the STEMLab-14 (and 10 for the STEMLab-10).
* `AXIS_TDATA_WIDTH` is data size to output to the FPGA. We will pad each DAC output to 16 bits, or two bytes, giving a total output size of 32. Since padding doesn't change the value of the number (i.e. `011` is the same number as `0011`), we can feed this output to Vivado blocks and have them treat it as a 16 bit number.

```verilog
module axis_red_pitaya_adc #
(
  parameter integer ADC_DATA_WIDTH = 14,
  parameter integer AXIS_TDATA_WIDTH = 32
)
```

The ADC has its own clock which it uses to sample data. We add a wire to output this clock to the FPGA, so any processing we do on the data can stay synchronised with the ADC input. When Vivado sees `clk` in the name it will assume this wire is a clock signal. We need to tell it the clock frequency (125MHz), or Vivado will show a warning, or even have trouble compiling in some cases. We do this with  `X_INTERFACE_PARAMETER`, see page 212 of the [Designing IP Subsystems documentation](https://docs.xilinx.com/v/u/2018.3-English/ug994-vivado-ip-subsystems) if you want more details.

```verilog
// System signals
(* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
output wire                        adc_clk,
```

The clock signal from the ADC comes in as the difference in voltage in two wires, `adc_clk_p` and `adc_clk_n`:

```verilog
// ADC signals
input  wire                        adc_clk_p,
input  wire                        adc_clk_n,
```

We get two input signals `adc_dat_a` and `adc_dat_b` from the Analog to Digital Converters with width `ADC_DATA_WIDTH`.

```verilog
input  wire [ADC_DATA_WIDTH-1:0]   adc_dat_a,
input  wire [ADC_DATA_WIDTH-1:0]   adc_dat_b,
```

 There is also an additional signal `adc_csn` which X.

```verilog
output wire                        adc_csn,
```

Finally there is the now-familiar standard *AXI Stream* output. From the names of the wires, Vivado will automatically combine them into a single `m_axis` port. Vivado also likes to know the frequency of AXI Stream output, so we tell it this with `X_INTERFACE_PARAMETER`. 

```verilog
// Master side
(* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata
output wire                        m_axis_tvalid,
```

## Clock signal

```verilog
wire                      int_clk;
IBUFDS adc_clk_inst (.I(adc_clk_p), .IB(adc_clk_n), .O(int_clk));
```

We create a wire `int_clk` (*internal clock*) to hold the clock signal. The clock is given by the difference between `adc_clk_p` and `adc_clk_n`, which can be found using the [`IBUFDS` module](https://docs.xilinx.com/r/en-US/ug974-vivado-ultrascale-libraries/IBUFDS) (*Input BUFfer Differential Signal*). This takes two inputs `I` and `IB`, and gives as output `O` the difference between them.

## Update registers

This core will read the ADCs at every rising edge of `int_clk`. In between these it needs to store the data, so we need two registers of length `ADC_DATA_WIDTH`:

```verilog
reg  [ADC_DATA_WIDTH-1:0] int_dat_a_reg;
reg  [ADC_DATA_WIDTH-1:0] int_dat_b_reg;

always @(posedge int_clk)
begin
  int_dat_a_reg <= adc_dat_a;
  int_dat_b_reg <= adc_dat_b;
end
```

## AXIS output

The *AXI Stream* protocol requires us to send a signal `tvalid` to say if the data is valid or not. The simplest thing to do is set it to always be true:

```verilog
assign m_axis_tvalid = 1'b1;
```

We then define a constant `PADDING_WIDTH` equal to the number of padding bits needed. For an ADC with 14 bit output, this is 2.

```verilog
localparam PADDING_WIDTH = AXIS_TDATA_WIDTH/2 - ADC_DATA_WIDTH;
```

Note that `localparam` is just a constant. Parameters defined with `parameter`  can be modified from Vivado by right-clicking the module and clicking *Customize Block*. `localparam`  on the other hand is for constants used internally by the code.

We then assign the data. We need to convert the ADC data from offset binary to two's complement, which is done by flipping the leftmost bit. However the numbers from the ADC are such that zero is the highest voltage. So after flipping the left bit, we flip all the bits to invert the number, with a net effect of preserving the leftmost bit and flipping all the rest.

```verilog
assign m_axis_tdata = {
  {(PADDING_WIDTH+1){int_dat_b_reg[ADC_DATA_WIDTH-1]}}, ~int_dat_b_reg[ADC_DATA_WIDTH-2:0],
  {(PADDING_WIDTH+1){int_dat_a_reg[ADC_DATA_WIDTH-1]}}, ~int_dat_a_reg[ADC_DATA_WIDTH-2:0]};
```

Recall that `{a,b}` joins the binary strings `a` and `b`, and `{(n)a}` represents `n` copies of `a`. So `(PADDING_WIDTH+1){int_dat_a_reg[ADC_DATA_WIDTH-1]}` represents three copies of the leftmost bit of `int_data_a_reg`, in effect [sign extending](https://en.wikipedia.org/wiki/Sign_extension) it on the left with two bits.

## Other output

We assign `int_clk`  to the output port:

```verilog
assign adc_clk = int_clk;
```

We also set `adc_csn` to 1.

```verilog
assign adc_csn = 1'b1;
```
