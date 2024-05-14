

`timescale 1ns / 1ps
module Converter #(parameter XLEN=32)
                        (input [XLEN-1:0]A,
                         output  [XLEN-1:0] result);

reg [23:0] first_comp; 
real result;

 assign result = (2**(A[30:23]-127))*($itor({1'b1,A[22:0]})/2**23)*((-1)**(A[31]));

endmodule


