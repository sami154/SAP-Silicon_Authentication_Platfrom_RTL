`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: FICS
// Engineer: Md Sami Ul Islam Sami
// 
// Create Date: 10/18/2021 10:38:22 PM
// Design Name: SAP
// Module Name: sap_master
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


module sap_master #(
	parameter integer INSTRUCT_SIZE = 4,
	parameter integer HOST_INSTRUCT_SIZE = 6,
	parameter SECURE_FUNC_ENC = 2'b10,
	parameter NON_SECURE_FUNC_ENC = 2'b01,
	parameter INSTRUCT_ENCRPT   = 4'b0001,
	parameter INSTRUCT_DECRPT   = 4'b0010,
	parameter INSTRUCT_HASH     = 4'b0011,
	parameter INSTRUCT_TRNG     = 4'b0100,
	parameter INSTRUCT_PUF      = 4'b0101,
	parameter INSTRUCT_ODOMETER = 4'b0111,
	parameter INSTRUCT_RAM = 4'b1001,
	parameter INSTRUCT_SEC_PUF = 4'b1011,
	parameter INSTRUCT_POCA = 4'b1100,
	parameter integer NO_OF_SLAVE = 7,
	
	//
	parameter integer ADDR_BUS_WIDTH = 32,
	parameter integer DATA_BUS_WIDTH = 32,
	parameter integer INPUT_DATA_SIZE = 128,
	parameter integer MAX_INPUT_DATA_SIZE = 512,
	parameter integer AES_TEXT_KEY_SIZE = 128,
	parameter integer HASH_INPUT_SIZE = 512,
	parameter integer ODOMETER_INPUT_SIZE = 5,
	parameter integer PUF_CHALLENGE_SIZE = 32,
	parameter integer PUF_HELPER_WIDTH = 96,
	parameter integer MULT_INPUT_SIZE = 128,
	parameter integer HASH_OUTPUT_SIZE = 256,
	parameter integer PUF_RESPONSE_SIZE = 256 ,
	parameter integer TRNG_DATA_SIZE = 128,
	parameter integer MULT_OUTPUT_SIZE = 128,
	parameter integer ODOMETER_OUTPUT_SIZE = 8,
	parameter integer ECC_OUTPUT_SIZE = 128,
	parameter integer MAX_OUTPUT_DATA_SIZE = 512,
	parameter integer RAM_ADDR_WIDTH = 8,
	parameter integer RAM_DATA_WIDTH = 32,
	parameter integer RAM_DEPTH = 64,
	parameter integer RAM_DATA_INPUT_BITS = 8,
	parameter integer RAM_READ_STORE_SIZE = 128,
	// 
	
	// parameter for POCA
	parameter integer   POCA_KEY_SIZE = 128,
	parameter integer	POCA_MULT_SIZE = 283,
	parameter integer	POCA_HASH_SIZE = 256,
	parameter integer	POCA_SEED_SIZE = 128,
	parameter integer	POCA_SIGN_SIZE = 128,
	parameter integer	POCA_CYCLE_SIZE = 32,
	//
	parameter integer OPERATION_ENCODE_SIZE = 5,
	parameter ENCRPT_WRITE_ENCODE   = 5'b00001,
	parameter DECRPT_WRITE_ENCODE   = 5'b00010,
	parameter TRNG_WRITE_ENCODE     = 5'b00011,
	parameter PUF_WRITE_ENCODE      = 5'b00100,
	parameter HASH_WRITE_ENCODE     = 5'b00101,
	parameter ECC_WRITE_ENCODE      = 5'b00110,
	parameter ODOMETER_WRITE_ENCODE = 5'b00111,
	parameter MULT_WRITE_ENCODE     = 5'b01000,
	parameter ENCRPT_READ_ENCODE    = 5'b01001,
	parameter DECRPT_READ_ENCODE    = 5'b01010,
	parameter TRNG_READ_ENCODE      = 5'b01011,
	parameter PUF_READ_ENCODE       = 5'b01100,
	parameter HASH_READ_ENCODE      = 5'b01101,
	parameter ECC_READ_ENCODE       = 5'b01110,
	parameter ODOMETER_READ_ENCODE  = 5'b01111,
	parameter MULT_READ_ENCODE      = 5'b10000,
	parameter RAM_WRITE_ENCODE      = 5'b10001,
	parameter RAM_READ_ENCODE      = 5'b10010
	
	


)( clk, rstn, host_instruction, host_data, write_complete, text_out, key_out, operation_type, hash_out, odometer_mode_sel, puf_challenge, puf_helper_data,
mult_input_1, mult_input_2, encrypt_output_data_port, decrypt_output_data_port, hash_output_port, puf_response_output_port,
trng_output_port, mult_output_port, odometer_output_port, ecc_output_port, data_input_ready, init_transaction, sap_start, sap_operation_done, sap_output, ram_output_port, addr_to_ram, 
ram_write_data, ram_control_data, poca_base_point_g, poca_signature_gen_seed, poca_signature_gen_capture_cycle, poca_public_key_hsm, poca_public_key_hsm_received, poca_response, poca_response_ready, test_mode, poca_data_received,
poca_asset_size


    );
    
    //`include "parameter_sap.v"
    
    //Global Input signals and inputs from host
    input clk, rstn;
    input [HOST_INSTRUCT_SIZE-1:0] host_instruction;
    input [MAX_INPUT_DATA_SIZE-1:0] host_data;
    input sap_start;
    
    //Inputs from SAP master wrapper for internal transactions
    
    input data_input_ready;
    input write_complete;
    input [AES_TEXT_KEY_SIZE-1:0] encrypt_output_data_port, decrypt_output_data_port;
    input [HASH_OUTPUT_SIZE-1:0] hash_output_port;
    input [PUF_RESPONSE_SIZE-1:0] puf_response_output_port;
    input [TRNG_DATA_SIZE-1:0] trng_output_port;
    input [MULT_OUTPUT_SIZE-1:0] mult_output_port;
    input [ODOMETER_OUTPUT_SIZE-1:0] odometer_output_port;
	input [RAM_DATA_WIDTH-1:0] ram_output_port;
    input [ECC_OUTPUT_SIZE-1:0] ecc_output_port;
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

    //output signals to host
    //output reg busy;
    output reg sap_operation_done;
	output reg [MAX_OUTPUT_DATA_SIZE-1:0] sap_output;
 
    //Output signals to wrapper for internal transactions
   
    output reg [AES_TEXT_KEY_SIZE-1:0] text_out;
    output reg [AES_TEXT_KEY_SIZE-1:0] key_out;
    output reg [HASH_INPUT_SIZE-1:0] hash_out;
    output reg [ODOMETER_INPUT_SIZE-1:0] odometer_mode_sel;
    output reg [PUF_CHALLENGE_SIZE-1:0] puf_challenge;
	output reg [PUF_HELPER_WIDTH-1:0] puf_helper_data;
    output reg [MULT_INPUT_SIZE-1:0] mult_input_1, mult_input_2;
    output reg [OPERATION_ENCODE_SIZE-1:0] operation_type;
	output reg [RAM_ADDR_WIDTH-1:0] addr_to_ram;
	output reg [RAM_DATA_WIDTH-1:0] ram_write_data;
	output reg [RAM_DATA_WIDTH-1:0] ram_control_data;
    output reg init_transaction;
    
    reg [MAX_INPUT_DATA_SIZE-1:0] input_data_port;
    reg [MAX_INPUT_DATA_SIZE-1:0] internal_data_port, internal_data_port_new;
