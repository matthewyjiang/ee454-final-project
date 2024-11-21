module tb_max_pool_layer_2x2;

    // Parameters for input size
    parameter int WIDTH = 16;
    parameter int STRIDE = 2;
    parameter int INPUT_DIM_WIDTH = 2;  // 2x2 input
    parameter int INPUT_DIM_HEIGHT = 2; // 2x2 input
    parameter int OUTPUT_DIM_WIDTH = INPUT_DIM_WIDTH / STRIDE;
    parameter int OUTPUT_DIM_HEIGHT = INPUT_DIM_HEIGHT / STRIDE;

    // Inputs to the max_pool_layer
    logic clk;
    logic rst;
    logic signed [WIDTH-1:0] input_feature_map [0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1];
    logic signed [WIDTH-1:0] input_gradient [0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1];

    // Outputs from the max_pool_layer
    logic signed [WIDTH-1:0] output_reduced_feature_map [0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1];
    logic signed [WIDTH-1:0] output_gradient [0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1];

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

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize clock and reset
        clk = 0;
        rst = 1;

        // Apply reset for 10 time units
        #10 rst = 0;

        // Test case: 2x2 input
        $display("Test Case: 2x2 Input");
        input_feature_map[0][0] = 16'd1;
        input_feature_map[0][1] = 16'd3;
        input_feature_map[1][0] = 16'd2;
        input_feature_map[1][1] = 16'd4;

        // Set gradient
        input_gradient[0][0] = 16'd5;
        input_gradient[0][1] = 16'd6;
        input_gradient[1][0] = 16'd7;
        input_gradient[1][1] = 16'd8;

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
