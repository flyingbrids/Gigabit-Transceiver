//----------------------------------------------------------------------------------------------------------------------
// Title      : Verilog Example Level Module
// File       : axi_ethernet_subsystem_packet_chk.v
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
// Description: This is a Streaming Packet checker module of AXI Ethernet IP Example Design.
//              It contains other resources required for an example.
//----------------------------------------------------------------------------------------------------------------------

`timescale 1ps/1ps


module axi_ethernet_subsystem_packet_chk (
    input           mtrlb_en_packet_chk        , 
    input           mtrlb_en_pkt_drop_chk      , 
    input           mtrlb_reset_error          , 
    output          mtrlb_pktchk_error         , 
    output          mtrlb_activity_flash       , 

    input   [ 1:0]  mtrlb_en_cs_offload        , 
    input   [ 4:0]  mtrlb_select_packet_type   , 
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

    input   [31:0]  s_patchk_rxin_tdata        , 
    input   [ 3:0]  s_patchk_rxin_tkeep        , 
    input           s_patchk_rxin_tvalid       , 
    input           s_patchk_rxin_tlast        , 
    output          s_patchk_rxin_tready       , 
     
    input           axis_resetn                , 
    input           axis_clk
);

localparam  ENABLE_VLAN    = 0;

localparam  PKTCHKIDLE  = 0,
            PKTCHKHDR  = 1,
            PKTCHKPAYLOAD  = 2,
            PKTCHKKT   = 3;

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

wire [15:0] pkt_size_cnt_case, pkt_size_cnt_int;
reg  [ 2:0] s_axis_cs, s_axis_ns;
reg  [47:0] dest_addr, src_addr;
reg  [31:0] ip_dest_addr, ip_src_addr;
reg  [15:0] frame_activity_count, pkt_size_cnt, tcp_dest_port, tcp_src_port, udp_dest_port, udp_src_port, min_size, max_size, rxs_cnt, rxs_cnt_int;
reg  [15:0] cur_pkt_size, cur_pkt_size_int, cur_pkt_type_int, cur_pkt_type, init_delay_cnt, exp_pkt_size;
reg         error_occured, en_packet_chk, pkt_chk_load_config;
reg         header_done, init_delay_cnt_z, en_pktdrp_chk; 
reg error_in_frame = 0, packet_dropped;
wire        packet_done, cur_pkt_last_word;
wire [1:0]  speed_sync;

assign s_patchk_rxin_tready = 1;
assign mtrlb_pktchk_error = (error_in_frame || packet_dropped) && en_packet_chk;
assign packet_done = (s_patchk_rxin_tlast && s_patchk_rxin_tvalid && s_patchk_rxin_tready ) || !en_packet_chk;
assign cur_pkt_last_word = s_patchk_rxin_tlast && s_patchk_rxin_tvalid && s_patchk_rxin_tready;

axi_ethernet_subsystem_bit_sync      speed_0   (.clk (axis_clk), .data_in  (mtrlb_line_speed[0]), .data_out  (speed_sync[0]));
axi_ethernet_subsystem_bit_sync      speed_1   (.clk (axis_clk), .data_in  (mtrlb_line_speed[1]), .data_out  (speed_sync[1]));
assign mtrlb_activity_flash = speed_sync[1] ? frame_activity_count[15] :
                              speed_sync[0] ? frame_activity_count[13] : frame_activity_count[11];

assign pkt_size_cnt_case = {2'h0, pkt_size_cnt[15:2]};
assign pkt_size_cnt_int = pkt_size_cnt + 4;

always @(posedge axis_clk) begin
    if (!axis_resetn) begin
        frame_activity_count <= 0;
        exp_pkt_size <= 100 ;
        packet_dropped <= 0;
    end else begin
        frame_activity_count <= (packet_done) ? (frame_activity_count + en_packet_chk) : frame_activity_count;
        exp_pkt_size <= (cur_pkt_last_word) ? ((exp_pkt_size > max_size) ? min_size : (cur_pkt_size + 1)) : exp_pkt_size ;
        packet_dropped <= (mtrlb_reset_error) ? 0 : ((packet_done && en_pktdrp_chk) ? (cur_pkt_size != exp_pkt_size) : packet_dropped);
    end
end

always @ * begin
    s_axis_ns = s_axis_cs; pkt_chk_load_config = 0;
    case (s_axis_cs)
        PKTCHKIDLE: begin
            if (s_patchk_rxin_tvalid && en_packet_chk ) begin
                s_axis_ns = PKTCHKHDR;
            end else begin
                s_axis_ns = PKTCHKIDLE; pkt_chk_load_config = 1;
            end
        end
        PKTCHKHDR: begin
            if ( header_done) begin
                s_axis_ns = PKTCHKPAYLOAD;
            end else if (packet_done) begin
                s_axis_ns = PKTCHKIDLE;
            end else begin
                s_axis_ns = PKTCHKHDR;
            end
        end
        PKTCHKPAYLOAD: begin
            if (packet_done) begin
                s_axis_ns = PKTCHKIDLE;
            end else begin
                s_axis_ns = PKTCHKPAYLOAD;
            end
        end
        default : s_axis_ns = PKTCHKIDLE;
    endcase
end

always @(posedge axis_clk) begin
    if (!axis_resetn) begin
        s_axis_cs <= PKTCHKIDLE;
    end else begin
        s_axis_cs <= s_axis_ns;
    end
end

always @(posedge axis_clk) begin
    if (!axis_resetn) begin
        pkt_size_cnt <= 0;
        cur_pkt_size <= 0;
    end else begin
        pkt_size_cnt <= packet_done ? 0 : ((s_patchk_rxin_tvalid & s_patchk_rxin_tready) ? pkt_size_cnt_int : pkt_size_cnt);
        cur_pkt_size <= cur_pkt_size_int;
    end
end

always @ * begin
    error_occured = 0; header_done = 0; cur_pkt_type_int = cur_pkt_type; cur_pkt_size_int = cur_pkt_size;
    if (s_patchk_rxin_tvalid && s_patchk_rxin_tready && en_packet_chk) begin
        case (pkt_size_cnt_case)
            0 : begin
                error_occured = (s_patchk_rxin_tdata != {dest_addr[23:16], dest_addr[31:24], dest_addr[39:32], dest_addr[47:40]}) ;
            end
            1 : begin
                error_occured = (s_patchk_rxin_tdata != {src_addr[39:32], src_addr[47:40], dest_addr[7:0], dest_addr[15:8]}); 
            end
            2 : begin
                error_occured = (s_patchk_rxin_tdata != {src_addr[7:0], src_addr[15:8], src_addr[23:16], src_addr[31:24]});
            end
            3 : begin
                if ( (s_patchk_rxin_tdata[15:8] == 8'h00) && (s_patchk_rxin_tdata[7:0] == 8'h81) ) begin
                    cur_pkt_type_int = ETH_TAG;
                end else begin
                    cur_pkt_type_int = ETH_LEN;
                    cur_pkt_size_int = ({s_patchk_rxin_tdata[7:0], s_patchk_rxin_tdata[15:8]} + 14); 
                    error_occured = (s_patchk_rxin_tkeep[3] && (s_patchk_rxin_tdata[31:24] != 8'hCD)) && (s_patchk_rxin_tkeep[2] && (s_patchk_rxin_tdata[23:16] != 8'hAB));
                    header_done = 1;
                end
            end
            4 : begin
                case (cur_pkt_type)
                    ETH_TAG  : begin
                        cur_pkt_size_int = ({s_patchk_rxin_tdata[7:0], s_patchk_rxin_tdata[15:8]} + 18); 
                        error_occured = (s_patchk_rxin_tkeep[3] && (s_patchk_rxin_tdata[31:24] != 8'hCD)) && (s_patchk_rxin_tkeep[2] && (s_patchk_rxin_tdata[23:16] != 8'hAB));
                        header_done = 1;
                    end
                    default : error_occured = ((s_patchk_rxin_tkeep[3] && (s_patchk_rxin_tdata[31:24] != {pkt_size_cnt_int[7:2], 2'h3})) || (s_patchk_rxin_tkeep[2] && (s_patchk_rxin_tdata[23:16] != {pkt_size_cnt_int[7:2], 2'h2})) || (s_patchk_rxin_tkeep[1] && (s_patchk_rxin_tdata[15: 8] != {pkt_size_cnt_int[7:2], 2'h1})) || (s_patchk_rxin_tkeep[0] && (s_patchk_rxin_tdata[ 7: 0] != {pkt_size_cnt_int[7:2], 2'h0}))) ;
                endcase
            end
            5 : begin
                case (cur_pkt_type)
                    default : error_occured = ((s_patchk_rxin_tkeep[3] && (s_patchk_rxin_tdata[31:24] != {pkt_size_cnt_int[7:2], 2'h3})) || (s_patchk_rxin_tkeep[2] && (s_patchk_rxin_tdata[23:16] != {pkt_size_cnt_int[7:2], 2'h2})) || (s_patchk_rxin_tkeep[1] && (s_patchk_rxin_tdata[15: 8] != {pkt_size_cnt_int[7:2], 2'h1})) || (s_patchk_rxin_tkeep[0] && (s_patchk_rxin_tdata[ 7: 0] != {pkt_size_cnt_int[7:2], 2'h0}))) ;
                endcase
            end
            6 : begin
                case (cur_pkt_type)
                    default : error_occured = ((s_patchk_rxin_tkeep[3] && (s_patchk_rxin_tdata[31:24] != {pkt_size_cnt_int[7:2], 2'h3})) || (s_patchk_rxin_tkeep[2] && (s_patchk_rxin_tdata[23:16] != {pkt_size_cnt_int[7:2], 2'h2})) || (s_patchk_rxin_tkeep[1] && (s_patchk_rxin_tdata[15: 8] != {pkt_size_cnt_int[7:2], 2'h1})) || (s_patchk_rxin_tkeep[0] && (s_patchk_rxin_tdata[ 7: 0] != {pkt_size_cnt_int[7:2], 2'h0}))) ;
                endcase
            end
            default : begin
                error_occured = ((s_patchk_rxin_tkeep[3] && (s_patchk_rxin_tdata[31:24] != {pkt_size_cnt_int[7:2], 2'h3})) || (s_patchk_rxin_tkeep[2] && (s_patchk_rxin_tdata[23:16] != {pkt_size_cnt_int[7:2], 2'h2})) || (s_patchk_rxin_tkeep[1] && (s_patchk_rxin_tdata[15: 8] != {pkt_size_cnt_int[7:2], 2'h1})) || (s_patchk_rxin_tkeep[0] && (s_patchk_rxin_tdata[ 7: 0] != {pkt_size_cnt_int[7:2], 2'h0}))) ;
            end
        endcase
    end 
end

always @ (negedge axis_clk) begin
    if (error_occured) begin
        case (pkt_size_cnt_case)
            0 : $display ("@%0dns error_occured at word %d as s_patchk_rxin_tdata != dest_addr[47:16] %h %h ", $time, pkt_size_cnt_case, s_patchk_rxin_tdata, dest_addr[47:16]);
            1 : $display ("@%0dns error_occured at word %d as s_patchk_rxin_tdata != {dest_addr[15:0], src_addr[47:32]} %h %h ", $time, pkt_size_cnt_case, s_patchk_rxin_tdata, {dest_addr[15:0], src_addr[47:32]});
            2 : $display ("@%0dns error_occured at word %d as s_patchk_rxin_tdata != src_addr[31:0] %h %h ", $time, pkt_size_cnt_case, s_patchk_rxin_tdata, src_addr[31:0]);
            3 : begin
                case (cur_pkt_type)
                    default : $display ("@%0dns error_occured at word %d as s_patchk_rxin_tdata[15:0] != 16'hABCD %h %h ", $time, pkt_size_cnt_case, s_patchk_rxin_tdata[15:0], 16'hABCD);
                endcase
            end
            4 : begin
                case (cur_pkt_type)
                    default : $display ("@%0dns error_occured at word %d as s_patchk_rxin_tdata != generated_data %h %h ", $time, pkt_size_cnt_case, s_patchk_rxin_tdata, {{pkt_size_cnt_int[7:2], 2'h3},{pkt_size_cnt_int[7:2], 2'h2},{pkt_size_cnt_int[7:2], 2'h1},{pkt_size_cnt_int[7:2], 2'h0}});
                endcase
            end
            5 : begin
                case (cur_pkt_type)
                    default : $display ("@%0dns error_occured at word %d as s_patchk_rxin_tdata != generated_data %h %h ", $time, pkt_size_cnt_case, s_patchk_rxin_tdata, {{pkt_size_cnt_int[7:2], 2'h3},{pkt_size_cnt_int[7:2], 2'h2},{pkt_size_cnt_int[7:2], 2'h1},{pkt_size_cnt_int[7:2], 2'h0}});
                endcase
            end
            default : $display ("@%0dns error_occured at word %d as s_patchk_rxin_tdata != generated_data %h %h ", $time, pkt_size_cnt_case, s_patchk_rxin_tdata, {{pkt_size_cnt_int[7:2], 2'h3},{pkt_size_cnt_int[7:2], 2'h2},{pkt_size_cnt_int[7:2], 2'h1},{pkt_size_cnt_int[7:2], 2'h0}});
        endcase

    end
end

always @ (posedge axis_clk) begin
    if (!axis_resetn) begin
        error_in_frame <= 0;
    end else begin
        if (error_occured) begin
            error_in_frame <= 1;
        end else if (mtrlb_reset_error) begin
            error_in_frame <= 0;
        end else begin
            error_in_frame <= error_in_frame;
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
        en_pktdrp_chk <= 0;
        en_packet_chk <= 0;
        cur_pkt_type  <= ETH_LEN;
    end else begin
        dest_addr     <= pkt_chk_load_config ? mtrlb_config_dest_addr     : dest_addr     ;
        src_addr      <= pkt_chk_load_config ? mtrlb_config_src_addr      : src_addr      ;
        ip_dest_addr  <= pkt_chk_load_config ? mtrlb_config_ip_dest_addr  : ip_dest_addr  ;
        ip_src_addr   <= pkt_chk_load_config ? mtrlb_config_ip_src_addr   : ip_src_addr   ;
        tcp_dest_port <= pkt_chk_load_config ? mtrlb_config_tcp_dest_port : tcp_dest_port ;
        tcp_src_port  <= pkt_chk_load_config ? mtrlb_config_tcp_src_port  : tcp_src_port  ;
        udp_dest_port <= pkt_chk_load_config ? mtrlb_config_udp_dest_port : udp_dest_port ;
        udp_src_port  <= pkt_chk_load_config ? mtrlb_config_udp_src_port  : udp_src_port  ;
        max_size      <= pkt_chk_load_config ? mtrlb_config_max_size      : max_size      ;
        min_size      <= pkt_chk_load_config ? mtrlb_config_min_size      : min_size      ;
        en_pktdrp_chk <= (mtrlb_reset_error) ? 0 : ((en_packet_chk && packet_done) ? mtrlb_en_pkt_drop_chk : en_pktdrp_chk);
        en_packet_chk <= mtrlb_en_packet_chk ? 1 : 0 ;
        cur_pkt_type  <= cur_pkt_type_int ;
    end
end

endmodule 