//    wire [HASH_INPUT_SIZE-1:0] hash_input;
    wire [1:0] secure_or_non;
    reg input_select;
    reg [INSTRUCT_SIZE-1:0] input_instuct;
    reg [AES_TEXT_KEY_SIZE-1:0] encrypt_output, decrypted_output;
    reg [HASH_OUTPUT_SIZE-1:0] hash_output;
    reg [PUF_RESPONSE_SIZE-1:0] puf_response_output;
    reg [TRNG_DATA_SIZE-1:0] trng_output;
    reg [MULT_OUTPUT_SIZE-1:0] mult_output;
    reg [ODOMETER_OUTPUT_SIZE-1:0] odometer_output;
    reg [ECC_OUTPUT_SIZE-1:0] ecc_output;
    reg encrypt_output_ready, decrypt_output_ready, hash_output_ready, puf_response_ready;
    reg trng_output_ready, mult_output_ready, odometer_output_ready, ecc_output_ready;
	reg ram_data_ready;
    reg input_data_transfer_complete;
    reg non_secure_func_start;
    reg secure_func_start;
    reg [INSTRUCT_SIZE-1:0] sap_instruction, sap_instruction_new;
    reg [NO_OF_SLAVE-1:0] slave_busy;
    reg write_start, read_start;
	reg [RAM_READ_STORE_SIZE-1:0] ram_output;
	reg sap_output_ready;
	
	/////
	reg [5:0] sap_state, sap_next_state;
    reg [1:0] ram_state;
	reg [RAM_ADDR_WIDTH-1:0] addr_ram_old, addr_ram_new, initial_write_addr;
	reg ram_write_go_new, ram_write_go_old, ram_read_go_new, ram_read_go_old;
	reg [RAM_DATA_INPUT_BITS:0] ram_data_size;
	reg [127:0] ram_input_old, ram_input_new;
	reg [RAM_DATA_INPUT_BITS-1: 0] loop_old, loop_new;
	reg [RAM_DATA_WIDTH-1:0] ram_control_old, ram_control_new;
	reg poca_go_new, poca_go_old;
	reg [RAM_DATA_INPUT_BITS-1:0] poca_data_write_loop_old, poca_data_write_loop_new;	
	wire [POCA_HASH_SIZE-1:0] poca_key_chip;
	////
	wire poca_secret_key_ready;
