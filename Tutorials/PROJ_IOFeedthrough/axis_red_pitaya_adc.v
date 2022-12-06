//Based on Pavel Denim's axis_red_pitaya_adc_v1_0
//https://github.com/pavel-demin/red-pitaya-notes/blob/master/cores/axis_red_pitaya_adc_v1_0/axis_red_pitaya_adc.v
//Minor modifications by Ruvi Lecamwasam, adding X_INTERFACE_PARAMETER because
//otherwise Vivado complains about missing FREQ_HZ, and sets everything to 100MHz.
//Also changed deprecated IBUFGDS to IBUFDS 

`timescale 1 ns / 1 ps

module axis_red_pitaya_adc #
(
  parameter integer ADC_DATA_WIDTH = 14,
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  // System signals
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  output wire                        adc_clk,

  // ADC signals
  input  wire                        adc_clk_p,
  input  wire                        adc_clk_n,
  input  wire [ADC_DATA_WIDTH-1:0]   adc_dat_a,
  input  wire [ADC_DATA_WIDTH-1:0]   adc_dat_b,
  output wire                        adc_csn,

  // Master side
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid
);

  reg  [ADC_DATA_WIDTH-1:0] int_dat_a_reg;
  reg  [ADC_DATA_WIDTH-1:0] int_dat_b_reg;
  wire                      int_clk;

  IBUFDS adc_clk_inst (.I(adc_clk_p), .IB(adc_clk_n), .O(int_clk));

  always @(posedge int_clk)
  begin
    int_dat_a_reg <= adc_dat_a;
    int_dat_b_reg <= adc_dat_b;
  end

  assign adc_clk = int_clk;

  assign adc_csn = 1'b1;

  assign m_axis_tvalid = 1'b1;

  localparam PADDING_WIDTH = AXIS_TDATA_WIDTH/2 - ADC_DATA_WIDTH;
  assign m_axis_tdata = {
    {(PADDING_WIDTH+1){int_dat_b_reg[ADC_DATA_WIDTH-1]}}, ~int_dat_b_reg[ADC_DATA_WIDTH-2:0],
    {(PADDING_WIDTH+1){int_dat_a_reg[ADC_DATA_WIDTH-1]}}, ~int_dat_a_reg[ADC_DATA_WIDTH-2:0]};

endmodule

