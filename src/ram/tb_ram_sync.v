module tb_ram_sync ();


	localparam ADDR_WIDTH = 3;
	localparam DATA_WIDTH = 32;
	localparam DEPTH = 8;
	
	reg clk;
	reg [ADDR_WIDTH-1:0] addr;
	reg [DATA_WIDTH-1:0] data;
	reg cs;
	reg we;
	reg oe;
	wire [DATA_WIDTH-1:0] ram_output;
	integer i;
	
	always #10 clk = ~clk;
	
	initial begin
		clk = 1;
		addr = '0;
		data = '0;
		cs = 0;
	    we = 0;
	    oe = 0;
		
		#40;
		cs = 1;
	    we = 1;
		

		for ( i = 0; i < DEPTH; i = i+1) begin
			addr = i;
						
			data = $random;
			@(posedge clk);
		end
		
		#100;
		
		cs = 1;
	    we = 0;
		oe = 1;
		
		#40;
		
		for ( i = 0; i< DEPTH; i= i+1) begin

				addr = i;
				@(posedge clk);
				$display ("output %d:\t %h", i, ram_output);
		end
	
	
	
	end
	ram_sync #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) uut (.*);
endmodule