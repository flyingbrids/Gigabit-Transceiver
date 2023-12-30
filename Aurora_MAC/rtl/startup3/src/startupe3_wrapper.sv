`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2023 08:17:29 PM
// Design Name: 
// Module Name: startupe3_wrapper
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


module startupe3_wrapper(
    input logic clk,
    input logic resetn,
    output logic DI_0,
    output logic DI_1,
    output logic DI_2,
    output logic DI_3,
    output logic EOS,
    input logic DO_0,
    input logic DO_1,
    input logic DO_2,
    input logic DO_3,
    input logic DTS_0,
    input logic DTS_1,
    input logic DTS_2,
    input logic DTS_3,
    input logic FCSBO,
//    input logic FCSBTS,
    input logic USRCCLKO
//    input logic USRCCLKTS
);

logic [ 3: 0] DI;
logic [ 3: 0] DO;
logic [ 3: 0] DTS;

//logic         PREQ_INT;
//logic         PACK_INT;
//logic [ 7: 0] PACK_PIPE;

//always_ff @(posedge clk) begin
//    if (resetn == 0) begin
//        PACK_PIPE[0] <= 1'b0;
//    end
//    else if (PREQ_INT) begin
//        PACK_PIPE[0] <= 1'b1;
//    end
//end

//always_ff @(posedge clk) begin
//    if (resetn == 0) begin
//        PACK_PIPE[7:1] <= 7'b0;
//    end
//    else begin
//        PACK_PIPE[1] <= PACK_PIPE[0];
//        PACK_PIPE[2] <= PACK_PIPE[1];
//        PACK_PIPE[3] <= PACK_PIPE[2];
//        PACK_PIPE[4] <= PACK_PIPE[3];
//        PACK_PIPE[5] <= PACK_PIPE[4];
//        PACK_PIPE[6] <= PACK_PIPE[5];
//        PACK_PIPE[7] <= PACK_PIPE[6];
//    end
//end

//assign PACK_INT = PACK_PIPE[7];

always_comb begin
    DI_0    = DI[0];
    DI_1    = DI[1];
    DI_2    = DI[2];
    DI_3    = DI[3];
    DO      = {DO_3, DO_2, DO_1, DO_0};
    DTS     = {DTS_3, DTS_2, DTS_1, DTS_0};
end
// STARTUPE3: STARTUP Block
//            UltraScale
// Xilinx HDL Language Template, version 2022.2

STARTUPE3 #(
   .PROG_USR("FALSE"),      // Activate program event security feature. Requires encrypted bitstreams.
   .SIM_CCLK_FREQ(10.0)     // Set the Configuration Clock Frequency (ns) for simulation.
)
STARTUPE3_inst (
   .CFGCLK          (),             // 1-bit output: Configuration main clock output.
   .CFGMCLK         (),             // 1-bit output: Configuration internal oscillator clock output.
   .DI              (DI),           // 4-bit output: Allow receiving on the D input pin.
   .EOS             (EOS),          // 1-bit output: Active-High output signal indicating the End Of Startup.
   .PREQ            (),             // 1-bit output: PROGRAM request to fabric output.
   .DO              (DO),           // 4-bit input: Allows control of the D pin output.
   .DTS             (DTS),          // 4-bit input: Allows tristate of the D pin.
   .FCSBO           (FCSBO),        // 1-bit input: Controls the FCS_B pin for flash access.
   .FCSBTS          ('0),       // 1-bit input: Tristate the FCS_B pin.
   .GSR             ('0),           // 1-bit input: Global Set/Reset input (GSR cannot be used for the port).
   .GTS             ('0),           // 1-bit input: Global 3-state input (GTS cannot be used for the port name).
   .KEYCLEARB       ('1),           // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM).
   .PACK            ('0),         // 1-bit input: PROGRAM acknowledge input.
   .USRCCLKO        (USRCCLKO),     // 1-bit input: User CCLK input.
   .USRCCLKTS       ('0),    // 1-bit input: User CCLK 3-state enable input.
   .USRDONEO        ('1),           // 1-bit input: User DONE pin output control.
   .USRDONETS       ('0)            // 1-bit input: User DONE 3-state enable output.
);

// End of STARTUPE3_inst instantiation
endmodule
