`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2020 02:50:25 PM
// Design Name: 
// Module Name: PE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PE(
    input A,
    input B,
    input Cin,
    input sel,
    output Cout,
    output Result
    );
    
    wire B_bar;    //For Subtract
    wire FA_Sum;   //FA_Result
    
    //B -> -B
    assign B_bar = ~B;
    //A + (-B)
    full_add Full_adder(.a(A), .b(B_bar), .cin(Cin), .sum(FA_Sum), .cout(Cout));
    //MuX (sel = 1 : Sum / sel = 0 : A)
    assign Result = (sel) ? FA_Sum : A;
endmodule

// Code your design : Full Adder
module full_add(a,b,cin,sum,cout);
  input a,b,cin;
  output sum,cout;
  wire x,y,z;
 
// instantiate building blocks of full adder 
  half_add h1(.a(a),.b(b),.s(x),.c(y));
  half_add h2(.a(x),.b(cin),.s(sum),.c(z));
  or o1(cout,y,z);
endmodule : full_add

// code your half adder design             
module half_add(a,b,s,c); 
  input a,b;
  output s,c;
 
// gate level design of half adder  
  xor x1(s,a,b);
  and a1(c,a,b);
endmodule :half_add
