## ########################################################################################################################
## ##
## # (c) Copyright 2012-2016 Xilinx, Inc. All rights reserved.
## #
## # This file contains confidential and proprietary information of Xilinx, Inc. and is protected under U.S. and
## # international copyright and other intellectual property laws. 
## #
## # DISCLAIMER
## # This disclaimer is not a license and does not grant any rights to the materials distributed herewith. Except as
## # otherwise provided in a valid license issued to you by Xilinx, and to the maximum extent permitted by applicable law:
## # (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND
## # CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## # INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract or tort,
## # including negligence, or under any other theory of liability) for any loss or damage of any kind or nature related to,
## # arising under or in connection with these materials, including for any direct, or any indirect, special, incidental, or
## # consequential loss or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered as a
## # result of any action brought by a third party) even if such damage or loss was reasonably foreseeable or Xilinx had
## # been advised of the possibility of the same.
## #
## # CRITICAL APPLICATIONS
## # Xilinx products are not designed or intended to be fail-safe, or for use in any application requiring fail-safe
## # performance, such as life-support or safety devices or systems, Class III medical devices, nuclear facilities,
## # applications related to the deployment of airbags, or any other applications that could lead to death, personal injury,
## # or severe property or environmental damage (individually and collectively, "Critical Applications"). Customer assumes
## # the sole risk and liability of any use of Xilinx products in Critical Applications, subject only to applicable laws and
## # regulations governing limitations on product liability.
## #
## # THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
## #
## ########################################################################################################################

# This is example design xdc.

#create_clock -name system_clock -period 20.00 [get_ports ref_clk]

#create_clock -name gt_clk -period 6.400 [get_ports gtref_clk]

set_false_path -to [get_pins -hier -nocase -regexp {.*axi_eth_ex_des_data_sync_reg0.*/D}]
set_false_path -to [get_pins -hier -nocase -regexp {.*axi_eth_ex_des_reset_sync.*/PRE}  ]
set_max_delay -from [list [get_pins axi_streaming_gen_inst/loopback_master_slaven_sync_inst/axi_eth_ex_des_data_sync_reg4/C] [get_pins {user_side_FIFO/*x_fifo_i/rd_addr_*_reg[*]/C}] [get_pins axi_streaming_gen_inst/slv_lb_inst/en_rx_on_saxis_reg/C] [get_pins {user_side_FIFO/rx_fifo_i/FSM_onehot_rd_state_reg[*]/C}] [get_pins axi_streaming_gen_inst/slv_lb_inst/U0_fifo/full_reg/C]] -to [get_pins {user_side_FIFO/*x_fifo_i/wr_rd_addr_reg[*]/D}] -datapath_only 3.2 -quiet


set_power_opt -exclude_cells [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ *.bram.* }]


create_waiver -quiet -type CDC -id {CDC-10} -user "axi_ethernet" -tags "11999" -desc "The CDC-10 warning is waived as it is on the reset path which is level signal. This is safe to ignore." -from [get_pins axi_lite_ctrl_inst/set_soft_rst_reg/C]
create_waiver -quiet -type CDC -id {CDC-11} -user "axi_ethernet" -tags "11999" -desc "The CDC-11 warning is waived as it is on the reset path which is level signal. This is safe to ignore." -from [get_pins -of [get_cells -hier -filter {name =~ */axi_*_reset_gen/axi_eth_ex_des_reset_sync4_reg*}] -filter {name =~ *C}]
create_waiver -quiet -type CDC -id {CDC-11} -user "axi_ethernet" -tags "11999" -desc "The speed[1:0] signal is synced with two different syncers where fan-out is expected so can be waived" -from [get_pins {axi_lite_ctrl_inst/set_speed_reg[*]/C}] -to [get_pins -of [get_cells -hier -filter {name =~ */speed_*/axi_eth_ex_des_data_sync_reg0*}] -filter {name =~ *D}] 
create_waiver -quiet -type CDC -id {CDC-10} -user "axi_ethernet" -tags "11999" -desc "The CDC-10 warning is waived as it is on the reset path which is level signal. This is safe to ignore." -from [get_pins -of [get_cells -hier -filter {name =~ */axi_eth_ex_des_reset_sync4_reg*}] -filter {name =~ *C}]
create_waiver -quiet -type CDC -id {CDC-10} -user "axi_ethernet" -tags "11999" -desc "The CDC-10 warning is waived as it is on the reset path which is level signal. This is safe to ignore." -from [get_pins axi_lite_ctrl_inst/rst_chk_err_reg/C] -to [get_pins -of [get_cells -hier -filter {name =~ */axi_eth_ex_des_reset_sync0_reg*}] -filter {name =~ *PRE}]
create_waiver -quiet -type CDC -id {CDC-11} -user "axi_ethernet" -tags "11999" -desc "The reset signal is synced with two different syncers where fan-out is expected so can be waived." -from [get_pins axi_lite_ctrl_inst/rst_chk_err_reg/C] -to [get_pins -of [get_cells -hier -filter {name =~ */axi_eth_ex_des_reset_sync0_reg*}] -filter {name =~ *PRE}]
create_waiver -quiet -type CDC -id {CDC-11} -user "axi_ethernet" -tags "11999" -desc "The reset signal is synced with two different syncers where fan-out is expected so can be waived." -from [get_pins axi_lite_ctrl_inst/set_soft_rst_reg/C]

