#Code from Anton, combined and slightly modified
#
# Create the input and output ports
startgroup

### ADC
create_bd_port -dir I -from 13 -to 0 adc_dat_a_i
create_bd_port -dir I -from 13 -to 0 adc_dat_b_i
create_bd_port -dir I adc_clk_p_i
create_bd_port -dir I adc_clk_n_i
create_bd_port -dir O adc_enc_p_o
create_bd_port -dir O adc_enc_n_o
create_bd_port -dir O adc_csn_o

### DAC
create_bd_port -dir O -from 13 -to 0 dac_dat_o
create_bd_port -dir O dac_clk_o
create_bd_port -dir O dac_rst_o
create_bd_port -dir O dac_sel_o
create_bd_port -dir O dac_wrt_o

### PWM
create_bd_port -dir O -from 3 -to 0 dac_pwm_o

### XADC
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux0
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux1
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux9
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux8

### Expansion connector
create_bd_port -dir IO -from 7 -to 0 exp_p_tri_io
create_bd_port -dir IO -from 7 -to 0 exp_n_tri_io

### SATA connector
create_bd_port -dir O -from 1 -to 0 daisy_p_o
create_bd_port -dir O -from 1 -to 0 daisy_n_o
create_bd_port -dir I -from 1 -to 0 daisy_p_i
create_bd_port -dir I -from 1 -to 0 daisy_n_i

### LED
create_bd_port -dir O -from 7 -to 0 led_o

endgroup

# Zynq processing system with RedPitaya specific preset
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 processing_system7_0
set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0 {1}] [get_bd_cells processing_system7_0]
#We'll add the xml file through the GUI, that way you don't have to worry about what folder it is in.
#set_property -dict [list CONFIG.PCW_IMPORT_BOARD_PRESET {red_pitaya.xml}] [get_bd_cells processing_system7_0]
endgroup

# Buffers for differential IOs
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_0
set_property -dict [list CONFIG.C_SIZE {2}] [get_bd_cells util_ds_buf_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_1
set_property -dict [list CONFIG.C_SIZE {2}] [get_bd_cells util_ds_buf_1]

create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_2
set_property -dict [list CONFIG.C_SIZE {2}] [get_bd_cells util_ds_buf_2]
set_property -dict [list CONFIG.C_BUF_TYPE {OBUFDS}] [get_bd_cells util_ds_buf_2]
endgroup

#Conections
startgroup
connect_bd_net [get_bd_ports adc_clk_p_i] [get_bd_pins util_ds_buf_0/IBUF_DS_P]
connect_bd_net [get_bd_ports adc_clk_n_i] [get_bd_pins util_ds_buf_0/IBUF_DS_N]
connect_bd_net [get_bd_ports daisy_p_i] [get_bd_pins util_ds_buf_1/IBUF_DS_P]
connect_bd_net [get_bd_ports daisy_n_i] [get_bd_pins util_ds_buf_1/IBUF_DS_N]
connect_bd_net [get_bd_ports daisy_p_o] [get_bd_pins util_ds_buf_2/OBUF_DS_P]
connect_bd_net [get_bd_ports daisy_n_o] [get_bd_pins util_ds_buf_2/OBUF_DS_N]
#Connection between input and output daisy pins.
connect_bd_net [get_bd_pins util_ds_buf_1/IBUF_OUT] [get_bd_pins util_ds_buf_2/OBUF_IN]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

connect_bd_net [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
endgroup
