

`timescale 1ns / 1ps
module FPU_convert    (input [31:0]A,
                       output  [31:0] result);

reg [7:0] exponent, exponent_temp; 

assign exponent = A[30:23]-127;

always @(*) begin
    exponent_temp = ~exponent +1'b1; 
    if(exponent[7]==1) begin
        result = (1*.10/exponent_temp)*($itor({1'b1,A[22:0]})/2**23)*((-1)**(A[31]));
    end 
    else begin 
         result = (2**(A[30:23]-127))*($itor({1'b1,A[22:0]})/2**23)*((-1)**(A[31]));
    end

end



endmodule


