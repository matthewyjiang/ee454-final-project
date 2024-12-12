`timescale 1ns / 1ps

module fully_connected_tb;

    // Parameters
    parameter int WIDTH = 2;
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
    fully_connected_layer #(
        .WIDTH(WIDTH),
        .INPUT_DIM(INPUT_DIM),
        .OUTPUT_DIM(OUTPUT_DIM),
        .LEARNING_RATE(LEARNING_RATE)
    ) uut (
        .clk(clk),
        .reset(reset),
        .input_data(input_data),
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
        // input_data = '{2'b00, 2'b01, 2'b10, 2'b11}; // Assign array with a single value
        // #PERIOD;
        // output_error = `{2'b00, 2'b01};
        // #PERIOD;
        // input_data = '{2'b01, 2'b01, 2'b01, 2'b01};
        // #PERIOD;
        // output_error = `{2'b01, 2'b00};
        // #PERIOD;
        // input_data = '{default: 32'h0};  // SystemVerilog array assignment

        // Finish simulation
        $stop;
    end


endmodule
