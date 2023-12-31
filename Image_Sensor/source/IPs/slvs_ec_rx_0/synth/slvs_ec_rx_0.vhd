-- (c) Copyright 1995-2024 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: FRAMOS.com:user:slvs_ec_rx:1.5
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY slvs_ec_rx_0 IS
  PORT (
    data_clk_i : IN STD_LOGIC;
    rstn_i : IN STD_LOGIC;
    axi_aclk : IN STD_LOGIC;
    axi_aresetn : IN STD_LOGIC;
    axi_awaddr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    axi_awvalid : IN STD_LOGIC;
    axi_awready : OUT STD_LOGIC;
    axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    axi_wvalid : IN STD_LOGIC;
    axi_wready : OUT STD_LOGIC;
    axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    axi_bvalid : OUT STD_LOGIC;
    axi_bready : IN STD_LOGIC;
    axi_araddr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    axi_arvalid : IN STD_LOGIC;
    axi_arready : OUT STD_LOGIC;
    axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    axi_rvalid : OUT STD_LOGIC;
    axi_rready : IN STD_LOGIC;
    data_i : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    rxdatak_i : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    XCVR_status_i : IN STD_LOGIC;
    fv_o : OUT STD_LOGIC;
    lv_o : OUT STD_LOGIC;
    dv_o : OUT STD_LOGIC;
    data_o : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
    lnum_o : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
    ebdl_o : OUT STD_LOGIC;
    did_o : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    hit_o : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    hinf_o : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    status_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END slvs_ec_rx_0;

ARCHITECTURE slvs_ec_rx_0_arch OF slvs_ec_rx_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF slvs_ec_rx_0_arch: ARCHITECTURE IS "yes";
  COMPONENT slvs_ec_rx IS
    GENERIC (
      CORE_VAR : INTEGER;
      LANE_NUM : INTEGER
    );
    PORT (
      data_clk_i : IN STD_LOGIC;
      rstn_i : IN STD_LOGIC;
      axi_aclk : IN STD_LOGIC;
      axi_aresetn : IN STD_LOGIC;
      axi_awaddr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      axi_awvalid : IN STD_LOGIC;
      axi_awready : OUT STD_LOGIC;
      axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      axi_wvalid : IN STD_LOGIC;
      axi_wready : OUT STD_LOGIC;
      axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      axi_bvalid : OUT STD_LOGIC;
      axi_bready : IN STD_LOGIC;
      axi_araddr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      axi_arvalid : IN STD_LOGIC;
      axi_arready : OUT STD_LOGIC;
      axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      axi_rvalid : OUT STD_LOGIC;
      axi_rready : IN STD_LOGIC;
      data_i : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      rxdatak_i : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      XCVR_status_i : IN STD_LOGIC;
      fv_o : OUT STD_LOGIC;
      lv_o : OUT STD_LOGIC;
      dv_o : OUT STD_LOGIC;
      data_o : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
      lnum_o : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
      ebdl_o : OUT STD_LOGIC;
      did_o : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      hit_o : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      hinf_o : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      status_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  END COMPONENT slvs_ec_rx;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF slvs_ec_rx_0_arch: ARCHITECTURE IS "slvs_ec_rx,Vivado 2021.2";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF slvs_ec_rx_0_arch : ARCHITECTURE IS "slvs_ec_rx_0,slvs_ec_rx,{}";
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF slvs_ec_rx_0_arch: ARCHITECTURE IS "package_project";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF axi_arprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi ARPROT";
  ATTRIBUTE X_INTERFACE_INFO OF axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF axi_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF axi_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF axi_awprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi AWPROT";
  ATTRIBUTE X_INTERFACE_PARAMETER OF axi_awaddr: SIGNAL IS "XIL_INTERFACENAME axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 5, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS" & 
"_PER_BYTE 0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 axi AWADDR";
  ATTRIBUTE X_INTERFACE_PARAMETER OF axi_aresetn: SIGNAL IS "XIL_INTERFACENAME axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF axi_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 axi_aresetn RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF axi_aclk: SIGNAL IS "XIL_INTERFACENAME axi_aclk, ASSOCIATED_BUSIF axi, ASSOCIATED_RESET axi_aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF axi_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 axi_aclk CLK";
BEGIN
  U0 : slvs_ec_rx
    GENERIC MAP (
      CORE_VAR => 0,
      LANE_NUM => 8
    )
    PORT MAP (
      data_clk_i => data_clk_i,
      rstn_i => rstn_i,
      axi_aclk => axi_aclk,
      axi_aresetn => axi_aresetn,
      axi_awaddr => axi_awaddr,
      axi_awprot => axi_awprot,
      axi_awvalid => axi_awvalid,
      axi_awready => axi_awready,
      axi_wdata => axi_wdata,
      axi_wstrb => axi_wstrb,
      axi_wvalid => axi_wvalid,
      axi_wready => axi_wready,
      axi_bresp => axi_bresp,
      axi_bvalid => axi_bvalid,
      axi_bready => axi_bready,
      axi_araddr => axi_araddr,
      axi_arprot => axi_arprot,
      axi_arvalid => axi_arvalid,
      axi_arready => axi_arready,
      axi_rdata => axi_rdata,
      axi_rresp => axi_rresp,
      axi_rvalid => axi_rvalid,
      axi_rready => axi_rready,
      data_i => data_i,
      rxdatak_i => rxdatak_i,
      XCVR_status_i => XCVR_status_i,
      fv_o => fv_o,
      lv_o => lv_o,
      dv_o => dv_o,
      data_o => data_o,
      lnum_o => lnum_o,
      ebdl_o => ebdl_o,
      did_o => did_o,
      hit_o => hit_o,
      hinf_o => hinf_o,
      status_o => status_o
    );
END slvs_ec_rx_0_arch;
