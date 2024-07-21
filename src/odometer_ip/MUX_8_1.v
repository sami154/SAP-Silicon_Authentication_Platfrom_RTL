`timescale 1ns/1ps

module MUX_8_1(a, b, c, d, e, f, g, h,  sel, out);

  input a, b, c, d, e, f, g, h;
  input [2:0] sel;
  output reg out;

  always@(*) begin
    case (sel)
      4'b000: out = a;
      4'b001: out = b;
      4'b010: out = c;
      4'b011: out = d;
      4'b100: out = e;
      4'b101: out = f;
      4'b110: out = g;
      4'b111: out = h;
    endcase
  end

endmodule
