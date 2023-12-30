///////////////////////////////////////////////////////////////////////////////
// (c) Copyright 1995-2014 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
///////////////////////////////////////////////////////////////////////////////

 `timescale 1 ns / 10 ps

(* core_generation_info = "aurora_8b10b_interfpga,aurora_8b10b_v11_1_13,{user_interface=AXI_4_Streaming,backchannel_mode=Sidebands,c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTHQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=31250,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=156250,c_simplex=false,c_simplex_mode=TX,c_stream=true,c_ufc=false,flow_mode=None,interface_mode=Streaming,dataflow_config=Duplex}" *)
module aurora_8b10b_interfpga_support
 (
 
input   [0:31]     s_axi_tx_tdata,
 
input              s_axi_tx_tvalid,
output             s_axi_tx_tready,

 
output  [0:31]     m_axi_rx_tdata,
 
output             m_axi_rx_tvalid,



    // GT Serial I/O
input              rxp,
input              rxn,

output             txp,
output             txn,

    // GT Reference Clock Interface
 
//input              gt_refclk0_p,
//input              gt_refclk0_n,
input              gt_refclk0,

    // Error Detection Interface
output             hard_err,
output             soft_err,
    // Status
output             lane_up,
output             channel_up,




    // System Interface
output              user_clk_out,
input               gt_reset,
input               reset,

input              power_down,
input   [2:0]      loopback,
output             tx_lock,

input              init_clk_in,
output             tx_resetdone_out,
output             rx_resetdone_out,
output             link_reset_out,
output             sys_reset_out,

    //DRP Ports
    input   [9:0]     gt0_drpaddr,
    input   [15:0]     gt0_drpdi,
    output  [15:0]     gt0_drpdo,
    input              gt0_drpen,
    output             gt0_drprdy,
    input              gt0_drpwe,


output             pll_not_locked_out

//GT Reference Clock for Ethernet Subsystem
//output              gt_refclk0_o
 );

 `define DLY #1

 //*********************************Main Body of Code**********************************

//----------  Wire declarations
//------------------{
//------------------}

wire               gt_refclk0;
//wire               gt_refclk0_o;
wire               tx_out_clk_i;
wire               user_clk_i;
wire               sync_clk_i;
wire               pll_not_locked_i;
wire               tx_lock_i;

wire               init_clk_i;
wire               tx_resetdone_i;
wire               rx_resetdone_i;
wire               link_reset_i;
wire               system_reset_i;
wire               gt_reset_i;
wire               drpclk_i;
wire               reset_sync_user_clk;
wire               gt_reset_sync_init_clk;

       // From GT 
wire  [0 : 0]          gt_txpmaresetdone_i;
wire  [0 : 0]          gt_rxpmaresetdone_i;
wire    [3:0]      rx_not_in_table_i;
wire    [3:0]      rx_disp_err_i;
wire    [3:0]      rx_char_is_comma_i;
wire    [3:0]      rx_char_is_k_i;
wire               rx_realign_i;
wire               rx_buf_err_i;
wire               tx_buf_err_i;
wire               ch_bond_done_i;
wire               raw_tx_out_clk_i;
wire               gttx_lock_i;


       // To GT
      wire    rxfsm_datavalid_i;
      wire    gtwiz_userclk_tx_reset_i;
      wire               rx_polarity_i;
      wire               rx_reset_i;
wire    [3:0]      tx_char_is_k_i;
wire    [31:0]     tx_data_i;
      wire               tx_reset_i;
wire    [31:0]     rx_data_i;
      wire    gtrxreset_i;
wire               ena_comma_align_i;
wire               en_chan_sync_i;

wire               tied_to_ground_i;
wire    [47:0]     tied_to_ground_vec_i;
wire               tied_to_vcc_i;






