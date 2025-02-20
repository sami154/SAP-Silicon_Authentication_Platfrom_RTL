`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2022 12:03:55 PM
// Design Name: 
// Module Name: sram1
// Project Name: 
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


module single_port_ram
(
	
	input [31:0] addr1,
	input re, clk,
	output reg [7:0] q
);

	// Declare the RAM variable
	
	
	
	// Variable to hold the registered read address
	
	
	always @ (posedge clk)
	begin
	// Write
		if (re)
		begin
		case (addr1)
			32'd00: begin q = 8'ha3; end 
			32'd01: begin q = 8'h0a; end 
			32'd02: begin q = 8'h22; end 
			32'd03: begin q = 8'h3b; end 
			32'd04: begin q = 8'hf7; end 
			32'd05: begin q = 8'h28; end 
			32'd06: begin q = 8'hb1; end 
			32'd07: begin q = 8'hd1; end 
			32'd08: begin q = 8'hb1; end 
			32'd09: begin q = 8'hdf; end 
			32'd10: begin q = 8'hd8; end 
			32'd11: begin q = 8'hdc; end 
			32'd12: begin q = 8'h8a; end 
			32'd13: begin q = 8'hdd; end 
			32'd14: begin q = 8'hd3; end 
			32'd15: begin q = 8'h99; end 
			32'd16: begin q = 8'h2a; end 
			32'd17: begin q = 8'h8b; end 
			32'd18: begin q = 8'h68; end 
			32'd19: begin q = 8'ha2; end 
			32'd20: begin q = 8'hf8; end 
			32'd21: begin q = 8'hff; end 
			32'd22: begin q = 8'hc7; end 
			32'd23: begin q = 8'h41; end 
			32'd24: begin q = 8'he8; end 
			32'd25: begin q = 8'h55; end 
			32'd26: begin q = 8'h02; end 
			32'd27: begin q = 8'h55; end 
			32'd28: begin q = 8'h6f; end 
			32'd29: begin q = 8'h75; end 
			32'd30: begin q = 8'h00; end 
			32'd31: begin q = 8'h4e; end 
			32'd32: begin q = 8'ha3; end 
			32'd33: begin q = 8'h0a; end 
			32'd34: begin q = 8'h22; end 
			32'd35: begin q = 8'h3a; end 
			32'd36: begin q = 8'hf7; end 
			32'd37: begin q = 8'h28; end 
			32'd38: begin q = 8'hb1; end 
			32'd39: begin q = 8'hd1; end 
			32'd40: begin q = 8'hb1; end 
			32'd41: begin q = 8'hdf; end 
			32'd42: begin q = 8'hd8; end 
			32'd43: begin q = 8'hdc; end 
			32'd44: begin q = 8'h8a; end 
			32'd45: begin q = 8'hdd; end 
			32'd46: begin q = 8'hd3; end 
			32'd47: begin q = 8'h99; end 
			default: begin q = 8'h00; end 
		endcase
	
		end
	end
	
	
endmodule



