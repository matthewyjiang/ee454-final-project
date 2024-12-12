`timescale 1ns / 1ps

module top_tb;

    // Parameters
    parameter int WIDTH = 32;
    parameter int INPUT_DIM_HEIGHT = 28;
    parameter int INPUT_DIM_WIDTH = 28;
    parameter int OUTPUT_DIM = 10;
    parameter int LEARNING_RATE = 0.25;
    parameter int PERIOD = 10;
    parameter int TEST_LENGTH = 100;

    // Inputs
    logic clk;
    logic reset;
    logic signed [WIDTH-1:0] input_data [INPUT_DIM_HEIGHT][INPUT_DIM_WIDTH];
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

        for (int i = 0; i < TEST_LENGTH; i++) begin
            
            // read input data from mem file
            $readmemh("mnist_images.mem", input_data);

            // Generate random output error
            for (int j = 0; j < OUTPUT_DIM; j++) begin
                output_error[j] = $random;
            end

            // Wait for some time
            #10;
        end

        #1000;

        // input_data = '{default: 32'h0};  // SystemVerilog array assignment

        // Finish simulation
        $stop;
    end


endmodule
