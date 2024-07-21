
//////////////////////////////////////////////////////////////////////////////////
// Company: FICS    
// Engineer: Sai Kiran Lade
// 
// Create Date: 01/24/2022 10:37:41 PM
// Design Name: 
// Module Name: sap_full_system_tb
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
///////////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module sap_full_system_tb();

`include "config_pkg.vh"

    //input from host to SAP
    reg clk, rstn;
    reg [HOST_INSTRUCT_SIZE-1:0] host_instruction;
    reg [MAX_INPUT_DATA_SIZE-1:0] host_data;
    reg sap_start;
    
    //outputs from SAP to host
    wire sap_operation_done;
    wire [MAX_OUTPUT_DATA_SIZE-1:0] sap_output;
    reg [POCA_MULT_SIZE-1:0] poca_base_point_g;
	reg [POCA_SEED_SIZE-1:0] poca_signature_gen_seed;
	reg [POCA_CYCLE_SIZE-1:0] poca_signature_gen_capture_cycle;
	reg [POCA_MULT_SIZE-1:0] poca_public_key_hsm;
	reg poca_public_key_hsm_received;
	reg poca_data_received;
	reg test_mode;
	reg [10:0] poca_asset_size;
	wire [POCA_MULT_SIZE+POCA_HASH_SIZE-1:0] poca_response;
	wire poca_response_ready;
	
    sap_full_system U0 (.clk(clk),
                        .rstn(rstn),
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
						.poca_asset_size(poca_asset_size)
						
						);
                        
    always #10 clk = !clk;
  
  initial begin
    clk = 1;
    rstn = 0;
    sap_start = 0;
    host_data = 0;
	test_mode = 0;
	poca_signature_gen_seed = 0;
	poca_signature_gen_capture_cycle = 0;
	poca_base_point_g = 0;
	poca_public_key_hsm = 0;
	poca_public_key_hsm_received = 0;
	poca_data_received = 0;
    #100
    rstn = 1;
    
    //ODOMETER
    host_instruction = 6'b010111;
    sap_start = 1;
    host_data = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF08;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
        
    //ODOMETER
    #200
    host_instruction = 6'b010111;
    sap_start = 1;
    host_data = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF10;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;

    //AES encrypt
    //#200; 
    rstn = 1;
    host_instruction = 6'b010001;
    sap_start = 1;
    host_data = 512'h0000000000000000000000000000000000000000000000000000000000000000BF85BA56926B4C798501ABBA49928C551499325D65411CD97031755A0784CF24;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;

 
    //AES decrypt
    //#200
    host_instruction = 6'b010010;
    sap_start = 1;
    host_data = 512'h0000000000000000000000000000000000000000000000000000000000000000BF85BA56926B4C797501ABBA49928C551499325D65411CD97031755A0784CF24;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;

     
    //HASH
    //#200
    host_instruction = 6'b010011;
    sap_start = 1;
    host_data = 512'h4321FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
     
    //AES encrypt
    #200; 
    rstn = 1;
    host_instruction = 6'b010001;
    sap_start = 1;
    host_data = 512'h0000000000000000000000000000000000000000000000000000000000000000BF85BA56926B4C798501ABBA49928C551499325D65411CD97031755A0784CF24;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
    
    //AES encrypt
    #200; 
    rstn = 1;
    host_instruction = 6'b010001;
    sap_start = 1;
    host_data = 512'h0000000000000000000000000000000000000000000000000000000000000000BF85BA56926B4C798501ABBA49928C551499325D65411CD97031755A0784CF24;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
   
   
   //AES decrypt
    #200
    host_instruction = 6'b010010;
    sap_start = 1;
    host_data = 512'h0000000000000000000000000000000000000000000000000000000000000000BF85BA56926B4C797501ABBA49928C551499325D65411CD97031755A0784CF24;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
    
    //AES decrypt
    #200
    host_instruction = 6'b010010;
    sap_start = 1;
    host_data = 512'h0000000000000000000000000000000000000000000000000000000000000000BF85BA56926B4C797501ABBA49928C551499325D65411CD97031755A0784CF24;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
   
   //HASH
    #200
    host_instruction = 6'b010011;
    sap_start = 1;
    host_data = 512'h4321FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
      
    //TRNG
    #200
    host_instruction = 6'b010100;
    sap_start = 1;
    //host_data = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
   
    //HASH
    #200
    host_instruction = 6'b010011;
    sap_start = 1;
    host_data = 512'h4321FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
    
    //AES encrypt
    #200; 
    rstn = 1;
    host_instruction = 6'b010001;
    sap_start = 1;
    host_data = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
    
    //AES decrypt
    #200
    host_instruction = 6'b010010;
    sap_start = 1;
    host_data = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
    
    
    //HASH
    #200
    host_instruction = 6'b010011;
    sap_start = 1;
    host_data = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
 
    
    //TRNG
    #200
    host_instruction = 6'b010100;
    sap_start = 1;
    //host_data = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
    
    //ODOMETER
    #200
    host_instruction = 6'b010111;
    sap_start = 1;
    host_data = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF10;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0; 
    
    //PUF 

    //rstn = 1;
    host_instruction = 6'b100101;
    sap_start = 1;
    host_data = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000796B559FF42768FA5F1FBC500000001;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0;
 	
	host_instruction = 6'b101001;
    sap_start = 1;
    host_data = 512'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000796B559FF42768FA5F10075654321001;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
    host_instruction = 0; 
    //Testing for MEM WRITE
	host_instruction = 6'b100110;
    sap_start = 1;
//    host_data = 512'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000796B559FF42768FA5F10075654321001;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
	#200;
	host_instruction = 6'b101010;
    sap_start = 1;
//    host_data = 512'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000796B559FF42768FA5F10075654321001;
    
    wait(sap_operation_done == 1);
    sap_start = 0;
//    host_instruction = 0;
    #200 $finish;

 //Testing for SEC_PUF
	host_instruction = 6'b101011;
    sap_start = 1;
    host_data = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000796B559FF42768FA5F1FBC500000001;
    
    wait(sap_operation_done == 1);
    sap_start = 0;


    #200 $finish;


 //Testing for POCA
	host_instruction = 6'b101100;
	test_mode = 1;
	poca_asset_size = 'd128;
	poca_signature_gen_seed = 'h60b998885e75315b3866889c53e92dfe ;
	poca_signature_gen_capture_cycle = 32'h000001F4;
	poca_base_point_g = 283'h503213f78ca44883f1a3b8162f188e553cd265f23c1567a16876913b0c2ac2458492836;
	#20;
    sap_start = 1;
	wait(poca_response_ready == 1);
	#100;
    host_data = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001499325D65411CD97031755A0784CF24;
	
    poca_public_key_hsm = 283'haab455e467872ea351d183201513207c6387517af45728b90595f6cb28f883355e52dc1;
	
	poca_public_key_hsm_received = 1;
	wait(U0.M00.U_M.poca_secret_key_ready == 1);
	poca_data_received = 1;
    wait(sap_operation_done == 1);
    sap_start = 0;


    #200 $finish;
 
	
	
end
  
endmodule