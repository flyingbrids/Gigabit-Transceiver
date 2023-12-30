//----------------------------------------------------------------------------------------------------------------------
// Title      : Verilog Support Level Module
// File       : axi_ethernet_subsystem_support.v
// Author     : Xilinx Inc.
// ########################################################################################################################
// ##
// # (c) Copyright 2012-2016 Xilinx, Inc. All rights reserved.
// #
// # This file contains confidential and proprietary information of Xilinx, Inc. and is protected under U.S. and
// # international copyright and other intellectual property laws. 
// #
// # DISCLAIMER
// # This disclaimer is not a license and does not grant any rights to the materials distributed herewith. Except as
// # otherwise provided in a valid license issued to you by Xilinx, and to the maximum extent permitted by applicable law:
// # (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND
// # CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// # INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract or tort,
// # including negligence, or under any other theory of liability) for any loss or damage of any kind or nature related to,
// # arising under or in connection with these materials, including for any direct, or any indirect, special, incidental, or
// # consequential loss or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered as a
// # result of any action brought by a third party) even if such damage or loss was reasonably foreseeable or Xilinx had
// # been advised of the possibility of the same.
// #
// # CRITICAL APPLICATIONS
// # Xilinx products are not designed or intended to be fail-safe, or for use in any application requiring fail-safe
// # performance, such as life-support or safety devices or systems, Class III medical devices, nuclear facilities,
// # applications related to the deployment of airbags, or any other applications that could lead to death, personal injury,
// # or severe property or environmental damage (individually and collectively, "Critical Applications"). Customer assumes
// # the sole risk and liability of any use of Xilinx products in Critical Applications, subject only to applicable laws and
// # regulations governing limitations on product liability.
// #
// # THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
// #
// ########################################################################################################################
// Description: This module holds the support level for the AXI Ethernet IP.
//              It contains potentially shareable FPGA resources such as clocking, reset and IDELAYCTRL logic.
//              This can be used as-is in a single core design, or adapted for use with multi-core implementations.
//----------------------------------------------------------------------------------------------------------------------
`timescale 1ps/1ps

module axi_ethernet_subsystem_support (
    input wire             resetn   ,  
    input wire             ref_clk             , 
    
    input wire            sgmii_rxn           , 
    input wire            sgmii_rxp           , 
    output wire            sgmii_txn           , 
    output wire            sgmii_txp           , 
    
    output wire            signal_detect_out       , 
    
    input wire            gtref_clk           , 
    output wire           mmcm_locked_out           ,
    output wire           pma_reset_out           ,
    
    output wire userclk_out,
    output wire userclk2_out,
    output wire rxuserclk_out,
    output wire rxuserclk2_out,
    
output wire  gtwiz_reset_rx_done_out,
output wire  gtwiz_reset_tx_done_out,
input wire  gtwiz_reset_all_in,
input wire  gtwiz_reset_clk_freerun_in,
input wire  gtwiz_reset_rx_datapath_in,
input wire  gtwiz_reset_rx_pll_and_datapath_in,
input wire  gtwiz_reset_tx_datapath_in,
input wire  gtwiz_reset_tx_pll_and_datapath_in,
input wire  gtwiz_userclk_rx_active_in,
input wire  gtwiz_userclk_tx_active_in,

    output wire               cplllock_out         ,
    
    input wire  [1 : 0]     rxpd_in,
    input wire  [1 : 0]     txpd_in,
    input wire  [15 : 0] gtwiz_userdata_tx_in,
    input wire  [15 : 0] txctrl0_in,
    input wire  [15 : 0] txctrl1_in,
    output wire  [1 : 0] rxclkcorcnt_out,
    output wire  [15 : 0] gtwiz_userdata_rx_out,
    output wire  [15 : 0] rxctrl0_out,
    output wire  [15 : 0] rxctrl1_out,
    output wire  [7 : 0] rxctrl2_out,
    output wire  [7 : 0] rxctrl3_out,
    output wire  rxpmaresetdone_out,
    output wire txpmaresetdone_out,
    output wire  rxresetdone_out,
    output wire  txresetdone_out,
    input wire  txelecidle_in,
    input wire  txusrclk2_in,
    input wire  txusrclk_in,
    input wire  rxusrclk2_in,
    input wire  rxusrclk_in,
    input wire  rx8b10ben_in,
    input wire  rxcommadeten_in,
    input wire  rxmcommaalignen_in,
    input wire  rxpcommaalignen_in,
    output wire  gtwiz_buffbypass_rx_done_out,
    input wire  gtwiz_buffbypass_rx_reset_in,
    input wire  gtwiz_buffbypass_rx_start_user_in,
    output wire  [2 : 0] rxbufstatus_out,
    output wire  [1 : 0] txbufstatus_out
    
//        .userclk               (userclk           ),
//        .userclk2              (userclk2          ),
//        .rxuserclk             (rxuserclk         ),
//        .rxuserclk2            (rxuserclk2        ),

//        .rx8b10ben_out                       (rx8b10ben_out                      ),
//        .rxclkcorcnt_in                      (2'b0 ),
//        .rxcommadeten_out                    (rxcommadeten_out                   ),
//        .rxctrl0_in                          (rxctrl0_in                         ),
//        .rxctrl1_in                          (rxctrl1_in                         ),
//        .rxctrl2_in                          (rxctrl2_in                         ),
//        .rxctrl3_in                          (rxctrl3_in                         ),
//        .rxmcommaalignen_out                 (rxmcommaalignen_out                ),
//        .rxpcommaalignen_out                 (rxpcommaalignen_out                ),
//        .rxpd_out                            (rxpd_out                           ),
//        .rxpmaresetdone_in                   (rxpmaresetdone_in                  ),
//        .rxresetdone_in                      (rxresetdone_in                     ),
//        .rxusrclk2_out                       (rxusrclk2_out                      ),
//        .rxusrclk_out                        (rxusrclk_out                       ),
//        .tx8b10ben_out                       (tx8b10ben_out                      ),
//        .txctrl0_out                         (txctrl0_out                       ),
//        .txctrl1_out                         (txctrl1_out                       ),
//        .txctrl2_out                         (txctrl2_out                       ),
//        .txelecidle_out                      (txelecidle_out                    ),
//        .txpd_out                            (txpd_out                          ),
//        .txresetdone_in                      (txresetdone_in                    ),
//        .txusrclk2_out                       (txusrclk2_out                     ),
//        .txusrclk_out                        (txusrclk_out                      ),

 
//        .gtwiz_buffbypass_rx_reset_out       (gtwiz_buffbypass_rx_reset_out     ),
//        .gtwiz_buffbypass_rx_start_user_out  (gtwiz_buffbypass_rx_start_user_out),
//        .gtwiz_buffbypass_rx_done_in         (gtwiz_buffbypass_rx_done_in       ),
//        .rxbufstatus_in                      (3'b0),
//        .txbufstatus_in                      (txbufstatus_in                    ),
//    output            mdio_mdc            , 
//    input             mdio_mdio_i         , 
//    output            mdio_mdio_o         , 
//    output            mdio_mdio_t         , 

//    input             s_axi_lite_clk
);



    wire cplllock_in, drp_den_in, drp_drdy_out, drp_dwe_in, drp_req_out;
    wire gtwiz_buffbypass_rx_done_in, gtwiz_buffbypass_rx_reset_out, gtwiz_buffbypass_rx_start_user_out, gtwiz_buffbypass_tx_reset_out;
    wire gtwiz_buffbypass_tx_start_user_out, gtwiz_reset_all_out, gtwiz_reset_clk_freerun_out, gtwiz_reset_rx_datapath_out, gtwiz_reset_rx_done_in;
    wire gtwiz_reset_rx_pll_and_datapath_out, gtwiz_reset_tx_datapath_out, gtwiz_reset_tx_done_in, gtwiz_reset_tx_pll_and_datapath_out;
    wire rx8b10ben_out, rxcommadeten_out, gtwiz_userclk_rx_active_out, gtwiz_buffbypass_tx_done_in, gtwiz_userclk_tx_active_out;
    wire rxmcommaalignen_out, rxoutclk, rxpcommaalignen_out, rxpmaresetdone_in, rxresetdone_in;
    wire rxusrclk2_out, rxusrclk_out, tx8b10ben_out, txelecidle_out, txoutclk, txpmaresetdone_in;
    wire txresetdone_in, txusrclk2_out, txusrclk_out;

    wire [ 1 : 0 ] rxclkcorcnt_in, rxpd_out, txbufstatus_in, txpd_out;
    wire [15 : 0 ] drp_di_in, drp_do_out, gtwiz_userdata_rx_in, gtwiz_userdata_tx_out, rxctrl0_in, rxctrl1_in, txctrl0_out, txctrl1_out;
    wire [ 2 : 0 ] rxbufstatus_in;
    wire [ 7 : 0 ] rxctrl2_in, rxctrl3_in, txctrl2_out;
    wire [ 9 : 0 ] drp_daddr_in;



    assign rxclkcorcnt_out = 2'b0;
    assign rxbufstatus_out = 3'b0;
    assign signal_detect = 1'b1;
/// wire  [ 27:0]  rx_statistics_data_int ;
/// wire  [ 31:0]  tx_statistics_data_int ;
/// assign  rx_statistics_statistics_data  =  rx_statistics_data_int[27:0];
/// assign  tx_statistics_statistics_data  =  tx_statistics_data_int[31:0];

//    axi_ethernet_subsystem   U0_axi_ethernet_subsystem
//    (
//        .axis_clk            (axis_clk         ),
//        .axi_txc_arstn       (axi_txc_arstn    ),
//        .s_axis_txc_tdata    (s_axis_txc_tdata ),
//        .s_axis_txc_tkeep    (s_axis_txc_tkeep ),
//        .s_axis_txc_tlast    (s_axis_txc_tlast ),
//        .s_axis_txc_tready   (s_axis_txc_tready),
//        .s_axis_txc_tvalid   (s_axis_txc_tvalid),
//        .axi_txd_arstn       (axi_txd_arstn    ),
//        .s_axis_txd_tdata    (s_axis_txd_tdata ),
//        .s_axis_txd_tkeep    (s_axis_txd_tkeep ),
//        .s_axis_txd_tlast    (s_axis_txd_tlast ),
//        .s_axis_txd_tready   (s_axis_txd_tready),
//        .s_axis_txd_tvalid   (s_axis_txd_tvalid),
//        .axi_rxd_arstn       (axi_rxd_arstn    ),
//        .m_axis_rxd_tdata    (m_axis_rxd_tdata ),
//        .m_axis_rxd_tkeep    (m_axis_rxd_tkeep ),
//        .m_axis_rxd_tlast    (m_axis_rxd_tlast ),
//        .m_axis_rxd_tready   (m_axis_rxd_tready),
//        .m_axis_rxd_tvalid   (m_axis_rxd_tvalid),
//        .axi_rxs_arstn       (axi_rxs_arstn    ),
//        .m_axis_rxs_tdata    (m_axis_rxs_tdata ),
//        .m_axis_rxs_tkeep    (m_axis_rxs_tkeep ),
//        .m_axis_rxs_tlast    (m_axis_rxs_tlast ),
//        .m_axis_rxs_tready   (m_axis_rxs_tready),
//        .m_axis_rxs_tvalid   (m_axis_rxs_tvalid),

//        .signal_detect         (signal_detect     ),


//        .pma_reset             (pma_reset         ),
//        .userclk               (userclk           ),
//        .userclk2              (userclk2          ),
//        .rxuserclk             (rxuserclk         ),
//        .rxuserclk2            (rxuserclk2        ),

//        .mdio_mdc              (mdio_mdc            ),
//        .mdio_mdio_i           (mdio_mdio_i         ),
//        .mdio_mdio_o           (mdio_mdio_o         ),
//        .mdio_mdio_t           (mdio_mdio_t         ),

//        .phy_rst_n             (phy_rst_n           ),

//        .mmcm_locked           (mmcm_locked       ),
//        .ref_clk               (ref_clk             ),

//        .cplllock_in (cplllock_in ),
//        .gtwiz_reset_all_out                 (gtwiz_reset_all_out                ),
//        .gtwiz_reset_clk_freerun_out         (gtwiz_reset_clk_freerun_out        ),
//        .gtwiz_reset_rx_datapath_out         (gtwiz_reset_rx_datapath_out        ),
//        .gtwiz_reset_rx_done_in              (gtwiz_reset_rx_done_in             ),
//        .gtwiz_reset_rx_pll_and_datapath_out (gtwiz_reset_rx_pll_and_datapath_out),
//        .gtwiz_reset_tx_datapath_out         (gtwiz_reset_tx_datapath_out        ),
//        .gtwiz_reset_tx_done_in              (gtwiz_reset_tx_done_in             ),
//        .gtwiz_reset_tx_pll_and_datapath_out (gtwiz_reset_tx_pll_and_datapath_out),
//        .gtwiz_userclk_rx_active_out         (gtwiz_userclk_rx_active_out        ),
//        .gtwiz_userclk_tx_active_out         (gtwiz_userclk_tx_active_out        ),
//        .gtwiz_userdata_rx_in                (gtwiz_userdata_rx_in               ),
//        .gtwiz_userdata_tx_out               (gtwiz_userdata_tx_out              ),
//        .rx8b10ben_out                       (rx8b10ben_out                      ),
//        .rxclkcorcnt_in                      (2'b0 ),
//        .rxcommadeten_out                    (rxcommadeten_out                   ),
//        .rxctrl0_in                          (rxctrl0_in                         ),
//        .rxctrl1_in                          (rxctrl1_in                         ),
//        .rxctrl2_in                          (rxctrl2_in                         ),
//        .rxctrl3_in                          (rxctrl3_in                         ),
//        .rxmcommaalignen_out                 (rxmcommaalignen_out                ),
//        .rxpcommaalignen_out                 (rxpcommaalignen_out                ),
//        .rxpd_out                            (rxpd_out                           ),
//        .rxpmaresetdone_in                   (rxpmaresetdone_in                  ),
//        .rxresetdone_in                      (rxresetdone_in                     ),
//        .rxusrclk2_out                       (rxusrclk2_out                      ),
//        .rxusrclk_out                        (rxusrclk_out                       ),
//        .tx8b10ben_out                       (tx8b10ben_out                      ),
//        .txctrl0_out                         (txctrl0_out                       ),
//        .txctrl1_out                         (txctrl1_out                       ),
//        .txctrl2_out                         (txctrl2_out                       ),
//        .txelecidle_out                      (txelecidle_out                    ),
//        .txpd_out                            (txpd_out                          ),
//        .txresetdone_in                      (txresetdone_in                    ),
//        .txusrclk2_out                       (txusrclk2_out                     ),
//        .txusrclk_out                        (txusrclk_out                      ),

 
//        .gtwiz_buffbypass_rx_reset_out       (gtwiz_buffbypass_rx_reset_out     ),
//        .gtwiz_buffbypass_rx_start_user_out  (gtwiz_buffbypass_rx_start_user_out),
//        .gtwiz_buffbypass_rx_done_in         (gtwiz_buffbypass_rx_done_in       ),
//        .rxbufstatus_in                      (3'b0),
//        .txbufstatus_in                      (txbufstatus_in                    ),

//        .s_axi_araddr      (s_axi_araddr [17:0] ),
//        .s_axi_awaddr      (s_axi_awaddr [17:0] ),
//        .s_axi_lite_resetn (s_axi_lite_resetn),
//        .s_axi_arready     (s_axi_arready    ),
//        .s_axi_arvalid     (s_axi_arvalid    ),
//        .s_axi_awready     (s_axi_awready    ),
//        .s_axi_awvalid     (s_axi_awvalid    ),
//        .s_axi_bready      (s_axi_bready     ),
//        .s_axi_bresp       (s_axi_bresp      ),
//        .s_axi_bvalid      (s_axi_bvalid     ),
//        .s_axi_rdata       (s_axi_rdata      ),
//        .s_axi_rready      (s_axi_rready     ),
//        .s_axi_rresp       (s_axi_rresp      ),
//        .s_axi_rvalid      (s_axi_rvalid     ),
//        .s_axi_wdata       (s_axi_wdata      ),
//        .s_axi_wready      (s_axi_wready     ),
//        .s_axi_wstrb       (4'hF             ),
//        .s_axi_wvalid      (s_axi_wvalid     ),
//        .s_axi_lite_clk    (s_axi_lite_clk   ) 
//);

axi_ethernet_subsystem_support_resets  axi_ethernet_support_resets
(
    .mmcm_rst_out         (mmcm_rst         ),
    .pma_reset            (pma_reset        ),
    .locked               (mmcm_locked_out      ),
    .ref_clk              (ref_clk          ),
    .resetn               (resetn) 
);


// Instantiate the sharable clocking logic
axi_ethernet_subsystem_support_clocks axi_ethernet_support_clocking
(
//    .gtref_clk      (gtref_clk         ),
    .txoutclk       (txoutclk          ),
    .rxoutclk       (rxoutclk          ),
//    .gtref_clk0     (gtref_clk0        ),
    .userclk        (userclk           ),
    .userclk2       (userclk2          ),
    .rxuserclk      (rxuserclk         ),
    .rxuserclk2     (rxuserclk2        ),
    .locked         (mmcm_locked       ), 
    .reset          (mmcm_rst          )
);


axi_ethernet_gt   gt_wrapper
(
    .cplllock_out                       (cplllock_out                        ),
    .cpllrefclksel_in                   (3'b001                             ),
    .drpclk_in                          (ref_clk                            ),
    .drpaddr_in                         (10'b0                              ),
    .drpdi_in                           (16'b0                              ),
    .drpdo_out                          (                                   ),
    .drpen_in                           (1'b0                               ),
    .drprdy_out                         (                                   ),
    .drpwe_in                           (1'b0                               ),
    .eyescanreset_in                    (1'b0                               ),
    .eyescantrigger_in                  (1'b0                               ),
    .gthrxn_in                          ( sgmii_rxn ),
    .gthrxp_in                          ( sgmii_rxp ),
    .gthtxn_out                         ( sgmii_txn ),
    .gthtxp_out                         ( sgmii_txp ),
    .gtrefclk0_in                       (gtref_clk                          ),
    .gtrefclk1_in                       (1'b0                               ),
    .gtwiz_reset_all_in                 (gtwiz_reset_all_in                ),
    .gtwiz_reset_clk_freerun_in         (gtwiz_reset_clk_freerun_in        ),
    .gtwiz_reset_rx_datapath_in         (gtwiz_reset_rx_datapath_in        ),
    .gtwiz_reset_rx_done_out            (gtwiz_reset_rx_done_out             ),
    .gtwiz_reset_rx_pll_and_datapath_in (gtwiz_reset_rx_pll_and_datapath_in),
    .gtwiz_reset_tx_datapath_in         (gtwiz_reset_tx_datapath_in        ),
    .gtwiz_reset_tx_done_out            (gtwiz_reset_tx_done_out             ),
    .gtwiz_reset_tx_pll_and_datapath_in (gtwiz_reset_tx_pll_and_datapath_in),
    .gtwiz_userclk_rx_active_in         (gtwiz_userclk_rx_active_in        ),
    .gtwiz_userclk_tx_active_in         (gtwiz_userclk_tx_active_in        ),
    .gtwiz_userdata_rx_out              (gtwiz_userdata_rx_out               ),
    .gtwiz_userdata_tx_in               (gtwiz_userdata_tx_in              ),
    .txpmaresetdone_out                 (txpmaresetdone_out                  ),
    .gtwiz_buffbypass_rx_reset_in       (gtwiz_buffbypass_rx_reset_in      ),
    .gtwiz_buffbypass_rx_start_user_in  (gtwiz_buffbypass_rx_start_user_in ),
    .gtwiz_buffbypass_rx_done_out       (gtwiz_buffbypass_rx_done_out        ),
    .txbufstatus_out                    (txbufstatus_out                     ),
    .loopback_in                        (3'b000                             ),
    .pcsrsvdin_in                       (16'h0000                           ),
    .rx8b10ben_in                       (rx8b10ben_in                      ),
    .rxcdrhold_in                       (1'b0                               ),
    .rxcommadeten_in                    (rxcommadeten_in                   ),
    .rxctrl0_out                        (rxctrl0_out                         ),
    .rxctrl1_out                        (rxctrl1_out                         ),
    .rxctrl2_out                        (rxctrl2_out                         ),
    .rxctrl3_out                        (rxctrl3_out                         ),
    .rxdfelpmreset_in                   (1'b0                               ),
    .rxlpmen_in                         (1'b1                               ),
    .rxmcommaalignen_in                 (rxmcommaalignen_in                ),
    .rxoutclk_out                       (rxoutclk                           ),
    .rxpcommaalignen_in                 (rxpcommaalignen_in                ),
    .rxpcsreset_in                      (1'b0                               ),
    .rxpd_in                            (rxpd_in                           ),
    .rxpmareset_in                      (1'b0                               ),
    .rxpmaresetdone_out                 (rxpmaresetdone_out                  ),
    .rxpolarity_in                      (1'b0                               ),
    .rxprbscntreset_in                  (1'b0                               ),
    .rxprbssel_in                       (3'b000                             ),
    .rxrate_in                          (3'b000                             ),
    .rxresetdone_out                    (rxresetdone_out                     ),
    .rxusrclk2_in                       (rxusrclk2_in                      ),
    .rxusrclk_in                        (rxusrclk_in                       ),
    .txctrl0_in                         (txctrl0_in                        ),
    .txctrl1_in                         (txctrl1_in                        ),
    .txdiffctrl_in                      (5'b11000                           ),
    .txelecidle_in                      (txelecidle_in                     ),
    .txinhibit_in                       (1'b0                               ),
    .txoutclk_out                       (txoutclk                           ),
    .txpcsreset_in                      (1'b0                               ),
    .txpd_in                            (txpd_out                           ),
    .txpmareset_in                      (1'b0                               ),
    .txpolarity_in                      (1'b0                               ),
    .txpostcursor_in                    (5'b00000                           ),
    .txprbsforceerr_in                  (1'b0                               ),
    .txprbssel_in                       (3'b000                             ),
    .txprecursor_in                     (5'b00000                           ),
    .txresetdone_out                    (txresetdone_out                     ),
    .txusrclk2_in                       (txusrclk2_in                      ),
    .txusrclk_in                        (txusrclk_in                       ),
    .gtpowergood_out                    ()
);

endmodule

