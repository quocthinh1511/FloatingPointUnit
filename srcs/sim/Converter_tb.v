`timescale 1ns / 1ps
`include "../sources/fpu.v"

module Converter_tb #(parameter XLEN = 32);
reg [XLEN-1:0] A,B;
wire [31:0] result;
wire   result_float;

reg [1:0] op;
FPU F_Add (.A(A),.B(B),.result(result), .result_float(result_float), .op(op));

initial  
begin

A = 32'b0_10000000_10011001100110011001100;  // 3.2
B = 32'b0_10000001_00001100110011001100110; 
op =2'b00;  // 4.2
#20
A = 32'b11000010100011000011111011111010;  // 70.123
B = 32'b11000001111100011001100110011010; 
op =2'b01;  // -30.2
#20
A = 32'b1_01111110_00000000000000000000000;  // -0.5
B = 32'b0_10000001_10011001100110011001100; 
op =2'b10;  // -6.4
#20
A = 32'b11000001011100011001100110011010;  // 15.1
B = 32'b01000000000100110011001100110011;
op =2'b11;   //  2.3
// #20
// A = 32'h4034b4b5;
// B = 32'hbf70f0f1;
end

initial
begin
#20
$display("Result Add : %b",result);
$display("Expected Value : %f ",result_float);
#20
$display("Result Subtract: %b",result);
$display("Expected Value : %f ",result);
#20
$display("Result Mul: %b",result);
$display("Result : %f",result_float);

#20
$display("Expected Value Div: %b",result);
$display("Expected Value : %f ",result_float);
#20


$finish;
end
endmodule