`timescale 1ns / 1ps

module tb_max_pool_layer_2x2;

    // Parameters
    parameter int WIDTH = 16;           // 16-bit fixed-point
    parameter int STRIDE = 2;           // Stride of 2
    parameter int INPUT_DIM_WIDTH = 8;  
    parameter int INPUT_DIM_HEIGHT = 8; 
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

        // Test case 3: 8x8 input (forward pass)
        #10;
        $display("Test Case: 8x8 Input");

        // Initialize input feature map
        input_feature_map[0][0] = 16'd1;   input_feature_map[0][1] = 16'd3;   input_feature_map[0][2] = 16'd5;   input_feature_map[0][3] = 16'd7;
        input_feature_map[0][4] = 16'd9;   input_feature_map[0][5] = 16'd11;  input_feature_map[0][6] = 16'd13;  input_feature_map[0][7] = 16'd15;

        input_feature_map[1][0] = 16'd2;   input_feature_map[1][1] = 16'd4;   input_feature_map[1][2] = 16'd6;   input_feature_map[1][3] = 16'd8;
        input_feature_map[1][4] = 16'd10;  input_feature_map[1][5] = 16'd12;  input_feature_map[1][6] = 16'd14;  input_feature_map[1][7] = 16'd16;

        input_feature_map[2][0] = 16'd17;  input_feature_map[2][1] = 16'd19;  input_feature_map[2][2] = 16'd21;  input_feature_map[2][3] = 16'd23;
        input_feature_map[2][4] = 16'd25;  input_feature_map[2][5] = 16'd27;  input_feature_map[2][6] = 16'd29;  input_feature_map[2][7] = 16'd31;

        input_feature_map[3][0] = 16'd18;  input_feature_map[3][1] = 16'd20;  input_feature_map[3][2] = 16'd22;  input_feature_map[3][3] = 16'd24;
        input_feature_map[3][4] = 16'd26;  input_feature_map[3][5] = 16'd28;  input_feature_map[3][6] = 16'd30;  input_feature_map[3][7] = 16'd32;

        input_feature_map[4][0] = 16'd33;  input_feature_map[4][1] = 16'd35;  input_feature_map[4][2] = 16'd37;  input_feature_map[4][3] = 16'd39;
        input_feature_map[4][4] = 16'd41;  input_feature_map[4][5] = 16'd43;  input_feature_map[4][6] = 16'd45;  input_feature_map[4][7] = 16'd47;

        input_feature_map[5][0] = 16'd34;  input_feature_map[5][1] = 16'd36;  input_feature_map[5][2] = 16'd38;  input_feature_map[5][3] = 16'd40;
        input_feature_map[5][4] = 16'd42;  input_feature_map[5][5] = 16'd44;  input_feature_map[5][6] = 16'd46;  input_feature_map[5][7] = 16'd48;

        input_feature_map[6][0] = 16'd49;  input_feature_map[6][1] = 16'd51;  input_feature_map[6][2] = 16'd53;  input_feature_map[6][3] = 16'd55;
        input_feature_map[6][4] = 16'd57;  input_feature_map[6][5] = 16'd59;  input_feature_map[6][6] = 16'd61;  input_feature_map[6][7] = 16'd63;

        input_feature_map[7][0] = 16'd50;  input_feature_map[7][1] = 16'd52;  input_feature_map[7][2] = 16'd54;  input_feature_map[7][3] = 16'd56;
        input_feature_map[7][4] = 16'd58;  input_feature_map[7][5] = 16'd60;  input_feature_map[7][6] = 16'd62;  input_feature_map[7][7] = 16'd64;

        // Display gradient (backward pass for testing)
        output_gradient[0][0] = 16'd8;
        output_gradient[0][1] = 16'd6;
        output_gradient[0][2] = 16'd4;
        output_gradient[0][3] = 16'd2;
        output_gradient[1][0] = 16'd1;
        output_gradient[1][1] = 16'd2;
        output_gradient[1][2] = 16'd3;
        output_gradient[1][3] = 16'd4;
        output_gradient[2][0] = 16'd3;
        output_gradient[2][1] = 16'd5;
        output_gradient[2][2] = 16'd7;
        output_gradient[2][3] = 16'd9;
        output_gradient[3][0] = 16'd2;
        output_gradient[3][1] = 16'd4;
        output_gradient[3][2] = 16'd6;
        output_gradient[3][3] = 16'd1;

        // Display input feature map
        $display("Input Feature Map:");
        for (int i = 0; i < INPUT_DIM_HEIGHT; i = i + 1) begin
            $display("%0p", input_feature_map[i]);
        end

        // Display output reduced feature map (Expected Result after 2x2 MaxPooling)
        $display("(to layer X+1) Output Reduced Feature Map (Expected):");
        $display("{  4,  8, 12, 16 }");
        $display("{ 20, 24, 28, 32 }");
        $display("{ 36, 40, 44, 48 }");
        $display("{ 52, 56, 60, 64 }");

        // Simulate clock cycles
        #20;

        $display("(to layer X+1) Output Reduced Feature Map:");
        for (int i = 0; i < OUTPUT_DIM_HEIGHT; i = i + 1) begin
            $display("%0p", output_reduced_feature_map[i]);
        end
        $display("(to layer X-1) Gradient:");
        for (int i = 0; i < INPUT_DIM_HEIGHT; i = i + 1) begin
            $display("%0p", input_gradient[i]);
        end

        // End simulation
        $finish;
    end
endmodule
