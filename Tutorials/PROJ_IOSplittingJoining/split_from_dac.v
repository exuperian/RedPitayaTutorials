//Ruvi Lecamwasam, May 2023
//Split a 32 bit signal from Pavel Denim's DAC core
//into two 16 bit signals.
//
//See github.com/exuperian/RedPitayaTutorials

`timescale 1 ns / 1 ps

module split_from_dac #
(
  parameter integer PADDED_DATA_WIDTH = 16,
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  // Inputs from ADC
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  input wire                        aclk,
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  input wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input wire                        s_axis_tvalid,
  
  //Split data output
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)  
  output wire [PADDED_DATA_WIDTH-1:0] in_1,
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  output wire [PADDED_DATA_WIDTH-1:0] in_2,
  output wire t_valid
);

  reg  [PADDED_DATA_WIDTH-1:0] in_1_reg;
  reg  [PADDED_DATA_WIDTH-1:0] in_2_reg;

  always @(posedge aclk)
  begin
    if(s_axis_tvalid)
    begin
        in_1_reg <= s_axis_tdata[15:0];
        in_2_reg <= s_axis_tdata[31:16];
    end
  end

  assign in_1 = in_1_reg;
  assign in_2 = in_2_reg;

  assign t_valid  = s_axis_tvalid;

endmodule
