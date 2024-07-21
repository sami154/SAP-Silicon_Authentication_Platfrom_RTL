`timescale 1ns/1ps
module top_auth_128 (out_final, clk, rst, load, cnt_load, seed_top, cycle, cnt_done, start_cnt);

output [127:0] out_final;
input wire load;
input [127:0] seed_top;
input wire clk, rst, start_cnt;
input wire cnt_load;
input [31:0] cycle;
output wire cnt_done;



wire nlfsr_1_out, nlfsr_2_out, nlfsr_3_out, nlfsr_4_out;


nlfsr_128 uut1 (
	.out(nlfsr_1_out), 
	.clk(clk), 
	.rst(rst), 
	.load(load), 
	.seed(seed_top[127:96]), 
	.flip_bit(nlfsr_4_out),
	.state_reg(out_final[127:96]),
	.start_cnt(start_cnt)
);

nlfsr_128 uut2 (
	.out(nlfsr_2_out), 
	.clk(clk), 
	.rst(rst), 
	.load(load), 
	.seed(seed_top[95:64]), 
	.flip_bit(nlfsr_1_out),
	.state_reg(out_final[95:64]),
	.start_cnt(start_cnt)
);

nlfsr_128 uut3 (
	.out(nlfsr_3_out), 
	.clk(clk), 
	.rst(rst), 
	.load(load), 
	.seed(seed_top[63:32]), 
	.flip_bit(nlfsr_2_out),
	.state_reg(out_final[63:32]),
	.start_cnt(start_cnt)
);

nlfsr_128 uut4 (
	.out(nlfsr_4_out), 
	.clk(clk), 
	.rst(rst), 
	.load(load), 
	.seed(seed_top[31:0]), 
	.flip_bit(nlfsr_3_out),
	.state_reg(out_final[31:0]),
	.start_cnt(start_cnt)
);

counter uut5 (
	.cycle(cycle), 
	.clk(clk), 
	.rst(rst), 
	.cnt_done(cnt_done), 
	.cnt_load(cnt_load), 
	.start_cnt(start_cnt)
);


endmodule