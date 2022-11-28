`timescale 1ns / 1ps

// Takes in two separate signals, and multiplexes them together with the right signals to drive the dual DAC
module DAC_drive(
    input clk_125MHz,
    input clk_250MHz,
    input [13:0] data_in_a,
    input [13:0] data_in_b,
    output [13:0] dac_data_out,
    
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 250000000" *)
    output dac_clk,
    output dac_reset,
    output dac_select,
    output dac_write
    );
    
    // The DAC contains a single 14-bit output, which runs at 250MHz, and the values are switched between
    // each DAC, so that each DAC uses every other sample. We have to multiplex together our two signals.
    
    // dac_select controls which DAC the signal on the chip's inout bus is routed to. We just alternate
    // between each DAC by connecting it to the slow clock line.
    assign dac_select = clk_125MHz;
    
    // Connect the DAC clock and write lines straight to the fast clock; these are used to run the DAC
    // and command it to read in from the input bus.
    assign dac_clk = clk_250MHz;
    assign dac_write = clk_250MHz;
    
    // Set the reset bit permenantly low; this is a reset-high device.
    assign dac_reset = 1'b0;
       
    // Use an "output double data rate" (ODDR) flip-flop to combine our slow signals together. DDR
    // data changes on both positive *and* negative edges of the clock, which is equivalent to 
    // "normal" data rate at twice the clock speed.

    // We use a loop to generate 13 ODDR flops for each bit of the bus.
    genvar j;
    generate
        for (j=0; j<13; j=j+1) begin
            ODDR ODDR_bit(.Q(dac_data_out[j]), .D1(data_in_b[j]), .D2(data_in_a[j]), .C(clk_125MHz), .CE(1'b1), .R(1'b0), .S(1'b0));
        end
    endgenerate
    
    // Internally we've been using signed integers to represent data. The Red Pitaya DAC expects offset
    // binary, which conveniently you can convert from two's complement signed values by flipping the most significant bit.
    // So we just do that here in the flop logic.
    ODDR sign_bit(.Q(dac_data_out[13]), .D1(~data_in_b[13]), .D2(~data_in_a[13]), .C(clk_125MHz), .CE(1'b1), .R(1'b0), .S(1'b0));
        
endmodule
