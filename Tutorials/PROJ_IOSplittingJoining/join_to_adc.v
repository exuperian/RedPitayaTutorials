`timescale 1 ns / 1 ps

module join_to_adc #
(
  parameter integer PADDED_DATA_WIDTH = 16,
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  //Split data input
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  input wire                        adc_clk,
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)  
  input wire [PADDED_DATA_WIDTH-1:0] o_data_a,
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
  input wire [PADDED_DATA_WIDTH-1:0] o_data_b,
  input wire t_valid,
  
  //Joined data output
  (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)  
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire m_axis_tvalid
);

    reg  [AXIS_TDATA_WIDTH-1:0] int_tdata_reg;
    
    always @(posedge adc_clk)
    begin
        if(t_valid)
        begin
            int_tdata_reg <= {o_data_b[PADDED_DATA_WIDTH-1:0],o_data_a[PADDED_DATA_WIDTH-1:0]};
        end
    end

  assign m_axis_tdata = int_tdata_reg;
  assign m_axis_tvalid = t_valid;

endmodule
