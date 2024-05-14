`timescale 1ns / 1ps
module Converter #(parameter XLEN=32)
                        (input [XLEN-1:0]A,
                         input [XLEN-1:0]B,
                         input clk,
                         output overflow,
                         output underflow,
                         output exception,
                         output reg  [XLEN-1:0] result);

wire  [23:0]  A_Mantissa,B_Mantissa;
wire  [24:0]  A_Mantissa_pad,B_Mantissa_pad;
wire  [47:0]  Temp_Mantissa;
reg  [47:0]  Temp_Mantissa_result;
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


bit8adder a1(A_Exponent,B_Exponent,temp_ex,/**/);
bit8adder a2(temp_ex,8'b10000001,Temp_Exponent,/**/);


nhan_24bit nhan(A_Mantissa,B_Mantissa,Temp_Mantissa,A_Mantissa_pad);


always @(*)
begin
Mantissa = Temp_Mantissa[47] ? Temp_Mantissa[46:24] : Temp_Mantissa[45:23];
Exponent = Temp_Mantissa[47] ? Temp_E xponent+1'b1 : Temp_Exponent;
Sign = A_sign^B_sign;
result = {Sign,Exponent,Mantissa};
end




endmodule

module adder_48bit(in1, in2, Sout, Cout);
input	[47:0]	in1,in2;
output [47:0] Sout;
output			Cout;
wire	[47:0]	S;
wire	[48:1]	temp_c;
FA_1 FA[47:0](in1[47:0],in2[47:0],{temp_c[47:1],1'b0},S[47:0],{Cout,temp_c[47:1]});
assign Sout = S;
endmodule

module nhan_24bit(a,b,ketquatruoc,ketqua);
input  [23:0] a,b;
output [47:0] ketquatruoc;
output [24:0] ketqua;
wire [47:0]X[24:1];
wire [47:0]S[23:0];

	assign X[1]  = b[0]?{24'b0,a}:48'b0;
	assign X[2] = b[1]?{23'b0,a,1'b0}:48'b0;
adder_48bit add1(.in1(X[1]), .in2(X[2]), .Sout(S[1]), .Cout());
        assign X[3]  = b[2]?{22'b0,a,2'b0}:48'b0;
adder_48bit add2(.in1(S[1]), .in2(X[3]), .Sout(S[2]), .Cout());  
        assign X[4]  = b[3]?{21'b0,a,3'b0}:48'b0;
adder_48bit add3(.in1(S[2]), .in2(X[4]), .Sout(S[3]), .Cout());
        assign X[5]  = b[4]?{20'b0,a,4'b0}:48'b0;
adder_48bit add4(.in1(S[3]), .in2(X[5]), .Sout(S[4]), .Cout());
        assign X[6]  = b[5]?{19'b0,a,5'b0}:48'b0;
adder_48bit add5(.in1(S[4]), .in2(X[6]), .Sout(S[5]), .Cout());
        assign X[7]  = b[6]?{18'b0,a,6'b0}:48'b0;
adder_48bit add6(.in1(S[5]), .in2(X[7]), .Sout(S[6]), .Cout());
        assign X[8]  = b[7]?{17'b0,a,7'b0}:48'b0;
adder_48bit add7(.in1(S[6]), .in2(X[8]), .Sout(S[7]), .Cout());
        assign X[9]  = b[8]?{16'b0,a,8'b0}:48'b0;
adder_48bit add8(.in1(S[7]), .in2(X[9]), .Sout(S[8]), .Cout());
        assign X[10] = b[9]?{15'b0,a,9'b0}:48'b0;
adder_48bit add9(.in1(S[8]), .in2(X[10]), .Sout(S[9]), .Cout());
        assign X[11] = b[10]?{14'b0,a,10'b0}:48'b0;
adder_48bit add10(.in1(S[9]), .in2(X[11]), .Sout(S[10]), .Cout());
	assign X[12] = b[11]?{13'b0,a,11'b0}:48'b0;
adder_48bit add11(.in1(S[10]), .in2(X[12]), .Sout(S[11]), .Cout());
        assign X[13] = b[12]?{12'b0,a,12'b0}:48'b0;
adder_48bit add12(.in1(S[11]), .in2(X[13]), .Sout(S[12]), .Cout());
        assign X[14] = b[13]?{11'b0,a,13'b0}:48'b0;
adder_48bit add13(.in1(S[12]), .in2(X[14]), .Sout(S[13]), .Cout());
        assign X[15] = b[14]?{10'b0,a,14'b0}:48'b0;
adder_48bit add14(.in1(S[13]), .in2(X[15]), .Sout(S[14]), .Cout());
        assign X[16] = b[15]?{9'b0,a,15'b0}:48'b0;
adder_48bit add15(.in1(S[14]), .in2(X[16]), .Sout(S[15]), .Cout());
        assign X[17] = b[16]?{8'b0,a,16'b0}:48'b0;
adder_48bit add16(.in1(S[15]), .in2(X[17]), .Sout(S[16]), .Cout());
        assign X[18] = b[17]?{7'b0,a,17'b0}:48'b0;
adder_48bit add17(.in1(S[16]), .in2(X[18]), .Sout(S[17]), .Cout());
        assign X[19]= b[18]?{6'b0,a,18'b0}:48'b0;
adder_48bit add18(.in1(S[17]), .in2(X[19]), .Sout(S[18]), .Cout());
        assign X[20] = b[19]?{5'b0,a,19'b0}:48'b0;
adder_48bit add19(.in1(S[18]), .in2(X[20]), .Sout(S[19]), .Cout());
        assign X[21] = b[20]?{4'b0,a,20'b0}:48'b0;
adder_48bit add20(.in1(S[19]), .in2(X[21]), .Sout(S[20]), .Cout());
        assign X[22] = b[21]?{3'b0,a,21'b0}:48'b0;
adder_48bit add21(.in1(S[20]), .in2(X[22]), .Sout(S[21]), .Cout());
        assign X[23] = b[22]?{2'b0,a,22'b0}:48'b0;
adder_48bit add22(.in1(S[21]), .in2(X[23]), .Sout(S[22]), .Cout());
        assign X[24] = b[23]?{1'b0,a,23'b0}:48'b0;
adder_48bit add23(.in1(S[22]), .in2(X[24]), .Sout(S[23]), .Cout()); 
assign ketquatruoc = S[23];
assign ketqua = ketquatruoc[47:23]; //25 bit???
endmodule

module FA_1(a, b, cin, s ,cout);
input a , b , cin;
output s , cout;
wire a,b,cin;
wire c1,c0;
wire sum,cout,s  ;
half_adder half_adder_00(a , b , c0, sum );
half_adder half_adder_01(sum , cin , c1 , s);
assign cout = c1 | c0;
endmodule

module half_adder (a, b, c, s);
input a,b;
output s,c;
wire a,b,c,s;
assign s = a ^ b;
assign c = a &b;
endmodule

module bit8adder (in1, in2, S, Cout);//bo cong 8bit
  input [7:0] in1, in2;
  output [7:0] S;
  output Cout;
  wire [7:1] temp;
  wire Cout;
  FA_1 A_0(in1[0], in2[0], 1'b0, S[0], temp[1]);
  FA_1 A_1(in1[1],in2[1], temp[1], S[1], temp[2]);
  FA_1 A_2(in1[2], in2[2], temp[2], S[2], temp[3]);
  FA_1 A_3(in1[3], in2[3], temp[3], S[3], temp[4]);
  FA_1 A_4(in1[4], in2[4], temp[4], S[4], temp[5]);
  FA_1 A_5(in1[5], in2[5], temp[5], S[5], temp[6]);
  FA_1 A_6(in1[6], in2[6], temp[6],S[6], temp[7]);
  FA_1 A_7(in1[7], in2[7],temp[7], S[7], Cout);
//   assign S[8] = Cout;
 
endmodule