//    reg done_write, done_read;
    //Input select determines whether the input is coming from HOST processor or from inside SAP
    
	always @(input_select or host_data or internal_data_port)
		begin
			if (input_select  == 0)
				input_data_port <= host_data;
			else 
				input_data_port <= internal_data_port;
		end
    
    assign secure_or_non = host_instruction[HOST_INSTRUCT_SIZE-1:HOST_INSTRUCT_SIZE-2];
    
    // Instruction decode for secure and non-secure task. assignment of input_instuct
    
    always @(posedge clk )
    begin
        if (rstn == 0)
           begin
                input_instuct <= 0;
                input_select <= 0;
            end
        else 
            begin
                if (secure_or_non == NON_SECURE_FUNC_ENC)
                    begin
                        input_instuct <= host_instruction[HOST_INSTRUCT_SIZE-3:0];
                        input_select <= 0;
                    end
                else if (secure_or_non == SECURE_FUNC_ENC)
                    begin
                        input_instuct <= sap_instruction;
                        input_select <= 1;
                    end
            end
	end
	// SAP output to host
	
	always @(posedge clk)
		begin
			if (rstn == 0)
				begin
					sap_output <= 0;
					sap_output_ready <= 0;
				end
				
			else 
				begin
					if (sap_operation_done == 1)
					begin
						sap_output_ready <= 1;
						if (secure_or_non == NON_SECURE_FUNC_ENC) 
						begin
						
							case (input_instuct)
									INSTRUCT_ENCRPT  : begin sap_output[AES_TEXT_KEY_SIZE-1:0] <= encrypt_output; end
									INSTRUCT_DECRPT  : begin sap_output[AES_TEXT_KEY_SIZE-1:0] <= decrypted_output; end
									INSTRUCT_HASH    : begin sap_output[HASH_OUTPUT_SIZE-1:0] <= hash_output; end
									INSTRUCT_ODOMETER: begin sap_output[HASH_OUTPUT_SIZE-1:0] <= odometer_output; end
									INSTRUCT_TRNG    : begin sap_output[TRNG_DATA_SIZE-1:0] <= trng_output; end
							endcase
						
						end
						else if (secure_or_non == SECURE_FUNC_ENC)	
						begin
							case (host_instruction[HOST_INSTRUCT_SIZE-3:0])
									INSTRUCT_SEC_PUF : begin sap_output[HASH_OUTPUT_SIZE+TRNG_DATA_SIZE-1:0] <= {hash_output, trng_output}; end
									
//									INSTRUCT_RAM_WRITE    : begin sap_output[TRNG_DATA_SIZE-1:0] <= ram_output; end
							endcase
						end
					end	
					else if (sap_start == 0)
					begin
						sap_output_ready <= 0;
						sap_output <= 0;
					end
						
			end
		
		end
   
 
 
		
    // Determining if any slave is busy or idle
    
