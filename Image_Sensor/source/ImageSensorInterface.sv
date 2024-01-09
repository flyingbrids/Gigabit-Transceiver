`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2022 12:02:34 PM
// Design Name: 
// Module Name: ImagerSubSystem
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
module ImagerSubSystem(
      // SLVS_EC interface
       input logic ref_clk_p
      ,input logic ref_clk_n
      ,input logic D0_p
      ,input logic D0_n
      ,input logic D1_p
      ,input logic D1_n
      ,input logic D2_p
      ,input logic D2_n
      ,input logic D3_p
      ,input logic D3_n
      ,input logic D4_p
      ,input logic D4_n
      ,input logic D5_p
      ,input logic D5_n
      ,input logic D6_p
      ,input logic D6_n
      ,input logic D7_p
      ,input logic D7_n  
      ,output logic xcvr_status_o
      // clock and reset
      ,input logic sys_clk
      ,input logic sys_rst_n 
      ,input logic sys_rst
      ,input logic main_pll_lock
      ,input logic imager_rst
      ,output logic mgt_clk
      ,output logic freerun_clk
      // imager control line
      ,input logic  cs_n	 
      ,output logic XCE
      ,output logic XCLR
      ,output logic MCLK
      ,output logic OMODE
	  ,output logic XHS
	  ,output logic XVS
	  ,output logic XMASTER
	  ,output logic [1:0]slavemode
      ,output logic Xtrigger1
      ,output logic Xtrigger2 
      // light control 
      ,output logic LEDEn
	  ,output logic MLLEn
	  ,output logic SLLEn
	  // image control
	  ,input  logic         dmaImageMode
	  ,input  logic         FPGASlaveMode
	  ,input  logic         new_frame
	  ,input  logic [15:0]  exposureTime
	  ,input  logic [15:0]  imageRow
	  ,input  logic [15:0]  imageCol
	  // image output interface to image processing IP
	  ,output logic [79:0]  imageDataSync
      ,output logic         imageDataSyncVld
      // image output interface to DMA IP for raw image capture 
      ,input  logic         DMAEnable
      ,output logic [2:0]   masterDMA_status 
      ,output logic [31:0]  outDataCount
      ,output logic [127:0] S_AXIS_S2MM_0_tdata
      ,output logic         S_AXIS_S2MM_0_tvalid
      ,output logic [15:0]  S_AXIS_S2MM_0_tkeep
      ,output logic         S_AXIS_S2MM_0_tlast
      ,input  logic         S_AXIS_S2MM_0_tready
      // AXI Interface
      ,input  logic s00_axi_aclk
	  ,input  logic s00_axi_aresetn
	  ,input  logic AWVALID_IMAGER  
	  ,input  logic ARVALID_IMAGER
	  ,input  logic AWVALID_FRAMOS  
	  ,input  logic ARVALID_FRAMOS
      ,input  logic [6:0] AWADDR 
      ,output logic AWREADY_IMAGER
      ,output logic AWREADY_FRAMOS
      ,input  logic [31:0] WDATA
      ,input  logic [3:0]  WSTRB
      ,input  logic WVALID 
      ,output logic WREADY_IMAGER
      ,output logic WREADY_FRAMOS
      ,output logic RESP_IMAGER
      ,output logic RESP_FRAMOS
      ,output logic BVALID_IMAGER
      ,output logic BVALID_FRAMOS
      ,input  logic BREADY
      ,input  logic [6:0] ARADDR  
      ,output logic ARREADY_IMAGER
      ,output logic ARREADY_FRAMOS      
      ,output logic [31:0] RDATA_IMAGER
      ,output logic [31:0] RDATA_FRAMOS
      ,output logic RRESP_IMAGER	 
      ,output logic RVALID_IMAGER  
      ,output logic RRESP_FRAMOS	 
      ,output logic RVALID_FRAMOS       
      ,input  logic RREADY 
    );
    
// clock and  reset
logic [1:0] img_reset; 
logic image_rst;
logic [28:0] image_rst_width;
always @ (posedge sys_clk, negedge sys_rst_n) begin
      if (!sys_rst_n) begin
         img_reset <= 2'b00;
         image_rst <= 1'b0;         
         image_rst_width <= '0;
      end else begin
         image_rst <= imager_rst;        
         if (image_rst_width[28]) begin
            img_reset <= 2'b10;
            if (&image_rst_width) 
               img_reset <= 2'b00;           
         end else if (~image_rst & imager_rst) begin
            img_reset <= 2'b11;
         end 
         if (|img_reset)
            image_rst_width <= image_rst_width + 1'b1;
      end
end


logic x_clk, free_run_clk_gb, x_rst, x_rst_n; 

assign x_clk = free_run_clk_gb;
assign freerun_clk = free_run_clk_gb;

reset_sync                                    
reset_sync_xcer                               
  ( .pll_clk               ( x_clk         )  
  , .pll_lock              ( main_pll_lock )  
  , .external_rst          ( img_reset[0]  )  
  , .sync_rst_out          ( x_rst         )  
  , .sync_rst_out_n        ( x_rst_n       )
  ) ;     
 
logic  img_rx_clk, img_rx_rst, img_rx_rst_n;
reset_sync                                    
reset_sync_derive                               
  ( .pll_clk               ( img_rx_clk        )  
  , .pll_lock              ( main_pll_lock     )  
  , .external_rst          ( img_reset[1]      )  
  , .sync_rst_out          ( img_rx_rst        )  
  , .sync_rst_out_n        ( img_rx_rst_n      )
  ) ;   
  

// image sensor transceiver    
logic [16*8-1:0] data_2_FRAMOS;
logic [2*8-1:0]  control_data_o;

ImageSensorWrapper imageSensor(
       .ref_clk_p (ref_clk_p)
      ,.ref_clk_n (ref_clk_n)
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
      ,.free_run_clk_gb (free_run_clk_gb)
      ,.mgt_clk       (mgt_clk)
      ,.reset_i       (x_rst)
      ,.data_o        (data_2_FRAMOS)
      ,.control_data_o(control_data_o)
      ,.data_clk_o    (img_rx_clk)    
      ,.xcvr_status_o (xcvr_status_o)
);   

// FRAMOS slvs-ec receiver IP 
logic [255:0] imageData;
logic [159:0] untapFifo_In;
logic [159:0] data_truncate1;
logic [12:0] lnum_o;
logic ebdl_o, fv_o, lv_o, dv_o;
logic fifoVld;
logic [3:0] did_o;
logic [2:0] hit_o;
logic [23:0] hinf_o;
logic [7:0] status_o;

genvar i;
generate 
  for (i=0; i<16; i++) begin : truncate
      assign data_truncate1[i*10+:10] = imageData[(15-i)*16+15 : (15-i)*16+6]; 
  end 
endgenerate 

logic frameStart;
logic [15:0] XceiverStatus;
logic [12:0] currentline;
logic [11:0] lineWidth; 
assign currentline = lnum_o;
assign lineWidth = hinf_o[11:0]; 
always @ (posedge img_rx_clk) begin
      fifoVld <= fv_o & lv_o & dv_o;
      untapFifo_In <= data_truncate1;
	  XceiverStatus<= {did_o,hit_o,status_o,xcvr_status_o};
end 

slvs_ec_rx_0 SLVS_EC_RX_i 
(
      .data_clk_i(img_rx_clk)
     ,.rstn_i (img_rx_rst_n)
     ,.axi_aclk (sys_clk)
     ,.axi_aresetn (sys_rst_n)  
     ,.axi_awaddr (AWADDR[4:0])
     ,.axi_awprot ('0)
     ,.axi_awvalid (AWVALID_FRAMOS)
     ,.axi_awready (AWREADY_FRAMOS)
     ,.axi_wdata (WDATA)
     ,.axi_wstrb (WSTRB)
     ,.axi_wvalid (WVALID)
     ,.axi_wready (WREADY_FRAMOS)
     ,.axi_bresp (RESP_FRAMOS)
     ,.axi_bvalid (BVALID_FRAMOS)
     ,.axi_bready (BREADY)
     ,.axi_araddr (ARADDR[4:0])
     ,.axi_arprot ('0)
     ,.axi_arvalid (ARVALID_FRAMOS)
     ,.axi_arready (ARREADY_FRAMOS)
     ,.axi_rdata (RDATA_FRAMOS)
     ,.axi_rresp (RRESP_FRAMOS)
     ,.axi_rvalid (RVALID_FRAMOS)
     ,.axi_rready (RREADY)
     ,.data_i (data_2_FRAMOS)
     ,.rxdatak_i (control_data_o)
     ,.XCVR_status_i (xcvr_status_o)  
     ,.fv_o (fv_o)
     ,.lv_o (lv_o)
     ,.dv_o (dv_o)
     ,.data_o (imageData)
     ,.lnum_o (lnum_o)
     ,.ebdl_o (ebdl_o)
     ,.did_o (did_o)
     ,.hit_o (hit_o)
     ,.hinf_o (hinf_o)
     ,.status_o (status_o)
);  

// imager and light source controller
logic XHS_in, XVS_in, XTRIG;

logic [79:0]        imageDataOut;
logic               imageDataVld;
always @ (posedge sys_clk) begin
	 imageDataSync    <= imageDataOut;
	 imageDataSyncVld <= imageDataVld;
end

ImagerControl ImagerControl_inst 
(
        .sys_clk (sys_clk),
        .sys_rst_n (sys_rst_n ),
        .img_rx_clk (img_rx_clk),
        .img_rx_rst_n (img_rx_rst_n),
        .x_clk (x_clk),
	    .x_rst (x_rst),        
        .new_frame (new_frame),
//        .nextFrame  (nextFrame),
//        .rawImageMode(rawImageMode),
        .XHS (XHS_in),
        .XVS (XVS_in),    
        .XTRIG (XTRIG),    
        // image data
        .untapFifo_In (untapFifo_In),
        .fifoVld (fifoVld),
	    .currentline(currentline),
        .lineWidth (lineWidth),	
		.imageRow  (imageRow),
		.imageCol  (imageCol),
        .imageData (imageDataOut),
	    .imageDataVld(imageDataVld),
		.XceiverStatus (XceiverStatus),
		.FPGASlaveMode (FPGASlaveMode),
		.exposureTime (exposureTime),
		// lightsouce control
		.LEDEn (LEDEn),
		.MLLEn (MLLEn),
		.SLLEn (SLLEn),
		// Ports of Axi Slave Bus Interface S00_AXI	
		.s00_axi_aclk(s00_axi_aclk),
		.s00_axi_aresetn(s00_axi_aresetn),	
		.s00_axi_awaddr(AWADDR),
		.s00_axi_awvalid(AWVALID_IMAGER),
		.s00_axi_awready(AWREADY_IMAGER),
		.s00_axi_wdata(WDATA),
		.s00_axi_wstrb(WSTRB),
		.s00_axi_wvalid(WVALID),
		.s00_axi_wready(WREADY_IMAGER),
		.s00_axi_bresp(RESP_IMAGER),
		.s00_axi_bvalid(BVALID_IMAGER),
		.s00_axi_bready(BREADY),
		.s00_axi_araddr(ARADDR),
		.s00_axi_arvalid(ARVALID_IMAGER),
		.s00_axi_arready(ARREADY_IMAGER),
		.s00_axi_rdata(RDATA_IMAGER),
		.s00_axi_rresp(RRESP_IMAGER),
		.s00_axi_rvalid(RVALID_IMAGER),
		.s00_axi_rready(RREADY)
);


// image sensor IO interface
logic  XMASTER_out, XVS_out, XHS_out;
assign slavemode = '0;
assign Xtrigger1 = XTRIG;
assign Xtrigger2 = 1'bz; 

assign XMASTER = XMASTER_out;
assign XVS     = XVS_out;
assign XHS     = XHS_out;

imx_pwr_on_seq_gen_1 imx_pwr_on_seq_i
(
  .clock (sys_clk),
  .reset_n(sys_rst_n),
  .XCE_in(cs_n),
  .XVS_in(XVS_in),
  .XHS_in(XHS_in),
  .INCK_in(x_clk),
  .XCE_out(XCE),
  .XVS_out(XVS_out),
  .XHS_out(XHS_out),
  .XMASTER_out(XMASTER_out),
  .XCLR_out(XCLR),
  .OMODE_out(OMODE),
  .INCK_out(MCLK)
);

// image data to AXIS for DMA IP 
DMAinterface MasterDataOutInterface
(
       .sys_clk (sys_clk),
       .sys_rst (sys_rst),
       .frame_rst (new_frame),
       .dataIn (imageDataSync),
       .data_vld (imageDataSyncVld), 
       .imageWidth(imageCol),
       .imageHeight(imageRow), 
       .imageMode(dmaImageMode),
       .dmaEnable (DMAEnable & xcvr_status_o),       
       .AxisData (S_AXIS_S2MM_0_tdata),
       .AxisDataVld(S_AXIS_S2MM_0_tvalid),
       .AxisDataReady(S_AXIS_S2MM_0_tkeep),
       .AxisDataEnd(S_AXIS_S2MM_0_tlast),
       .AxisDataRead(S_AXIS_S2MM_0_tready),
       .status(masterDMA_status),
       .outDataCount(outDataCount)
);

`ifdef DEBUG
slvs_ec_IF slvs_ec_IF_i (
   .clk (img_rx_clk),
   .probe0 (fv_o),
   .probe1 (lv_o),
   .probe2 (dv_o),
   .probe3 (lnum_o),   
   .probe4 (status_o),
   .probe5 (imageData),
   .probe6 (data_o),  
   .probe7 (control_data_o)
);
`endif 
    
endmodule
