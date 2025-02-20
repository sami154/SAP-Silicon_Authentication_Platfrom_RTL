module add_generator #(
	parameter CHALLENGE_SIZE = 32,
			  SIGN_SIZE = 256,
			  HELPER_DATA_SIZE = 96,
			  MEM_SIZE_PER_ADDR = 8
			  
) (

	input wire [CHALLENGE_SIZE-1:0] addr,
	input wire clk,
	input wire rst,
	input wire en,
	input wire load,
	input wire [0:HELPER_DATA_SIZE-1] i_helper,
	output wire [SIGN_SIZE-1:0] puf_signature_out,
	output wire done

);
//	localparam NO_ROUND = $clog2(SIGN_SIZE)+2;
	localparam NO_ROUND = SIGN_SIZE/MEM_SIZE_PER_ADDR;
	reg [CHALLENGE_SIZE-1:0] cnt;
	reg [$clog2(NO_ROUND)+1:0] cnt1, temp_cnt1;
	wire puf_done;
	reg [SIGN_SIZE-1:0] puf_signature;
	wire [MEM_SIZE_PER_ADDR-1:0] puf_sig_sram;
	wire [SIGN_SIZE+8-1:0] puf_signature_ecc_out;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cnt <= 0;
			cnt1 <= 0;
			temp_cnt1 <= 0;
		end
		else 
		begin
			if (load == 1 & en == 0)
				begin
					cnt <= addr;
				end
			else if (load == 0 & en == 0) begin
				temp_cnt1 <= 0; 
				cnt1 <= 0;
			end
			else if (load == 1 & en == 1 & puf_done != 1)
				begin
					cnt <= cnt+1;
					temp_cnt1 <= temp_cnt1+1;
						if (temp_cnt1 == NO_ROUND) begin
							cnt1 <= temp_cnt1;
						end
				end
				
				

		end
	end
	
	
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
//			puf_done <= 0;

			puf_signature <= 0;
		end
		else 
		begin
			if (cnt1 != NO_ROUND) begin
				puf_signature <= {puf_signature[247:0], puf_sig_sram};
				
				
//				if (cnt1 == SIGN_SIZE) begin
//					cnt1 <= 0;
//					puf_done <= 1'b1;
					
//				end
			end 
//			else 
				
//			else begin
//				puf_done <= 1'b0;
//			end
		end
	end
	assign puf_done = (cnt1 == NO_ROUND) ? 1'b1 : 1'b0;
/*	always @(posedge clk or posedge rst) begin
		if (rst) begin
			puf_done <= 0;
		end
		else 
		begin
			if (cnt1 == SIGN_SIZE) 
				begin
					puf_done <= 1'b1;
				end
			else 
					puf_done <= 1'b0;
		end

	end
*/	
	single_port_ram ram1 (
		.addr1(cnt),
		.re(en), 
		.clk(clk),
		.q(puf_sig_sram)
	);
	
	decoder_top ecc1 (
	
    .i_Data({8'h0,puf_signature}),
    .i_helper(i_helper),
    .clk(clk),
    .enable(puf_done),
    .reset(rst),
    .done(done),
    .o_Data(puf_signature_ecc_out)
	
	);
	
	assign puf_signature_out = puf_signature_ecc_out[255:0];
	
	
endmodule

