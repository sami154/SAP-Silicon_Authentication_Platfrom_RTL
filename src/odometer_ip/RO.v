`timescale 1ns/1ps

module RO_ODO #(parameter NO_STAGES=21, parameter INV_DELAY_ns=1)
           (input wire En,output wire RO_out);    
    
    wire [NO_STAGES:0] wi;
    assign wi[0] = En ? wi[NO_STAGES] : 0;
    assign RO_out = En ? wi[NO_STAGES] : 0;
    genvar i;
    generate
        for(i = 0; i < NO_STAGES; i = i+1) begin
            if(i==0) begin
                not #(INV_DELAY_ns) (wi[i+1], wi[0]);
                end                    
            else begin
                not #(INV_DELAY_ns) (wi[i+1], wi[i]); 
                end
        end
    endgenerate 
    
endmodule  