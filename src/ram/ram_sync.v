module ram_sync #(

	parameter ADDR_WIDTH = 6,
	parameter DATA_WIDTH = 32,
	parameter DEPTH = 64

)
(

	input clk,
	input [ADDR_WIDTH-1:0] addr,
	input [DATA_WIDTH-1:0] data,
	input cs,
	input we,
	input oe,
	output wire [DATA_WIDTH-1:0] ram_output

);

	reg [DATA_WIDTH-1:0] temp_data;
	reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];
	
	always @(posedge clk) begin
	
		if (cs & we)
			mem[addr] <= data;
	end
	
	always @(posedge clk) begin
		if (cs & !we)
			temp_data <= mem[addr];

	end
	assign ram_output = cs & oe & !we ? temp_data : 32'hz;

endmodule