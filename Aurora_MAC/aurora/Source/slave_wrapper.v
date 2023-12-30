//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.2 (win64) Build 3367213 Tue Oct 19 02:48:09 MDT 2021
//Date        : Fri Mar 10 17:39:05 2023
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
    sys_clk_clk_n,
    sys_clk_clk_p,
    sys_rst);
  input GT_SERIAL_RX_0_grx_n;
  input GT_SERIAL_RX_0_grx_p;
  output GT_SERIAL_TX_0_gtx_n;
  output GT_SERIAL_TX_0_gtx_p;
  output fan_on;
  input [0:0]geg_det_n;
  input [0:0]gt_clk_clk_n;
  input [0:0]gt_clk_clk_p;
  output [0:0]ims_pwr_oe;
  input sys_clk_clk_n;
  input sys_clk_clk_p;
  input [0:0]sys_rst;

  wire GT_SERIAL_RX_0_grx_n;
  wire GT_SERIAL_RX_0_grx_p;
  wire GT_SERIAL_TX_0_gtx_n;
  wire GT_SERIAL_TX_0_gtx_p;
  wire fan_on;
  wire [0:0]geg_det_n;
  wire [0:0]gt_clk_clk_n;
  wire [0:0]gt_clk_clk_p;
  wire [0:0]ims_pwr_oe;
  wire sys_clk_clk_n;
  wire sys_clk_clk_p;
  wire [0:0]sys_rst;

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
        .sys_clk_clk_n(sys_clk_clk_n),
        .sys_clk_clk_p(sys_clk_clk_p),
        .sys_rst(sys_rst));
endmodule