create_waiver -quiet -type CDC -id {CDC-1} -user "axi_ethernet" -tags "11999" -desc "This data-bus is part of the DMUX synchronizer, which is essentially a false paths and can be ignored." -from [get_pins -of [get_cells -hier -filter {name =~ */rx_fifo_i/rd_addr_prev_reg[*]*}] -filter {name =~ *C}] -to [get_pins -of [get_cells -hier -filter {name =~ */rx_fifo_i/wr_rd_addr_reg[*]*}] -filter {name =~ *D}]

create_waiver -quiet -type CDC -id {CDC-10} -user "axi_ethernet" -tags "11999" -desc "The CDC-10 warning is waived as it is on the reset path which is level signal. This is safe to ignore." -from [get_pins -of [get_cells -hier -filter {name =~ */transceiver_inst/gtwiz_reset_*x_done_in_int_reg_reg*}] -filter {name =~ *C}] -to [get_pins -of [get_cells -hier -filter {name =~ */reset_synchronizer_gtwiz_reset_*x_*_inst/rst_in_meta_reg*}] -filter {name =~ *PRE}]
create_waiver -quiet -type CDC -id {CDC-11} -user "axi_ethernet" -tags "11999" -desc "The pat_chk_en/gen signal is synced with two different syncers where fan-out is expected so can be waived" -from [get_pins -of [get_cells -hier -filter {name =~ */pat_*_enable_reg_reg*}] -filter {name =~ *C}] -to [get_pins -of [get_cells -hier -filter {name =~ */pat_*_en/axi_eth_ex_des_data_sync_reg0*}] -filter {name =~ *D}]
create_waiver -quiet -type CDC -id {CDC-11} -user "axi_ethernet" -tags "11999" -desc "This is known CPLL Calibration logic path. This is safe to ignore." -from [get_pins -of [get_cells -hier -filter {name =~ */U_TXOUTCLK_FREQ_COUNTER/state_reg[0]*}] -filter {name =~ *C}] -to [list [get_pins -of [get_cells -hier -filter {name =~ */U_TXOUTCLK_FREQ_COUNTER/reset_synchronizer_testclk_rst_inst/rst_in_meta_reg*}] -filter {name =~ *PRE}] [get_pins -of [get_cells -hier -filter {name =~ */U_TXOUTCLK_FREQ_COUNTER/tstclk_rst_dly1_reg*}] -filter {name =~ *D}] ]

create_waiver -quiet -type CDC -id {CDC-1} -user "axi_ethernet" -tags "11999" -desc "clock signal is connected  to clock reg data pin." -from [get_pins -of [get_cells -hier -filter {name =~ */bit8_sample_*/source_data_in_reg1_reg*}] -filter {name =~ *C}] -to [get_pins -of [get_cells -hier -filter {name =~ */bit8_sample_*/data_sync1_reg*}] -filter {name =~ *D}]

create_waiver -quiet -type CDC -id {CDC-12} -user "axi_ethernet" -desc "The CDC-12 warning is waived as it is on the reset path which is level signal. This is safe to ignore." -tags "11999" -to [get_pins -hierarchical -regexp .*/reset_synchronizer_gtwiz_reset_(r|t)x_.*/rst_in_meta_reg/PRE] 
create_waiver -quiet -type CDC -id {CDC-10} -user "axi_ethernet" -desc "The CDC-10 warning is waived as it is on the reset path which is level signal. This is safe to ignore." -tags "11999" -to [get_pins -hierarchical -regexp .*/reset_synchronizer_gtwiz_reset_(r|t)x_.*/rst_in_meta_reg/PRE] 
create_waiver -quiet -type CDC -id {CDC-13} -user "axi_ethernet" -desc "The CDC-13 warning is waived as comma align enable is a level signal. This is safe to ignore" -tags "11999" -from [get_pins -hierarchical -regexp .*transceiver_inst/reclock_encommaalign/reset_sync6/C] -to [get_pins -hierarchical -regexp .*GTYE4_CHANNEL_PRIM_INST/RX(P|M)COMMAALIGNEN]

