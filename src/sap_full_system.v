//////////////////////////////////////////////////////////////////////////////////
// Company: FICS
// Engineer: Md Sami Ul Islam Sami
// 
// Create Date: 11/09/2021 06:07:18 PM
// Design Name: 
// Module Name: sap_full_system
// Project Name: SAP
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

`include "timescale.v"

module sap_full_system(clk, rstn, host_instruction, host_data, sap_start, sap_output, sap_operation_done, poca_base_point_g, poca_signature_gen_seed, 
					  poca_signature_gen_capture_cycle, poca_public_key_hsm, poca_public_key_hsm_received, poca_response, poca_response_ready, test_mode, poca_data_received,
					  poca_asset_size);

`include "config_pkg.vh"


    //Global Input signals and inputs from host
    input wire                              clk;
    input wire                              rstn;
    input wire  [HOST_INSTRUCT_SIZE-1:0]    host_instruction;
    input wire  [MAX_INPUT_DATA_SIZE-1:0]   host_data;
    input wire                              sap_start;
    
    //output signals to host
    output wire sap_operation_done;
	output wire [MAX_OUTPUT_DATA_SIZE-1:0] sap_output;
	//
	input [POCA_MULT_SIZE-1:0] poca_base_point_g;
	input [POCA_SEED_SIZE-1:0] poca_signature_gen_seed;
	input [POCA_CYCLE_SIZE-1:0] poca_signature_gen_capture_cycle;
	input [POCA_MULT_SIZE-1:0] poca_public_key_hsm;
	input poca_public_key_hsm_received;
	input poca_data_received;
	input test_mode;
	input [10:0] poca_asset_size;
	output wire [POCA_MULT_SIZE+POCA_HASH_SIZE-1:0] poca_response;
	output wire poca_response_ready;
	// 
	// signals from master
    wire                                PCLK;
    wire                                PRESETn;    
    wire    [APB_ADDR_WIDTH-1 : 0]      PADDR;
    wire    [APB_DATA_WIDTH-1 : 0]      PWDATA;
    wire    [2 : 0]                     PPROT;
    wire    [PSELx_WIDTH-1 :0]          PSELx;
    wire                                PENABLE;
    wire                                PWRITE;
    wire    [APB_STROBE_WIDTH-1 : 0]    PSTRB;
  
    wire                                PREADY;
    wire                                PSLVERR;
    wire    [APB_DATA_WIDTH-1 : 0]      PRDATA;
    
    // shared slave signals
   
    wire PSEL_00, PSEL_01, PSEL_02, PSEL_03, PSEL_04, PSEL_05, PSEL_06;   
    
    wire PREADY_00, PREADY_01, PREADY_02, PREADY_03, PREADY_04, PREADY_05, PREADY_06;
    
    wire PSLVERR_00, PSLVERR_01, PSLVERR_02, PSLVERR_03, PSLVERR_04, PSLVERR_05, PSLVERR_06;
    
    wire [APB_DATA_WIDTH-1 : 0] PRDATA_00, PRDATA_01, PRDATA_02, PRDATA_03, PRDATA_04, PRDATA_05, PRDATA_06;
    
    reg psel_00, psel_01, psel_02, psel_03, psel_04, psel_05, psel_06;
    
    reg pready;
    // pready_00, pready_01, pready_02, pready_03, pready_04, pready_05, pready_06;
    
    reg [APB_DATA_WIDTH-1 : 0] prdata;
    // prdata_00, prdata_01, prdata_02, prdata_03, prdata_04, prdata_05, prdata_06;
   
    reg pslverr;
    // pslverr_00, pslverr_01, pslverr_02, pslverr_03, pslverr_04, pslverr_05, pslverr_06;
    
    assign PCLK = clk;
    assign PRESETn = rstn;
    
    assign PSEL_00 = psel_00;
    assign PSEL_01 = psel_01;
    assign PSEL_02 = psel_02;
    assign PSEL_03 = psel_03;
    assign PSEL_04 = psel_04;
    assign PSEL_05 = psel_05;
    assign PSEL_06 = psel_06;
    
    
      assign PREADY = pready;
