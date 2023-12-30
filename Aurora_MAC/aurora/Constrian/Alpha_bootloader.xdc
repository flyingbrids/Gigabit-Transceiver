## 2.5G ethernet
set_property PACKAGE_PIN AF5 [get_ports gt_clk_clk_n]
set_property PACKAGE_PIN AF6 [get_ports gt_clk_clk_p]
create_clock -period 6.734 -name clk_ethernet [get_ports gt_clk_clk_p]

set_property PACKAGE_PIN A14 [get_ports mdio_rtl_0_mdc]
set_property PACKAGE_PIN A15 [get_ports mdio_rtl_0_mdio_io]
set_property PACKAGE_PIN D14 [get_ports {phy_rst_n[0]}]
set_property PACKAGE_PIN K15 [get_ports {geg_det_n[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports mdio_rtl_0_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_rtl_0_mdio_io]
set_property IOSTANDARD LVCMOS18 [get_ports {phy_rst_n[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {geg_det_n[0]}]
set_property PULLUP true [get_ports {geg_det_n[0]}]

##fans
set_property PACKAGE_PIN AP11 [get_ports fan_on]
set_property IOSTANDARD LVCMOS33 [get_ports fan_on]

#UART
set_property PACKAGE_PIN H19 [get_ports uart_rtl_0_rxd]
set_property PACKAGE_PIN J15 [get_ports uart_rtl_0_txd]
set_property IOSTANDARD LVCMOS18 [get_ports uart_rtl_0_rxd]
set_property IOSTANDARD LVCMOS18 [get_ports uart_rtl_0_txd]

#system
set_property PACKAGE_PIN AJ18 [get_ports sys_clk_clk_p]
set_property PACKAGE_PIN AK18 [get_ports sys_clk_clk_n]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports sys_clk_clk_p]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports sys_clk_clk_n]
set_property PACKAGE_PIN AD34 [get_ports {ims_pwr_oe[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {ims_pwr_oe[0]}]
set_property PACKAGE_PIN AA29 [get_ports sys_rst]
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins design_1_i/clk_wiz_1/inst/mmcme4_adv_inst/CLKOUT0]] -group [get_clocks -of_objects [get_pins design_1_i/clk_wiz_1/inst/mmcme4_adv_inst/CLKOUT1]] -group [get_clocks -of_objects [get_pins design_1_i/clk_wiz_1/inst/mmcme4_adv_inst/CLKOUT2]] -group [get_clocks -of_objects [get_pins {design_1_i/aurora_8b10b_interfp_0/inst/gt_wrapper_i/aurora_8b10b_gth_i/inst/gen_gtwizard_gthe4_top.aurora_8b10b_gth_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
