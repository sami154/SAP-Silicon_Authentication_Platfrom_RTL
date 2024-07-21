`timescale 1ns / 1ps

module SN_CDIR_DECODER_tb();
reg clk;
reg [1:0] mode;
wire [7:0] freq_diff;
//wire SN_CDIR_out;
reg [2:0]sel;

parameter NO_STAGES=21;
parameter TIMER=100;
    
SN_CDIR_DECODER #(
                    .NO_STAGES(NO_STAGES),
                    .TIMER(TIMER)
                    ) 
                DUT(
                    .clk(clk),
                    .mode(mode),
                    .ODO_SEL_MUX(sel),          
                    //.SN_CDIR_out(SN_CDIR_out),
                    .freq_diff(freq_diff)
                    );
    
always #5 clk=~clk;

//testbench code
initial begin 
    clk =0;
    sel = 2'b000;
     
    #20 mode = 2'b00;
    #1200 mode =2'b01;
    #1200 mode =2'b10;
    #1200 mode =2'b11;
    #1200 mode =2'b00;
    
    sel = 4'b001;
   
    #20 mode = 2'b00;
    #200 mode =2'b01;
    #200 mode =2'b10;
    #200 mode =2'b11;
    #200 mode =2'b00;
     
    #200    $finish;
end

endmodule
