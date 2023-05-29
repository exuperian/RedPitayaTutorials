`timescale 1 ns / 1 ps

module split_from_dac #
(
  parameter integer PADDED_DATA_WIDTH = 16,
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  // Inputs from ADC
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  input wire                        adc_clk,
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  input wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  input wire                        m_axis_tvalid,
  
  //Split data output
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)  
  output wire [PADDED_DATA_WIDTH-1:0] o_data_a,
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  output wire [PADDED_DATA_WIDTH-1:0] o_data_b
);

  reg  [PADDED_DATA_WIDTH-1:0] int_data_a_reg;
  reg  [PADDED_DATA_WIDTH-1:0] int_data_b_reg;

  always @(posedge adc_clk)
  begin
    if(m_axis_tvalid)
    begin
        int_data_a_reg <= m_axis_tdata[15:0];
        int_data_b_reg <= m_axis_tdata[31:16];
    end
  end

  assign o_data_a = int_data_a_reg;
  assign o_data_b = int_data_b_reg;

endmodule
