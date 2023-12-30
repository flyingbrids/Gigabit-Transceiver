//----------------------------------------------------------------------------------------------------------------------
// Title      : Verilog Example Level Module
// File       : axi_ethernet_subsystem_slave_loopback.v
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
// Description: This module loops back the data in DEMO mode of AXI Ethernet IP Example Design.
//              It contains other resources required for an example.
//----------------------------------------------------------------------------------------------------------------------

`timescale 1ps/1ps


module axi_ethernet_subsystem_slave_loopback (
    input             axis_clk             , 
    input             axis_resetn          , 

    input             slvlb_en_l2_addr_swap, 
    output            mtrlb_activity_flash , 

    input      [31:0] s_axis_slvlb_d_tdata , 
    input      [ 3:0] s_axis_slvlb_d_tkeep , 
    input             s_axis_slvlb_d_tvalid, 
    input             s_axis_slvlb_d_tlast , 
    output reg        s_axis_slvlb_d_tready, 

    output reg [31:0] m_axis_slvlb_d_tdata , 
    output reg [ 3:0] m_axis_slvlb_d_tkeep , 
    output reg        m_axis_slvlb_d_tvalid, 
    output reg        m_axis_slvlb_d_tlast , 
    input             m_axis_slvlb_d_tready
);

wire [36:0] fdi, fdo;
wire wre, rde, fifof, fifoe;

reg  [7:0] rx_srcbyte1, rx_srcbyte2, rx_srcbyte3, rx_srcbyte4,   rx_srcbyte5,   rx_srcbyte6;  
reg  [7:0] rx_dstbyte1, rx_dstbyte2, rx_dstbyte3, rx_dstbyte4,   rx_dstbyte5,   rx_dstbyte6;  
reg  [5:0] rx_cnt, axis_rx_cs, tx_cnt, axis_tx_cs;
reg        en_rx_on_saxis = 1, en_tx_on_maxis = 0;
reg        rde_q, wre_q;
reg  [15:0] frame_activity_count;
reg [63:0] ptp_cmd = 64'hFDEC_DBCA_7564_0001;

assign wre = s_axis_slvlb_d_tvalid && s_axis_slvlb_d_tready;
assign rde = m_axis_slvlb_d_tvalid && m_axis_slvlb_d_tready;
assign fdi = {s_axis_slvlb_d_tlast,s_axis_slvlb_d_tdata,s_axis_slvlb_d_tkeep};
assign mtrlb_activity_flash = frame_activity_count[13];

always @(posedge axis_clk) begin
    if (!axis_resetn) begin
        frame_activity_count <= 0;
    end else begin
        frame_activity_count <= (s_axis_slvlb_d_tlast) ? (frame_activity_count + 1) : frame_activity_count;
    end
end

always @(posedge axis_clk) begin
    if (axis_resetn == 0) begin
        en_tx_on_maxis <= 0;
        en_rx_on_saxis <= 1;
        rde_q <= 0; wre_q <= 0;
    end else begin
        rde_q <= rde; wre_q <= wre;
        en_tx_on_maxis <= ((rx_cnt == 2) && wre_q) ? 1 : (((tx_cnt == 1) && rde_q) ? 0 : en_tx_on_maxis);
        en_rx_on_saxis <= ((tx_cnt == 0 && !en_tx_on_maxis) ? 1 : ((rx_cnt == 0) ? 0 : en_rx_on_saxis));
    end
end

always @ (*) begin
    s_axis_slvlb_d_tready = !fifof && en_rx_on_saxis;
    m_axis_slvlb_d_tkeep  = fdo[3:0];
    m_axis_slvlb_d_tlast  = fdo[36];
    case (tx_cnt)
        0       : m_axis_slvlb_d_tvalid = en_tx_on_maxis;
        default : m_axis_slvlb_d_tvalid = !fifoe || fdo[36];
    endcase
    case (tx_cnt)
        0 : begin
            m_axis_slvlb_d_tdata[ 7: 0] = (slvlb_en_l2_addr_swap) ? rx_srcbyte1 : fdo[11: 4];
            m_axis_slvlb_d_tdata[15: 8] = (slvlb_en_l2_addr_swap) ? rx_srcbyte2 : fdo[19:12];
            m_axis_slvlb_d_tdata[23:16] = (slvlb_en_l2_addr_swap) ? rx_srcbyte3 : fdo[27:20];
            m_axis_slvlb_d_tdata[31:24] = (slvlb_en_l2_addr_swap) ? rx_srcbyte4 : fdo[35:28];
        end
        1 : begin
            m_axis_slvlb_d_tdata[ 7: 0] = (slvlb_en_l2_addr_swap) ? rx_srcbyte5 : fdo[11: 4];
            m_axis_slvlb_d_tdata[15: 8] = (slvlb_en_l2_addr_swap) ? rx_srcbyte6 : fdo[19:12];
            m_axis_slvlb_d_tdata[23:16] = (slvlb_en_l2_addr_swap) ? rx_dstbyte1 : fdo[27:20];
            m_axis_slvlb_d_tdata[31:24] = (slvlb_en_l2_addr_swap) ? rx_dstbyte2 : fdo[35:28];
        end
        2 : begin
            m_axis_slvlb_d_tdata[ 7: 0] = (slvlb_en_l2_addr_swap) ? rx_dstbyte3 : fdo[11: 4];
            m_axis_slvlb_d_tdata[15: 8] = (slvlb_en_l2_addr_swap) ? rx_dstbyte4 : fdo[19:12];
            m_axis_slvlb_d_tdata[23:16] = (slvlb_en_l2_addr_swap) ? rx_dstbyte5 : fdo[27:20];
            m_axis_slvlb_d_tdata[31:24] = (slvlb_en_l2_addr_swap) ? rx_dstbyte6 : fdo[35:28];
        end
        3: begin
            m_axis_slvlb_d_tdata = fdo[35:4];
        end
        4: begin
            m_axis_slvlb_d_tdata = fdo[35:4];
        end
        default : begin
            m_axis_slvlb_d_tdata = fdo[35:4];
        end
    endcase
end

always @(posedge axis_clk) begin
    if (axis_resetn == 0) begin
        rx_cnt <= 0;
        tx_cnt <= 0;
        rx_srcbyte6 <= 0; rx_srcbyte5 <= 0; rx_srcbyte4 <= 0; rx_srcbyte3 <= 0; rx_srcbyte2 <= 0; rx_srcbyte1 <= 0;
        rx_dstbyte6 <= 0; rx_dstbyte5 <= 0; rx_dstbyte4 <= 0; rx_dstbyte3 <= 0; rx_dstbyte2 <= 0; rx_dstbyte1 <= 0;
    end else begin
        rx_cnt <= (wre) ? (s_axis_slvlb_d_tlast ? 0 : ((rx_cnt > 2) ? 3 : (rx_cnt + 1))) : rx_cnt;
        tx_cnt <= (rde) ? (m_axis_slvlb_d_tlast ? 0 : ((tx_cnt > 2) ? 3 : (tx_cnt + 1))) : tx_cnt;
        rx_dstbyte1 <= ((rx_cnt == 0) && wre) ? s_axis_slvlb_d_tdata[ 7: 0] : rx_dstbyte1;
        rx_dstbyte2 <= ((rx_cnt == 0) && wre) ? s_axis_slvlb_d_tdata[15: 8] : rx_dstbyte2;
        rx_dstbyte3 <= ((rx_cnt == 0) && wre) ? s_axis_slvlb_d_tdata[23:16] : rx_dstbyte3;
        rx_dstbyte4 <= ((rx_cnt == 0) && wre) ? s_axis_slvlb_d_tdata[31:24] : rx_dstbyte4;
        rx_dstbyte5 <= ((rx_cnt == 1) && wre) ? s_axis_slvlb_d_tdata[ 7: 0] : rx_dstbyte5;
        rx_dstbyte6 <= ((rx_cnt == 1) && wre) ? s_axis_slvlb_d_tdata[15: 8] : rx_dstbyte6;
        rx_srcbyte1 <= ((rx_cnt == 1) && wre) ? s_axis_slvlb_d_tdata[23:16] : rx_srcbyte1;
        rx_srcbyte2 <= ((rx_cnt == 1) && wre) ? s_axis_slvlb_d_tdata[31:24] : rx_srcbyte2;
        rx_srcbyte3 <= ((rx_cnt == 2) && wre) ? s_axis_slvlb_d_tdata[ 7: 0] : rx_srcbyte3;
        rx_srcbyte4 <= ((rx_cnt == 2) && wre) ? s_axis_slvlb_d_tdata[15: 8] : rx_srcbyte4;
        rx_srcbyte5 <= ((rx_cnt == 2) && wre) ? s_axis_slvlb_d_tdata[23:16] : rx_srcbyte5;
        rx_srcbyte6 <= ((rx_cnt == 2) && wre) ? s_axis_slvlb_d_tdata[31:24] : rx_srcbyte6;
    end
end

axi_ethernet_subsystem_slave_loopback_fifo #(.DATA(37), .ADDR(6)) U0_fifo 
(
    .clk   (axis_clk  ),
    .rstn  (axis_resetn),
    .wre   (wre       ),
    .rde   (rde       ),
    .d_in  (fdi       ),
    .full  (fifof     ),
    .empty (fifoe     ),
    .d_out (fdo       ) 
);

endmodule 

module axi_ethernet_subsystem_slave_loopback_fifo #(
    parameter DATA = 32,
    parameter ADDR = 8)
(
    input    clk    , rstn  , 
    input    wre    , rde   , 
    input    [DATA-1:0] d_in , 
    output   reg  full,
    output   reg  empty,
    output   [DATA-1:0] d_out
);
    
reg [DATA-1:0] mem [0:(2**ADDR)-1];
reg [ADDR-1:0] rd_ptr, wr_ptr;
wire [ADDR-1:0] rd_ptr_p1, wr_ptr_p1, wr_ptr_p2;

assign d_out = mem[rd_ptr];
assign rd_ptr_p1 = (rd_ptr + 1);
assign wr_ptr_p1 = (wr_ptr + 1);
assign wr_ptr_p2 = (wr_ptr + 2);

integer i;
initial begin
    for( i = 0; i < 2**ADDR; i = i + 1 ) begin
        mem[i] <= 0;
    end
end

always @ (negedge clk) begin
    if (wre && (wr_ptr_p1 == rd_ptr))   $display ("@%0dns Caution: In eth_eg_des_e005_slave_loopback_fifo FIFO overflow occured  ", $time);
    if (rde && (rd_ptr == wr_ptr))      $display ("@%0dns Caution: In eth_eg_des_e005_slave_loopback_fifo FIFO underflow occured ", $time);
end

always @ (posedge clk) begin
    if (rstn == 0) begin
        rd_ptr <= 0;
        wr_ptr <= 0;
        full   <= 0;
        empty  <= 1;
    end else begin
        rd_ptr <= (rde) ? rd_ptr_p1 : rd_ptr;
        wr_ptr <= (wre) ? wr_ptr_p1 : wr_ptr;
        full   <= (wr_ptr_p1 == rd_ptr) || (wr_ptr_p2 == rd_ptr);
        empty  <= (rd_ptr == wr_ptr) || (rd_ptr_p1 == wr_ptr);
    end
end

always @(posedge clk) begin
    if (wre) begin
        mem[wr_ptr] <= d_in;
    end
end

endmodule
