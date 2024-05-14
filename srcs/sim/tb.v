`timescale 1ns / 1ps
`include "../sources/Adder.v"

module Converter_tb #(parameter XLEN = 32);
reg [XLEN-1:0] A,B;
wire [31:0] result;
wire [31:0] result_float;
real value;
real valueA;
real valueB;
Adder F_Add (.A(A),.B(B),.result(result));

initial  
begin

A = 32'b0_10000000_10011001100110011001100;  // 3.2
B = 32'b0_10000001_00001100110011001100110;  // 4.2
#20
A = 32'b11000010100011000011111011111010;  // 70.123
B = 32'b11000001111100011001100110011010;  // -30.2
#20
A = 32'b1_01111110_00000000000000000000000;  // -0.5
B = 32'b0_10000001_10011001100110011001100;  // -6.4
#20
A = 32'b11000001011100011001100110011010;  // 15.1
B = 32'b01000000000100110011001100110011;  //  2.3

end

initial
begin

valueA =(2**(A[30:23]-127))*($itor({1'b1,A[22:0]})/2**23)*((-1)**(A[31]));
valueB =(2**(B[30:23]-127))*($itor({1'b1,B[22:0]})/2**23)*((-1)**(B[31]));
value =(2**(result[30:23]-127))*($itor({1'b1,result[22:0]})/2**23)*((-1)**(result[31]));
$display("Result cua %f + %f la : %f",valueA, valueB, value);
#20
valueA =(2**(A[30:23]-127))*($itor({1'b1,A[22:0]})/2**23)*((-1)**(A[31]));
valueB =(2**(B[30:23]-127))*($itor({1'b1,B[22:0]})/2**23)*((-1)**(B[31]));
value =(2**(result[30:23]-127))*($itor({1'b1,result[22:0]})/2**23)*((-1)**(result[31]));
$display("Result cua %f + %f la : %f",valueA, valueB, value);
#20
valueA =(2**(A[30:23]-127))*($itor({1'b1,A[22:0]})/2**23)*((-1)**(A[31]));
valueB =(2**(B[30:23]-127))*($itor({1'b1,B[22:0]})/2**23)*((-1)**(B[31]));
value =(2**(result[30:23]-127))*($itor({1'b1,result[22:0]})/2**23)*((-1)**(result[31]));
$display("Result cua %f + %f la : %f",valueA, valueB, value);
// $display("Expected Value : %f Result : %f",result_float);

#20
valueA =(2**(A[30:23]-127))*($itor({1'b1,A[22:0]})/2**23)*((-1)**(A[31]));
valueB =(2**(B[30:23]-127))*($itor({1'b1,B[22:0]})/2**23)*((-1)**(B[31]));
value =(2**(result[30:23]-127))*($itor({1'b1,result[22:0]})/2**23)*((-1)**(result[31]));
$display("Result cua %f + %f la : %f",valueA, valueB, value);
$finish;
end
endmodule