`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2022 06:15:13 PM
// Design Name: 
// Module Name: ImageSensorWrapper 
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
module ImageSensorWrapper (
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
      ,output logic mgt_clk
      ,output logic free_run_clk_gb
      ,input logic reset_i
      ,output logic [16*8-1:0] data_o
      ,output logic [2*8-1:0] control_data_o
      ,output logic data_clk_o    
      ,output logic xcvr_status_o
);

// clock and reset
logic gtwiz_tx_reset, gtwiz_rx_reset;   
logic reset_buff;
logic [1:0] ref_clk;
logic ref_clk_o;
logic gtwiz_userclk_rx_usrclk2_out;

assign ref_clk[0] = ref_clk_o;
assign ref_clk[1] = ref_clk_o;
assign mgt_clk    = ref_clk_o;

logic freerun_clk_i;

IBUF IBUF_i (.O(reset_buff), .I(reset_i));

logic [16*8-1:0] rxctrl0;
logic [16*8-1:0] data_rx;

IBUFDS_GTE4 #(
.REFCLK_EN_TX_PATH(1'b0), // Refer to Transceiver User Guide
.REFCLK_HROW_CK_SEL(2'b01), // Refer to Transceiver User Guide
.REFCLK_ICNTL_RX(2'b00) // Refer to Transceiver User Guide
)
IBUFDS_GTE4_inst (
.O(ref_clk_o),          // 1-bit output: Refer to Transceiver User Guide
.ODIV2(freerun_clk_i), // 1-bit output: Refer to Transceiver User Guide
.CEB('0), // 1-bit input: Refer to Transceiver User Guide
.I(ref_clk_p), // 1-bit input: Refer to Transceiver User Guide
.IB(ref_clk_n) // 1-bit input: Refer to Transceiver User Guide
);

// data out register
always @ (posedge gtwiz_userclk_rx_usrclk2_out) begin
     control_data_o[3*2 +: 2] <= rxctrl0[0*16 +: 2];
     data_o[3*16 +: 16]       <= data_rx[0*16 +: 16]; 
     control_data_o[4*2 +: 2] <= rxctrl0[1*16 +: 2];
     data_o[4*16 +: 16]       <= data_rx[1*16 +: 16]; 
     control_data_o[2*2 +: 2] <= rxctrl0[2*16 +: 2];
     data_o[2*16 +: 16]       <= data_rx[2*16 +: 16]; 
     control_data_o[5*2 +: 2] <= rxctrl0[3*16 +: 2];
     data_o[5*16 +: 16]       <= data_rx[3*16 +: 16]; 
     control_data_o[1*2 +: 2] <= rxctrl0[4*16 +: 2];
     data_o[1*16 +: 16]       <= data_rx[4*16 +: 16]; 
     control_data_o[6*2 +: 2] <= rxctrl0[5*16 +: 2];
     data_o[6*16 +: 16]       <= data_rx[5*16 +: 16]; 
     control_data_o[0*2 +: 2] <= rxctrl0[6*16 +: 2];
     data_o[0*16 +: 16]       <= data_rx[6*16 +: 16]; 
     control_data_o[7*2 +: 2] <= rxctrl0[7*16 +: 2];
     data_o[7*16 +: 16]       <= data_rx[7*16 +: 16]; 
end 

// free run clock generate
BUFG_GT 
BUFG_GT_inst (
   .O(free_run_clk_gb),             // 1-bit output: Buffer
   .CE(1'b1),           // 1-bit input: Buffer enable
   .CEMASK(1'b0),   // 1-bit input: CE Mask
   .CLR(1'b0),         // 1-bit input: Asynchronous clear
   .CLRMASK(1'b0), // 1-bit input: CLR Mask
   .DIV('0),         // 3-bit input: Dynamic divide Value
   .I(freerun_clk_i)              // 1-bit input: Buffer
);

assign data_clk_o = gtwiz_userclk_rx_usrclk2_out;

// -- transceiver daisy chain bonding logic 
logic [39:0] rxchbondi;
logic [39:0] rxchbondo;
logic [23:0] rxchbondlevel;
logic [7:0]  rxchbondmaster;
logic [7:0]  rxchbondslave;

genvar i;
generate 
 for (i=0; i<8; i++) begin: daisy_chain_boding
     assign rxchbondmaster[i] = (i==4)? 1'b1: 1'b0;
     assign rxchbondslave [i] = ~rxchbondmaster[i];
     assign rxchbondlevel [i*3 +: 3] = (i>=4)? 8-i : i;
     assign rxchbondi[i*5 +: 5] = (i>4)? rxchbondo[(i-1)*5 +: 5] : 
                                  (i<4)? rxchbondo[(i+1)*5 +: 5] : '0; 
 end
endgenerate

`ifdef DEBUG
  vio_0 vio_0_inst (
    .clk (gtwiz_userclk_rx_usrclk2_out)
    ,.probe_in0 (gtwiz_userclk_rx_active_out)
    ,.probe_in1 (gtpowergood_out)
    ,.probe_in2 (rxpmaresetdone_out)
    ,.probe_in3 (rxbyteisaligned_out)
    ,.probe_in4 (rxchanisaligned_out)
    ,.probe_in5 (rxcommadet_out)
    ,.probe_in6 (rxchanrealign_out)
    ,.probe_in7 (rxbyterealign_out)
  );
