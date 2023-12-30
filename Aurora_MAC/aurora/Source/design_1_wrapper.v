//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.2 (win64) Build 3367213 Tue Oct 19 02:48:09 MDT 2021
//Date        : Fri Mar 10 15:48:02 2023
//Host        : LM2LCND8246NDG running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (GT_SERIAL_RX_0_grx_n,
    GT_SERIAL_RX_0_grx_p,
    GT_SERIAL_TX_0_gtx_n,
    GT_SERIAL_TX_0_gtx_p,
    fan_on,
    geg_det_n,
    gt_clk_clk_n,
    gt_clk_clk_p,
    ims_pwr_oe,
    mdio_rtl_0_mdc,
    mdio_rtl_0_mdio_io,
    phy_rst_n,
    sgmii_rtl_0_rxn,
    sgmii_rtl_0_rxp,
    sgmii_rtl_0_txn,
    sgmii_rtl_0_txp,
    sys_clk_clk_n,
    sys_clk_clk_p,
    sys_rst,
//    uart_rtl_0_baudoutn,
//    uart_rtl_0_ctsn,
//    uart_rtl_0_dcdn,
//    uart_rtl_0_ddis,
//    uart_rtl_0_dsrn,
//    uart_rtl_0_dtrn,
//    uart_rtl_0_out1n,
//    uart_rtl_0_out2n,
//    uart_rtl_0_ri,
//    uart_rtl_0_rtsn,
    uart_rtl_0_rxd,
   // uart_rtl_0_rxrdyn,
    uart_rtl_0_txd,
    //uart_rtl_0_txrdyn
    );
  input GT_SERIAL_RX_0_grx_n;
  input GT_SERIAL_RX_0_grx_p;
  output GT_SERIAL_TX_0_gtx_n;
  output GT_SERIAL_TX_0_gtx_p;
  output fan_on;
  input [0:0]geg_det_n;
  input gt_clk_clk_n;
  input gt_clk_clk_p;
  output [0:0]ims_pwr_oe;
  output mdio_rtl_0_mdc;
  inout mdio_rtl_0_mdio_io;
  output [0:0]phy_rst_n;
  input sgmii_rtl_0_rxn;
  input sgmii_rtl_0_rxp;
  output sgmii_rtl_0_txn;
  output sgmii_rtl_0_txp;
  input sys_clk_clk_n;
  input sys_clk_clk_p;
  input sys_rst;
//  output uart_rtl_0_baudoutn;
//  input uart_rtl_0_ctsn;
//  input uart_rtl_0_dcdn;
//  output uart_rtl_0_ddis;
//  input uart_rtl_0_dsrn;
//  output uart_rtl_0_dtrn;
//  output uart_rtl_0_out1n;
//  output uart_rtl_0_out2n;
//  input uart_rtl_0_ri;
//  output uart_rtl_0_rtsn;
  input uart_rtl_0_rxd;
  //output uart_rtl_0_rxrdyn;
  output uart_rtl_0_txd;
  //output uart_rtl_0_txrdyn;

  wire GT_SERIAL_RX_0_grx_n;
  wire GT_SERIAL_RX_0_grx_p;
  wire GT_SERIAL_TX_0_gtx_n;
  wire GT_SERIAL_TX_0_gtx_p;
  wire fan_on;
  wire [0:0]geg_det_n;
  wire gt_clk_clk_n;
  wire gt_clk_clk_p;
  wire [0:0]ims_pwr_oe;
  wire mdio_rtl_0_mdc;
  wire mdio_rtl_0_mdio_i;
  wire mdio_rtl_0_mdio_io;
  wire mdio_rtl_0_mdio_o;
  wire mdio_rtl_0_mdio_t;
  wire [0:0]phy_rst_n;
  wire sgmii_rtl_0_rxn;
  wire sgmii_rtl_0_rxp;
  wire sgmii_rtl_0_txn;
  wire sgmii_rtl_0_txp;
  wire sys_clk_clk_n;
  wire sys_clk_clk_p;
  wire sys_rst;
  wire uart_rtl_0_baudoutn;
  wire uart_rtl_0_ctsn;
  wire uart_rtl_0_dcdn;
  wire uart_rtl_0_ddis;
  wire uart_rtl_0_dsrn;
  wire uart_rtl_0_dtrn;
  wire uart_rtl_0_out1n;
  wire uart_rtl_0_out2n;
  wire uart_rtl_0_ri;
  wire uart_rtl_0_rtsn;
  wire uart_rtl_0_rxd;
  wire uart_rtl_0_rxrdyn;
  wire uart_rtl_0_txd;
  wire uart_rtl_0_txrdyn;

  design_1 design_1_i
       (.GT_SERIAL_RX_0_grx_n(GT_SERIAL_RX_0_grx_n),
        .GT_SERIAL_RX_0_grx_p(GT_SERIAL_RX_0_grx_p),
        .GT_SERIAL_TX_0_gtx_n(GT_SERIAL_TX_0_gtx_n),
        .GT_SERIAL_TX_0_gtx_p(GT_SERIAL_TX_0_gtx_p),
        .fan_on(fan_on),
        .geg_det_n(geg_det_n),
        .gt_clk_clk_n(gt_clk_clk_n),
        .gt_clk_clk_p(gt_clk_clk_p),
        .ims_pwr_oe(ims_pwr_oe),
        .mdio_rtl_0_mdc(mdio_rtl_0_mdc),
        .mdio_rtl_0_mdio_i(mdio_rtl_0_mdio_i),
        .mdio_rtl_0_mdio_o(mdio_rtl_0_mdio_o),
        .mdio_rtl_0_mdio_t(mdio_rtl_0_mdio_t),
        .phy_rst_n(phy_rst_n),
        .sgmii_rtl_0_rxn(sgmii_rtl_0_rxn),
        .sgmii_rtl_0_rxp(sgmii_rtl_0_rxp),
        .sgmii_rtl_0_txn(sgmii_rtl_0_txn),
        .sgmii_rtl_0_txp(sgmii_rtl_0_txp),
        .sys_clk_clk_n(sys_clk_clk_n),
        .sys_clk_clk_p(sys_clk_clk_p),
        .sys_rst(sys_rst),
        .uart_rtl_0_baudoutn(uart_rtl_0_baudoutn),
        .uart_rtl_0_ctsn(uart_rtl_0_ctsn),
        .uart_rtl_0_dcdn(uart_rtl_0_dcdn),
        .uart_rtl_0_ddis(uart_rtl_0_ddis),
        .uart_rtl_0_dsrn(uart_rtl_0_dsrn),
        .uart_rtl_0_dtrn(uart_rtl_0_dtrn),
        .uart_rtl_0_out1n(uart_rtl_0_out1n),
        .uart_rtl_0_out2n(uart_rtl_0_out2n),
        .uart_rtl_0_ri(uart_rtl_0_ri),
        .uart_rtl_0_rtsn(uart_rtl_0_rtsn),
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_rxrdyn(uart_rtl_0_rxrdyn),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .uart_rtl_0_txrdyn(uart_rtl_0_txrdyn));
  IOBUF mdio_rtl_0_mdio_iobuf
       (.I(mdio_rtl_0_mdio_o),
        .IO(mdio_rtl_0_mdio_io),
        .O(mdio_rtl_0_mdio_i),
        .T(mdio_rtl_0_mdio_t));
endmodule