/*     always @(posedge clk)
        begin
            if (rstn == 0)
                begin
                    slave_busy <= 0;
                end
              
             else if (write_complete == 1)
                begin
                    case (input_instuct)
                        INSTRUCT_ENCRPT  : begin slave_busy[0] <= 1; end
                        INSTRUCT_DECRPT  : begin slave_busy[0] <= 1; end
                        INSTRUCT_HASH    : begin slave_busy[1] <= 1; end
                        INSTRUCT_TRNG    : begin slave_busy[2] <= 1; end
                        INSTRUCT_PUF     : begin slave_busy[3] <= 1; end
 //                       INSTRUCT_ERR_COR : begin slave_busy[4] <= 1; end
                        INSTRUCT_ODOMETER: begin slave_busy[5] <= 1; end
                        INSTRUCT_MULT    : begin slave_busy[6] <= 1; end
                     endcase
                end
             else if (input_data_transfer_complete == 1)
                begin
                    case (input_instuct)
                        INSTRUCT_ENCRPT  : begin slave_busy[0] <= 0; end
                        INSTRUCT_DECRPT  : begin slave_busy[0] <= 0; end
                        INSTRUCT_HASH    : begin slave_busy[1] <= 0; end
                        INSTRUCT_TRNG    : begin slave_busy[2] <= 0; end
                        INSTRUCT_PUF     : begin slave_busy[3] <= 0; end
 //                       INSTRUCT_ERR_COR : begin slave_busy[4] <= 0; end
                        INSTRUCT_ODOMETER: begin slave_busy[5] <= 0; end
                        INSTRUCT_MULT    : begin slave_busy[6] <= 0; end
                     endcase
                end
  
        end
         */
   
    //Registers to store the read data from slaves
     always @(posedge clk) begin
        if (rstn == 0) begin
          
			encrypt_output <= 0;
			decrypted_output <= 0;
			hash_output <= 0;
			puf_response_output <= 0;
			trng_output <=0;
			mult_output <= 0;
			odometer_output <= 0;
			ecc_output <= 0;
			ram_output <= 0;
			input_data_transfer_complete <= 0;

        end
        
     else if (encrypt_output_ready == 1) 
        begin
            encrypt_output <= encrypt_output_data_port;  
            input_data_transfer_complete <= 1;
        end   
     else if (decrypt_output_ready == 1)  
        begin      
            decrypted_output <= decrypt_output_data_port;  
            input_data_transfer_complete <= 1;
        end
     else if (hash_output_ready == 1)       
        begin 
            hash_output <= hash_output_port;        
            input_data_transfer_complete <= 1;
        end    
     else if (puf_response_ready == 1)     
        begin   
            puf_response_output <= puf_response_output_port;
            input_data_transfer_complete <= 1;
        end    
     else if (trng_output_ready == 1) 
        begin
            trng_output <= trng_output_port;    
            input_data_transfer_complete <= 1;    
        end 
     else if (mult_output_ready == 1) 
        begin
            mult_output <= mult_output_port;     
            input_data_transfer_complete <= 1; 
        end  
     else if (odometer_output_ready == 1) 
        begin
            odometer_output <= odometer_output_port;    
            input_data_transfer_complete <= 1;
        end
     else if (ecc_output_ready == 1) 
        begin
            ecc_output <= ecc_output_port;   
            input_data_transfer_complete <= 1;   
        end  
	else if (ram_data_ready == 1) 
        begin
            ram_output <= {ram_output_port, ram_output[RAM_READ_STORE_SIZE-1:RAM_DATA_WIDTH]};   
            input_data_transfer_complete <= 1;   
        end

    //#################################################################################
    else
        input_data_transfer_complete <= 0;
     end
     //#################################################################################
     
    //FSM for managing read and write to the components
    localparam  IDLE  = 'd0,
                WRITE = 'd1,
                READ  = 'd2,
                WRITE_DONE  = 'd3,
                READ_DONE = 'd4;
        
    reg [2:0] state, next_state;
            
    always @(posedge clk)
    begin
        if (rstn == 0)
            state <= IDLE;
        else 
            state <= next_state;
    end
    
    always @(*)
    begin
    
//        error <= 0;
        next_state <= state;
        init_transaction <= 0;
//        done_write <= 0;
//        done_read <= 0;
        text_out <= 0;
        key_out <= 0;
        operation_type <= 0;
        hash_out <= 0;
        puf_challenge <= 0;
        mult_input_1 <= 0;
        mult_input_2 <= 0;
        encrypt_output_ready <= 0;
        decrypt_output_ready <= 0;
        hash_output_ready <= 0;
        trng_output_ready <= 0;
        puf_response_ready <= 0;
        ecc_output_ready <= 0;
        odometer_output_ready <= 0;
        mult_output_ready <= 0;
		ram_data_ready <= 0;
        case(state)
            IDLE:   begin
                        if (write_start == 1)
                            next_state <= WRITE;
                        else if (read_start == 1)
                            next_state <= READ;
                        else 
                            next_state <= IDLE;
                    end
                    
             WRITE: begin    
                         if (write_complete == 1)
                            begin
                                init_transaction <= 0;
                                next_state <= WRITE_DONE;
                            end
                         else 
                                next_state <= WRITE;
                              

           
						   case (input_instuct)
						   INSTRUCT_ENCRPT:     begin
														
														if (input_data_port != 0)
														begin
																text_out <= input_data_port[AES_TEXT_KEY_SIZE-1:0];
																key_out <= input_data_port[AES_TEXT_KEY_SIZE*2-1:AES_TEXT_KEY_SIZE];
																operation_type <= ENCRPT_WRITE_ENCODE;
																init_transaction <= 1;
															   
														end
																										 
												end
												
						   INSTRUCT_DECRPT:     begin
														if (input_data_port != 0)
														begin
																text_out <= input_data_port[AES_TEXT_KEY_SIZE-1:0];
																key_out <= input_data_port[AES_TEXT_KEY_SIZE*2-1:AES_TEXT_KEY_SIZE];
																operation_type <= DECRPT_WRITE_ENCODE;
																init_transaction <= 1;
														   
														end
																										  
												end 
												
						   INSTRUCT_HASH:       begin
														if (input_data_port != 0)
														begin
																hash_out <= input_data_port[HASH_INPUT_SIZE-1:0];
																operation_type <= HASH_WRITE_ENCODE;
																init_transaction <= 1;
															
														end
														
												end 
												
						   INSTRUCT_TRNG:       begin
														operation_type <= TRNG_WRITE_ENCODE;
														init_transaction <= 1;
													  
														
												end 
												
						   
						   INSTRUCT_ODOMETER:   begin
														odometer_mode_sel <= input_data_port[ODOMETER_INPUT_SIZE-1:0];
														operation_type <= ODOMETER_WRITE_ENCODE;
														init_transaction <= 1;
												   
												end
											   
												
