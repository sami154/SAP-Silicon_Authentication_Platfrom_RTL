`timescale 1ns/1ps
module tb_top_poca_primitive_v1();
	
	localparam   KEY_SIZE = 128,
				 MULT_SIZE = 283,
				 HASH_SIZE = 256,
				 SEED_SIZE = 128,
				 SIGN_SIZE = 128,
				 CYCLE_SIZE = 32;
	
	
	//integer  f;
	reg clk,rst;
	reg public_key_hsm_received;
	reg [MULT_SIZE-1:0] dh_G;
	reg [SEED_SIZE-1:0] seed;
	reg [CYCLE_SIZE-1:0] cycle;
	reg [MULT_SIZE-1:0] public_key_hsm;
	reg go;
	wire [MULT_SIZE+HASH_SIZE-1:0] response;
	wire secret_key_ready;
	wire response_ready;
	 always #10 clk = ~clk;
	
	
	/* initial begin
		f = $fopen("output.txt","a");
	end */
	
	initial begin
	rst = 1;
	clk = 0;
	seed = 0;
	dh_G = 0;
	go = 0;
	cycle = 0;
	public_key_hsm_received = 0;
	//file1 = $fopen("nlfsr_out.txt","w");
	#100;
	rst = 0;
	//f = $fopen("results_trng.txt","a");
	#100;
	seed = 'h60b998885e75315b3866889c53e92dfe ;
	$display("The challenge TP1: %h\n", seed);
	//seed = 'hd1de90088a228fd3c64efd808d8b671d;
	//seed = 'haa846c9106022d0bff377d89e990b1d6;
	//seed = 'h12215b4406ea6391cb93d851498e075a;
	//seed = 'h8adfa57f9d694be42b25e3591b6952d2;
	//seed = 'h8d5ab12feb373e73d59599bf3b9a3d06;
	//seed = 'h23595567d1fea7229ce84cf75481b193;
	//seed = 'hd91e636d71a6ad2edd9ec9aec57bb283;
	//seed = 'h22d44e9902016a114ae23961c9c6bd3d;
	//seed = 'hde5c6084b2f69a77c3d5b2b0fbf99bd9;
	//seed = 'h2e0f3b429e60cd2ee0cf93b1c670f6e3;
	cycle = 32'h000001F4;
	$display("The challenge C1: %h\n", cycle);
	dh_G = 283'h503213f78ca44883f1a3b8162f188e553cd265f23c1567a16876913b0c2ac2458492836;
	$display("The base point for Elliptic Curve: %h\n", dh_G);
	//dh_G = 283'd5000;
	#40;
	go = 1;
	wait(uut.trng_done == 1);
	$display ("Private Key of the Chip: %h\n", uut.private_key);
	wait(uut.public_key_ready == 1);
	$display ("Public Key of the Chip: %h\n", uut.public_key_reg);
	wait(uut.signature_done == 1);
	$display ("Signature of the Chip: %h\n", uut.signature_response);
	wait(uut.hash_done == 1);
	$display ("Hash of the Public Key: %h\n", uut.hash_out);
	wait(response_ready == 1);
	$display ("POCA response: %h\n", response);
	//$display ("concate: %b\n", uut.concate);
/* 	$fwrite(f,"%b \t %b\n", uut.concate, response); 
	$fclose(f); */
	//$display ("signature response: %h\n", uut.signature_response);
	
	#200;
	//public_key_hsm = 283'h5efbeaca909fac9b5efbeaca81110d31e3895975909fac9bbd5893d6f0423345739ea4e7;
	public_key_hsm = 283'haab455e467872ea351d183201513207c6387517af45728b90595f6cb28f883355e52dc1;
	$display ("Public Key of the HSM: %h\n", public_key_hsm);
	public_key_hsm_received = 1;
	wait(secret_key_ready == 1);
	$display ("Secret Key of the Chip & HSM: %h\n", uut.secret_key_chip );
	#200;
	 
	$finish;
	//$display ("hash_out_1sr: %h\n", uut.hash_out);
	
	end
	
	/* initial begin
		$fclose(f);  
	end */

top_poca_primitive_v1 #(
	
	.KEY_SIZE(KEY_SIZE),
	.MULT_SIZE(MULT_SIZE),
	.HASH_SIZE(HASH_SIZE),
	.SEED_SIZE(SEED_SIZE), 
	.SIGN_SIZE(SIGN_SIZE), 
   .CYCLE_SIZE(CYCLE_SIZE)
	
	) uut (
	.clk(clk),
	.rst(rst),
	.dh_G(dh_G),
	.seed(seed),
	.cycle(cycle), 
	.go(go),
	.response(response),
	.public_key_hsm_received(public_key_hsm_received),
	.public_key_hsm(public_key_hsm),
	.secret_key_ready(secret_key_ready),
	.response_ready(response_ready)
	/* .secret_key(secret_key),
	.trng_out(trng_out) */


);




endmodule
