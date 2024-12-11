`timescale 1ns / 1ps

module tb_max_pool_layer_2x2;

    // Parameters
    parameter int WIDTH = 16;           // 16-bit fixed-point
    parameter int STRIDE = 2;           // Stride of 2
    parameter int INPUT_DIM_WIDTH = 4;  
    parameter int INPUT_DIM_HEIGHT = 4; 
    parameter int OUTPUT_DIM_WIDTH = INPUT_DIM_WIDTH / STRIDE;   // 1x1 output
    parameter int OUTPUT_DIM_HEIGHT = INPUT_DIM_HEIGHT / STRIDE; // 1x1 output

    // Inputs
    logic clk;
    logic signed [WIDTH-1:0] input_feature_map [0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1];
    logic signed [WIDTH-1:0] input_gradient [0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1];

    // Outputs
    logic signed [WIDTH-1:0] output_reduced_feature_map [0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1];
    logic signed [WIDTH-1:0] output_gradient [0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1];


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
        .input_feature_map(input_feature_map),
        .input_gradient(input_gradient),
        .output_reduced_feature_map(output_reduced_feature_map),
        .output_gradient(output_gradient)
    );


    // stimulus
    initial begin
        // Test case 1: 2x2 input (forward pass)
        #10;
        $display("Test Case: 2x2 Input");
        input_feature_map[0][0] = 16'd1;
        input_feature_map[0][1] = 16'd3;
        input_feature_map[1][0] = 16'd2;
        input_feature_map[1][1] = 16'd4;

        // Test case 1: Set gradient (backwards pass)
        output_gradient[0][0] = 16'd8;

        // Simulate clock cycles
        #20;

        // Test case 1: Display Output
        $display("Input Feature Map:");
        for (int i = 0; i < INPUT_DIM_HEIGHT; i = i + 1) begin
            $display("%0p", input_feature_map[i]);
        end
        $display("(to layer X+1) Output Reduced Feature Map:");
        for (int i = 0; i < OUTPUT_DIM_HEIGHT; i = i + 1) begin
            $display("%0p", output_reduced_feature_map[i]);
        end
        $display("(to layer X-1) Gradient:");
        for (int i = 0; i < INPUT_DIM_HEIGHT; i = i + 1) begin
            $display("%0p", input_gradient[i]);
        end

        
        // Test case 2: 3x3 input (forward pass)
        #10;
        $display("Test Case: 2x2 Input");
        input_feature_map[0][0] = 16'd1;
        input_feature_map[0][1] = 16'd2;
        input_feature_map[0][2] = 16'd3;
        input_feature_map[0][3] = 16'd4;
        input_feature_map[1][0] = 16'd5;
        input_feature_map[1][1] = 16'd6;
        input_feature_map[1][2] = 16'd7;
        input_feature_map[1][3] = 16'd8;
        input_feature_map[2][0] = 16'd9;
        input_feature_map[2][1] = 16'd0;
        input_feature_map[2][2] = 16'd1;
        input_feature_map[2][3] = 16'd2;
        input_feature_map[3][0] = 16'd3;
        input_feature_map[3][1] = 16'd4;
        input_feature_map[3][2] = 16'd5;
        input_feature_map[3][3] = 16'd6;

        // Test case 2: Set gradient (backwards pass)
        output_gradient[0][0] = 16'd8;
        output_gradient[0][1] = 16'd4;
        output_gradient[1][0] = 16'd6;
        output_gradient[1][1] = 16'd3;

        // Simulate clock cycles
        #20;

        // Test case 2: Display Output
        $display("Input Feature Map:");
        for (int i = 0; i < INPUT_DIM_HEIGHT; i = i + 1) begin
            $display("%0p", input_feature_map[i]);
        end
        $display("(to layer X+1) Output Reduced Feature Map:");
        for (int i = 0; i < OUTPUT_DIM_HEIGHT; i = i + 1) begin
            $display("%0p", output_reduced_feature_map[i]);
        end
        $display("(to layer X-1) Gradient:");
        for (int i = 0; i < INPUT_DIM_HEIGHT; i = i + 1) begin
            $display("%0p", input_gradient[i]);
        end

        
        // // Test case 1: 2x2 input (forward pass)
        // #10;
        // $display("Test Case: 2x2 Input");
        // input_feature_map[0][0] = 16'd1;
        // input_feature_map[0][1] = 16'd3;
        // input_feature_map[1][0] = 16'd2;
        // input_feature_map[1][1] = 16'd4;

        // // Test case 1: Set gradient (backwards pass)
        // output_gradient[0][0] = 16'd8;

        // // Simulate clock cycles
        // #20;

        // // Test case 1: Display Output
        // $display("Output Reduced Feature Map:");
        // for (int i = 0; i < OUTPUT_DIM_HEIGHT; i = i + 1) begin
        //     $display("%0p", output_reduced_feature_map[i]);
        // end
        // $display("Output Gradient:");
        // for (int i = 0; i < INPUT_DIM_HEIGHT; i = i + 1) begin
        //     $display("%0p", input_gradient[i]);
        // end

        // End simulation
        $finish;
    end
endmodule