/* 						   INSTRUCT_MULT:       begin
														if (input_data_port != 0)
														begin
																mult_input_1 <= input_data_port[MULT_INPUT_SIZE-1:0];
																mult_input_2 <= input_data_port[MULT_INPUT_SIZE*2-1:MULT_INPUT_SIZE];
																operation_type <= MULT_WRITE_ENCODE;
																init_transaction <= 1;
															
														end
														
												end */
						   endcase  
					
					if (secure_or_non == SECURE_FUNC_ENC) 
					begin
						case (input_instuct)
							INSTRUCT_PUF:        begin
														if (input_data_port != 0)
														begin
																puf_challenge <= input_data_port[PUF_CHALLENGE_SIZE-1:0];
																puf_helper_data <= input_data_port[PUF_CHALLENGE_SIZE+PUF_HELPER_WIDTH-1:PUF_CHALLENGE_SIZE];
																operation_type <= PUF_WRITE_ENCODE;
																init_transaction <= 1;
															  
														end
														
												end 
												
						   INSTRUCT_RAM:    begin
														if (input_data_port != 0)
														begin
																addr_to_ram <= input_data_port[RAM_ADDR_WIDTH-1:0];
																ram_write_data <= input_data_port[RAM_ADDR_WIDTH+RAM_DATA_WIDTH-1:RAM_ADDR_WIDTH];
																ram_control_data <= input_data_port[RAM_ADDR_WIDTH+2*RAM_DATA_WIDTH-1:RAM_ADDR_WIDTH+RAM_DATA_WIDTH];
																operation_type <= RAM_WRITE_ENCODE;
																init_transaction <= 1;
															  
														end
														  
												end 
												
						endcase
					end
			end
                    
             READ: begin
                            
                         if (input_data_transfer_complete == 1) 
                            begin
                                init_transaction <= 0;
                                next_state <= READ_DONE;
                            end
                         else 
                            begin
                                next_state <= READ;
                            end
                            
                        case (input_instuct)
                        
                        INSTRUCT_ENCRPT:    begin
                                                operation_type <= ENCRPT_READ_ENCODE;
                                                init_transaction <= 1;
                                                //#################################################################################
                                                if (data_input_ready == 1 )
                                                begin 
                                                    encrypt_output_ready <= 1;
                                                    init_transaction <= 0;
                                                end
                                                //#################################################################################
                                                
 
                                            end
                                            
                        INSTRUCT_DECRPT:    begin
                                                operation_type <= DECRPT_READ_ENCODE;
                                                init_transaction <= 1;
                                                //#################################################################################
                                                if (data_input_ready == 1 )
                                                begin 
                                                    decrypt_output_ready <= 1;
                                                    init_transaction <= 0;
                                                end
                                                //#################################################################################
 
                                            end
                                            
                        INSTRUCT_HASH:      begin
                                                 operation_type <= HASH_READ_ENCODE;
                                                 init_transaction <= 1;
                                                 
                                                 if (data_input_ready == 1 ) 
                                                 begin
                                                    hash_output_ready <= 1;
                                                    init_transaction <= 0;
                                                 end
                                                      
                                            end
                                            
                        INSTRUCT_TRNG:      begin
                                                operation_type <= TRNG_READ_ENCODE;
                                                init_transaction <= 1;
                                                
                                                if (data_input_ready == 1 ) 
                                                    trng_output_ready <= 1;
                                                    
                                            end
                                            
                       
                                            
                                            
                        INSTRUCT_ODOMETER:  begin
                                                operation_type <= ODOMETER_READ_ENCODE;
                                                init_transaction <= 1;
                                                
                                                if (data_input_ready == 1 ) 
                                                    odometer_output_ready <= 1;
                                                    
                                            end
                                            
/*                         INSTRUCT_MULT:      begin
                                                operation_type <= MULT_READ_ENCODE;
                                                init_transaction <= 1;
                                                
                                                if (data_input_ready == 1 ) 
                                                    mult_output_ready <= 1;
                                                        
                         
                                            end */
						
                        
                        endcase
					if (secure_or_non == SECURE_FUNC_ENC) 
					begin
						case (input_instuct)
							INSTRUCT_RAM:      begin
                                                operation_type <= RAM_READ_ENCODE;
                                                init_transaction <= 1;
                                                
                                                if (data_input_ready == 1 ) 
                                                    ram_data_ready <= 1;
                                                        
                         
                                            end
							INSTRUCT_PUF:       begin
                                                operation_type <= PUF_READ_ENCODE;
                                                init_transaction <= 1;
                                                
                                                 if (data_input_ready == 1 ) 
                                                    puf_response_ready <= 1;
                                                    
                                            end
						
						endcase
					end
             end
                    
             WRITE_DONE: begin
