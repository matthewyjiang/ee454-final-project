`timescale 1ps / 1ps

module top_tb;

    // Parameters
    parameter int WIDTH = 32;
    parameter int INPUT_DIM_HEIGHT = 4;
    parameter int INPUT_DIM_WIDTH = 4;
    parameter int FCL_OUTPUT_DIM = 10;
    parameter int PERIOD = 4;
    parameter int TEST_LENGTH = 100;

    // Inputs
    logic clk;
    logic reset;
    logic signed [WIDTH-1:0] input_data  [INPUT_DIM_HEIGHT][INPUT_DIM_WIDTH];
    logic signed [WIDTH-1:0] input_labels [FCL_OUTPUT_DIM];
    // Clock generation
    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end

    // Instantiate Unit Under Test (UUT)
    cnn_top #(
        .WIDTH(WIDTH),
        .INPUT_DIM_HEIGHT(INPUT_DIM_HEIGHT),
        .INPUT_DIM_WIDTH(INPUT_DIM_WIDTH),
        .FCL_OUTPUT_DIM(FCL_OUTPUT_DIM)
    ) uut (
        .clk(clk),
        .reset(reset),
        .input_data(input_data),
        .input_labels(input_labels)
    );
    // Stimulus
    initial begin
        // Initialize Inputs
        reset = 1;
        #10;
        reset = 0;
        #10;
        reset = 1;

        // #(1720*PERIOD); // wait for initialization
        #75; // Input needs to be ready before changing to RUN state. else will overwrite everything with X

        for (int i = 0; i < 5; i++) begin
            
            // read input data from mem file
            $readmemh("C:/Users/cl917/OneDrive/Documents/Classes/ee454/ee454-final-project/verilog/test.mem", input_data);

            // set input labels
            input_labels = '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            input_labels[i % FCL_OUTPUT_DIM] = 1;
            

            // two clocks for forward, backward pass
            #(PERIOD*2);
        end

        // #1000;

        // input_data = '{default: 32'h0};  // SystemVerilog array assignment

        // Finish simulation
        $stop;
    end


endmodule
