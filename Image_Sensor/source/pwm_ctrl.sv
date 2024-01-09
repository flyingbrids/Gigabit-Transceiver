`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2022 10:43:08 AM
// Design Name: 
// Module Name: fan_ctrl
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
module pwm_ctrl(
       input logic [6:0] dutyCycleIn,
       input logic [23:0] preScaleIn,
       input logic enable,
       input logic forceON,
       input logic sys_clk,
       input logic sys_rst,
       output logic pwm
    );
    
logic [23:0] preScale; 
logic [7:0] periodCnt;
logic [7:0] dutyCycle;
assign dutyCycle = (dutyCycleIn > 8'd100) ? 8'd100 : dutyCycleIn;  

always @ (posedge sys_clk, posedge sys_rst) begin
    if (sys_rst) begin
        preScale <= '0;
        periodCnt <= '0;
    end else if (preScale == preScaleIn) begin// prescale 
        preScale <= '0;
        periodCnt <= (periodCnt == 8'd99) ? '0 : periodCnt + 1'b1;// PWM period
    end else begin 
        preScale <= preScale + 1'b1; 
    end    
end    

always @ (posedge sys_clk)
   pwm <= ((dutyCycle >= periodCnt) | forceON)? enable : 1'b0; 
    
endmodule
