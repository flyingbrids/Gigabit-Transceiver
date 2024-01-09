// (c) Copyright 1995-2024 Xilinx, Inc. All rights reserved.
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
// DO NOT MODIFY THIS FILE.


// IP VLNV: FRAMOS.com:user:imx_pwr_on_seq_gen:1.0
// IP Revision: 1

(* X_CORE_INFO = "imx_pwr_on_seq_gen,Vivado 2021.2" *)
(* CHECK_LICENSE_TYPE = "imx_pwr_on_seq_gen_1,imx_pwr_on_seq_gen,{}" *)
(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module imx_pwr_on_seq_gen_1 (
  clock,
  reset_n,
  XCE_in,
  XVS_in,
  XHS_in,
  INCK_in,
  XCE_out,
  XVS_out,
  XHS_out,
  XMASTER_out,
  XCLR_out,
  OMODE_out,
  INCK_out
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clock, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *)
input wire clock;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_n RST" *)
input wire reset_n;
input wire XCE_in;
input wire XVS_in;
input wire XHS_in;
input wire INCK_in;
output wire XCE_out;
output wire XVS_out;
output wire XHS_out;
output wire XMASTER_out;
output wire XCLR_out;
output wire OMODE_out;
output wire INCK_out;

  imx_pwr_on_seq_gen #(
    .pDEVICE_FAMILY("kintexuplus")
  ) inst (
    .clock(clock),
    .reset_n(reset_n),
    .XCE_in(XCE_in),
    .XVS_in(XVS_in),
    .XHS_in(XHS_in),
    .INCK_in(INCK_in),
    .XCE_out(XCE_out),
    .XVS_out(XVS_out),
    .XHS_out(XHS_out),
    .XMASTER_out(XMASTER_out),
    .XCLR_out(XCLR_out),
    .OMODE_out(OMODE_out),
    .INCK_out(INCK_out)
  );
endmodule
