`timescale 1ns / 1ps
module ro_trng(

input clk, rst,
input go,
output reg [127:0] rand_out,
output reg done

);

reg [8:0] cnt;
//wire out2;
wire [7:0] out1;
//wire [9:0] out2;
wire temp;
reg en;
//XOR Tree
assign temp = out1[0]^out1[1]^out1[2]^out1[3]^out1[4]^out1[5]^out1[6]^out1[7];

always @(posedge clk) begin
    if(rst == 1) begin
        en <= 0;
    end
    else if (go == 1) begin
        en <= 1;
   
    end
    else if (done == 1) begin
        en <= 0;    
    end
end
always @(posedge clk)
begin
    if (rst == 1) begin
        cnt <= 0;
        done <= 0;
     end
    else if ( en == 1) begin
        cnt <= cnt+1;
            if (cnt == 200) begin
                cnt <= 0;
                done <= 1;
            end
     end
end

always @(posedge clk)
begin
    if (rst == 1)
        rand_out   <= 0;
    else if (en == 1 && done != 1)
       // rand_out <= {temp,rand_out[127:1]};
		//out2 <= 128'h06759EE04673F503054044091165C108;
		//out2 <= 128'd5000;
		
		//out2 <= 128'hc518e42402d62b848f554fa25b844433;
		//out2 <= 128'ha0228a8a6ea6ddd86a7d4639daec52fd;
		//out2 <= 128'h9aacecef7085b3bedff2dfc5eb90238f;
		//out2 <= 128'h6a59aa236afc6645e301daaa190f58b4;
		//out2 <= 128'h03acd167b74895d141b9922c9c802e03;
		//out2 <= 128'hf14b4ce10cdfa932b4d9cf0a55a7b28e;
		//out2 <= 128'hdfe621f3f4c1b215b68af47fd8070ffb;
		//out2 <= 128'hfaeb9d031c2b4b064b2a2d50907b8535;
		//out2 <= 128'h1db1dfd11c0bfd196e31d81e59148c93;
		//out2 <= 128'habef760ec484a449ad764aa8d2d042c4;
		
		//out2 <= 128'hb2971dbaa13b88de3757f0fb19d5ac9e; 
		//out2 <= 128'h9ac1a388cb07794869f7db9c019ad07d; 
		//out2 <= 128'hd6cb8608929680293b2cf277ea93afa2; 
		//out2 <= 128'hfba254a2265038049a89633ef9d0675b; 
		//out2 <= 128'h3ffd989e1e133eb211a95884075671cb; 
		//out2 <= 128'hbe53c336791942b143d9775e7226e5a9; 
		//out2 <= 128'ha7acae2bbe5fe7c67f70b3906ee264db; 
		//out2 <= 128'ha71700c4ff44afcb5392c48d1e6b59dc; 
		//out2 <= 128'h66e52dcef07b39978e2c0f23a9e5c45b; 
		rand_out <= 128'h3dd16a0a3554db070e0b00ce143b7344;
end

//    genvar i;

//	generate	
//		for(i=0; i<8; i= i+1) begin : loop	
//			ro ro_inst (.en(en), .roout(out1[i])); //ro output in out1
//		end
//	endgenerate   
	
endmodule