wire               bufg_gt_clr_int;
wire bufg_gt_clr_out;
assign bufg_gt_clr_int = bufg_gt_clr_out;

 
//  IBUFDS_GTE4 IBUFDS_GTE4_refclk0 
//  (
//    .I     (gt_refclk0_p),
//    .IB    (gt_refclk0_n),
//    .CEB   (1'b0),
//    .O     (gt_refclk0),
//    .ODIV2 (gt_refclk0_o)
//  );



    // Instantiate a clock module for clock division.
    aurora_8b10b_interfpga_CLOCK_MODULE clock_module_i
    (
        .GT_CLK(tx_out_clk_i),
        .GT_CLK_LOCKED(tx_lock_i),
	.BUFG_GT_CLR_IN(bufg_gt_clr_int),
        .USER_CLK(user_clk_i),
        .SYNC_CLK(sync_clk_i),
        .PLL_NOT_LOCKED(pll_not_locked_i)
    );
   assign init_clk_i = init_clk_in;

  //  outputs
 
  assign user_clk_out          =  user_clk_i;
  assign pll_not_locked_out    =  pll_not_locked_i;
  assign tx_lock               =  tx_lock_i;
  assign tx_resetdone_out      =  tx_resetdone_i;
  assign rx_resetdone_out      =  rx_resetdone_i;
  assign link_reset_out        =  link_reset_i;


    assign reset_sync_user_clk = reset;
    assign gt_reset_sync_init_clk = gt_reset;

    aurora_8b10b_interfpga_SUPPORT_RESET_LOGIC support_reset_logic_i
    (
        .RESET(reset_sync_user_clk),
        .USER_CLK(user_clk_i),
        .INIT_CLK_IN(init_clk_i),
        .GT_RESET_IN(gt_reset_sync_init_clk),
        .SYSTEM_RESET(system_reset_i),
        .GT_RESET_OUT(gt_reset_i)
    );


//----- Instance of _xci -----[
aurora_8b10b_interfpga aurora_8b10b_interfpga_i
     (
        // AXI TX Interface
       .s_axi_tx_tdata               (s_axi_tx_tdata),
       .s_axi_tx_tvalid              (s_axi_tx_tvalid),
       .s_axi_tx_tready              (s_axi_tx_tready),

        // AXI RX Interface
       .m_axi_rx_tdata               (m_axi_rx_tdata),
       .m_axi_rx_tvalid              (m_axi_rx_tvalid),


        // GT Serial I/O
        // Error Detection Interface

        // Error Detection Interface
       .hard_err                     (hard_err),
       .soft_err                     (soft_err),

        // Status
       .channel_up                   (channel_up),
       .lane_up                      (lane_up),




        // System Interface
       .user_clk                     (user_clk_i),
       .sync_clk                     (sync_clk_i),
       .reset                        (system_reset_i),
       .power_down                   (power_down),
       .gt_reset                     (gt_reset_i),
       .tx_lock                      (tx_lock_i),
       .init_clk_in                  (init_clk_i),
       .link_reset_out               (link_reset_i),


       // From GT in
      .gttxresetdone_in(tx_resetdone_i),
      .gtrxresetdone_in(rx_resetdone_i),
      .rxdata_in(rx_data_i),
      .rxnotintable_in(rx_not_in_table_i),
      .rxdisperr_in(rx_disp_err_i),
      .rxcharisk_in(rx_char_is_k_i),
      .rxchariscomma_in(rx_char_is_comma_i),
      .rxrealign_in(rx_realign_i),
      .rxbuferr_in(rx_buf_err_i),
      .txbuferr_in(tx_buf_err_i),
      .chbonddone_in(ch_bond_done_i),
      .txoutclk_in(raw_tx_out_clk_i),
      .txlock_in(gttx_lock_i),


       // To GT out
      .rxfsm_datavalid_out(rxfsm_datavalid_i),
      .rxpolarity_out(rx_polarity_i),
      .rxreset_out(rx_reset_i),
      .txcharisk_out(tx_char_is_k_i),
      .txdata_out(tx_data_i),
      .txreset_out(tx_reset_i),
      .gtrxreset_out(gtrxreset_i),
      .enacommaalign_out(ena_comma_align_i),
      .enchansync_out(en_chan_sync_i),



       .sys_reset_out                (sys_reset_out),
       .tx_out_clk                   (tx_out_clk_i)

     );
