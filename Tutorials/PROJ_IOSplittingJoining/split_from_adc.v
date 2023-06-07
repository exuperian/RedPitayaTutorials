//Ruvi Lecamwasam, June 2023
//Split a 32 bit signal from Pavel Denim's ADC core
//into two 16 bit signals.
//
//See github.com/exuperian/RedPitayaTutorials

`timescale 1 ns / 1 ps

module split_from_adc #
(
  parameter integer PADDED_DATA_WIDTH = 16,
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  //Input from the ADC is a single AXI stream
  //Clock signal
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  input wire                        aclk,
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  //Data
  input wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input wire                        s_axis_tvalid,
  
  //Wires carrying the output data
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)  
  output wire [PADDED_DATA_WIDTH-1:0] in1,
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  output wire [PADDED_DATA_WIDTH-1:0] in2,
  //Only need a single t_valid, since both will 
  //be valid at the same time
  output wire t_valid
);

  //Registers to hold the data in-between valid signals
  reg  [PADDED_DATA_WIDTH-1:0] in1_reg;
  reg  [PADDED_DATA_WIDTH-1:0] in2_reg;

  //Every clock signal, update both registers if the AXI
  //stream is valid.
  always @(posedge aclk)
  begin
    if(s_axis_tvalid)
    begin
        in1_reg <= s_axis_tdata[15:0];
        in2_reg <= s_axis_tdata[31:16];
    end
  end

  //Connect output wires to the registers
  assign in1 = in1_reg;
  assign in2 = in2_reg;

  //Because registers always hold valid data,
  //output will always be valid
  assign t_valid  = 1'b1;

endmodule
