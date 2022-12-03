# Pavel's AXIS ADC Core

Here we'll go through Pavel Denim's [AXIS ADC Core v2](https://github.com/pavel-demin/red-pitaya-notes/blob/master/cores/axis_red_pitaya_adc_v2_0/axis_red_pitaya_adc.v), which reads data from the fast analog inputs, and makes it available with the *AXI Stream* protocol. We'll assume you've read through the explanation for the [DAC core](/Tutorials/CORE_DAC_AXIS), in which case this should be quite straightforward. Unlike the DAC, which had a single input which took Dual Data Rate input, the Red Pitya's ADCs provide two separate channels running at the standard data rate. 

It will help to read our tutorial on [negative numbers in binary](/Tutorials/FPGA_NegativeBinary). The ADC output comes in offset binary, which is then converted to the more common two's complement encoding. 

## Inputs and outputs

As before the module has two parameter, `ADC_DATA_WIDTH` giving the size of the DAC output, and `AXIS_TDATA_WIDTH` giving the data size to output to the FPGA.

```verilog
module axis_red_pitaya_adc #
(
  parameter integer ADC_DATA_WIDTH = 14,
  parameter integer AXIS_TDATA_WIDTH = 32
)
```

The ADC takes in a clock signal `aclk`. Previously we gave the DAC the clock signal `FCLK` from the processing system, and it generated data at that rate. The ADC however has its own clock according to which it is sampling data, and it is this clock that we will feed the block.

```verilog
// System signals
input  wire        aclk,
```

We get two input signals `adc_dat_a` and `adc_dat_b` from the Analog to Digital Converters with width `ADC_DATA_WIDTH` depending on the model of Pitaya. There is also an additional signal `adc_csn` which X.

```verilog
// ADC signals
output wire                        adc_csn,
input  wire [ADC_DATA_WIDTH-1:0]   adc_dat_a,
input  wire [ADC_DATA_WIDTH-1:0]   adc_dat_b,
```

Finally there is the now-familiar standard *AXI Stream* output. Note that this has a width of 32 bits, so we will have to pad the data from the ADC.

```verilog
// Master side
output wire                        m_axis_tvalid,
output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata
```

## Update registers

This core will read the ADCs at every rising edge of `aclk`. In between these it needs to store the data, thus two registers are required. The lengths of these are `ADC_DATA_WIDTH`.

```verilog
reg  [ADC_DATA_WIDTH-1:0] int_dat_a_reg;
reg  [ADC_DATA_WIDTH-1:0] int_dat_b_reg;
```

On every rising clock edge, the code takes data from the ADC and send it to the registers.

```verilog
always @(posedge aclk)
begin
  int_dat_a_reg <= adc_dat_a;
  int_dat_b_reg <= adc_dat_b;
end
```

## AXIS output

We set `adc_csn` to 1.

```verilog
assign adc_csn = 1'b1;
```

The *AXI Stream* protocol requires us to send a signal `tvalid` to say if the data is valid or not. The simplest thing to do is set it to always be true:

```verilog
assign m_axis_tvalid = 1'b1;
```

Finally we assign the output data:

```verilog
localparam PADDING_WIDTH = AXIS_TDATA_WIDTH/2 - ADC_DATA_WIDTH;

assign m_axis_tdata = {
  {(PADDING_WIDTH+1){int_dat_b_reg[ADC_DATA_WIDTH-1]}}, ~int_dat_b_reg[ADC_DATA_WIDTH-2:0],
  {(PADDING_WIDTH+1){int_dat_a_reg[ADC_DATA_WIDTH-1]}}, ~int_dat_a_reg[ADC_DATA_WIDTH-2:0]};
```

A few things are happening in this block:

* The data from each ADC was padded up to 16 bits.We need to convert from offset binary to two's complement. Typically this would mean flipping the leftmost bit. However the numbers from the ADC are such that zero is the highest voltage and one is the lowest. So after flipping the first bit, we flip all the bits to invert the number, with a net effect of preserving the leftmost bit and flipping all the rest.

## Final note

It may seem confusing how data comes in from the ADC padded on the right, but goes out to the FPGA padded on the left. The ADC provides two channels of data, whereas the DAC accepts a single channel at DDR input. The reason for this is that the ADC, DAC, Zynq chip, and Vivado were all made by different manufacturers, with their own standards and conventions. Part of FPGA programming is interfacing data between different formats, which is why it's so helpful to understand a little bit of binary.
