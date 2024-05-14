`timescale 1ns / 1ps
// `include "../sources/Multiplication.v"
// `include "../sources/Adder.v"
module FloatingDivision#(parameter XLEN=32)
                        (input [XLEN-1:0]A,
                         input [XLEN-1:0]B,
                         input clk,
                         output overflow,
                         output underflow,
                         output exception,
                         output [XLEN-1:0] result);
                         
reg [23:0] A_Mantissa,B_Mantissa;
reg [22:0] Mantissa;
wire [7:0] exp;
reg [23:0] Temp_Mantissa;
wire [7:0] A_Exponent,B_Exponent,Temp_Exponent,diff_Exponent;
wire [7:0] Exponent;
reg [7:0] A_adjust,B_adjust;
reg A_sign,B_sign,Sign;
reg [32:0] Temp;
wire [31:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7,debug;
wire [31:0] reciprocal;
wire [31:0] x0,x1,x2,x3;
reg [6:0] exp_adjust;
reg [XLEN-1:0] B_scaled; 
reg en1,en2,en3,en4,en5;
reg dummy;
/*----Initial value----*/
Multiplication M1(.A({{1'b0,8'd126,B[22:0]}}),.B(32'h3ff0f0f1),.clk(clk),.result(temp1)); //verified
assign debug = {1'b1,temp1[30:0]};
Adder A1(.A(32'h4034b4b5),.B({1'b1,temp1[30:0]}),.result(x0));

/*----First Iteration----*/
Multiplication M2(.A({{1'b0,8'd126,B[22:0]}}),.B(x0),.clk(clk),.result(temp2));
Adder A2(.A(32'h40000000),.B({!temp2[31],temp2[30:0]}),.result(temp3));
Multiplication M3(.A(x0),.B(temp3),.clk(clk),.result(x1));

/*----Second Iteration----*/
Multiplication M4(.A({1'b0,8'd126,B[22:0]}),.B(x1),.clk(clk),.result(temp4));
Adder A3(.A(32'h40000000),.B({!temp4[31],temp4[30:0]}),.result(temp5));
Multiplication M5(.A(x1),.B(temp5),.clk(clk),.result(x2));

/*----Third Iteration----*/
Multiplication M6(.A({1'b0,8'd126,B[22:0]}),.B(x2),.clk(clk),.result(temp6));
Adder A4(.A(32'h40000000),.B({!temp6[31],temp6[30:0]}),.result(temp7));
Multiplication M7(.A(x2),.B(temp7),.clk(clk),.result(x3));




/*----Reciprocal : 1/B----*/
// assign Exponent = x3[30:23]+8'd126-B[30:23];
Addition_CV A5(.op1(x3[30:23]),.op2(8'd126),.result(Temp_Exponent));
Subtraction_CV S1(.op1(Temp_Exponent), .op2(B[30:23]), .result(Exponent));
assign reciprocal = {B[31],Exponent,x3[22:0]};

/*----Multiplication A*1/B----*/
Multiplication M8(.A(A),.B(reciprocal),.clk(clk),.result(result));
endmodule

//===================================================================
module Subtraction_CV
(
	output	[7:0] 	result, 
	input 	[7:0]	op1,
	input 	[7:0]	op2
);	
	wire 	[7:0]	man_x,
					man_y,
					pre_result,
					cal_c_out;
	
	wire	[8:0]	cal_c_in;				
	
	assign	cal_c_in[0] = 1'b1;
	assign 	man_x = op1;
	assign 	man_y = op2;
	assign 	result = pre_result;
	
	genvar a;
	generate
		for(a = 0; a < 8; a = a + 1)
		begin:	full_adder
			assign pre_result[a] = man_x[a] ^ (1'b1 ^ man_y[a]) ^ cal_c_in[a];
			assign cal_c_out[a] = man_x[a] && (1'b1 ^ man_y[a]) || cal_c_in[a] && (man_x[a] ^ (1'b1 ^ man_y[a]));
			assign cal_c_in[a+1] = cal_c_out[a];
		end
	endgenerate		

endmodule

module Addition_CV
(
	output	[7:0] 	result, 
	input 	[7:0]	op1,
	input 	[7:0]	op2
);	
	wire 	[7:0]	man_x,
					man_y,
					pre_result,
					cal_c_out;
	
	wire	[8:0]	cal_c_in;				
	
	assign	cal_c_in[0] = 1'b0; // For addition, initial carry-in is set to 0
	assign 	man_x = op1;
	assign 	man_y = op2;
	assign 	result = pre_result;
	
	genvar a;
	generate
		for(a = 0; a < 8; a = a + 1)
		begin:	full_adder
			assign pre_result[a] = man_x[a] ^ man_y[a] ^ cal_c_in[a];
			assign cal_c_out[a] = (man_x[a] & man_y[a]) | (cal_c_in[a] & (man_x[a] ^ man_y[a]));
			assign cal_c_in[a+1] = cal_c_out[a];
		end
	endgenerate		

endmodule