//                            done_write <= 1;
                            if (write_start == 0)
                                next_state <= IDLE;
                            else 
                                next_state <= WRITE_DONE;
                         end   
                         
             READ_DONE: begin
//                            done_read <= 1;                                
                            if (read_start == 0)
                                next_state <= IDLE;
                            else 
                                next_state <= READ_DONE;
                        end
             
             default: 
                            next_state <= IDLE;
        endcase
    
    end
    
    // SAP FSM Controller 
     localparam  SAP_IDLE     = 'd0,
                SAP_S_OR_NS  = 'd1,
                SAP_NS_WRITE = 'd2,
                SAP_NS_READ  = 'd3,  
                SAP_NS_DONE  = 'd4,
                SAP_SECURE_OPERATION  = 'd5,
				MEM_CONTROL = 'd6,
				MEM_WRITE_IDLE = 'd7,
				MEM_WRITE_DATA = 'd8,
				MEM_WRITE_REPEAT = 'd9,
				MEM_CONTROL_READ = 'd10,
				MEM_READ_IDLE = 'd11,
				MEM_READ_DATA = 'd12, 
				SEC_PUF_NONCE_GEN = 'd13,
                SEC_PUF_NONCE_READ = 'd14,
				SEC_PUF_WRITE = 'd15,
				SEC_PUF_READ = 'd16,
				SEC_PUF_HASH_WRITE = 'd17,
				SEC_PUF_HASH_READ = 'd18,
				SAP_SEC_NS_DONE = 'd19,
				POCA_START = 'd20,
				POCA_SEC_KEY_GEN = 'd21,
				POCA_DECRYPT_ASSET_WRITE = 'd22,
				POCA_DECRYPT_ASSET_READ = 'd23,
				POCA_WRITE_ASSET_RAM = 'd24,
				POCA_WRITE_CONTROL_RAM = 'd25;
				
	
     always @(posedge clk)
        begin
            if (rstn == 0) begin
                sap_state <= SAP_IDLE;
				addr_ram_old <= 0;
				ram_input_old <= 0;
				loop_old <= 0;
				sap_instruction <= 0;
				internal_data_port <= 0;
				ram_control_old <= 0;
				ram_read_go_old <= 0;
				poca_go_old <= 0;
				poca_data_write_loop_old <= 0;
				ram_write_go_old <= 0; 
			end
            else begin
                sap_state <= sap_next_state;
				addr_ram_old <= addr_ram_new;
				ram_input_old <= ram_input_new;
				loop_old <= loop_new;
				sap_instruction <= sap_instruction_new;
				internal_data_port <= internal_data_port_new;
				ram_control_old <= ram_control_new;
				ram_read_go_old <= ram_read_go_new;
				poca_go_old <= poca_go_new;
				poca_data_write_loop_old <= poca_data_write_loop_new;
				ram_write_go_old <= ram_write_go_new;
			end
        end
    
    always @(*)
        begin
            sap_operation_done = 0;
            sap_next_state = sap_state;
            write_start = 0;
            read_start = 0;
            addr_ram_new = addr_ram_old;
			sap_instruction_new = sap_instruction;
			internal_data_port_new = internal_data_port;
			loop_new = loop_old;
			ram_input_new = ram_input_old;
			ram_control_new = ram_control_old;
			ram_read_go_new = ram_read_go_old;
			poca_go_new = poca_go_old;
			poca_data_write_loop_new = poca_data_write_loop_old;
			ram_write_go_new = ram_write_go_old;
            case(sap_state)
                SAP_IDLE:   begin
                                if (sap_start == 1)
                                    sap_next_state = SAP_S_OR_NS;
                                else 
                                    sap_next_state = SAP_IDLE;
                            end
                            
                SAP_S_OR_NS: begin
                                if (secure_or_non == NON_SECURE_FUNC_ENC) 
                                    sap_next_state = SAP_NS_WRITE;    
                                else 
                                    sap_next_state = SAP_SECURE_OPERATION; 
                              end  
                SAP_NS_WRITE: begin
                                    write_start = 1;
                                    //#################################################################################
                                    if (write_complete == 1)
                                    //#################################################################################
                                        sap_next_state = SAP_NS_READ;  
                                    else 
                                        sap_next_state = SAP_NS_WRITE; 
                              end
                SAP_NS_READ: begin
                                    write_start = 0;
                                    read_start = 1;
                                    //#################################################################################
                                    if (data_input_ready == 1)
                                    //#################################################################################
                                        sap_next_state = SAP_NS_DONE;  
                                    else 
                                        sap_next_state = SAP_NS_READ; 
                              end     
                SAP_NS_DONE:  begin
                                    read_start = 0;
                                    sap_operation_done = 1;
                                    if (sap_start == 0)
                                        sap_next_state = SAP_IDLE;  
                                    else 
                                        sap_next_state = SAP_NS_DONE; 
                              end 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////							  
				SAP_SECURE_OPERATION : begin
											case(host_instruction[HOST_INSTRUCT_SIZE-3:0])
