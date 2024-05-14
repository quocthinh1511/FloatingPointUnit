`timescale 1ns / 1ps
module Multiplication #(parameter XLEN=32)
                        (input [XLEN-1:0]A,
                         input [XLEN-1:0]B,
                         input clk,
                         output overflow,
                         output underflow,
                         output exception,
                         output reg  [XLEN-1:0] result);

wire  [23:0]  A_Mantissa,B_Mantissa;
// wire  [24:0]  A_Mantissa_pad;
wire  [23:0]  Temp_Mantissa;
wire redundant;
reg [22:0] Mantissa;
reg [7:0] Exponent;
reg Sign;
wire MSB;
wire [7:0] temp_ex;
wire [7:0] A_Exponent,B_Exponent,Temp_Exponent,diff_Exponent;
wire A_sign,B_sign,Temp_sign;
reg [32:0] Temp;
reg carry;
reg [2:0] one_hot;
reg comp;
reg sign_bit;
reg [7:0] exp_adjust;
reg [23:0] generate_bit; 
reg [23:0] propegate_bit; 
reg [24:0] carry_bit; 
reg [23:0] sum; 
reg [23:0] diff; 
reg [31:0] B_comp;
reg [23:0] B_Mantissa1;
reg E1;
reg [1:0] temp;
integer i ; 
integer g;



assign A_Mantissa = {1'b1,A[22:0]};
assign A_Exponent = A[30:23];
assign A_sign = A[31];
  
assign B_Mantissa = {1'b1,B[22:0]};
assign B_Exponent = B[30:23];
assign B_sign = B[31];


Addition_8bit A1(.op1(A_Exponent), .op2(B_Exponent), .result(temp_ex)/**/);
Addition_8bit A2(.op1(temp_ex), .op2(8'b10000001), .result(Temp_Exponent)/**/);


Vedic_Multiplication V1(.man_x(A_Mantissa), .man_y(B_Mantissa), .result(Temp_Mantissa), .redundant_mul(redundant));


always @(*)
begin
Mantissa = Temp_Mantissa[23:1];
Exponent = redundant ? Temp_Exponent+1'b1 : Temp_Exponent;
Sign = A_sign^B_sign;
result = {Sign,Exponent,Mantissa};
end

endmodule

module Addition_8bit
(
	output	[7:0] 	result, 
	input 	[7:0]	op1,
	input 	[7:0]	op2
);	
	logic 	[7:0]	man_x,
					man_y,
					pre_result,
					cal_c_out;
	
	logic	[8:0]	cal_c_in;				
	
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

module Vedic_Multiplication 
#(
parameter	BIT_LENGTH = 24
)
(
	output	logic	[BIT_LENGTH-1:0]		result,
	output 	logic 							redundant_mul,
	input	[BIT_LENGTH-1:0]				man_x,
	input 	[BIT_LENGTH-1:0]				man_y
);
	logic 	[11:0] 	r0,
					r1;
					
	logic 	[23:0]	r2,
					r3,
					r4;
	
	logic	[23:0]	c_out_1,
					c_out_2,
					c_out_3,
					addr_slot2_1,
					addr_slot2_2,
					s_out_1,
					r5,
					r6;
					
	logic 	[24:0]	c_in_1,
					c_in_2,
					c_in_3;
					
	Vedic_12x12	V1212_1
	(
	.result({r1, r0}),
	.in1(man_x[11:0]),
	.in2(man_y[11:0])
	);
	
	Vedic_12x12	V1212_2
	(
	.result(r2),
	.in1(man_x[23:12]),
	.in2(man_y[11:0])
	);
	
	Vedic_12x12	V1212_3
	(
	.result(r3),
	.in1(man_x[11:0]),
	.in2(man_y[23:12])
	);
	
	Vedic_12x12	V1212_4	
	(
	.result(r4),
	.in1(man_x[23:12]),
	.in2(man_y[23:12])
	);
	
	assign 	c_in_1[0] = 1'b0;
	
	genvar a;
	generate
		for(a = 0; a < 24; a = a + 1)
		begin:	full_adder_1
			assign r5[a] = r3[a] ^ r2[a] ^ c_in_1[a];
			assign c_out_1[a] = r3[a] && r2[a] || c_in_1[a] && (r3[a] ^ r2[a]);
			assign c_in_1[a+1] = c_out_1[a];
		end
	endgenerate	
	
	assign	addr_slot2_1 = {12'b0, r1};
	assign 	c_in_2[0] = 1'b0;
	
	genvar b;
	generate
		for(b = 0; b < 24; b = b + 1)
		begin:	full_adder_2
			assign s_out_1[b] = r5[b] ^ addr_slot2_1[b] ^ c_in_2[b];
			assign c_out_2[b] = r5[b] && addr_slot2_1[b] || c_in_2[b] && (r5[b] ^ addr_slot2_1[b]);
			assign c_in_2[b+1] = c_out_2[b];
		end
	endgenerate		
	

	assign	addr_slot2_2 = {11'b0, c_out_1[23] || c_out_2[23],s_out_1[23:12]};
	assign 	c_in_3[0] = 1'b0;
	
	genvar c;
	generate
		for(c = 0; c < 24; c = c + 1)
		begin:	full_adder_3
			assign r6[c] = r4[c] ^ addr_slot2_2[c] ^ c_in_3[c];
			assign c_out_3[c] = r4[c] && addr_slot2_2[c] || c_in_3[c] && (r4[c] ^ addr_slot2_2[c]);
			assign c_in_3[c+1] = c_out_3[c];
		end
	endgenerate	
	
	assign 	redundant_mul  = r6[23];
	assign	result = {r6[22:0], s_out_1[11]};
/*
	logic 	[24*2-1:0]	check;
	assign 	check = {r6, s_out_1[11:0], r0};
*/
endmodule	

//===================================================================
//	3x3 Vedic multiplier
module	Vedic_3x3
(
	output 	[5:0]	result,
	input 	[2:0]	in1,
	input 	[2:0]	in2
);
	logic 	[8:0]			i_stage_1_1;
	
	logic 					r1,
							r2,
							r3,
							r4,
							r5,
							s2,
							s3;
							
	assign 	i_stage_1_1[0] = in1[0] && in2[0];
	assign 	i_stage_1_1[1] = in1[0] && in2[1];
	assign 	i_stage_1_1[2] = in1[1] && in2[0];
	assign 	i_stage_1_1[3] = in1[1] && in2[1];
	assign 	i_stage_1_1[4] = in1[2] && in2[0];
	assign 	i_stage_1_1[5] = in1[0] && in2[2];			
	assign 	i_stage_1_1[6] = in1[1] && in2[2];
	assign 	i_stage_1_1[7] = in1[2] && in2[1];
	assign 	i_stage_1_1[8] = in1[2] && in2[2];	
	
	assign 	result[0]	   = i_stage_1_1[0];
	
	assign 	result[1]	   = i_stage_1_1[1] ^ i_stage_1_1[2];	
	assign 	r1			   = i_stage_1_1[1] && i_stage_1_1[2];	
	
	assign 	s2			   = i_stage_1_1[3] ^ i_stage_1_1[4] ^ i_stage_1_1[5]; 
	assign 	r2 			   = i_stage_1_1[3] && i_stage_1_1[4] || i_stage_1_1[5] && (i_stage_1_1[3] ^ i_stage_1_1[4]);
	
	assign 	result[2]	   = r1 ^ s2; 
	assign 	r3			   = r1 && s2; 
	
	assign 	s3			   = i_stage_1_1[6] ^ i_stage_1_1[7];
	assign 	r4			   = i_stage_1_1[6] && i_stage_1_1[7]; 
	
	assign 	result[3]	   = s3 ^ r2 ^ r3;
	assign 	r5			   = s3 && r2 || r3 && (s3 ^ r2);
	
	assign 	result[4]	   = i_stage_1_1[8] ^ r4 ^ r5;
	assign 	result[5] 	   = i_stage_1_1[8] && r4 || r5 && (i_stage_1_1[8] ^ r4);
	
endmodule

//===================================================================
//	6x6 Vedic multiplier	
module Vedic_6x6
(
	output	[11:0]	result,
	input 	[5:0]	in1,
	input 	[5:0]	in2
);
	logic 	[2:0] 	r0,
					r1;
					
	logic 	[5:0]	r2,
					r3,
					r4;
	
	logic	[5:0]	c_out_1,
					c_out_2,
					c_out_3,
					addr_slot2_1,
					addr_slot2_2,
					s_out_1,
					r5,
					r6;
					
	logic 	[6:0]	c_in_1,
					c_in_2,
					c_in_3;
					
	Vedic_3x3	V33_1
	(
	.result({r1, r0}),
	.in1(in1[2:0]),
	.in2(in2[2:0])
	);
	
	Vedic_3x3	V33_2
	(
	.result(r2),
	.in1(in1[5:3]),
	.in2(in2[2:0])
	);
	
	Vedic_3x3	V33_3
	(
	.result(r3),
	.in1(in1[2:0]),
	.in2(in2[5:3])
	);
	
	Vedic_3x3	V33_4	
	(
	.result(r4),
	.in1(in1[5:3]),
	.in2(in2[5:3])
	);
	
	assign 	c_in_1[0] = 1'b0;
	
	genvar a;
	generate
		for(a = 0; a < 6; a = a + 1)
		begin:	full_adder_1
			assign r5[a] = r3[a] ^ r2[a] ^ c_in_1[a];
			assign c_out_1[a] = r3[a] && r2[a] || c_in_1[a] && (r3[a] ^ r2[a]);
			assign c_in_1[a+1] = c_out_1[a];
		end
	endgenerate	
	
	assign	addr_slot2_1 = {3'b0, r1};
	assign 	c_in_2[0] = 1'b0;
	
	genvar b;
	generate
		for(b = 0; b < 6; b = b + 1)
		begin:	full_adder_2
			assign s_out_1[b] = r5[b] ^ addr_slot2_1[b] ^ c_in_2[b];
			assign c_out_2[b] = r5[b] && addr_slot2_1[b] || c_in_2[b] && (r5[b] ^ addr_slot2_1[b]);
			assign c_in_2[b+1] = c_out_2[b];
		end
	endgenerate		
	

	assign	addr_slot2_2 = {2'b0, c_out_1[5] || c_out_2[5],s_out_1[5:3]};
	assign 	c_in_3[0] = 1'b0;
	
	genvar c;
	generate
		for(c = 0; c < 6; c = c + 1)
		begin:	full_adder_3
			assign r6[c] = r4[c] ^ addr_slot2_2[c] ^ c_in_3[c];
			assign c_out_3[c] = r4[c] && addr_slot2_2[c] || c_in_3[c] && (r4[c] ^ addr_slot2_2[c]);
			assign c_in_3[c+1] = c_out_3[c];
		end
	endgenerate	
	
	assign	result = {r6, s_out_1[2:0], r0};
	
endmodule

//===================================================================
//	12x12 Vedic multiplier 	
module	Vedic_12x12
(
	output 	[23:0]	result,
	input 	[11:0]	in1,
	input	[11:0]	in2 	
);
	logic 	[5:0] 	r0,
					r1;
					
	logic 	[11:0]	r2,
					r3,
					r4;
	
	logic	[11:0]	c_out_1,
					c_out_2,
					c_out_3,
					addr_slot2_1,
					addr_slot2_2,
					s_out_1,
					r5,
					r6;
					
	logic 	[12:0]	c_in_1,
					c_in_2,
					c_in_3;
					
	Vedic_6x6	V66_1
	(
	.result({r1, r0}),
	.in1(in1[5:0]),
	.in2(in2[5:0])
	);
	
	Vedic_6x6	V66_2
	(
	.result(r2),
	.in1(in1[11:6]),
	.in2(in2[5:0])
	);
	
	Vedic_6x6	V66_3
	(
	.result(r3),
	.in1(in1[5:0]),
	.in2(in2[11:6])
	);
	
	Vedic_6x6	V66_4	
	(
	.result(r4),
	.in1(in1[11:6]),
	.in2(in2[11:6])
	);
	
	assign 	c_in_1[0] = 1'b0;
	
	genvar a;
	generate
		for(a = 0; a < 12; a = a + 1)
		begin:	full_adder_1
			assign r5[a] = r3[a] ^ r2[a] ^ c_in_1[a];
			assign c_out_1[a] = r3[a] && r2[a] || c_in_1[a] && (r3[a] ^ r2[a]);
			assign c_in_1[a+1] = c_out_1[a];
		end
	endgenerate	
	
	assign	addr_slot2_1 = {6'b0, r1};
	assign 	c_in_2[0] = 1'b0;
	
	genvar b;
	generate
		for(b = 0; b < 12; b = b + 1)
		begin:	full_adder_2
			assign s_out_1[b] = r5[b] ^ addr_slot2_1[b] ^ c_in_2[b];
			assign c_out_2[b] = r5[b] && addr_slot2_1[b] || c_in_2[b] && (r5[b] ^ addr_slot2_1[b]);
			assign c_in_2[b+1] = c_out_2[b];
		end
	endgenerate		
	

	assign	addr_slot2_2 = {5'b0, c_out_1[11] || c_out_2[11],s_out_1[11:6]};
	assign 	c_in_3[0] = 1'b0;
	
	genvar c;
	generate
		for(c = 0; c < 12; c = c + 1)
		begin:	full_adder_3
			assign r6[c] = r4[c] ^ addr_slot2_2[c] ^ c_in_3[c];
			assign c_out_3[c] = r4[c] && addr_slot2_2[c] || c_in_3[c] && (r4[c] ^ addr_slot2_2[c]);
			assign c_in_3[c+1] = c_out_3[c];
		end
	endgenerate	
	
	assign	result = {r6, s_out_1[5:0], r0};
endmodule