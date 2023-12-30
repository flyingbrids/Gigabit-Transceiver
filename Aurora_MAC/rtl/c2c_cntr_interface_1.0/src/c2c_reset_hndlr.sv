`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2023 12:01:45 PM
// Design Name: 
// Module Name: c2c_reset_hndlr
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


module c2c_reset_hndlr # (
    parameter   FREQ = 188000000,
    parameter   DIV = 1000
)(
    input   c2c_aclk,
    input   c2c_aresetn,
    input   c2c_config_error,
    input   c2c_link_status,
    input   c2c_multi_bit_error,
    input   c2c_link_error,
    input   c2c_link_hndlr_in_prog,
    input   c2c_clr_error,
    input   c2c_master,
    
    output logic [ 2: 0] c2c_error_status,
    output logic c2c_aresetn_out
    );
    
localparam TIMEOUT = FREQ/DIV;
//FSM for managing c2c link
(* KEEP = "TRUE" *) typedef enum logic [ 2: 0] {  
    C2C_RST,
    IDLE,
    LNKH_ACT
} state_e;

(* KEEP = "TRUE" *) state_e state, state_next;  


//////////////////////////////////////////////////////////////////////////////////
// Link Management FSM
//////////////////////////////////////////////////////////////////////////////////

logic [31: 0]   timeout_cntr;
logic [ 2: 0]   rst_cntr;
logic           rst_in_progress;
logic           c2c_error;
logic           rst_done;
logic           wait_for_link;

//rst_handler_ila rst_handler_ila_i (
//	.clk(c2c_aclk), // input wire clk


//	.probe0(timeout_cntr), // input wire [31:0]  probe0  
//	.probe1(rst_cntr), // input wire [2:0]  probe1 
//	.probe2(state), // input wire [2:0]  probe2 
//	.probe3(rst_in_progress), // input wire [0:0]  probe3 
//	.probe4(c2c_error), // input wire [0:0]  probe4 
//	.probe5(rst_done), // input wire [0:0]  probe5 
//	.probe6(wait_for_link) // input wire [0:0]  probe6
//);

// error tracking, sticky error bits that can be cleared by ublaze
assign c2c_error = (c2c_config_error | c2c_multi_bit_error | c2c_link_error);
always_ff @ (posedge c2c_aclk) begin
    if (c2c_aresetn == 1'b0) begin
        c2c_error_status    <= '0;
    end
    else begin
        //clear when read
        if (c2c_clr_error)  c2c_error_status <= '0;
        else                c2c_error_status <= {c2c_link_error, c2c_multi_bit_error, c2c_config_error};
    end
end

assign wait_for_link = ((state == IDLE) & c2c_master & ~c2c_link_status);
//timeout and reset cnt
always_ff @ (posedge c2c_aclk) begin
    if (c2c_aresetn == 1'b0) begin 
        rst_cntr        <= '1;
        timeout_cntr    <= '0;
    end
    else begin
        rst_cntr        <= (rst_in_progress) ? rst_cntr - 1'b1 : '1;
        timeout_cntr    <= (wait_for_link) ? timeout_cntr + 1'b1 : '0;
    end
end
//present state clocked logic
always_ff @ (posedge c2c_aclk) begin
    if (c2c_aresetn == 1'b0)    state <= C2C_RST;
    else                        state <= state_next; 
end

always_comb begin
//    state_next = 'bx;
    case (state)
        C2C_RST : begin
            if (rst_cntr == 3'b0)           state_next = IDLE;
            else                            state_next = C2C_RST;
        end
        IDLE : begin
            if (c2c_link_hndlr_in_prog)     state_next = LNKH_ACT;
            else if (c2c_error)             state_next = C2C_RST;
            else if (timeout_cntr >= TIMEOUT)    state_next = C2C_RST;
            else                            state_next = IDLE;
        end
        LNKH_ACT : begin
            if (~c2c_link_hndlr_in_prog)    state_next = C2C_RST;
            else                            state_next = LNKH_ACT;
        end
    endcase
end

always_ff @( posedge c2c_aclk) begin
    if (c2c_aresetn == 1'b0) begin
        rst_in_progress <= '1;
        rst_done        <= '0;
        c2c_aresetn_out <= '0;
    end

    else begin
        rst_in_progress <= '0;
        rst_done        <= '0;
        c2c_aresetn_out <= '1;
        
        case (state_next)
            C2C_RST : begin
                rst_in_progress <= '1;
                c2c_aresetn_out <= '0;
            end
            IDLE    : begin
                if (c2c_link_status) 
                    rst_done   <= '1;              
            end 
        endcase
    end
end

endmodule