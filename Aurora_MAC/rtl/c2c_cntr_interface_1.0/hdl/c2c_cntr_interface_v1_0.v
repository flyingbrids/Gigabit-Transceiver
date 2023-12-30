
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
		input wire c2c_init_clk,
		input wire c2c_aclk,
		input wire c2c_aresetn,
		
		output wire c2c_enablen,
        output wire [3:0] c2c_m2s_int,
        input wire [3:0] c2c_s2m_int,
        input wire c2c_config_error,
        input wire c2c_link_status,
        input wire c2c_multi_bit_error,
        input wire c2c_link_error,
        
        input wire sec_start_in,
        input wire c2c_m2s_test,
        input wire c2c_test_enablen,
        
        output wire c2c_config_error_int,
        output wire c2c_link_status_int,
        output wire c2c_bit_error_int,
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
    wire CONFIG_ERROR, LINK_STATUS, BIT_ERROR, LINK_ERROR, ENABLE;

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
		
		.ENABLE(ENABLE),
		.CONFIG_ERROR(CONFIG_ERROR),
		.LINK_STATUS(LINK_STATUS),
		.BIT_ERROR(BIT_ERROR),
		.LINK_ERROR(LINK_ERROR)
	);

	// Add user logic here
	
    wire enable_sync;  
    wire vio_sync;
    wire [3:0] c2c_m2s_int_async;
    reg [3:0] c2c_s2m_int_reg;
    
    //assignments
    
    assign c2c_enablen = !(enable_sync | vio_sync);
    //start command from capture sync, forwards to secondary
    assign c2c_m2s_int_async[0] = sec_start_in;
    assign c2c_m2s_int_async[1] = c2c_m2s_test;
    assign c2c_m2s_int_async[3:2] = 2'b0;
    
    //cdc - to c2c init clk domain
    toggle_sync enable_sync (
        .sig_in(ENABLE),
        .clk_b(c2c_init_clk),
        .rst_b(!c2c_aresetn),
        .sig_sync(enable_sync)
    );
    
    toggle_sync vio_en_sync (
        .sig_in(c2c_test_enablen),
        .clk_b(c2c_init_clk),
        .rst_b(!c2c_aresetn),
        .sig_sync(vio_sync)
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
    
    ila_0 u_ila_0 (
        .clk(s00_axi_aclk), // input wire clk
    
    
        .probe0(CONFIG_ERROR), // input wire [0:0]  probe0  
        .probe1(LINK_STATUS), // input wire [0:0]  probe1 
        .probe2(BIT_ERROR), // input wire [0:0]  probe2 
        .probe3(LINK_ERROR) // input wire [0:0]  probe3
    );

    ila_1 u_ila_1 (
        .clk(c2c_aclk), // input wire clk
    
    
        .probe0(c2c_config_error), // input wire [0:0]  probe0  
        .probe1(c2c_link_status), // input wire [0:0]  probe1 
        .probe2(c2c_multi_bit_error), // input wire [0:0]  probe2 
        .probe3(c2c_link_error) // input wire [0:0]  probe3
    );

    //cdc - to ublaze peripheral axi clock domain
    toggle_sync config_error_sync (
        .sig_in(c2c_config_error),
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
        .sig_in(c2c_multi_bit_error),
        .clk_b(s00_axi_aclk),
        .rst_b(!s00_axi_aresetn),
        .sig_sync(BIT_ERROR)
    );  
    
    toggle_sync link_error_sync (
        .sig_in(c2c_link_error),
        .clk_b(s00_axi_aclk),
        .rst_b(!s00_axi_aresetn),
        .sig_sync(LINK_ERROR)
    );
    
    assign c2c_link_status_int = LINK_STATUS;
    assign c2c_bit_error_int = BIT_ERROR;
    assign c2c_config_error_int = CONFIG_ERROR;
	// User logic ends

	endmodule
