`timescale 1ns/1ps

module top_poca_primitive_v1 #(
	parameter   KEY_SIZE = 128,
				MULT_SIZE = 283,
				HASH_SIZE = 256,
				SEED_SIZE = 128,
				SIGN_SIZE = 128,
				CYCLE_SIZE = 32
	)(
		input wire clk,rst,
		input wire [MULT_SIZE-1:0] dh_G,
		input wire [SEED_SIZE-1:0] seed,
		input wire [CYCLE_SIZE-1:0] cycle,
		input wire [MULT_SIZE-1:0] public_key_hsm,
		input wire public_key_hsm_received,
		input wire go,
		output wire [MULT_SIZE+HASH_SIZE-1:0] response,
		output reg secret_key_ready,
		output wire response_ready,
		output reg [HASH_SIZE-1:0] secret_key_chip
	);
	
	reg [MULT_SIZE-1:0] dh_G_reg;
	reg [MULT_SIZE+HASH_SIZE-1:0] signature_reg;
	reg seed_load, cycle_load; 
    	wire start_cnt;
	reg trng_en;
	reg [MULT_SIZE-1:0] private_key_reg;
	reg dh_rst;
	reg [MULT_SIZE-1:0] public_key_reg;
	reg [HASH_SIZE-1:0] hash_public_key_reg;
//	reg [HASH_SIZE-1:0] secret_key_chip;
	reg hash_init;
	reg secret_key_ready_delay_1, secret_key_ready_delay_2, public_key_ready;
	
	wire signature_done;
	wire [SEED_SIZE-1:0] signature_response;
	wire trng_done;
	wire [KEY_SIZE-1:0] private_key;
	wire dh_done;
	wire [MULT_SIZE-1:0] dh_out;
	wire [HASH_SIZE-1:0] hash_out;
	wire hash_done;
	wire [MULT_SIZE+HASH_SIZE-1:0] concate;
	wire [MULT_SIZE-1:0] mult_input_1;
	wire ready;
	wire secret_key_ready_cntl;
	localparam 	state_0 = 4'd0,
			state_1 = 4'd1,
			state_2 = 4'd2;
		
	reg [1:0] state, next_state;


	
	//singature generation control 
	always @(posedge clk) begin
		if (rst == 1) begin
			seed_load <= 1;
			cycle_load <= 1;
		//	start_cnt <= 0;
		end
			

		else begin
		
			if (go == 1 && signature_done != 1) begin
				seed_load <= 0;
				cycle_load <= 0;
			//	start_cnt <= 1;
			end	
			/* else 
				start_cnt <= 0; */
		
		end
	
	end
	assign start_cnt = (rst != 1 && go == 1 && signature_done != 1) ? 1 : 0;
	//trng controll signal
	
	always @(posedge clk) begin
		if (rst == 1)
			trng_en <= 0;
		else begin 
			if (go == 1 && trng_done != 1)
				trng_en <= 1;
			else 
				trng_en <= 0;
		end
	end
	
	
	//Multiplier control
	// HSM public key control and secret key generation
	always @(posedge clk) begin
		if (rst == 1)
			state <= state_0;
		else 
			state <= next_state;
	end
	
	always @(*) begin
			next_state = state;
			dh_rst = 1;
			case(state)
				state_0: begin

								if (dh_done == 1)
										next_state = state_1;
								else begin
									if (trng_done == 1) begin
										dh_rst = 0;
										next_state = state_0;
									end
								end	
						end
						
				state_1: begin 	
								if (public_key_hsm_received == 1) begin
									dh_rst = 1;
									next_state = state_2;
								end
								else 
									next_state = state_1;
						end
				state_2: begin 	
								dh_rst = 0;
								next_state = state_2;
								
						end
			endcase
	
	end
		

	//public key register
	always @(posedge clk) begin
		if(rst == 1) begin
			public_key_reg <= 1'b0;
			public_key_ready <= 1'b0;
		end
		else if (dh_done == 1 && public_key_hsm_received != 1) begin
			public_key_reg <= dh_out;
			public_key_ready <= 1'b1;
		end
	
	end
	
	//Hash of public key
	always @(posedge clk) begin
		if(rst == 1) begin
			hash_public_key_reg <= 0;
			secret_key_chip <= 0;
		end
		else begin
			if (hash_done == 1 && public_key_hsm_received != 1)
				hash_public_key_reg <= hash_out;
			else if (secret_key_ready_cntl == 1)
			
				secret_key_chip <= hash_out;
				

		end
	end
	
	
	// final output
	assign concate = {public_key_reg, hash_out};
	assign response = (hash_done == 1 && signature_done == 1 && public_key_hsm_received != 1) ?  (concate ^ {5{signature_response}}) : 0;
	assign response_ready = (hash_done == 1 && signature_done == 1 && public_key_hsm_received != 1) ?  1 : 0;
	assign mult_input_1 = {public_key_hsm_received == 1} ? public_key_hsm : dh_G;
	assign secret_key_ready_cntl = {secret_key_ready_delay_2 == 1 && hash_done == 1} ? 1 : 0; //For FPGA implementation
	// Structural instantiation
	top_auth_128 uut1 (
		.out_final(signature_response), 
		.clk(clk), 
		.rst(rst), 
		.load(seed_load), 
		.seed_top(seed), 
		.cycle(cycle), 
		.cnt_load(cycle_load), 
		.cnt_done(signature_done), 
		.start_cnt(start_cnt)
	);

	ro_trng1 trn_uut2(
		.clk(clk), 
		.rst(rst),
		.en1(trng_en),
		.out2(private_key),
		.done_1(trng_done)
	
	);

	serial_multiplier_283 dh1 (
        .clk(clk), 
		.reset(dh_rst), 
		.ax(mult_input_1), 
		.bx({155'b0, private_key}), 
		.done(dh_done), 
		.cx(dh_out)

	);
	sha256_core sha1 (
                  .clk(clk),
                  .reset_n(!rst),
                  .init(hash_init),
                  .next(1'b0),
                  .block({229'b0, dh_out}),
                  .ready(ready),
                  .digest(hash_out),
                  .digest_valid(hash_done)
                 );
				 
				 
	always @(*) begin
		if (dh_done == 1)
			hash_init <= 1; 
		else if (hash_done == 1)
			hash_init <= 0;
		else 
		    hash_init <= 0;
	end
	
	
	always @(posedge clk) begin
		if (rst == 1)
			secret_key_ready_delay_1 <= 0;
		else if (public_key_hsm_received == 1 && dh_done == 1 && hash_done == 1)
			secret_key_ready_delay_1 <= 1;
	
	end
	
	always @(posedge clk) begin
		if (rst == 1)
			secret_key_ready_delay_2 <= 0;
		else if (secret_key_ready_delay_1 == 1)
			secret_key_ready_delay_2 <= 1;
	
	end
	
	always @(posedge clk) begin
		if (rst == 1)
			secret_key_ready <= 0;
		else if (secret_key_ready_cntl == 1)
			secret_key_ready <= 1;
	
	end


endmodule

