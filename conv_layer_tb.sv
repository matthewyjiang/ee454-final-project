`timescale 1ns / 1ps

module fully_connected_tb;

    // Parameters
    parameter int WIDTH = 2;
    parameter int NUM_KERNELS = 2;
    parameter int KERNEL_DIM = 3;
    parameter int INPUT_DIM_WIDTH = 3;
    parameter int INPUT_DIM_HEIGHT = 3;
    parameter int LEARNING_RATE = 1;
    parameter int PERIOD = 10;

    // Inputs
    logic signed [WIDTH-1:0] input_image [INPUT_DIM_HEIGHT][INPUT_DIM_WIDTH], // Convert from 8-bit input to WIDTH-bit fixed point
    logic signed [WIDTH-1:0] output_error [OUTPUT_DIM_HEIGHT][OUTPUT_DIM_WIDTH], 
    logic signed [WIDTH-1:0] input_kernels [NUM_KERNELS][KERNEL_DIM][KERNEL_DIM]

    // Outputs
    logic signed [WIDTH-1:0] output_data [OUTPUT_DIM];
    logic signed [WIDTH-1:0] input_error [INPUT_DIM];

    // Clock generation
    initial begin
        clk = 0;
        forever #PERIOD clk = ~clk;
    end

    // Instantiate Unit Under Test (UUT)
    conv_layer #(
        .WIDTH(WIDTH),
        .INPUT_DIM(INPUT_DIM),
        .OUTPUT_DIM(OUTPUT_DIM),
        .LEARNING_RATE(LEARNING_RATE)
    ) uut (
        .clk(clk),
        .reset(reset),
        .input_image(input_image),
        .output_error(output_error),
        .output_data(output_data),
        .input_error(input_error)
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
        input_image = '{2'b00, 2'b01, 2'b10, 2'b11}; // Assign array with a single value
        #PERIOD;
        output_error = `{2'b00, 2'b01};
        #PERIOD;
        input_image = '{2'b01, 2'b01, 2'b01, 2'b01};
        #PERIOD;
        output_error = `{2'b01, 2'b00};
        #PERIOD;
        // input_image = '{default: 32'h0};  // SystemVerilog array assignment

        // Finish simulation
        $stop;
    end


endmodule
