`include "util.sv"

module multiply_tb;

    import utilities::*;

    // Parameters
    localparam WIDTH = 32;
    localparam FIXED_POINT_INDEX = 16;
    localparam PERIOD = 10;

    // Inputs
    logic clk;
    logic reset;
    logic signed [WIDTH-1:0] a;
    logic signed [WIDTH-1:0] b;
    logic signed [WIDTH-1:0] lr;

    // Outputs
    logic signed [WIDTH-1:0] result;

    // Clock generation
    initial begin
        clk = 0;
        forever #PERIOD clk = ~clk;
    end


    // Stimulus
    initial begin
        // Initialize Inputs
        reset = 1;
        #10;
        reset = 0;
        #10;
        reset = 1;

        // Test Vector 1
        a = 32'sh00010000; // 1.0 in fixed-point representation
        b = 32'sh00020000; // 2.0 in fixed-point representation
        #20;
        $display("Test Vector 1: a = %0d, b = %0d, result = %0d", a, b, result);

        result = util#(WIDTH, FIXED_POINT_INDEX)::fixed_point_multiply (a, b);

        // Test Vector 2
        a = 32'shFFFF0000; // -1.0 in fixed-point representation
        b = 32'sh00010000; // 1.0 in fixed-point representation
        #20;
        $display("Test Vector 2: a = %0d, b = %0d, result = %0d", a, b, result);
        
        result = util#(WIDTH, FIXED_POINT_INDEX)::fixed_point_multiply (a, b);

        // Test Vector 3
        lr = 1 << (FIXED_POINT_INDEX-2); // 0.25 in fixed-point representation
        a = 32'sh00010000; // 1.0 in fixed-point representation
        
         result = util#(WIDTH, FIXED_POINT_INDEX)::fixed_point_multiply (a, lr);
    end

endmodule