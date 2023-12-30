
`timescale 1 ns / 1 ps

	module c2c_cntr_interface_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
		input wire c2c_aclk,
		input wire c2c_aresetn,
		input wire c2c_master,
		output wire c2c_aresetn_out,
		
        output wire [3:0] c2c_m2s_int,
        input wire [3:0] c2c_s2m_int,
        
        input wire c2c_config_error,
        input wire c2c_link_status,
        input wire c2c_multi_bit_error,
        input wire c2c_link_error,
        input wire c2c_link_hndlr_in_prog,
        
        input wire c2c_m2s_io0,
        input wire c2c_m2s_io1,
        input wire c2c_m2s_io2,
        input wire c2c_m2s_io3,
        
        output wire c2c_s2m_io0,
        output wire c2c_s2m_io1,
        output wire c2c_s2m_io2,
        output wire c2c_s2m_io3,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI
    wire CONFIG_ERROR, LINK_STATUS, BIT_ERROR, LINK_ERROR, CLR_DATA_READY;

	c2c_cntr_interface_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) c2c_cntr_interface_v1_0_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		
		.CLR_DATA_READY(CLR_DATA_READY),
		.CONFIG_ERROR(CONFIG_ERROR),
		.LINK_STATUS(LINK_STATUS),
		.BIT_ERROR(BIT_ERROR),
		.LINK_ERROR(LINK_ERROR)
	);

	// Add user logic here
	
    wire [3:0] c2c_m2s_int_async;
    reg [3:0] c2c_s2m_int_reg;
    
    // reset handler 
    wire [ 2: 0] c2c_error_status;
    c2c_reset_hndlr # (
        .DIV (1)
        ) c2c_reset_hndlr_i (
        .c2c_aclk               (c2c_aclk),
        .c2c_aresetn            (c2c_aresetn),
        .c2c_config_error       (c2c_config_error),
        .c2c_link_status        (c2c_link_status),
        .c2c_multi_bit_error    (c2c_multi_bit_error),
        .c2c_link_error         (c2c_link_error),
        .c2c_link_hndlr_in_prog (c2c_link_hndlr_in_prog),
        .c2c_clr_error          (c2c_clr_error),
        .c2c_master             (c2c_master),
        .c2c_error_status       (c2c_error_status),
        .c2c_aresetn_out        (c2c_aresetn_out) 
    );
    
    //assignments
    
    //high priority signals from primary to secondary
    assign c2c_m2s_int_async[0] = c2c_m2s_io0;
    assign c2c_m2s_int_async[1] = c2c_m2s_io1;
    assign c2c_m2s_int_async[2] = c2c_m2s_io2;
    assign c2c_m2s_int_async[3] = c2c_m2s_io3;
    //high priority signals from secondary to primary
    assign c2c_s2m_io0          = c2c_s2m_int_reg[0];
    assign c2c_s2m_io1          = c2c_s2m_int_reg[1];
    assign c2c_s2m_io2          = c2c_s2m_int_reg[2];
    assign c2c_s2m_io3          = c2c_s2m_int_reg[3];
    
    //cdc - to c2c init clk domain
    toggle_sync enable_sync (
        .sig_in(CLR_DATA_READY),
        .clk_b(c2c_aclk),
        .rst_b(!c2c_aresetn),
        .sig_sync(c2c_clr_error)
    );
    
    //cdc - to c2c axi clock domain
    //interrupts are not true vector, treated as signal bits for sync
    genvar i;
    generate
        for (i=0; i<4; i = i+1) begin
            toggle_sync c2c_m2s_int (
                .sig_in(c2c_m2s_int_async[i]),
                .clk_b(c2c_aclk),
                .rst_b(!c2c_aresetn),
                .sig_sync(c2c_m2s_int[i])
            );
        end
    endgenerate
    
    always @(posedge c2c_aclk) begin
        if (c2c_aresetn == 1'b0) begin
            c2c_s2m_int_reg <= 4'b0;
        end
        else begin
            c2c_s2m_int_reg <= c2c_s2m_int;
        end
    end   

    //cdc - to ublaze peripheral axi clock domain
    toggle_sync config_error_sync (
        .sig_in(c2c_error_status[0]),
        .clk_b(s00_axi_aclk),
        .rst_b(!s00_axi_aresetn),
        .sig_sync(CONFIG_ERROR)
    );
    
    toggle_sync link_status_sync (
        .sig_in(c2c_link_status),
        .clk_b(s00_axi_aclk),
        .rst_b(!s00_axi_aresetn),
        .sig_sync(LINK_STATUS)
    );

    toggle_sync bit_error_sync (
        .sig_in(c2c_error_status[1]),
        .clk_b(s00_axi_aclk),
        .rst_b(!s00_axi_aresetn),
        .sig_sync(BIT_ERROR)
    );  
    
    toggle_sync link_error_sync (
        .sig_in(c2c_error_status[2]),
        .clk_b(s00_axi_aclk),
        .rst_b(!s00_axi_aresetn),
        .sig_sync(LINK_ERROR)
    );
    

	// User logic ends

	endmodule