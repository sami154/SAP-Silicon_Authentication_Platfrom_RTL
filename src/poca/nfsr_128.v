`timescale 1ns/1ps
module nlfsr_128 (out, clk, rst, load, seed, flip_bit, start_cnt, state_reg );

  output wire out;
  input wire clk, rst, load, flip_bit, start_cnt;
  input [31:0] seed;
  
  
  wire feedback, xored_feedback;
  output reg [31:0] state_reg;
  
  assign feedback = (state_reg[0] ^ state_reg[2] ^ state_reg[6] ^ state_reg[7] ^ state_reg[12] ^ state_reg[17]^ state_reg[20] ^ state_reg[27] ^ state_reg[30] ^ state_reg[3] * state_reg[9] ^ state_reg[12] * state_reg[15] ^ state_reg[4] * state_reg[5] * state_reg[16]);
  assign xored_feedback = feedback ^ flip_bit;
  assign out = state_reg[0];
  
always @(posedge clk, posedge rst)
  begin
    if (rst)
      state_reg <= 0;
	else if (load == 1)
		state_reg <= seed;
    else
	begin
		if (start_cnt == 1)
			state_reg <= {xored_feedback, state_reg[31:1]};
		else 
			state_reg <= state_reg;
	end
  end




endmodule