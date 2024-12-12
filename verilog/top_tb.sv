`timescale 1ns / 1ps

module top_tb;

    // Parameters
    parameter int WIDTH = 32;
    parameter int INPUT_DIM = 4;
    parameter int OUTPUT_DIM = 2;
    parameter int LEARNING_RATE = 1;
    parameter int PERIOD = 10;

    // Inputs
    logic clk;
    logic reset;
    logic signed [WIDTH-1:0] input_data [INPUT_DIM];
    logic signed [WIDTH-1:0] output_error [OUTPUT_DIM];

    // Outputs
    logic signed [WIDTH-1:0] output_data [OUTPUT_DIM];
    logic signed [WIDTH-1:0] input_error [INPUT_DIM];

    // Clock generation
    initial begin
        clk = 0;
        forever #PERIOD clk = ~clk;
    end

    // Instantiate Unit Under Test (UUT)

    cnn_top #(
        .WIDTH(WIDTH),
        .LEARNING_RATE(LEARNING_RATE),
        .FCL_INPUT_DIM(INPUT_DIM),
        .FCL_OUTPUT_DIM(OUTPUT_DIM)
    ) uut (
        .clk(clk),
        .reset(reset),
        .input_data(input_data),
        .fcl_output_error(output_error)
    );

    // Stimulus
    initial begin
        // Initialize Inputs
        reset = 1;
        #10;
        reset = 0;
        #10;
        reset = 1;

        // Apply test vectors
        input_data = '{2'sb01, 2'sb10, 2'sb11, 2'sb00};
        output_error = '{2'sb01, 2'sb10};
        #10;

        input_data = '{2'sb11, 2'sb00, 2'sb01, 2'sb10};
        output_error = '{2'sb11, 2'sb00};
        #10;

        input_data = '{2'sb00, 2'sb01, 2'sb10, 2'sb11};
        output_error = '{2'sb10, 2'sb01};
        #10;

        #1000;

        // input_data = '{default: 32'h0};  // SystemVerilog array assignment

        // Finish simulation
        $stop;
    end


endmodule
