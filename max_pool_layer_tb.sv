`timescale 1ns / 1ps

module tb_max_pool_layer_2x2;

    // Parameters
    parameter int WIDTH = 16;           // 16-bit fixed-point
    parameter int STRIDE = 2;           // Stride of 2
    parameter int INPUT_DIM_WIDTH = 2;  // 2x2 input
    parameter int INPUT_DIM_HEIGHT = 2; // 2x2 input
    parameter int OUTPUT_DIM_WIDTH = INPUT_DIM_WIDTH / STRIDE;   // 1x1 output
    parameter int OUTPUT_DIM_HEIGHT = INPUT_DIM_HEIGHT / STRIDE; // 1x1 output

    // Inputs
    logic clk;
    logic rst;
    logic signed [WIDTH-1:0] input_feature_map [0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1];
    logic signed [WIDTH-1:0] input_gradient [0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1];

    // Outputs
    logic signed [WIDTH-1:0] output_reduced_feature_map [0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1];
    logic signed [WIDTH-1:0] output_gradient [0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1];

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Instantiate the max_pool_layer
    max_pool_layer #(
        .WIDTH(WIDTH),
        .STRIDE(STRIDE),
        .INPUT_DIM_WIDTH(INPUT_DIM_WIDTH),
        .INPUT_DIM_HEIGHT(INPUT_DIM_HEIGHT),
        .OUTPUT_DIM_WIDTH(OUTPUT_DIM_WIDTH),
        .OUTPUT_DIM_HEIGHT(OUTPUT_DIM_HEIGHT)
    ) uut (
        .clk(clk),
        .rst(rst),
        .input_feature_map(input_feature_map),
        .input_gradient(input_gradient),
        .output_reduced_feature_map(output_reduced_feature_map),
        .output_gradient(output_gradient)
    );


    // stimulus
    initial begin
        rst = 1; // rst init
        #10 rst = 0; // rst deassert after 10 time units

        // Test case 1: 2x2 input (forward pass)
        $display("Test Case: 2x2 Input");
        input_feature_map[0][0] = 16'd1;
        input_feature_map[0][1] = 16'd3;
        input_feature_map[1][0] = 16'd2;
        input_feature_map[1][1] = 16'd4;

        // Test case 1: Set gradient (backwards pass)
        input_gradient[0][0] = 16'd8;

        // Simulate clock cycles
        #10;

        // End simulation
        $finish;
    end

    // Display output
    always @(posedge clk) begin
        $display("Output Reduced Feature Map:");
        for (int i = 0; i < OUTPUT_DIM_HEIGHT; i = i + 1) begin
            $display("%0p", output_reduced_feature_map[i]);
        end
        $display("Output Gradient:");
        for (int i = 0; i < INPUT_DIM_HEIGHT; i = i + 1) begin
            $display("%0p", output_gradient[i]);
        end
    end
endmodule