//    assign PREADY_00 = pready_00;
//    assign PREADY_01 = pready_01;
//    assign PREADY_02 = pready_02;
//    assign PREADY_03 = pready_03;
//    assign PREADY_04 = pready_04;
//    assign PREADY_05 = pready_05;
//    assign PREADY_06 = pready_06;
    
      assign PRDATA = prdata;
//    assign PRDATA_00 = prdata_00;
//    assign PRDATA_01 = prdata_01;
//    assign PRDATA_02 = prdata_02;
//    assign PRDATA_03 = prdata_03;
//    assign PRDATA_04 = prdata_04;
//    assign PRDATA_05 = prdata_05;
//    assign PRDATA_06 = prdata_06;
    
      assign PSLVERR = pslverr;
//    assign PSLVERR_00 = pslverr_00;
//    assign PSLVERR_01 = pslverr_01;
//    assign PSLVERR_02 = pslverr_02;
//    assign PSLVERR_03 = pslverr_03;
//    assign PSLVERR_04 = pslverr_04;
//    assign PSLVERR_05 = pslverr_05;
//    assign PSLVERR_06 = pslverr_06;
    
    
    
    always@(*) begin
        prdata = 32'd0;
        pready = 1'b1;
        pslverr = 1'b0;
        case(PSELx)
            3'b000:
            begin
                prdata = 32'd0;
                pready = 1'b1;
                pslverr = 1'b0;
            end
            3'b001:
            begin
                prdata = PRDATA_00;
                pready = PREADY_00;
                pslverr = PSLVERR_00;
            end
            3'b010:
            begin
                prdata = PRDATA_01;
                pready = PREADY_01;
                pslverr = PSLVERR_01;
            end 
            3'b011:
            begin
                prdata = PRDATA_02;
                pready = PREADY_02;
                pslverr = PSLVERR_02;
            end
            3'b100:
            begin
                prdata = PRDATA_03;
                pready = PREADY_03;
                pslverr = PSLVERR_03;
            end
            3'b110:
            begin
                prdata = PRDATA_04;
                pready = PREADY_04;
                pslverr = PSLVERR_04;
            end   
            3'b101:
            begin
                prdata = PRDATA_05;
                pready = PREADY_05;
                pslverr = PSLVERR_05;
            end 
            3'b111:
            begin
                prdata = PRDATA_06;
                pready = PREADY_06;
                pslverr = PSLVERR_06;
            end
        endcase
   
    end
    
    always@(*) begin
        
        psel_00 = 1'b0;
        psel_01 = 1'b0;
        psel_02 = 1'b0;
        psel_03 = 1'b0;
        psel_04 = 1'b0;
        psel_05 = 1'b0;
        psel_06 = 1'b0;
        case(PSELx)
     
            3'b001: psel_00 = 1'b1;
            3'b010: psel_01 = 1'b1;
            3'b011: psel_02 = 1'b1;
            3'b100: psel_03 = 1'b1;
            3'b110: psel_04 = 1'b1;
            3'b101: psel_05 = 1'b1;
            3'b111: psel_06 = 1'b1;
            3'b000: 
            begin
                psel_00 = 1'b0;
                psel_01 = 1'b0;
                psel_02 = 1'b0;
                psel_03 = 1'b0;
                psel_04 = 1'b0;
                psel_05 = 1'b0;
                psel_06 = 1'b0;
            end
        endcase
   
    end
    
    sap_m00_wrapper_top M00(
                            .host_instruction(host_instruction),
                            .host_data(host_data),
                            .sap_start(sap_start),
                            .sap_operation_done(sap_operation_done),
                            .sap_output(sap_output),
							.poca_base_point_g(poca_base_point_g), 
							.poca_signature_gen_seed(poca_signature_gen_seed), 
							.poca_signature_gen_capture_cycle(poca_signature_gen_capture_cycle), 
							.poca_public_key_hsm(poca_public_key_hsm), 
							.poca_public_key_hsm_received(poca_public_key_hsm_received), 
							.poca_response(poca_response), 
							.poca_response_ready(poca_response_ready), 
							.test_mode(test_mode), 
							.poca_data_received(poca_data_received),
							.poca_asset_size(poca_asset_size),
                            .PCLK(PCLK),
                            .PRESETn(PRESETn),
                            .PADDR(PADDR),
                            .PWDATA(PWDATA),
                            .PPROT(PPROT),
                            .PSELx(PSELx),
                            .PENABLE(PENABLE),
                            .PWRITE(PWRITE),
                            .PSTRB(PSTRB),
                            .PREADY(PREADY),
                            .PSLVERR(PSLVERR),
                            .PRDATA(PRDATA)
                            );
                            
    aes_s00_wrapper_top    S00(.pclk_00(PCLK),
                            .presetn_00(PRESETn),
                            .paddr_00(PADDR),
                            .pprot_00(PPROT),
                            .psel_00(PSEL_00),
                            .penable_00(PENABLE),
                            .pwrite_00(PWRITE),
                            .pwdata_00(PWDATA),
                            .pstrb_00(PSTRB),
                            .pready_00(PREADY_00),
                            .pslverr_00(PSLVERR_00),
                            .prdata_00(PRDATA_00)
                            ); 
                            
     hash_s01_wrapper_top    S01(.pclk_01(PCLK),
                            .presetn_01(PRESETn),
                            .paddr_01(PADDR),
                            .pprot_01(PPROT),
                            .psel_01(PSEL_01),
                            .penable_01(PENABLE),
                            .pwrite_01(PWRITE),
                            .pwdata_01(PWDATA),
                            .pstrb_01(PSTRB),
                            .pready_01(PREADY_01),
                            .pslverr_01(PSLVERR_01),
                            .prdata_01(PRDATA_01)
                            ); 
                            
     odometer_s02_wrapper_top    S02(.pclk_02(PCLK),
                               .presetn_02(PRESETn),
                               .paddr_02(PADDR),
                               .pprot_02(PPROT),
                               .psel_02(PSEL_02),
                               .penable_02(PENABLE),
                               .pwrite_02(PWRITE),
                               .pwdata_02(PWDATA),
                               .pstrb_02(PSTRB),
                               .pready_02(PREADY_02),
                               .pslverr_02(PSLVERR_02),
                               .prdata_02(PRDATA_02)
                               ); 
                               
      trng_s03_wrapper_top    S03(.pclk_03(PCLK),
                              .presetn_03(PRESETn),
                              .paddr_03(PADDR),
                              .pprot_03(PPROT),
                              .psel_03(PSEL_03),
                              .penable_03(PENABLE),
                              .pwrite_03(PWRITE),
                              .pwdata_03(PWDATA),
                              .pstrb_03(PSTRB),
                              .pready_03(PREADY_03),
                              .pslverr_03(PSLVERR_03),
                              .prdata_03(PRDATA_03)
                              ); 
							  
		puf_s04_wrapper_top S04 (.pclk_04(PCLK),
							  .presetn_04(PRESETn),
		                      .paddr_04(PADDR),
		                      .pprot_04(PPROT),
		                      .psel_04(PSEL_04),
							  .penable_04(PENABLE),
							  .pwrite_04(PWRITE),
							  .pwdata_04(PWDATA),
							  .pstrb_04(PSTRB),
							  .pready_04(PREADY_04),
							  .pslverr_04(PSLVERR_04),
							  .prdata_04(PRDATA_04)
							);	

		ram_s05_wrapper_top S05 (.pclk_05(PCLK),
							  .presetn_05(PRESETn),
		                      .paddr_05(PADDR),
		                      .pprot_05(PPROT),
		                      .psel_05(PSEL_05),
							  .penable_05(PENABLE),
							  .pwrite_05(PWRITE),
							  .pwdata_05(PWDATA),
							  .pstrb_05(PSTRB),
							  .pready_05(PREADY_05),
							  .pslverr_05(PSLVERR_05),
							  .prdata_05(PRDATA_05)
							);	
    
endmodule
