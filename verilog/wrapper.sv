module wrapper
# (
    parameter int WIDTH = 48;
    parameter int INPUT_DIM_HEIGHT = 10;
    parameter int INPUT_DIM_WIDTH = 10;
    parameter int FCL_OUTPUT_DIM = 10;
    parameter int PERIOD = 4;
    parameter int INPUT_SIZE = INPUT_DIM_HEIGHT * INPUT_DIM_WIDTH;
    parameter int NUM_IMAGES = 1000;
    parameter int TEST_LENGTH = 5;
) 
(   logic clk,
    logic reset
);


    logic signed [WIDTH-1:0] input_data  [INPUT_DIM_HEIGHT][INPUT_DIM_WIDTH];
    logic signed [WIDTH-1:0] input_labels [FCL_OUTPUT_DIM];
    logic signed [$clog2(NUM_IMAGES)-1:0] input_index

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

    // hardcode the input data and labels
    always @(posedge clk) begin
        if (!reset) begin
            // manually set the input data and labels
            ...
        end
    end

    always @(input_index) begin
        for(int row = 0; row < INPUT_DIM_HEIGHT; row++) begin
            for(int col = 0; col < INPUT_DIM_WIDTH; col++) begin
                input_data[row][col] = image_mem[input_index * INPUT_SIZE + row * INPUT_DIM_WIDTH + col];
            end
        end
        for(int label = 0; label < FCL_OUTPUT_DIM; label++) begin
            input_labels[label] = label_mem[input_index * FCL_OUTPUT_DIM + label];
        end
        
    end


endmodule