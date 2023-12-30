//----------------------------------------------------------------------------------------------------------------------
// Title      : Verilog Example Level Module
// File       : axi_ethernet_subsystem_streaming_generator.v
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
// Description: This is a warpper for the Streaming data generator and checker connected to AXI Ethernet IP Example Design.
//              It contains other resources required for an example.
//----------------------------------------------------------------------------------------------------------------------

`timescale 1ps/1ps

module axi_ethernet_subsystem_streaming_generator (
     input           loopback_master_slaven ,
     input           slvlb_en_l2_addr_swap  ,
     input           mtrlb_en_packet_gen    ,
    input           ex_des_blink_on_tx         ,
    input   [ 1:0]  mtrlb_en_cs_offload        ,
    input   [ 4:0]  mtrlb_select_packet_type   ,
    input           mtrlb_da_sa_swap_en        , 
    input   [ 1:0]  mtrlb_line_speed           ,
    input   [47:0]  mtrlb_config_dest_addr     ,
    input   [47:0]  mtrlb_config_src_addr      ,
    input   [11:0]  mtrlb_config_vlan_id       ,
    input   [ 2:0]  mtrlb_config_vlan_priority ,
    input   [31:0]  mtrlb_config_ip_dest_addr  ,
    input   [31:0]  mtrlb_config_ip_src_addr   ,
    input   [15:0]  mtrlb_config_tcp_dest_port ,
    input   [15:0]  mtrlb_config_tcp_src_port  ,
    input   [15:0]  mtrlb_config_udp_dest_port ,
    input   [15:0]  mtrlb_config_udp_src_port  ,
    input   [15:0]  mtrlb_config_min_size      ,
    input   [15:0]  mtrlb_config_max_size      ,
     input           mtrlb_en_packet_chk   ,
     input           mtrlb_reset_error     ,
     input           mtrlb_en_pkt_drop_chk ,
     output          mtrlb_pktchk_error        ,
     output          mtrlb_activity_flash      ,

    input           axi_txc_arstn              ,
    output  [31:0]  m_axis_str_gen_c_tdata     ,
    output  [3:0]   m_axis_str_gen_c_tkeep     ,
    output          m_axis_str_gen_c_tlast     ,
    input           m_axis_str_gen_c_tready    ,
    output          m_axis_str_gen_c_tvalid    ,

    input           axi_txd_arstn              ,
     output  [31:0]  m_axis_str_gen_d_tdata          ,
     output  [3:0]   m_axis_str_gen_d_tkeep          ,
     output          m_axis_str_gen_d_tlast          ,
     input           m_axis_str_gen_d_tready         ,
     output          m_axis_str_gen_d_tvalid         ,

    input           axi_rxd_arstn                    ,
     input   [31:0]  s_axis_str_gen_d_tdata          ,
     input   [3:0]   s_axis_str_gen_d_tkeep          ,
     input           s_axis_str_gen_d_tlast          ,
     output          s_axis_str_gen_d_tready         ,
     input           s_axis_str_gen_d_tvalid         ,

    input           axi_rxs_arstn                    ,
    input   [31:0]  s_axis_str_gen_s_tdata           ,
    input   [3:0]   s_axis_str_gen_s_tkeep           ,
    input           s_axis_str_gen_s_tlast           ,
    output          s_axis_str_gen_s_tready          ,
    input           s_axis_str_gen_s_tvalid          ,

    input           axis_clk
);


wire [31:0] slv_lb_inst_out_tdata;
wire [3:0] slv_lb_inst_out_tkeep;
wire axis_resetn, slv_lb_inst_out_tvalid, slv_lb_inst_out_tlast;

wire [31:0] m_pkt_gen_d_tdata;
wire [3:0] m_pkt_gen_d_tkeep;
wire mtrlb_activity_flash_g, mtrlb_activity_flash_c, mtrlb_activity_flash_lb ;
wire m_pkt_gen_d_tvalid, m_pkt_gen_d_tlast; 
wire [31:0] m_pkt_gen_c_tdata;
wire [3:0] m_pkt_gen_c_tkeep;
wire m_pkt_gen_c_tvalid, m_pkt_gen_c_tlast;

wire  s_patchk_rxin_d_tready , s_slvlb_d_tready;
wire loopback_master_slaven_sync, slvlb_en_l2_addr_swap_sync, mtrlb_en_packet_gen_sync, mtrlb_en_packet_chk_sync, mtrlb_reset_error_sync, mtrlb_en_pkt_drop_chk_sync, mtrlb_da_sa_swap_en_sync  ;

axi_ethernet_subsystem_bit_sync    loopback_master_slaven_sync_inst    (.clk(axis_clk), .data_in(loopback_master_slaven  ), .data_out(loopback_master_slaven_sync));
axi_ethernet_subsystem_bit_sync    slvlb_en_l2_addr_swap_sync_inst     (.clk(axis_clk), .data_in(slvlb_en_l2_addr_swap   ), .data_out(slvlb_en_l2_addr_swap_sync ));
axi_ethernet_subsystem_bit_sync    mtrlb_en_packet_gen_sync_inst       (.clk(axis_clk), .data_in(mtrlb_en_packet_gen     ), .data_out(mtrlb_en_packet_gen_sync   ));
axi_ethernet_subsystem_bit_sync    mtrlb_en_packet_chk_sync_inst       (.clk(axis_clk), .data_in(mtrlb_en_packet_chk     ), .data_out(mtrlb_en_packet_chk_sync   ));
axi_ethernet_subsystem_bit_sync    mtrlb_reset_error_sync_inst         (.clk(axis_clk), .data_in(mtrlb_reset_error       ), .data_out(mtrlb_reset_error_sync     ));
axi_ethernet_subsystem_bit_sync    mtrlb_en_pkt_drop_chk_sync_inst     (.clk(axis_clk), .data_in(mtrlb_en_pkt_drop_chk   ), .data_out(mtrlb_en_pkt_drop_chk_sync ));
axi_ethernet_subsystem_bit_sync    mtrlb_da_sa_swap_en_sync_inst       (.clk(axis_clk), .data_in(mtrlb_da_sa_swap_en     ), .data_out(mtrlb_da_sa_swap_en_sync   ));

assign axis_resetn = axi_txc_arstn & axi_txd_arstn & axi_rxd_arstn & axi_rxs_arstn;
assign mtrlb_activity_flash = loopback_master_slaven ? (ex_des_blink_on_tx ? mtrlb_activity_flash_g : mtrlb_activity_flash_c) : mtrlb_activity_flash_lb ;

assign m_axis_str_gen_d_tdata   = loopback_master_slaven_sync ? m_pkt_gen_d_tdata  : slv_lb_inst_out_tdata;
assign m_axis_str_gen_d_tkeep   = loopback_master_slaven_sync ? m_pkt_gen_d_tkeep  : slv_lb_inst_out_tkeep;
assign m_axis_str_gen_d_tvalid  = loopback_master_slaven_sync ? m_pkt_gen_d_tvalid : slv_lb_inst_out_tvalid;
assign m_axis_str_gen_d_tlast   = loopback_master_slaven_sync ? m_pkt_gen_d_tlast  : slv_lb_inst_out_tlast;

assign m_axis_str_gen_c_tdata   = loopback_master_slaven_sync ? m_pkt_gen_c_tdata   : s_axis_str_gen_s_tdata;
assign m_axis_str_gen_c_tkeep   = loopback_master_slaven_sync ? m_pkt_gen_c_tkeep   : s_axis_str_gen_s_tkeep;
assign m_axis_str_gen_c_tvalid  = loopback_master_slaven_sync ? m_pkt_gen_c_tvalid  : s_axis_str_gen_s_tvalid;
assign m_axis_str_gen_c_tlast   = loopback_master_slaven_sync ? m_pkt_gen_c_tlast   : s_axis_str_gen_s_tlast;

assign s_axis_str_gen_d_tready  = loopback_master_slaven_sync ? s_patchk_rxin_d_tready : s_slvlb_d_tready;
assign s_axis_str_gen_s_tready  = loopback_master_slaven_sync ? 1 : m_axis_str_gen_c_tready;

axi_ethernet_subsystem_slave_loopback slv_lb_inst
(
    .slvlb_en_l2_addr_swap   (slvlb_en_l2_addr_swap_sync ),
    .mtrlb_activity_flash    (mtrlb_activity_flash_lb    ),
    .s_axis_slvlb_d_tdata    (s_axis_str_gen_d_tdata     ),
    .s_axis_slvlb_d_tkeep    (s_axis_str_gen_d_tkeep     ),
    .s_axis_slvlb_d_tvalid   (s_axis_str_gen_d_tvalid    ),
    .s_axis_slvlb_d_tlast    (s_axis_str_gen_d_tlast     ),
    .s_axis_slvlb_d_tready   (s_slvlb_d_tready),

    .m_axis_slvlb_d_tdata    (slv_lb_inst_out_tdata     ),
    .m_axis_slvlb_d_tkeep    (slv_lb_inst_out_tkeep     ),
    .m_axis_slvlb_d_tvalid   (slv_lb_inst_out_tvalid    ),
    .m_axis_slvlb_d_tlast    (slv_lb_inst_out_tlast     ),
    .m_axis_slvlb_d_tready   (m_axis_str_gen_d_tready   ),

    .axis_resetn             (axis_resetn               ),
    .axis_clk                (axis_clk                  )
);


axi_ethernet_subsystem_packet_gen  packet_gen_inst
(
    .mtrlb_en_packet_gen        (mtrlb_en_packet_gen_sync   ),
    .mtrlb_en_cs_offload        (mtrlb_en_cs_offload        ),
    .mtrlb_da_sa_swap_en        (mtrlb_da_sa_swap_en_sync   ), 
    .mtrlb_select_packet_type   (mtrlb_select_packet_type   ),
    .mtrlb_line_speed           (mtrlb_line_speed           ),
    .mtrlb_config_dest_addr     (mtrlb_config_dest_addr     ),
    .mtrlb_config_src_addr      (mtrlb_config_src_addr      ),
    .mtrlb_config_vlan_id       (mtrlb_config_vlan_id       ),
    .mtrlb_config_vlan_priority (mtrlb_config_vlan_priority ),
    .mtrlb_config_ip_dest_addr  (mtrlb_config_ip_dest_addr  ),
    .mtrlb_config_ip_src_addr   (mtrlb_config_ip_src_addr   ),
    .mtrlb_config_tcp_dest_port (mtrlb_config_tcp_dest_port ),
    .mtrlb_config_tcp_src_port  (mtrlb_config_tcp_src_port  ),
    .mtrlb_config_udp_dest_port (mtrlb_config_udp_dest_port ),
    .mtrlb_config_udp_src_port  (mtrlb_config_udp_src_port  ),
    .mtrlb_config_min_size      (mtrlb_config_min_size      ),
    .mtrlb_config_max_size      (mtrlb_config_max_size      ),
    .mtrlb_activity_flash  (mtrlb_activity_flash_g    ),

    .m_axis_txc_tdata      (m_pkt_gen_c_tdata    )  ,
    .m_axis_txc_tkeep      (m_pkt_gen_c_tkeep    )  ,
    .m_axis_txc_tvalid     (m_pkt_gen_c_tvalid   )  ,
    .m_axis_txc_tlast      (m_pkt_gen_c_tlast    )  ,
    .m_axis_txc_tready     (m_axis_str_gen_c_tready)  ,

    .m_axis_txd_tdata      (m_pkt_gen_d_tdata    )  ,
    .m_axis_txd_tkeep      (m_pkt_gen_d_tkeep    )  ,
    .m_axis_txd_tvalid     (m_pkt_gen_d_tvalid   )  ,
    .m_axis_txd_tlast      (m_pkt_gen_d_tlast    )  ,
    .m_axis_txd_tready     (m_axis_str_gen_d_tready)  ,

    .axis_resetn   (axis_resetn )              ,
    .axis_clk      (axis_clk    )

);

axi_ethernet_subsystem_packet_chk  packet_chk_inst
(
    .mtrlb_en_packet_chk   (mtrlb_en_packet_chk_sync  ),
    .mtrlb_reset_error     (mtrlb_reset_error_sync    ),
    .mtrlb_en_pkt_drop_chk (mtrlb_en_pkt_drop_chk_sync),
    .mtrlb_pktchk_error    (mtrlb_pktchk_error        ),
    .mtrlb_activity_flash  (mtrlb_activity_flash_c    ),

    .mtrlb_en_cs_offload        (mtrlb_en_cs_offload        ),
    .mtrlb_select_packet_type   (mtrlb_select_packet_type   ),
    .mtrlb_line_speed           (mtrlb_line_speed           ),
    .mtrlb_config_dest_addr     (mtrlb_config_dest_addr     ),
    .mtrlb_config_src_addr      (mtrlb_config_src_addr      ),
    .mtrlb_config_vlan_id       (mtrlb_config_vlan_id       ),
    .mtrlb_config_vlan_priority (mtrlb_config_vlan_priority ),
    .mtrlb_config_ip_dest_addr  (mtrlb_config_ip_dest_addr  ),
    .mtrlb_config_ip_src_addr   (mtrlb_config_ip_src_addr   ),
    .mtrlb_config_tcp_dest_port (mtrlb_config_tcp_dest_port ),
    .mtrlb_config_tcp_src_port  (mtrlb_config_tcp_src_port  ),
    .mtrlb_config_udp_dest_port (mtrlb_config_udp_dest_port ),
    .mtrlb_config_udp_src_port  (mtrlb_config_udp_src_port  ),
    .mtrlb_config_min_size      (mtrlb_config_min_size      ),
    .mtrlb_config_max_size      (mtrlb_config_max_size      ),

    .s_patchk_rxin_tdata  (s_axis_str_gen_d_tdata    ),
    .s_patchk_rxin_tkeep  (s_axis_str_gen_d_tkeep    ),
    .s_patchk_rxin_tvalid (s_axis_str_gen_d_tvalid   ),
    .s_patchk_rxin_tlast  (s_axis_str_gen_d_tlast    ),
    .s_patchk_rxin_tready (s_patchk_rxin_d_tready   ),
    .axis_resetn          (axis_resetn ),
    .axis_clk             (axis_clk    )
);
endmodule
