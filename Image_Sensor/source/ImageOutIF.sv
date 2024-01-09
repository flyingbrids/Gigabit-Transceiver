`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2022 11:16:16 AM
// Design Name: 
// Module Name: ImageOutIF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module ImageOutIF(
    
     input logic         img_rx_clk
	,input logic         img_rx_rst_n
	,input logic         sys_clk
	,input logic         sys_rst_n
	
    ,input logic         new_frame
	,input logic         new_frame_lat
	,input logic         new_frame_rx
	,input logic         fifoVld	
    ,input logic [159:0] untapFifo_In
    ,input logic  [11:0] lineWidth
	
	,output logic [15:0] columnCnt
	,output logic [15:0] rowCnt
	,input  logic [15:0] imageRow
	,input  logic [15:0] imageCol
	,output logic [12:0] col_cnt
	,output logic [15:0] row_cnt
	
	,output logic [79:0] imageData
	,output logic        imageDataVld	
	,output logic        untapOvfl

);

logic columnCntEnd;
assign columnCntEnd = (lineWidth[3:0] == '0)?  (columnCnt[7:0] == lineWidth[11:4]-1'b1) : (columnCnt[7:0] == lineWidth[11:4]);

always @ (posedge img_rx_clk, negedge img_rx_rst_n) begin
       if (~img_rx_rst_n) begin
	      columnCnt <= '0;
		  rowCnt <= '0;
	   end else if (new_frame_rx) begin
	      columnCnt <= '0;
		  rowCnt <= '0;
	   end else if (fifoVld) begin
	      columnCnt <= columnCntEnd? '0            : columnCnt + 1'b1;
		  rowCnt    <= columnCntEnd? rowCnt + 1'b1 : rowCnt;
	   end 	  
end 

logic fifoEnable;
assign fifoEnable = ((columnCnt < imageCol[15:4]) && (rowCnt < imageRow)) ? 1'b1 : 1'b0; 

logic MasterImageVld;
logic [159:0] MasterImage;
always @ (posedge img_rx_clk) begin 
   MasterImageVld <=  fifoVld & fifoEnable;
   MasterImage    <=  untapFifo_In;   
end  

// *********************************** fifo for master image ***********************************************************
logic        Master_empty;
logic        Master_read;
logic        Master_read_d;
logic        Master_line_full_wr, Master_line_full, Master_full; 

always @ (posedge img_rx_clk, negedge img_rx_rst_n) begin
     if (~img_rx_rst_n)
        untapOvfl <= '0;
	 else if (new_frame_rx)
      	untapOvfl <= '0;
     else if (Master_full & MasterImageVld)	 
    	untapOvfl <= '1;
end		

 untap_fifo MasterImageFIFO 
 (
      .din   (MasterImage),
      .wr_en (MasterImageVld),
      .empty (Master_empty),
      .dout  (imageData),
      .rd_en (Master_read),
      .rst   (new_frame_lat),
      .prog_full_thresh (imageCol[12:4]-1),	  
      .prog_full (Master_line_full_wr),
      .full  (Master_full),	  
      .wr_clk(img_rx_clk),
      .rd_clk(sys_clk)  
);	

toggle_sync master_line_full_sys (
       .sig_in(Master_line_full_wr),                    
       .clk_b (sys_clk),      
       .rst_b (~sys_rst_n),       
       .sig_sync(Master_line_full)  
);
		
always @ (posedge sys_clk, negedge sys_rst_n) begin
     if (~sys_rst_n) begin
	    imageDataVld <= '0;
		col_cnt <= '0;
		row_cnt <= '0;
		Master_read_d <= '0;
	 end else if (new_frame) begin
		imageDataVld <= '0;
		col_cnt <= '0;
		row_cnt <= '0;
		Master_read_d <= '0;   
	 end else begin
	    Master_read_d <= Master_read;
        imageDataVld  <= Master_read_d;
	 
	    if (col_cnt == imageCol[11:3]-1'b1)
		   Master_read <= 1'b0;
		else if (Master_line_full & ~Master_empty)
		   Master_read <= 1'b1;
		
		if (Master_read) begin
		   col_cnt <= (col_cnt == imageCol[11:3]-1'b1)? '0: col_cnt + 1'b1;
		   row_cnt <= (col_cnt == imageCol[11:3]-1'b1)? row_cnt + 1'b1 : row_cnt;
	    end 
	 end
end 

endmodule
