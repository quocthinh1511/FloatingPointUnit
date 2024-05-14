`include "../sources/Adder.v"
`include "../sources/Substract.v"
`include "../sources/Multiplication.v"
`include "../sources/FloatingDivision.v"
`include "../sources/FP_convert.v"


module FPU(input [31:0]A,
                         input [31:0]B,
                         input [1:0] op,
                         output   [31:0] result, result_float );

wire [31:0] result_add;
wire [31:0] result_sub;
wire [31:0] result_mul;
wire [31:0] result_div;
reg  [31:0] result;

 Adder add (.A(A), .B(B), .result(result_add) );
 Substract sub (.A(A), .B(B), .result(result_sub));
 Multiplication mul(.A(A), .B(B), .result(result_mul));
 FloatingDivision div (.A(A), .B(B), .result(result_div));


always @(*) begin
    case(op) 
        2'b00: begin
            result = result_add;
        end
        2'b01: begin
            result = result_sub;
        end
        2'b10: begin
            result = result_mul;
        end
        2'b11: begin
            result = result_div;
        end

    default: begin
    end
    endcase


end

FPU_convert convert(.A(result), .result(result_float) );
endmodule 