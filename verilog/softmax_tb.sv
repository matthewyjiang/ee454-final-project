`timescale 1ns/1ps

module softmax_tb;
    
    // Parameters
    localparam WIDTH = 32;
    localparam FIXED_POINT_INDEX = 16;
    localparam PERIOD = 10;
    localparam LEARNING_RATE = 1 << (FIXED_POINT_INDEX-3);

    // Inputs
    logic clk;
    logic reset;
    logic signed [WIDTH-1:0] a [4];
    logic signed [WIDTH-1:0] b [4];
    logic start;
    logic done;
    
    softmax #(.WIDTH(WIDTH), .DIMENSION(4), .FIXED_POINT_INDEX(FIXED_POINT_INDEX)) softmax_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .input_data(a),
        .output_data(b),
        .done(done)

    );

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
        #20;
        reset = 0;
        #10;
        reset = 1;

        // Apply test vectors
        a[0] = 32'h00010000; // 1.0 in fixed-point
        a[1] = 32'h00020000; // 2.0 in fixed-point
        a[2] = 32'h00030000; // 3.0 in fixed-point
        a[3] = 32'h00040000; // 4.0 in fixed-point
        #20;
        start = 1;
        #100;
        wait(done);
        $stop;

        a[0] = 32'h00040000; // 4.0 in fixed-point
        a[1] = 32'h00030000; // 3.0 in fixed-point
        a[2] = 32'h00020000; // 2.0 in fixed-point
        a[3] = 32'h00010000; // 1.0 in fixed-point
        #20;
        start = 1;
        wait(done);

        a[0] = 32'h00000000; // 0.0 in fixed-point
        a[1] = 32'h00000000; // 0.0 in fixed-point
        a[2] = 32'h00000000; // 0.0 in fixed-point
        a[3] = 32'h00000000; // 0.0 in fixed-point
        #20;
        start = 1;
        wait(done);

       
        $stop;
    end

endmodule