`endif

// transceiver IP    
logic [7:0]  txpmaresetdone;
assign gtwiz_tx_reset = ~ (&txpmaresetdone);
assign gtwiz_rx_reset = '0;

// debug signals
logic gtwiz_userclk_rx_active_out;
logic [7:0]gtpowergood_out;
logic [7:0]rxpmaresetdone_out;
logic [7:0]rxbyteisaligned_out;
logic [7:0]rxcommadet_out; 
logic [7:0]rxchanisaligned_out;  
logic [7:0]rxchanrealign_out;
logic [7:0]rxbyterealign_out;

assign xcvr_status_o = &{gtwiz_userclk_rx_active_out, gtpowergood_out, rxpmaresetdone_out, rxbyteisaligned_out, rxchanisaligned_out};

image_sensor_receiver gtwizard_ultrascale_i
(
  // Free-running clock used to reset transceiver primitives.
  // Must be toggling prior to device configuration.
  .gtwiz_reset_clk_freerun_in       (free_run_clk_gb), 
  // User signal to reset the phase-locked loops (PLLs) and active data directions of transceiver primitives. 
  // The falling edge of an active-High, asynchronous pulse of at least one gtwiz_reset_clk_freerun_in period in duration initializes the process.
  .gtwiz_reset_all_in               (reset_buff),
  // User signal to reset the transmit data direction and associated PLLs of transceiver primitives.
  // An active-High, asynchronous pulse of at least one gtwiz_reset_clk_freerun_in period in duration initializes the process.
  .gtwiz_reset_tx_pll_and_datapath_in('0),
  // User signal to reset the transmit data direction of transceiver primitives. 
  // An active-High, asynchronous pulse of at least one gtwiz_reset_clk_freerun_in period in duration initializes the process.
  .gtwiz_reset_tx_datapath_in        ('0),
  // User signal to reset the receive data direction and associated PLLs of transceiver primitives.
  // An active-High, asynchronous pulse of at least one gtwiz_reset_clk_freerun_in period in duration initializes the process.
  .gtwiz_reset_rx_pll_and_datapath_in('0),
  //User signal to reset the receive data direction of transceiver primitives. 
  //An active-High, asynchronous pulse of at least one gtwiz_reset_clk_freerun_in period in duration initializes theprocess.
  .gtwiz_reset_rx_datapath_in        ('0),
  // Active-High indication that the transmitter reset sequence of transceiver primitives as initiated by the reset controller helper block has completed.
  .gtwiz_reset_tx_done_out           (),  // TXUSRCLK2
  // Active-High indication that the receiver reset sequence of transceiver primitives as initiated by the reset controller helper block has completed.
  .gtwiz_reset_rx_done_out           (),  // RXUSRCLK2
  
  // User signal to reset the clocking resources within the helper block. 
  // The active-High assertion should remain until gtwiz_userclk_tx_srcclk_in/out is stable.
  .gtwiz_userclk_tx_reset_in        (gtwiz_tx_reset),
  // Transceiver primitive-based clock source used to derive and buffer TXUSRCLK and TXUSRCLK2 outputs.  
  .gtwiz_userclk_tx_srcclk_out           (), 
  // Drives TXUSRCLK of transceiver channel primitives. Derived from gtwiz_userclk_tx_srcclk_in/out, buffered and divided as necessary by BUFG_GT primitive.
  .gtwiz_userclk_tx_usrclk_out           (), 
  // Drives TXUSRCLK2 of transceiver channel primitives. Derived from gtwiz_userclk_tx_srcclk_in/out, buffered and divided as necessary by BUFG_GT primitive if required.
  .gtwiz_userclk_tx_usrclk2_out          (),
  // Active-High indication that the clocking resources within the helper block are not held in reset.
  .gtwiz_userclk_tx_active_out           (),  // gtwiz_userclk_tx_usrclk2_out
  // This active-high signal indicates TX PMA reset is complete.
  // This port is driven Low when GTTXRESET or TXPMARESET is asserted.
  .txpmaresetdone_out                (txpmaresetdone),
  
  // User signal to reset the clocking resources within the helperblock. 
  // The active-High assertion should remain until gtwiz_userclk_rx_srcclk_in/out is stable.
  .gtwiz_userclk_rx_reset_in        (gtwiz_rx_reset),
  // Transceiver primitive-based clock source used to derive and buffer the RXUSRCLK and RXUSRCLK2 outputs.
  .gtwiz_userclk_rx_srcclk_out           (), 
  // Drives RXUSRCLK of transceiver channel primitives. 
  // Derived from gtwiz_userclk_rx_srcclk_in/out, buffered and divided as necessary by BUFG_GT primitive.
  .gtwiz_userclk_rx_usrclk_out           (), 
  // Drives RXUSRCLK2 of transceiver channel primitives.
  // Derived from gtwiz_userclk_rx_srcclk_in/out, buffered and divided as necessary by BUFG_GT primitive if required.  
  .gtwiz_userclk_rx_usrclk2_out     (gtwiz_userclk_rx_usrclk2_out), 
  // Active-High indication that the clocking resources within the helper block are not held in reset.
  .gtwiz_userclk_rx_active_out      (gtwiz_userclk_rx_active_out),  // gtwiz_userclk_rx_usrclk2_out
  // This active-High signal indicates RX PMA reset is complete.
  // This port is driven Low when GTRXRESET or RXPMARESET is asserted.
  .rxpmaresetdone_out               (rxpmaresetdone_out), 
  // This port is driven High and then deasserted to start the RX elastic buffer reset process. 
  // In either single mode or sequential mode, activating RXBUFRESET resets the RX elastic buffer only.
  .rxbufreset_in                         ('0), 
    
  // User interface for data to be transmitted by transceiver channels
  .gtwiz_userdata_tx_in              ('0),  // TXUSRCLK2
  // User interface for data received by transceiver channels
  .gtwiz_userdata_rx_out             (data_rx), // RXUSRCLK2
  
  // Connects to GTREFCLK01 on transceiver common primitives
  .gtrefclk01_in                     (ref_clk),
  // Connects to QPLL0OUTCLK on transceiver common primitives
  .qpll1outclk_out           		 (), 
  // Connects to QPLL0OUTREFCLK on transceiver common primitives
  .qpll1outrefclk_out            	 (),    
  
  // Power good indicator. When this signal asserts High, the clock
  // output from IBUFDS_GTE3/4 is ready after a delay of 250 ?s.  
  .gtpowergood_out                   (gtpowergood_out), 
  
  // Differential complements of one another forming a differential transmit output pair. 
  // These ports represent the pads. The locations of these ports must be constrained
//  .gtytxn_out           	 		(), 
//  .gtytxp_out           	 		(),
  // Differential complements of one another forming a differential receiver input pair. 
  // These ports represent pads. The location of these ports must be constrained
  .gthrxn_in                        ({D7_n,D6_n,D5_n,D4_n,D3_n,D2_n,D1_n,D0_n}),
  .gthrxp_in                        ({D7_p,D6_p,D5_p,D4_p,D3_p,D2_p,D1_p,D0_p}),
  //TX and RX 8b/10b encoder enable 
  .tx8b10ben_in                      ('1),
  .rx8b10ben_in                      ('1),
  // 8b/10b bits for tx TXUSRCLK2
  .txctrl0_in                        ('0),
  .txctrl1_in                        ('0),  
  .txctrl2_in                        ('0),
  // 8b/10b bits for rx RXUSRCLK2
  .rxctrl0_out                       (rxctrl0),  
  .rxctrl1_out                       (), 
  .rxctrl2_out                       (), 
  .rxctrl3_out                       (),

  // This signal from the comma detection and realignment circuit is High to indicate that the
  // parallel data stream is properly aligned on byte boundaries according to comma detection.
  // 0: Parallel data stream not aligned to byte boundaries
  // 1: Parallel data stream aligned to byte boundaries
  .rxbyteisaligned_out         (rxbyteisaligned_out),  //RXUSRCLK2
  // This signal from the comma detection and realignment circuit indicates that the byte
  // alignment within the serial data stream has changed due to comma detection.
  // 0: Byte alignment has not changed
  // 1: Byte alignment has changed
  // Data can be lost or repeated when alignment occurs, which can cause data errors (and disparity errors when the 8B/10B decoder is used).
  .rxbyterealign_out           (rxbyterealign_out),   // RXUSRCLK2
  // RXCOMMADETEN activates the comma detection and alignment circuit.
  // 0: Bypass the circuit
  // 1: Use the comma detection and alignment circuit
  .rxcommadeten_in             ('1),  
  // Aligns the byte boundary when comma minus is detected.
  // 0: Disabled
  // 1: Enabled.
  .rxmcommaalignen_in          ('1),
  // Aligns the byte boundary when comma plus is detected.
  // 0: Disabled
  // 1: Enabled. 
  .rxpcommaalignen_in          ('1), 
  // This signal is asserted when the comma alignment block detects a comma. 
  // The assertion occurs several cycles before the comma is available at the RX interface.
  // 0: Comma not detected
  // 1: Comma detected
  .rxcommadet_out              (rxcommadet_out), // RXUSRCLK2 
  
  // RX buffer status.
  // 000b: Nominal condition. 
  // 001b: Number of bytes in the buffer are less than CLK_COR_MIN_LAT
  // 010b: Number of bytes in the buffer are greater than CLK_COR_MAX_LAT
  // 101b: RX elastic buffer underflow
  // 110b: RX elastic buffer overflow
  .rxbufstatus_out            (), 
  // This signal from the RX elastic buffer goes High to indicate that the channel is properly aligned with
  // the master transceiver according to observed channel bonding sequences in the data stream.
  // This signal goes Low if an unaligned channel bonding or unaligned clock correction sequence is detected, 
  // indicating that channel alignment waslost.
  .rxchanisaligned_out         (rxchanisaligned_out), // RXUSRCLK2
  // This signal from the RX elastic buffer is held High for at least one cycle when the receiver has changed 
  // the alignment between this transceiver and the master.
  .rxchanrealign_out           (rxchanrealign_out), // RXUSRCLK2
  // Reports the clock correction status of the RX elastic buffer when the first byte of a clock correction sequence is shown in RXDATA.
  // 00: No clock correction
  // 01: One sequence skipped
  // 10: Two sequences skipped
  // 11: One sequence added
  .rxclkcorcnt_out             (), // RXUSRCLK2 
  
  // Receiver channel bonding logic 
  .rxchbonden_in                     ('1),
  .rxchbondi_in                      (rxchbondi),
  .rxchbondlevel_in                  (rxchbondlevel),   
  .rxchbondmaster_in                 (rxchbondmaster),
  .rxchbondslave_in                  (rxchbondslave),
  .rxchbondo_out                     (rxchbondo),
  // This port goes High when RXDATA contains the start of a channel bonding sequence.
  .rxchanbondseq_out           ()  // RXUSRCLK2
);
    
endmodule
