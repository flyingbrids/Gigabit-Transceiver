`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2024 10:04:31 PM
// Design Name: 
// Module Name: TopLevel
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
module TopLevel(
     input  logic C0_SYS_CLK_0_clk_n,
     input  logic C0_SYS_CLK_0_clk_p, 
     // image sensor 
     input logic img_clk_p,
     input logic img_clk_n,
     input logic D0_p,
     input logic D0_n,
     input logic D1_p,
     input logic D1_n,
     input logic D2_p,
     input logic D2_n,
     input logic D3_p,
     input logic D3_n,
     input logic D4_p,
     input logic D4_n,
     input logic D5_p,
     input logic D5_n,
     input logic D6_p,
     input logic D6_n,
     input logic D7_p,
     input logic D7_n,
     output logic omode,
     output logic MCLK,
     output logic XCE,
     output logic XCLR,
     output logic SCLK,
     output logic X_MOSI,
     input  logic X_MISO,
     output logic [1:0] slavemode,
     output logic Xtrigger1,
     output logic Xtrigger2,
     output logic Xmaster,  
     output logic XHS,
     output logic XVS,
     output logic LEDEn,
	 output logic MLLEn,
	 output logic SLLEn	 
    );

logic sys_clk,main_pll_lock, sys_rst_n, sys_rst;
clk_wiz_0 clk_gen
(
  .clk_in1_n (C0_SYS_CLK_0_clk_n),
  .clk_in1_p (C0_SYS_CLK_0_clk_p),
  .clk_out1  (sys_clk),
  .locked    (main_pll_lock)
);

reset_sync rst_gen         
(   
    .pll_clk               ( sys_clk           )  
  , .pll_lock              ( main_pll_lock     )  
  , .external_rst          ( '0                )  
  , .sync_rst_out          ( sys_rst           )  
  , .sync_rst_out_n        ( sys_rst_n         )
) ;  

logic [7:0] delayCnt;
logic imager_rst;
always @ (posedge sys_clk, posedge sys_rst) begin
       if (sys_rst) begin
          delayCnt <= '0;
          imager_rst <= '0;
       end else if (main_pll_lock) begin
          delayCnt <= &delayCnt? '1: delayCnt + 1'b1;
          imager_rst <= (delayCnt == 8'd255 -1'b1)? 1'b1 : 1'b0;
       end   
end 

ImagerSubSystem ImagerSubSystem_i
(     // slvs_ec interface
       .ref_clk_p (img_clk_p)
      ,.ref_clk_n (img_clk_n)
      ,.D0_p      (D0_p)
      ,.D0_n      (D0_n)
      ,.D1_p      (D1_p)
      ,.D1_n      (D1_n)
      ,.D2_p      (D2_p)
      ,.D2_n      (D2_n)
      ,.D3_p      (D3_p)
      ,.D3_n      (D3_n)
      ,.D4_p      (D4_p)
      ,.D4_n      (D4_n)
      ,.D5_p      (D5_p)
      ,.D5_n      (D5_n)
      ,.D6_p      (D6_p)
      ,.D6_n      (D6_n)
      ,.D7_p      (D7_p)
      ,.D7_n      (D7_n)  
      //,.xcvr_status_o (image_xcvr_status)
	  // clock and reset
	  ,.sys_clk          (sys_clk)
	  ,.sys_rst_n        (sys_rst_n)
	  ,.sys_rst          (sys_rst)
	  ,.imager_rst       (imager_rst)
	  ,.main_pll_lock    (main_pll_lock)
	  // The rest are connected to the application layer
      // image control line  
//      ,.cs_n             (image_cs_n)
//      ,.XCE              (XCE)
//      ,.XCLR             (XCLR)
//      ,.MCLK             (MCLK)
//      ,.OMODE            (omode)
//      ,.XVS              (XVS)
//      ,.XHS       		 (XHS)
//      ,.XMASTER          (Xmaster)
//	  ,.slavemode 		 (slavemode)
//	  ,.Xtrigger1        (Xtrigger1)
//	  ,.Xtrigger2 	     (Xtrigger2)
//	  ,.FPGASlaveMode    (~FPGA_master)
//	  ,.exposureTime     ('hff)
//	  ,.dmaImageMode     ('0)
//      // flow control
//      ,.new_frame        (frame_rst)
//      ,.imageCol     	 (imageWidth)
//      ,.imageRow         (imageHeight)
//	  // image data out
//	  ,.imageDataSync    (imageDataSync)
//      ,.imageDataSyncVld (imageDataVld)   
//      // DMA interface 
//      ,.DMAEnable            (dmaEnable)       
//      ,.S_AXIS_S2MM_0_tdata  (S_AXIS_S2MM_0_tdata)
//      ,.S_AXIS_S2MM_0_tvalid (S_AXIS_S2MM_0_tvalid)
//      ,.S_AXIS_S2MM_0_tkeep  (S_AXIS_S2MM_0_tkeep)
//      ,.S_AXIS_S2MM_0_tlast  (S_AXIS_S2MM_0_tlast)
//      ,.S_AXIS_S2MM_0_tready (S_AXIS_S2MM_0_tready)
//      ,.masterDMA_status     (masterDMA_status)
//      ,.outDataCount         (top_reg_fbck[11])         
//      // Axis bus
//      ,.s00_axi_aclk   ( sys_clk       )
//      ,.s00_axi_aresetn( sys_rst_n     )
//	  ,.AWVALID_IMAGER ( AWVALID_IMAGER) 
//	  ,.ARVALID_IMAGER ( ARVALID_IMAGER) 	  
//      ,.AWADDR         ( AWADDR       )
//	  ,.AWREADY_IMAGER ( AWREADY_IMAGER)
//      ,.WDATA          ( WDATA        )
//      ,.WSTRB          ( WSTRB        )
//      ,.WVALID         ( WVALID       )    
//	  ,.WREADY_IMAGER  ( WREADY_IMAGER) 
//	  ,.RESP_IMAGER    ( RESP_IMAGER  ) 
//      ,.BVALID_IMAGER  ( BVALID_IMAGER) 	  
//      ,.BREADY         ( BREADY       )
//      ,.ARADDR         ( ARADDR       )
//      ,.ARREADY_IMAGER ( ARREADY_IMAGER) 
//      ,.RDATA_IMAGER   ( RDATA_IMAGER )	  
//      ,.RRESP_IMAGER   ( RRESP_IMAGER )	 
//      ,.RVALID_IMAGER  ( RVALID_IMAGER) 	  
//      ,.RREADY         ( RREADY       ) 
);


    
endmodule
