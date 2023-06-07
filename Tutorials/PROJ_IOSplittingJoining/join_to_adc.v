//Ruvi Lecamwasam, June 2023
//Joins two 16 bit signals into a 32 bit signal 
//which can be given to Pavel Denim's AXIS ADC core.
//
//See github.com/exuperian/RedPitayaTutorials

`timescale 1 ns / 1 ps

module join_to_adc #
(
  parameter integer PADDED_DATA_WIDTH = 16,
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  //Clock signal, should be 125MHz from ADC
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  input wire                        aclk,
  //Data to send to outputs
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)  
  input wire [PADDED_DATA_WIDTH-1:0] out1,
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  input wire [PADDED_DATA_WIDTH-1:0] out2,
  input wire out1_valid,
  input wire out2_valid,
  
  //Joined output data
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)  
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire m_axis_tvalid
);

  //Two registers to hold the values of out1/2
  //during periods where the valid signal is false.
  reg  [PADDED_DATA_WIDTH-1:0] out1_reg;
  reg  [PADDED_DATA_WIDTH-1:0] out2_reg;
  
  //Each clock cycle, update the data in each register
  //if the corresponding signal is valid.
  always @(posedge aclk)
  begin
    if(out1_valid)
    begin
        out1_reg <= out1[PADDED_DATA_WIDTH-1:0];
    end
    if(out2_valid)
    begin
        out2_reg <= out2[PADDED_DATA_WIDTH-1:0];
    end
  end

  //Send the two registers as output
  assign m_axis_tdata = {out2_reg[PADDED_DATA_WIDTH-1:0],out1_reg[PADDED_DATA_WIDTH-1:0]};
  //Since our registers always hold correct data,
  //the output signal is always valid
  assign m_axis_tvalid = 1'b1;

endmodule
