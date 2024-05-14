`timescale 1ns / 1ps
`include "../sources/FP_convert.v"

module Converter_tb #(parameter XLEN = 32);
reg [XLEN-1:0] A;

wire [31:0] result;

FPU_convert F_Add (.A(A),.result(result));

initial  
begin

A = 32'b0_10000000_10011001100110011001100;  // 3.2
#20
A = 32'b11000010100011000011111011111010;  // 70.123
#20
A = 32'b10111101111111000010100010000000;  // -0.5
#20
A = 32'b01000001011100011001100110011010;  // 15.1
#20
A = 32'h4034b4b5;
end

initial
begin
#20
$display("Result : %f",result);
#20
$display("Result : %f",result);
#20
$display("Result : %f",result);
#20
$display("Result : %f",result);
#20
$finish;
end
endmodule