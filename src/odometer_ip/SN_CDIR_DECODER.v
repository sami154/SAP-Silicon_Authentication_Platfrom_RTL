`timescale 1ns / 1ps
`define INVERTER_DELAY_NS_1 0.20
`define INVERTER_DELAY_NS_2 0.21
`define INVERTER_DELAY_NS_3 0.25
`define INVERTER_DELAY_NS_4 0.27
`define INVERTER_DELAY_NS_5 0.25
`define INVERTER_DELAY_NS_6 0.25
`define INVERTER_DELAY_NS_7 0.22
`define INVERTER_DELAY_NS_8 0.20
`define INVERTER_DELAY_NS_9 0.24
`define INVERTER_DELAY_NS_10 0.26
`define INVERTER_DELAY_NS_11 0.21
`define INVERTER_DELAY_NS_12 0.23
`define INVERTER_DELAY_NS_13 0.27
`define INVERTER_DELAY_NS_14 0.25
`define INVERTER_DELAY_NS_15 0.24
`define INVERTER_DELAY_NS_16 0.20

module SN_CDIR_DECODER 
    ( 
    input wire clk,
    input wire [2:0] ODO_SEL_MUX,
    input wire [1:0] mode,
    //output wire SN_CDIR_out,
    output reg [7:0] freq_diff
    );
    parameter NO_STAGES=21;
    parameter TIMER=100;
    wire MUX_R_out,MUX_S_out;
    reg R_SLEEP,S_SLEEP;
    reg RO_SEL;
    wire cdir_out;
    wire RO_out_1;
    wire RO_out_2;
    wire RO_out_3;
    wire RO_out_4;
    wire RO_out_5;
    wire RO_out_6;
    wire RO_out_7;
    wire RO_out_8;
    wire RO_out_9;
    wire RO_out_10;
    wire RO_out_11;
    wire RO_out_12;
    wire RO_out_13;
    wire RO_out_14;
    wire RO_out_15;
    wire RO_out_16;
    
    wire SN_CDIR_out;
     
  
    reg [7:0] time_cc=0;
    reg [7:0] temp_count1= 8'h00;
    reg[7:0] temp_count2 = 8'h00; 
   
    
    RO_ODO #(.NO_STAGES(NO_STAGES), .INV_DELAY_ns(`INVERTER_DELAY_NS_1))
    ref_ro_1 (.En(R_SLEEP),.RO_out(RO_out_1));
    RO_ODO  #(.NO_STAGES(NO_STAGES), .INV_DELAY_ns(`INVERTER_DELAY_NS_2))
    ref_ro_2 (.En(R_SLEEP),.RO_out(RO_out_2));
    RO_ODO  #(.NO_STAGES(NO_STAGES), .INV_DELAY_ns(`INVERTER_DELAY_NS_3))
    ref_ro_3 (.En(R_SLEEP),.RO_out(RO_out_3));
    RO_ODO  #(.NO_STAGES(NO_STAGES), .INV_DELAY_ns(`INVERTER_DELAY_NS_4))
    ref_ro_4 (.En(R_SLEEP),.RO_out(RO_out_4));
    RO_ODO  #(.NO_STAGES(NO_STAGES), .INV_DELAY_ns(`INVERTER_DELAY_NS_5))
    ref_ro_5 (.En(R_SLEEP),.RO_out(RO_out_5));
    RO_ODO  #(.NO_STAGES(NO_STAGES), .INV_DELAY_ns(`INVERTER_DELAY_NS_6))
    ref_ro_6 (.En(R_SLEEP),.RO_out(RO_out_6));
    RO_ODO  #(.NO_STAGES(NO_STAGES), .INV_DELAY_ns(`INVERTER_DELAY_NS_7))
    ref_ro_7 (.En(R_SLEEP),.RO_out(RO_out_7));
    RO_ODO  #(.NO_STAGES(NO_STAGES), .INV_DELAY_ns(`INVERTER_DELAY_NS_8))
    ref_ro_8 (.En(R_SLEEP),.RO_out(RO_out_8));
        
    RO_ODO  #(.NO_STAGES(NO_STAGES),.INV_DELAY_ns(`INVERTER_DELAY_NS_9))
    stressed_ro_1 (.En(S_SLEEP),.RO_out(RO_out_9));
    RO_ODO  #(.NO_STAGES(NO_STAGES),.INV_DELAY_ns(`INVERTER_DELAY_NS_10))
    stressed_ro_2 (.En(S_SLEEP),.RO_out(RO_out_10));
    RO_ODO  #(.NO_STAGES(NO_STAGES),.INV_DELAY_ns(`INVERTER_DELAY_NS_11))
    stressed_ro_3 (.En(S_SLEEP),.RO_out(RO_out_11));
    RO_ODO  #(.NO_STAGES(NO_STAGES),.INV_DELAY_ns(`INVERTER_DELAY_NS_12))
    stressed_ro_4 (.En(S_SLEEP),.RO_out(RO_out_12));
    RO_ODO  #(.NO_STAGES(NO_STAGES),.INV_DELAY_ns(`INVERTER_DELAY_NS_13))
    stressed_ro_5 (.En(S_SLEEP),.RO_out(RO_out_13));
    RO_ODO  #(.NO_STAGES(NO_STAGES),.INV_DELAY_ns(`INVERTER_DELAY_NS_14))
    stressed_ro_6 (.En(S_SLEEP),.RO_out(RO_out_14));
    RO_ODO  #(.NO_STAGES(NO_STAGES),.INV_DELAY_ns(`INVERTER_DELAY_NS_15))
    stressed_ro_7 (.En(S_SLEEP),.RO_out(RO_out_15));
    RO_ODO  #(.NO_STAGES(NO_STAGES),.INV_DELAY_ns(`INVERTER_DELAY_NS_16))
    stressed_ro_8 (.En(S_SLEEP),.RO_out(RO_out_16));
        
