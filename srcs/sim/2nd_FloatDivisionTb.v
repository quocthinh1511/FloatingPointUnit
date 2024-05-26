`timescale 1ns / 1ps

module FloatDivisionTB;
    // Parameters
    parameter XLEN = 32;

    // Reg and Wire Declarations
    reg [XLEN-1:0] A, B;
    reg clk, rst, en;
    reg overflow, underflow, exception;
    wire [XLEN-1:0] result;
    real value;
    
    // Instantiate the Unit Under Test (UUT)
    FP_Divider #( .DW(XLEN) ) F_Div (
        .clk(clk),
        .rst(rst),
        .en(en),
        .A(A),
        .B(B),
        .C(result)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock
    end

    // Testbench Logic
    initial begin
        // Initialize signals
        rst = 1;
        en = 1;

        // Apply Reset
        rst = 0;
        #20;
        rst = 1;
        #20;

        // Apply Test Vectors
        A = 32'b0_10000001_00001100110011001100110;  // 4.2 
        B = 32'b0_10000000_10011001100110011001100;  // 3.2
        #40; // Wait for a few clock cycles
        value = (2**(result[30:23]-127)) * ($itor({1'b1,result[22:0]})/2**23) * ((-1)**(result[31]));
        $display("Expected Value: %f, Result: %f", 4.2/3.2, value);
        
        A = 32'b0_01111110_01010001111010111000010;  // 0.66
        B = 32'b0_01111110_00000101000111101011100;  // 0.51
        #40; // Wait for a few clock cycles
        value = (2**(result[30:23]-127)) * ($itor({1'b1,result[22:0]})/2**23) * ((-1)**(result[31]));
        $display("Expected Value: %f, Result: %f", 0.66/0.51, value);

        A = 32'b1_10000001_10011001100110011001100;  // -6.4 
        B = 32'b1_01111110_00000000000000000000000;  // -0.5
        #40; // Wait for a few clock cycles
        value = (2**(result[30:23]-127)) * ($itor({1'b1,result[22:0]})/2**23) * ((-1)**(result[31]));
        $display("Expected Value: %f, Result: %f", (-6.4)/(-0.5), value);

        A = 32'b0_10000001_10011001100110011001100;  // 6.4
        B = 32'b1_01111110_00000000000000000000000;  // -0.5
        #40; // Wait for a few clock cycles
        value = (2**(result[30:23]-127)) * ($itor({1'b1,result[22:0]})/2**23) * ((-1)**(result[31]));
        $display("Expected Value: %f, Result: %f", 6.4/(-0.5), value);

        A = 32'h4034b4b5; //2.82
        B = 32'hbf70f0f1; //0.94
        #40; // Wait for a few clock cycles
        value = (2**(result[30:23]-127)) * ($itor({1'b1,result[22:0]})/2**23) * ((-1)**(result[31]));
        $display("Expected Value: %f, Result: %f", 2.82/0.94, value);

        // Finish the simulation
        $finish;
    end
endmodule
