`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2022 05:26:22 PM
// Design Name: 
// Module Name: DMAinterface
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
module DMAinterface # 
(
       parameter integer LANE = 8,
       parameter integer DWIDTH = 10,
       parameter integer ROWS = 2048, // max row
       parameter integer COLS = 2448 // max col   
)
(
       // clock and reset
       input logic sys_clk,
       input logic sys_rst,
       input logic frame_rst,
       // image input 
       input logic [DWIDTH*LANE-1:0] dataIn,
       input logic data_vld,    
       input logic [31:0] imageWidth,
       input logic [31:0] imageHeight, 
       input logic imageMode,
       input logic dmaEnable,
       // AXIS interface
       output logic [127:0] AxisData,
       output logic AxisDataVld,
       output logic [15:0] AxisDataReady,
       output logic AxisDataEnd,
       input  logic AxisDataRead,
       output logic [1:0] status,
       output logic [31:0] outDataCount 
);

// image fifo data interface
logic [63:0]  rawData_comb;
logic [127:0] rawImage;
logic [127:0] rawImage10bit;
logic [127:0] FIFO_out;
logic rawImageVld;
logic TenbitImageMode;

genvar i;
generate
  for (i=0; i<8; i= i+1) begin
      assign rawData_comb  [i*8+7  : i*8]    = dataIn[(7-i)*10+9 : (7-i)*10+2];  // change the endienss
      assign rawImage10bit [i*16+9 : i*16]   = dataIn[(7-i)*10+9 : (7-i)*10];
      assign rawImage10bit [i*16+15: i*16+10]= '0;
  end
endgenerate

logic [1:0] dmaEnable_d = 0;
logic dmaEnable_lat = 0;

always @ (posedge sys_clk) begin
     dmaEnable_d <= {dmaEnable_d[0], dmaEnable};
     rawImage <= {rawData_comb, rawImage[127:64]};
     if (dmaEnable_d == 2'b10) 
        dmaEnable_lat <= '0;
     else if (dmaEnable_d == 2'b01)
        dmaEnable_lat <= '1;
end 

logic data_cnt;
always @ (posedge sys_clk, posedge frame_rst) begin
      if (frame_rst) begin
         rawImageVld <= '0;
         data_cnt <= '0;
         TenbitImageMode <= imageMode;
      end else if (dmaEnable_lat) begin
         data_cnt <= data_vld? data_cnt + 1'b1 : data_cnt;
         rawImageVld <= data_vld? &data_cnt : '0; 
         TenbitImageMode <= TenbitImageMode;
      end else begin
         rawImageVld <= '0;
         data_cnt <= '0;      
         TenbitImageMode <= TenbitImageMode;
      end 
end 

logic [127:0] FIFO_in;
logic FIFO_wr = 1'b0;
logic [31:0] imageWidth_d;
logic [31:0] imageHeight_d;
always @ (posedge sys_clk) begin
    FIFO_in <= TenbitImageMode? rawImage10bit             :  rawImage   ;
    FIFO_wr <= TenbitImageMode? data_vld & dmaEnable_lat  :  rawImageVld;
    imageWidth_d <= imageWidth;
    imageHeight_d <= imageHeight;
end 

// fifo write control
logic FIFO_full, FIFO_empty;
logic FIFO_overflow;
logic FIFO_reset;
assign FIFO_reset = sys_rst | frame_rst;
always @ (posedge sys_clk, posedge FIFO_reset) begin
     if (FIFO_reset)
	    FIFO_overflow <= 1'b0;
	 else if (FIFO_wr & FIFO_full)
        FIFO_overflow <= 1'b1;
end		

// initiate data read
logic initRead, initRead_d, initRead_2d;
logic prog_full;
logic FIFO_rd = ~FIFO_empty & ( AxisDataRead | (initRead & (~initRead_d))  | (initRead_d & (~initRead_2d)));
always @ (posedge sys_clk, posedge FIFO_reset) begin
      if (FIFO_reset) begin
         initRead <= 1'b0;
		 initRead_d <= 1'b0;
		 initRead_2d <= 1'b0;
      end else begin
         initRead <= prog_full & (~AxisDataVld) & (~AxisDataRead);	
         initRead_d <= initRead;
         initRead_2d <= initRead_d;
	  end
end

logic FIFO_vld;
always @ (posedge sys_clk) begin
    FIFO_vld <= FIFO_rd;
end

DMAFIFO streamFIFO (
      .din  (FIFO_in),
      .wr_en(FIFO_wr),
      .dout (FIFO_out),
      .empty(FIFO_empty),
	  .full (FIFO_full),
      .rd_en(FIFO_rd),
      .clk  (sys_clk),
      .srst (FIFO_reset),
	  .prog_full (prog_full)
 );
 
logic AxisDataVld_next;
logic [127:0] AxisData_next;
logic [15:0]  AxisDataReady_next;
logic [31:0] lineCnt;
logic [31:0] colCnt;
logic columnFull;
assign columnFull = TenbitImageMode? (colCnt == imageWidth_d[31:3]) : (colCnt == imageWidth_d[31:4]);
always @ (posedge sys_clk, posedge FIFO_reset) begin
      if (FIFO_reset) begin
         AxisData_next <= 128'b0;
         AxisDataVld_next <= 1'b0;
		 AxisDataReady_next <= 16'd0;
		 lineCnt <= 1;
		 colCnt  <= 1;
      end else if (FIFO_vld) begin
         AxisData_next <= FIFO_out;
         AxisDataVld_next  <= 1'b1;		 
		 lineCnt <= columnFull ? lineCnt + 1 : lineCnt;
		 colCnt  <= columnFull ?           1 : colCnt + 1; 
		 AxisDataReady_next <= 16'hffff; // presume image column size is the multiple of 16		 
	  end else begin
         AxisDataVld_next  <= 1'b0;		  
	  end 
end

logic countfinished;
assign countfinished = columnFull & (lineCnt == imageHeight_d);
logic AxisDataEndSent;
logic AxisDataEnd_next;
always @ (posedge sys_clk, posedge FIFO_reset) begin
      if (FIFO_reset) begin
	     AxisDataEnd_next<= 1'b0;
		 AxisDataEndSent <= 1'b0;
	  end else if ((~AxisDataVld | AxisDataRead) & AxisDataEnd_next) begin
         AxisDataEnd_next <= 1'b0;	
         AxisDataEndSent <= 1'b1;		 
	  end else if (~AxisDataEndSent & countfinished & FIFO_vld )begin 	     
		 AxisDataEnd_next <= 1'b1;	
      	 AxisDataEndSent <= 1'b1;	 
	  end
end		 

`ifdef DEBUG
ilaDMA ilaDMA_i (
   .clk (sys_clk),
   .probe0 (colCnt),
   .probe1 (lineCnt),
   .probe2 (countfinished),
   .probe3 (AxisDataRead),   
   .probe4 (imageMode),
   .probe5 (TenbitImageMode),
   .probe6 (columnFull)
);  
`endif 

always @ (posedge sys_clk) begin
      if (FIFO_reset) begin
	     AxisDataVld <= 1'b0;
	     AxisData <= 128'b0;
	     AxisDataEnd <= 1'b0;
	     AxisDataReady <= 16'b0;  
	  end else if (~AxisDataVld | AxisDataRead) begin
	     AxisDataVld <= AxisDataVld_next;
	     AxisData <= AxisData_next;
	     AxisDataEnd <= AxisDataEnd_next;
	     AxisDataReady <= AxisDataReady_next;	  
	 end 
end    

// count AxisData output
always @ (posedge sys_clk, posedge FIFO_reset) begin
      if (FIFO_reset) begin
	     outDataCount <= 0;
	  end else if (AxisDataVld & AxisDataRead) begin 	     
		 outDataCount <= TenbitImageMode? outDataCount + 8 : outDataCount + 16;		 
	  end
end	
	 
assign status = {FIFO_empty,FIFO_overflow};


endmodule
