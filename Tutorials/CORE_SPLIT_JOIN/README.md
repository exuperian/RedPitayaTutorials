# Cores for splitting and joining AXIS data

Here are the cores we use for splitting and joining AXIS data.

## split_from_dac

The first core splits 

### Block

![The split_from_dac block. It has inputs m_axis and adc_clk; m_axis contains a 32 bit vector m_axis_tdata and m_axis_tvalid. It has two 16 bit output vectors o_data_a and o_data_b.](img_splitfromdac.png)

### Code

The code is

```verilog
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
```

## join_to_adc

### Block

![The join_to_adc block. It has inputs adc_clk, t_valid, and two 16 bit vectors o_data_a and o_data_b. It has a single output m_axis, containing a 32 bit vector m_axis_tdata and m_axis_tvalid.](img_jointoadc.png)

### Code

```verilog
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
```


