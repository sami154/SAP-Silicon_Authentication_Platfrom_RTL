`timescale 1ns/1ps
module counter (clk, rst, cycle, cnt_done, cnt_load, start_cnt);

input clk, rst, cnt_load, start_cnt;
input [31:0] cycle;
output reg cnt_done;
reg [31:0] cnt;

always @(posedge clk)
begin
	if (rst == 1)
		begin
			cnt <= 0;
			cnt_done <= 0;
		end
	else if (cnt_load == 1)
		cnt <= cycle;
	else if (start_cnt == 1)
		begin
			cnt <= cnt - 1;
				if (cnt == 1)
					cnt_done <= 1;
		end
	

end


endmodule