//----- Instance of _xci -----]

    //_________________________Instantiate GT Wrapper ______________________________
    aurora_8b10b_interfpga_GT_WRAPPER  gt_wrapper_i
    (
        .RXFSM_DATA_VALID            (rxfsm_datavalid_i),

     .gtwiz_userclk_tx_reset_in      (gtwiz_userclk_tx_reset_i),
     .gt_txpmaresetdone      (gt_txpmaresetdone_i),
     .gt_rxpmaresetdone      (gt_rxpmaresetdone_i),


        // DRP I/F
.DRPADDR_IN                     (gt0_drpaddr),
.DRPCLK_IN                      (init_clk_i),
.DRPDI_IN                       (gt0_drpdi),
.DRPDO_OUT                      (gt0_drpdo),
.DRPEN_IN                       (gt0_drpen),
.DRPRDY_OUT                     (gt0_drprdy),
.DRPWE_IN                       (gt0_drpwe),

        .INIT_CLK_IN                    (init_clk_i),   
	.PLL_NOT_LOCKED                 (pll_not_locked_i),
	.TX_RESETDONE_OUT               (tx_resetdone_i),
	.RX_RESETDONE_OUT               (rx_resetdone_i),
        // Aurora Lane Interface
.RXPOLARITY_IN(rx_polarity_i),
.RXRESET_IN(rx_reset_i),
.TXCHARISK_IN(tx_char_is_k_i[3:0]),
.TXDATA_IN(tx_data_i[31:0]),
.TXRESET_IN(tx_reset_i),
.RXDATA_OUT(rx_data_i[31:0]),
.RXNOTINTABLE_OUT(rx_not_in_table_i[3:0]),
.RXDISPERR_OUT(rx_disp_err_i[3:0]),
.RXCHARISK_OUT(rx_char_is_k_i[3:0]),

.RXCHARISCOMMA_OUT(rx_char_is_comma_i[3:0]),
.RXREALIGN_OUT(rx_realign_i),
.RXBUFERR_OUT(rx_buf_err_i),
.TXBUFERR_OUT(tx_buf_err_i),

        // Reset due to channel initialization watchdog timer expiry  
        .GTRXRESET_IN(gtrxreset_i),


        // reset for hot plug
        .LINK_RESET_IN(link_reset_i),


        // Phase Align Interface
.ENMCOMMAALIGN_IN(ena_comma_align_i),
.ENPCOMMAALIGN_IN(ena_comma_align_i),

        // Global Logic Interface
.ENCHANSYNC_IN(en_chan_sync_i),
.CHBONDDONE_OUT(ch_bond_done_i),

        // Serial IO
.RX1N_IN(rxn),
.RX1P_IN(rxp),
.TX1N_OUT(txn),
.TX1P_OUT(txp),

        // Clocks and Clock Status
        .RXUSRCLK_IN(sync_clk_i),
        .RXUSRCLK2_IN(user_clk_i),
        .TXUSRCLK_IN(sync_clk_i),
        .TXUSRCLK2_IN(user_clk_i),
        .REFCLK(gt_refclk0),

.TXOUTCLK1_OUT(raw_tx_out_clk_i),

.PLLLKDET_OUT(gttx_lock_i),
        // System Interface
        .GTRESET_IN(gt_reset_sync_init_clk),
        .LOOPBACK_IN(loopback),
        .gt_powergood          (),
//------------------{
//------------------}

        .POWERDOWN_IN(power_down)
 );


  assign gtwiz_userclk_tx_reset_i  =  !(&gt_txpmaresetdone_i);
  assign bufg_gt_clr_out           =  gtwiz_userclk_tx_reset_i;

    // Tie off top level constants
    assign          tied_to_gnd_vec_i       = 16'd0;
    assign          tied_to_ground_vec_i    = 64'd0;
    assign          tied_to_ground_i        = 1'b0;
    assign          tied_to_vcc_i           = 1'b1;



 endmodule 
