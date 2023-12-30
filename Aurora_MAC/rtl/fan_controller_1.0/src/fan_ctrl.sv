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
module fan_ctrl # (
        parameter sys_clk_rate = 100
    )
    (
       input logic [7:0] dutyCycleIn,
       input logic [23:0] preScaleIn,
       input logic enable,
       input logic forceON,
       input logic sys_clk,
       input logic sys_rst,
       input logic tach,
       output logic [19:0] fan_rps,
       output logic pwm
    );
    
logic [23:0] preScale; 
logic [7:0] periodCnt;
logic [7:0] dutyCycle;

logic [26:0] pps_cnt;
logic [19:0] tach_pulse_cnt;

logic fan_tach_d1;
logic fan_tach_d2;
logic one_pps;

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

always_ff @ (posedge sys_clk, posedge sys_rst) begin
    if (sys_rst) begin
        fan_tach_d1 <= '0;
        fan_tach_d2 <= '0;
    end
    else begin
        fan_tach_d1 <= tach;
        fan_tach_d2 <= fan_tach_d1;
    end
end

always_ff @ (posedge sys_clk, posedge sys_rst) begin
    if (sys_rst) begin
        fan_rps <= '0;
        tach_pulse_cnt <= '0;
    end
    else begin
        if (one_pps) begin
            fan_rps <= tach_pulse_cnt >> 1;
            tach_pulse_cnt <= '0;
        end
        else begin
            if (fan_tach_d1 > fan_tach_d2)
                tach_pulse_cnt <= tach_pulse_cnt + 1'b1;
            else
                tach_pulse_cnt <= tach_pulse_cnt;
        end
    end
end

always_ff @(posedge sys_clk, posedge sys_rst) begin
    if (sys_rst) begin
        one_pps <= '0;
        pps_cnt <= '0;
    end
    else begin
        if (pps_cnt == (27'd100_000_000 - 1'd1)) begin
            one_pps <= 1'b1;
            pps_cnt <= '0;
        end
        else begin
            one_pps <= 1'b0;
            pps_cnt <= pps_cnt + 1'b1;
        end
    end
end
 
endmodule
