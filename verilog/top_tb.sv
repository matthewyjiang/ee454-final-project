`timescale 1ps / 1ps

module top_tb;

    // Parameters
    parameter int WIDTH = 48;
    parameter int INPUT_DIM_HEIGHT = 10;
    parameter int INPUT_DIM_WIDTH = 10;
    parameter int FCL_OUTPUT_DIM = 10;
    parameter int PERIOD = 4;
    parameter int INPUT_SIZE = INPUT_DIM_HEIGHT * INPUT_DIM_WIDTH;
    parameter int NUM_IMAGES = 1000;
    parameter int TEST_LENGTH = 5;

    // Inputs
    logic clk;
    logic reset;
    logic signed [WIDTH-1:0] input_data  [INPUT_DIM_HEIGHT][INPUT_DIM_WIDTH];
    logic signed [WIDTH-1:0] input_labels [FCL_OUTPUT_DIM];
    logic softmax_done;
    logic signed [$clog2(NUM_IMAGES)-1:0] input_index;
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
        .FCL_OUTPUT_DIM(FCL_OUTPUT_DIM),
        .NUM_IMAGES(NUM_IMAGES)
    ) uut (
        .clk(clk),
        .reset(reset),
        .input_data(input_data),
        .input_labels(input_labels),
        .softmax_done(softmax_done),
        .input_index(input_index),
        .train(1'b1)
    );

    logic signed [WIDTH-1:0] image_mem [NUM_IMAGES*INPUT_SIZE];
    logic signed [WIDTH-1:0] label_mem [NUM_IMAGES*FCL_OUTPUT_DIM];

    always @(input_index) begin
        for(int row = 0; row < INPUT_DIM_HEIGHT; row++) begin
            for(int col = 0; col < INPUT_DIM_WIDTH; col++) begin
                input_data[row][col] = image_mem[input_index * INPUT_SIZE + row * INPUT_DIM_WIDTH + col];
            end
        end
        for(int label = 0; label < FCL_OUTPUT_DIM; label++) begin
            input_labels[label] = label_mem[input_index * FCL_OUTPUT_DIM + label];
            $display("Label %0d: %0h", label, input_labels[label]);
        end
        
    end

    // Stimulus
    initial begin
        // Initialize Inputs
        $readmemh("scripts/mnist_images.mem", image_mem);
        $readmemh("scripts/mnist_labels.mem", label_mem);


        
        reset = 1;
        #10;
        reset = 0;
        #10;
        reset = 1;

        // IMPORTANT: Input needs to be ready before changing to RUN state. else will overwrite everything with X
        #(1700*PERIOD); // wait for initialization
        // = 10 kernels + 28-3+1 = 26x26 => 13x13 = 169*10 + 10
        // #75;



        for (int j = 0; j < TEST_LENGTH; j++) begin
            
            @(posedge softmax_done);
        end 

        // #1000;

        // input_data = '{default: 32'h0};  // SystemVerilog array assignment

        // Finish simulation
        $stop;
    end


endmodule
