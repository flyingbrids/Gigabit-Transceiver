//----------------------------------------------------------------------------------------------------------------------
// Title      : Verilog Example Level Module
// File       : axi_ethernet_subsystem_packet_gen.v
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
// Description: This is a Streaming Packet generator of AXI Ethernet IP Example Design.
//              It contains other resources required for an example.
//----------------------------------------------------------------------------------------------------------------------

`timescale 1ps/1ps

module axi_ethernet_subsystem_packet_gen (
    input               mtrlb_en_packet_gen        , 
    input       [ 1:0]  mtrlb_en_cs_offload        , 
    input               mtrlb_da_sa_swap_en        , 
    input       [ 4:0]  mtrlb_select_packet_type   , 
    input       [ 1:0]  mtrlb_line_speed           , 
    input       [47:0]  mtrlb_config_dest_addr     , 
    input       [47:0]  mtrlb_config_src_addr      , 
    input       [11:0]  mtrlb_config_vlan_id       , 
    input       [ 2:0]  mtrlb_config_vlan_priority , 
    input       [31:0]  mtrlb_config_ip_dest_addr  , 
    input       [31:0]  mtrlb_config_ip_src_addr   , 
    input       [15:0]  mtrlb_config_tcp_dest_port , 
    input       [15:0]  mtrlb_config_tcp_src_port  , 
    input       [15:0]  mtrlb_config_udp_dest_port , 
    input       [15:0]  mtrlb_config_udp_src_port  , 
    input       [15:0]  mtrlb_config_min_size      , 
    input       [15:0]  mtrlb_config_max_size      , 
    output              mtrlb_activity_flash       , 

    output reg  [31:0]  m_axis_txc_tdata           , 
    output reg  [ 3:0]  m_axis_txc_tkeep           , 
    output              m_axis_txc_tvalid          , 
    output              m_axis_txc_tlast           , 
    input               m_axis_txc_tready          , 

    output reg  [31:0]  m_axis_txd_tdata           , 
    output reg  [ 3:0]  m_axis_txd_tkeep           , 
    output              m_axis_txd_tvalid          , 
    output              m_axis_txd_tlast           , 
    input               m_axis_txd_tready          , 

    input               axis_resetn                , 
    input               axis_clk
);

// Packet Types
localparam  ETH_LEN                =   1, 
            ETH_TAG                =   2, 
            ETH_TAGINTAG           =   3, 
            ETH_IPV4               =   4, 
            ETH_IPV4_TCP           =   5, 
            ETH_IPV4_UDP           =   6, 
            ETH_TAG_IPV4           =   7, 
            ETH_TAG_IPV4_TCP       =   8, 
            ETH_TAG_IPV4_UDP       =   9, 
            ETH_SNAP               =  10, 
            ETH_TAG_SNAP           =  11, 
            ETH_SNAP_TAGINTAG      =  12, 
            ETH_SNAP_IPV4          =  13, 
            ETH_SNAP_IPV4_TCP      =  14, 
            ETH_SNAP_IPV4_UDP      =  15, 
            ETH_TAG_SNAP_IPV4      =  16, 
            ETH_TAG_SNAP_IPV4_TCP  =  17, 
            ETH_TAG_SNAP_IPV4_UDP  =  18, 
            PAUSE                  =  19, 
            CONTROL                =  20, 
            JUMBO                  =  21, 
            PTP_INLN_CMD           =  22,
            PTP_OUTBND_CMD         =  23,
            PTP_TXC_CMD            =  24,
            SMALL                  =  29; 

reg [47:0] dest_addr, src_addr;
reg [31:0] ip_dest_addr, ip_src_addr;
reg [15:0] pkt_size_cnt, pkt_size_cnt_int, tcp_dest_port, tcp_src_port, udp_dest_port, udp_src_port, min_size, max_size, txc_cnt, txc_cnt_int;
reg [15:0] next_pkt_size, next_pkt_type, cur_pkt_size, cur_pkt_type, init_delay_cnt ;
reg        en_packet_gen, pkt_gen_ready_2_start, m_axis_txd_tvalid_int, m_axis_txd_tlast_int, m_axis_txc_tvalid_int, m_axis_txc_tlast_int, init_delay_cnt_z;
reg [63:0] ptp_cmd = 64'hFDEC_DBCA_7564_0001;
reg        en_in_band_ptp_cmd = 0;
reg [15:0] wait_cnt, wait_cnt_int;
reg        wait_cnt_16r;

wire [31:0] eth_pkt_hdr_vlan;
wire [15:0] cur_pkt_header_size, cur_pkt_payload_size, pkt_size_cnt_int_case;
wire        pkt_gen_load_config, cur_pkt_last_word;
reg         pkt_gen_load_config_reg, cur_pkt_last_word_reg;
reg  [15:0] frame_activity_count;

assign mtrlb_activity_flash = frame_activity_count[13];

always @(posedge axis_clk) begin
    if (!axis_resetn) begin
        frame_activity_count <= 0;
    end else begin
        frame_activity_count <= (cur_pkt_last_word_reg) ? (frame_activity_count + 1) : frame_activity_count;
    end
end

always @ * begin
    next_pkt_size = cur_pkt_size ;
    if (cur_pkt_last_word_reg) begin
        next_pkt_size = (cur_pkt_size > max_size) ? min_size : (cur_pkt_size + 1) ;
    end
end

always @ * begin
    next_pkt_type = cur_pkt_type;
    if (cur_pkt_last_word_reg) begin
        if (en_in_band_ptp_cmd) begin
            next_pkt_type = PTP_INLN_CMD;
        end else begin
            case (cur_pkt_type)
                ETH_LEN : next_pkt_type = ETH_TAG;
                ETH_TAG : next_pkt_type = ETH_LEN;
                default : next_pkt_type = ETH_LEN;
            endcase
        end
    end
end

assign cur_pkt_last_word = m_axis_txd_tready && m_axis_txd_tlast_int;
assign cur_pkt_header_size = (cur_pkt_type == ETH_LEN) ? 14 : ((cur_pkt_type == ETH_TAG) ? 18 : ((cur_pkt_type == PTP_INLN_CMD) ? 18 : 14));
assign cur_pkt_payload_size = cur_pkt_size - cur_pkt_header_size;
assign pkt_gen_load_config = cur_pkt_last_word_reg || (!en_packet_gen && mtrlb_en_packet_gen);
assign pkt_last_word = (pkt_size_cnt_int >= cur_pkt_size);
assign txc_last_word = (txc_cnt_int >= 6);
assign pkt_size_cnt_int_case = {2'h0, pkt_size_cnt_int[15:2]} ;
assign m_axis_txd_tlast = m_axis_txd_tlast_int;
assign m_axis_txd_tvalid = m_axis_txd_tvalid_int;
assign m_axis_txc_tlast = m_axis_txc_tlast_int;
assign m_axis_txc_tvalid = m_axis_txc_tvalid_int;
assign eth_pkt_hdr_vlan = {16'h8100, mtrlb_config_vlan_priority, 1'h0, mtrlb_config_vlan_id};

always @ (*) begin
    txc_cnt_int = txc_cnt;
    if (pkt_gen_ready_2_start) begin
        txc_cnt_int = 1;
    end else if (m_axis_txc_tvalid_int && m_axis_txc_tready && m_axis_txc_tlast_int) begin
        txc_cnt_int = 0;
    end else if (m_axis_txc_tvalid_int && m_axis_txc_tready) begin
        txc_cnt_int = txc_cnt + 1;
    end
end

always @ (*) begin
    wait_cnt_int = wait_cnt;
    if (pkt_gen_load_config_reg) begin
        wait_cnt_int = 16'h450;
    end else if (wait_cnt[15]) begin
        wait_cnt_int = wait_cnt_int;
    end else begin
        wait_cnt_int = wait_cnt_int - 1;
    end
end

always @ (*) begin
    pkt_size_cnt_int = pkt_size_cnt;
    if (pkt_gen_ready_2_start) begin
        pkt_size_cnt_int = 4;
    end else if (m_axis_txd_tvalid_int && m_axis_txd_tready) begin
        if (m_axis_txd_tlast_int) begin
            pkt_size_cnt_int = 0;
        end else begin
            pkt_size_cnt_int = pkt_size_cnt + 4;
        end
    end
end

always @ (posedge axis_clk) begin
    if (!axis_resetn) begin
        m_axis_txc_tdata <= 32'h05487B9A;
        m_axis_txc_tvalid_int    <= 0;
        m_axis_txc_tlast_int     <= 0;
        m_axis_txc_tkeep     <= 0;
    end else begin
        m_axis_txc_tvalid_int    <= (|txc_cnt_int);
        m_axis_txc_tlast_int     <= txc_last_word;
        m_axis_txc_tkeep     <= 4'hF;
        case (txc_cnt_int) 
            1: begin
                m_axis_txc_tdata <= 32'h1a5aa5a5;
            end
            2: begin
                m_axis_txc_tdata <= 32'h25a55a5a;
            end
            3: begin
                m_axis_txc_tdata <= 32'h3a5aa5a5;
            end
            4: begin
                m_axis_txc_tdata <= 32'h45a55a5a;
            end
            5: begin
                m_axis_txc_tdata <= 32'h5a5aa5a5;
            end
            6: begin
                m_axis_txc_tdata <= 32'h65a55a5a;
            end
            default m_axis_txc_tdata <= m_axis_txc_tdata;
        endcase
    end
end

always @ (posedge axis_clk) begin
    if (!axis_resetn) begin
        m_axis_txd_tdata <= 0; 
    end else begin
        // Assuming cur_pkt_type = ETH_LEN as default
        // $display ("Current Packet Type is %d and Packet Size count is %d %d", cur_pkt_type, pkt_size_cnt_int, pkt_size_cnt_int[15:2] );
        case (pkt_size_cnt_int_case)
            1 : begin
                case (cur_pkt_type)
                    PTP_INLN_CMD : m_axis_txd_tdata <= {ptp_cmd[39:32], ptp_cmd[47:40], ptp_cmd[55:48], ptp_cmd[63:56]};
                    default      : m_axis_txd_tdata <= {dest_addr[23:16], dest_addr[31:24], dest_addr[39:32], dest_addr[47:40]};
                endcase
            end 
            2 : begin
                case (cur_pkt_type)
                    PTP_INLN_CMD : m_axis_txd_tdata <= {ptp_cmd[7:0], ptp_cmd[15:8], ptp_cmd[23:16], ptp_cmd[31:24]};
                    default      : m_axis_txd_tdata <= {src_addr[39:32], src_addr[47:40], dest_addr[7:0], dest_addr[15:8]};
                endcase
            end 
            3 : begin
                case (cur_pkt_type)
                    PTP_INLN_CMD : m_axis_txd_tdata <= {dest_addr[23:16], dest_addr[31:24], dest_addr[39:32], dest_addr[47:40]};
                    default      : m_axis_txd_tdata <=  {src_addr[7:0], src_addr[15:8], src_addr[23:16], src_addr[31:24]};
                endcase
            end 
            4 : begin
                case (cur_pkt_type)
                    PTP_INLN_CMD : m_axis_txd_tdata <= {src_addr[39:32], src_addr[47:40], dest_addr[7:0], dest_addr[15:8]};
                    ETH_TAG:  m_axis_txd_tdata <= {eth_pkt_hdr_vlan[7:0], eth_pkt_hdr_vlan[15:8], eth_pkt_hdr_vlan[23:16], eth_pkt_hdr_vlan[31:24]};
                    default : m_axis_txd_tdata <= {8'hCD, 8'hAB, cur_pkt_payload_size[7:0] ,  cur_pkt_payload_size[15:8]}; 
                endcase
            end
            5 : begin
                case (cur_pkt_type)
                    PTP_INLN_CMD : m_axis_txd_tdata <=  {src_addr[7:0], src_addr[15:8], src_addr[23:16], src_addr[31:24]};
                    ETH_TAG : m_axis_txd_tdata <= {8'hCD, 8'hAB, cur_pkt_payload_size[7:0], cur_pkt_payload_size[15:8]}; 
                    default : m_axis_txd_tdata <=  {{pkt_size_cnt_int[7:2], 2'h3},{pkt_size_cnt_int[7:2], 2'h2},{pkt_size_cnt_int[7:2], 2'h1},{pkt_size_cnt_int[7:2], 2'h0}}; 
                endcase
            end
            6 : begin
                case (cur_pkt_type)
                    PTP_INLN_CMD : m_axis_txd_tdata <= {8'hCD, 8'hAB, cur_pkt_payload_size[7:0] ,  cur_pkt_payload_size[15:8]}; 
                    default : m_axis_txd_tdata <= {{pkt_size_cnt_int[7:2], 2'h3},{pkt_size_cnt_int[7:2], 2'h2},{pkt_size_cnt_int[7:2], 2'h1},{pkt_size_cnt_int[7:2], 2'h0}}; 
                endcase
            end
            default : begin
                m_axis_txd_tdata <= {{pkt_size_cnt_int[7:2], 2'h3},{pkt_size_cnt_int[7:2], 2'h2},{pkt_size_cnt_int[7:2], 2'h1},{pkt_size_cnt_int[7:2], 2'h0}}; 
            end
        endcase
    end
end

always @ (posedge axis_clk) begin
    if (!axis_resetn) begin
        m_axis_txd_tkeep <= 0; 
        m_axis_txd_tvalid_int    <= 0;
        m_axis_txd_tlast_int     <= 0;
    end else begin
        m_axis_txd_tvalid_int    <= (|pkt_size_cnt_int);
        m_axis_txd_tlast_int     <= pkt_last_word;
        if (pkt_last_word) begin
            case (cur_pkt_size[1:0])
                1: m_axis_txd_tkeep <= 4'h1;
                2: m_axis_txd_tkeep <= 4'h3;
                3: m_axis_txd_tkeep <= 4'h7;
                default: m_axis_txd_tkeep <= 4'hF;
            endcase
        end else begin
            m_axis_txd_tkeep <= 4'hF;
        end
    end
end


always @ (posedge axis_clk) begin
    if (axis_resetn == 0) begin
        dest_addr     <= 0;
        src_addr      <= 0;
        ip_dest_addr  <= 0;
        ip_src_addr   <= 0;
        tcp_dest_port <= 0;
        tcp_src_port  <= 0;
        udp_dest_port <= 0;
        udp_src_port  <= 0;
        max_size      <= 0;
        min_size      <= 100;
        cur_pkt_size  <= min_size;
        cur_pkt_type  <= ETH_LEN;
        pkt_gen_load_config_reg <= 0;
        pkt_gen_ready_2_start <= 0;
    end else begin
        if ( mtrlb_da_sa_swap_en ) begin
            src_addr   <= pkt_gen_load_config ? mtrlb_config_dest_addr     : dest_addr     ;
            dest_addr  <= pkt_gen_load_config ? mtrlb_config_src_addr      : src_addr      ;
        end else begin
            dest_addr  <= pkt_gen_load_config ? mtrlb_config_dest_addr     : dest_addr     ;
            src_addr   <= pkt_gen_load_config ? mtrlb_config_src_addr      : src_addr      ;
        end
        ip_dest_addr  <= pkt_gen_load_config ? mtrlb_config_ip_dest_addr  : ip_dest_addr  ;
        ip_src_addr   <= pkt_gen_load_config ? mtrlb_config_ip_src_addr   : ip_src_addr   ;
        tcp_dest_port <= pkt_gen_load_config ? mtrlb_config_tcp_dest_port : tcp_dest_port ;
        tcp_src_port  <= pkt_gen_load_config ? mtrlb_config_tcp_src_port  : tcp_src_port  ;
        udp_dest_port <= pkt_gen_load_config ? mtrlb_config_udp_dest_port : udp_dest_port ;
        udp_src_port  <= pkt_gen_load_config ? mtrlb_config_udp_src_port  : udp_src_port  ;
        max_size      <= pkt_gen_load_config ? mtrlb_config_max_size      : max_size      ;
        min_size      <= pkt_gen_load_config ? mtrlb_config_min_size      : min_size      ;
        cur_pkt_size  <= pkt_gen_load_config ? next_pkt_size              : cur_pkt_size  ;
        cur_pkt_type  <= pkt_gen_load_config ? next_pkt_type              : cur_pkt_type  ;
        pkt_gen_load_config_reg <= pkt_gen_load_config;
        pkt_gen_ready_2_start <= !wait_cnt_16r && wait_cnt[15];
    end
end

always @ (posedge axis_clk) begin
    if ( !axis_resetn ) begin
        pkt_size_cnt <= 0;
        txc_cnt <= 0;
        en_packet_gen <= 0;
        cur_pkt_last_word_reg <= 0;
        wait_cnt <= 16'hFFFF;
        wait_cnt_16r <= 1'b1;
    end else begin
        en_packet_gen <= mtrlb_en_packet_gen;
        pkt_size_cnt <= pkt_size_cnt_int ;
        wait_cnt <= wait_cnt_int;
        wait_cnt_16r <= wait_cnt[15] ;
        txc_cnt <= txc_cnt_int;
        cur_pkt_last_word_reg <= cur_pkt_last_word;
    end
end

endmodule 
