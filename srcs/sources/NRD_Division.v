module NRD_Division (
    output [QUOTIENT_LENGTH-1:0] quotient,
    output [DIVISOR_LENGTH-1:0] remainder,
    input [DIVIDEND_LENGTH-1:0] pre_dividend,
    input [DIVISOR_LENGTH-1:0] pre_divisor,
    input ge
);
    parameter DIVIDEND_LENGTH = 24;
    parameter DIVISOR_LENGTH = 24;
    parameter QUOTIENT_LENGTH = 24;
    
    wire [QUOTIENT_LENGTH-1:0][DIVISOR_LENGTH-1:0] carry_out;
    wire [QUOTIENT_LENGTH-1:0][DIVISOR_LENGTH-1:0] sum_out;
    wire [QUOTIENT_LENGTH-2:0][DIVISOR_LENGTH-2:0] new_dividend;
    wire [DIVIDEND_LENGTH+22:0] dividend;
    wire [DIVISOR_LENGTH-1:0] divisor;
    wire [QUOTIENT_LENGTH-1:0] pre_quotient;
    
    assign dividend = {pre_dividend, 23'b0};
    assign divisor = ge ? pre_divisor : {1'b0, pre_divisor[DIVISOR_LENGTH-1:1]};
    
    genvar i, j;
    generate
        for(i = QUOTIENT_LENGTH-3; i >= 0; i = i - 1) begin: fa_row_gen1
            for(j = 2; j < DIVISOR_LENGTH; j = j + 1) begin: fa_column_gen2
                assign new_dividend[i][j-1] = (!carry_out[i+1][DIVISOR_LENGTH-1]) ? new_dividend[i+1][j-2] : sum_out[i+1][j-1];
                assign sum_out[i][j] = (!divisor[j] ^ new_dividend[i][j-1] ^ carry_out[i][j-1]);
                assign carry_out[i][j] = (!divisor[j] && new_dividend[i][j-1]) || (carry_out[i][j-1] && (!divisor[j] ^ new_dividend[i][j-1]));
            end
        end
    endgenerate
    
    genvar k;
    generate
        for(k = 1; k < DIVISOR_LENGTH; k = k + 1) begin: fa_row0_gen
            assign sum_out[QUOTIENT_LENGTH-1][k] = (!divisor[k] ^ dividend[k+QUOTIENT_LENGTH-1] ^ carry_out[QUOTIENT_LENGTH-1][k-1]);
            assign carry_out[QUOTIENT_LENGTH-1][k] = (!divisor[k] && dividend[k+QUOTIENT_LENGTH-1]) || (carry_out[QUOTIENT_LENGTH-1][k-1] && (!divisor[k] ^ dividend[k+QUOTIENT_LENGTH-1]));
        end
    endgenerate
    
    genvar l;
    generate
        for(j = 1; j < DIVISOR_LENGTH; j = j + 1) begin: fa_row1_gen
            assign new_dividend[QUOTIENT_LENGTH-2][j-1] = sum_out[QUOTIENT_LENGTH-1][j-1];
            assign sum_out[QUOTIENT_LENGTH-2][j] = (!divisor[j] ^ new_dividend[QUOTIENT_LENGTH-2][j-1] ^ carry_out[QUOTIENT_LENGTH-2][j-1]);
            assign carry_out[QUOTIENT_LENGTH-2][j] = (!divisor[j] && new_dividend[QUOTIENT_LENGTH-2][j-1]) || (carry_out[QUOTIENT_LENGTH-2][j-1] && (!divisor[j] ^ new_dividend[QUOTIENT_LENGTH-2][j-1]));
        end
    endgenerate
    
    genvar m;
    generate
        for(m = QUOTIENT_LENGTH-1; m >= 0; m = m - 1) begin: fa_column0_gen
            assign sum_out[m][0] = (!divisor[0] ^ dividend[m] ^ 1'b1);
            assign carry_out[m][0] = (!divisor[0] && dividend[m]) || (1'b1 && (!divisor[0] ^ dividend[m]));
        end
    endgenerate
    
    genvar n;
    generate
        for(n = QUOTIENT_LENGTH-3; n >= 0; n = n - 1) begin: fa_column1_gen
            assign new_dividend[n][0] = (sum_out[n+1][DIVISOR_LENGTH-1]) ? dividend[n+1] : sum_out[n+1][0];
            assign sum_out[n][1] = (!divisor[1] ^ new_dividend[n][0] ^ carry_out[n][0]);
            assign carry_out[n][1] = (!divisor[1] && new_dividend[n][0]) || (carry_out[n][0] && (!divisor[1] ^ new_dividend[n][0]));
        end
    endgenerate
    
    genvar p;
    generate
        for(p = 0; p < DIVISOR_LENGTH; p = p + 1) begin: divisor_gen
            assign remainder[p] = sum_out[0][p];
        end
    endgenerate
    
    genvar q;
    generate
        for(q = 0; q < QUOTIENT_LENGTH; q = q + 1) begin: quotient_gen
            assign pre_quotient[q] = carry_out[q][DIVISOR_LENGTH-1];
        end
    endgenerate
    
    assign quotient = ge ? pre_quotient : {1'b0, pre_quotient[QUOTIENT_LENGTH-1:1]};
    
endmodule