//												INSTRUCT_RAM_SAP : sap_next_state = MEM_CONTROL; 
//												INSTRUCT_RAM_SAP_READ : sap_next_state = MEM_CONTROL_READ; 
												INSTRUCT_SEC_PUF : sap_next_state = SEC_PUF_NONCE_GEN;
												INSTRUCT_POCA    : sap_next_state = POCA_START;
											endcase
										end
///////////////////////////////////////---RAM_WRITE_CONTROL----//////////////////////////////////////////////	
// To write into the memory the following signals need the data. The FSM state that will write into the memory needs to define these signals similarly.
//				MEM_CONTROL : 	begin
//									initial_write_addr = 0;   
//									ram_input_new = 128'h87654321876543218765432187654321;
//									ram_control_new = 32'h3;
//									ram_write_go = 1'b1;
//									ram_data_size = 'd128;
//									sap_next_state = MEM_WRITE_IDLE; 
//								end
				MEM_WRITE_IDLE: 	begin
										if (ram_write_go_new == 1'b1) begin
											loop_new = 0;
											addr_ram_new = initial_write_addr;
											sap_instruction_new = INSTRUCT_RAM;
										
											sap_next_state = MEM_WRITE_DATA;
										end
//										if (sap_start == 0)
//                                        sap_next_state = SAP_IDLE;  
									end
					
				MEM_WRITE_DATA:		begin
//										internal_data_port_new = (MAX_INPUT_DATA_SIZE-2*RAM_DATA_WIDTH-RAM_ADDR_WIDTH)'({ram_control_new, ram_input_new[RAM_DATA_WIDTH-1:0], addr_ram_new});
										internal_data_port_new = (MAX_INPUT_DATA_SIZE)'({ram_control_new, ram_input_new[RAM_DATA_WIDTH-1:0], addr_ram_new});
										ram_input_new = ram_input_new >> RAM_DATA_WIDTH;
										addr_ram_new = addr_ram_new + 'h1;
//										write_start = 1;
										loop_new = loop_new + 1;
										sap_next_state = MEM_WRITE_REPEAT;
									end
				MEM_WRITE_REPEAT :  begin
										write_start = 1;
										if (write_complete == 1) begin
											write_start = 0;
											if (ram_read_go_new == 1'b1) 
												sap_next_state = MEM_READ_DATA;
											else if (loop_new <= (ram_data_size/RAM_DATA_WIDTH)-1)
												sap_next_state = MEM_WRITE_DATA;
//											else if (ram_write_go == 1'b0)
											else if (loop_new > (ram_data_size/RAM_DATA_WIDTH)-1 && poca_data_write_loop_new < poca_asset_size/AES_TEXT_KEY_SIZE)
												sap_next_state = POCA_WRITE_CONTROL_RAM;
											else begin
												ram_write_go_new = 1'b0;
//												sap_operation_done = 1;
//												sap_next_state = MEM_WRITE_IDLE;
												sap_next_state = SAP_SEC_NS_DONE;
											end
										end
									end
// To read from the memory the following signals need the data. The FSM state that will read from the memory needs to define these signals similarly.					
//                MEM_CONTROL_READ : 	begin
//										initial_write_addr = 0;
//										ram_input_new = 128'h0;
//										ram_control_new = 32'h5;
//										ram_read_go_new = 1'b1;
//										ram_data_size = 'd128;
//										sap_next_state = MEM_READ_IDLE; 
//									end
				MEM_READ_IDLE :		begin
										if (ram_read_go_new == 1'b1) begin
											ram_write_go_new = 1'b1;
											sap_next_state = MEM_WRITE_IDLE;
										end
										if (sap_start == 0)
                                        sap_next_state = SAP_IDLE; 
									end
				MEM_READ_DATA: 		begin
										read_start = 1; 
										if (data_input_ready == 1) begin
											read_start = 0; 
											if (loop_new <= (ram_data_size/RAM_DATA_WIDTH)-1)
												sap_next_state = MEM_WRITE_DATA;
											else begin
												ram_write_go_new = 1'b0;
												ram_read_go_new = 1'b0;
//												sap_operation_done = 1;
//												sap_next_state = MEM_READ_IDLE;
												sap_next_state = SAP_SEC_NS_DONE;
											end
										end
									end

				SEC_PUF_NONCE_GEN : begin
										internal_data_port_new = host_data;
										sap_instruction_new = INSTRUCT_TRNG;
										write_start = 1;
										if (write_complete == 1) begin
											write_start = 0;
											sap_next_state = SEC_PUF_NONCE_READ; 
										end
									end
				SEC_PUF_NONCE_READ : begin
										
										read_start = 1;
										if (data_input_ready == 1) begin
											read_start = 0;
											sap_next_state = SEC_PUF_WRITE;  
										end
									 end
				SEC_PUF_WRITE : begin
																				
										sap_instruction_new = INSTRUCT_PUF;
										write_start = 1;
										if (write_complete == 1) begin
											write_start = 0;
											sap_next_state = SEC_PUF_READ;
										end
								end
				SEC_PUF_READ : 	begin
										
										read_start = 1;
										if (data_input_ready == 1) begin
											read_start = 0;
											sap_next_state = SEC_PUF_HASH_WRITE;  
										end
								end
								
				SEC_PUF_HASH_WRITE : 	begin
											sap_instruction_new = INSTRUCT_HASH;
											internal_data_port_new = (MAX_INPUT_DATA_SIZE)'({2{trng_output}}^puf_response_output);
											write_start = 1;
											if (write_complete == 1) begin
												write_start = 0;
												sap_next_state = SEC_PUF_HASH_READ;
											end
										end
				SEC_PUF_HASH_READ : 	begin
											read_start = 1;
											if (data_input_ready == 1) begin
												read_start = 0;
//												sap_operation_done = 1;
												sap_next_state = SAP_SEC_NS_DONE; 
//												if (sap_start == 0)
//													sap_next_state = SAP_IDLE; 
											end
										end	
				SAP_SEC_NS_DONE:  begin
//                                    read_start = 0;
                                    sap_operation_done = 1;
                                    if (sap_start == 0)
                                        sap_next_state = SAP_IDLE;  
                                    else 
                                        sap_next_state = SAP_SEC_NS_DONE; 
                              end 
				
				POCA_START :  begin
									if (test_mode == 1)
									begin
										poca_go_new = 1;
										initial_write_addr = 0;
										poca_data_write_loop_new = 0; 
										if (poca_response_ready == 1)
											sap_next_state = POCA_SEC_KEY_GEN; 
									end
							  end
				POCA_SEC_KEY_GEN : begin
										if (poca_public_key_hsm_received == 1)
										begin
											if (poca_secret_key_ready)
												sap_next_state = POCA_DECRYPT_ASSET_WRITE; 
										end	
										else 
											sap_next_state = POCA_SEC_KEY_GEN; 
									end
				POCA_DECRYPT_ASSET_WRITE : begin
												if (poca_data_received)
												begin
													internal_data_port_new = {poca_key_chip, host_data[AES_TEXT_KEY_SIZE-1:0]};
													sap_instruction_new = INSTRUCT_DECRPT;
													write_start = 1;
													if (write_complete == 1) 
													begin
														write_start = 0;
														sap_next_state = POCA_DECRYPT_ASSET_READ; 
													end
												end
											end
				POCA_DECRYPT_ASSET_READ: begin
											read_start = 1;
											if (data_input_ready == 1) begin
												read_start = 0;
												sap_next_state = POCA_WRITE_ASSET_RAM;  
											end
										 end
										 
				POCA_WRITE_ASSET_RAM : begin						 
										   
									     ram_input_new = decrypted_output;
									     ram_control_new = 32'h3;
									     ram_write_go_new = 1'b1;
									     ram_data_size = AES_TEXT_KEY_SIZE;
									     sap_next_state = MEM_WRITE_IDLE; 
										end
										
				POCA_WRITE_CONTROL_RAM : begin
											initial_write_addr = initial_write_addr + AES_TEXT_KEY_SIZE/DATA_BUS_WIDTH; 
											poca_data_write_loop_new = poca_data_write_loop_new + 'h1;
											if (poca_data_write_loop_new < poca_asset_size/AES_TEXT_KEY_SIZE)
												sap_next_state = POCA_DECRYPT_ASSET_WRITE; 
											else 
												sap_next_state = SAP_SEC_NS_DONE; 
										end
            endcase
        end
		
		
		
		
	
	top_poca_primitive_v1 #(
	  .KEY_SIZE(POCA_KEY_SIZE), 
	  .MULT_SIZE(POCA_MULT_SIZE),
	  .HASH_SIZE(POCA_HASH_SIZE),
	  .SEED_SIZE(POCA_SEED_SIZE),
	  .SIGN_SIZE(POCA_SIGN_SIZE),
	  .CYCLE_SIZE(POCA_CYCLE_SIZE)
	) poca (
		.clk(clk),
		.rst(!rstn),
		.dh_G(poca_base_point_g),
		.seed(poca_signature_gen_seed),
		.cycle(poca_signature_gen_capture_cycle),
		.public_key_hsm(poca_public_key_hsm),
		.public_key_hsm_received(poca_public_key_hsm_received),
		.go(poca_go_new),
		.response(poca_response),
		.secret_key_ready(poca_secret_key_ready),
		.response_ready(poca_response_ready),
		.secret_key_chip(poca_key_chip)
	);
	
endmodule
