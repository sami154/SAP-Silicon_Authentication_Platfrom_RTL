module wrapper_puf #(
	parameter CHALLENGE_SIZE = 32,
			  RESPONSE_SIZE = 256,
			  HELPER_DATA_SIZE = 96
			  
) ( 
	input wire [CHALLENGE_SIZE-1:0] CHALLENGE,
	input wire CLK,
	input wire RST,
	input wire INPUT_READY,
	input wire [0:HELPER_DATA_SIZE-1] HELPER_DATA,
	output wire [RESPONSE_SIZE-1:0] PUF_RESPONSE,
	output reg DONE
	
);
	localparam SRAM_DATA_PER_ADDR_SIZE = 8;
	localparam  INIT = 4'd0,
				LOAD = 4'd1,
				ENABLE = 4'd2;
				
				

	reg PUF_LOAD, PUF_EN, NEXT_DONE;
	reg NEXT_PUF_LOAD, NEXT_PUF_EN;
	wire ECC_DONE;
	reg [3:0] STATE, NEXT_STATE;
	
	always @(posedge CLK or posedge RST) begin
		if (RST) begin
			STATE <= INIT;
			PUF_LOAD <= 0;
			PUF_EN <= 0;
			DONE <= 0;
		end
		else begin
			STATE <= NEXT_STATE;
			PUF_LOAD <= NEXT_PUF_LOAD;
			PUF_EN <= NEXT_PUF_EN;
			DONE <= NEXT_DONE;
		end
	end
	always @(*) begin
		NEXT_STATE = STATE;
		NEXT_PUF_EN = PUF_EN;
		NEXT_PUF_LOAD = PUF_LOAD;
		NEXT_DONE = DONE;
		case(STATE) 
			INIT :  begin
						if(INPUT_READY == 1'b1)	begin
							NEXT_DONE = 0;
							NEXT_STATE = LOAD;
						end
						else
							NEXT_STATE = INIT;
					end
			LOAD :  begin
						NEXT_PUF_LOAD = 1'b1;
						NEXT_STATE = ENABLE;
					end
			ENABLE :  begin
						NEXT_PUF_EN = 1'b1;
						if (ECC_DONE == 1'b1) begin
							NEXT_PUF_LOAD = 1'b0;
							NEXT_PUF_EN = 1'b0;
							NEXT_DONE = 1;
							NEXT_STATE = INIT;
						end
					end
		
		endcase
	
	end

/*	always @(posedge CLK or posedge RST) begin
		if (RST) 
			PUF_EN <= 1'b0;
		else begin
			if (INPUT_READY == 1'b1)
				PUF_EN <= 1'b1;
		end
	end
	
	/// PUF control
	always @(posedge CLK or posedge RST) begin
		if (RST) begin
			PUF_LOAD <= 0;
			PUF_EN <= 0;
		end
		else 
			begin
				if (PUF_EN & PUF_LOAD == 0) begin
					PUF_LOAD <= 1;
					
				end
				else if (PUF_EN & PUF_LOAD == 1)
					PUF_EN <= 1;
				else begin
					PUF_LOAD <= 0;
					PUF_EN <= 0;
				end
			end
	
	end
	
*/

	add_generator #( .CHALLENGE_SIZE(CHALLENGE_SIZE),
					 .SIGN_SIZE(RESPONSE_SIZE),
					 .HELPER_DATA_SIZE(HELPER_DATA_SIZE),
					 .MEM_SIZE_PER_ADDR(SRAM_DATA_PER_ADDR_SIZE))
		PUF1 (
					 .addr(CHALLENGE),
					 .clk(CLK),
					 .rst(RST),
					 .en(NEXT_PUF_EN),
					 .load(NEXT_PUF_LOAD),
					 .i_helper(HELPER_DATA),
					 .puf_signature_out(PUF_RESPONSE),
					 .done(ECC_DONE)
			);



endmodule