`timescale 1ns / 1ps
module ro_trng1(

input clk, rst,
input en1,
output reg [127:0] out2,
output reg done_1

);

reg [8:0] cnt_1;
//wire out2;
wire [7:0] out_1;
//wire [9:0] out2;
wire temp1;
//XOR Tree
assign temp1 = out_1[0]^out_1[1]^out_1[2]^out_1[3]^out_1[4]^out_1[5]^out_1[6]^out_1[7];


always @(posedge clk)
begin
    if (rst == 1) begin
        cnt_1 <= 0;
        done_1 <= 0;
     end
    else if ( en1 == 1) begin
        cnt_1 <= cnt_1+1;
            if (cnt_1 == 200) begin
                cnt_1 <= 0;
                done_1 <= 1;
            end
     end
end

always @(posedge clk)
begin
    if (rst == 1)
        out2 <= 0;
    else if (en1 == 1 && done_1 != 1)
        //out2 <= {temp1,out2[127:1]};
		//out2 <= 128'h06759EE04673F503054044091165C108;
		//out2 <= 128'd5000;
	out2 <= 128'h3dd16a0a3554db070e0b00ce143b7344;
end
/*
  genvar i;

	generate	
		for(i=0; i<8; i= i+1) begin :loop	
			ro ro1 (.en(en), .roout(out_1[i])); //ro output in out_1
		end
	endgenerate  
*/
	
endmodule