always @(posedge clk)
begin
    case (mode)
        0: begin
            R_SLEEP =1'b0;
            S_SLEEP =1'b0;
            RO_SEL =1'bx;
            end
        1: begin 
            R_SLEEP =1'b0;
            S_SLEEP =1'b1;
            RO_SEL =1'bx;            
            end
        2: begin
            R_SLEEP =1'b1;
            S_SLEEP =1'b1;
            RO_SEL =1'b0;
            end
        3: begin
            R_SLEEP =1'b1;
            S_SLEEP =1'b1;
            RO_SEL =1'b1;
            end
    endcase
end
    
        MUX_8_1 MUX_R(RO_out_1, RO_out_2, RO_out_3, RO_out_4, RO_out_5, 
                      RO_out_6, RO_out_7, RO_out_8, ODO_SEL_MUX, MUX_R_out);
        
         MUX_8_1 MUX_S(RO_out_9, RO_out_10, RO_out_11, RO_out_12, RO_out_13, 
                      RO_out_14, RO_out_15, RO_out_16, ODO_SEL_MUX, MUX_S_out);
                         
        assign SN_CDIR_out = RO_SEL?   MUX_S_out : MUX_R_out;
        
        
        always @(cdir_out)
    begin
    case (mode)
        2:  begin
            time_cc = 0;
            if (time_cc<TIMER && MUX_R_out==1'b1) begin
                    temp_count1 <=temp_count1+1;
                    end         
                time_cc <= time_cc + 1;
            end
        3: begin
            time_cc = 0;
            if (time_cc<TIMER && MUX_S_out==1'b1) begin
                    temp_count2 <=temp_count2+1;
                    end         
                time_cc <= time_cc + 1;
            end
    endcase
        freq_diff <= temp_count1-temp_count2;
        freq_diff <= temp_count1-temp_count2;
end

    assign cdir_out = RO_SEL? MUX_S_out:MUX_R_out;

endmodule