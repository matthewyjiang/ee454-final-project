module fully_connected_layer #(parameter WIDTH = 16; parameter INPUT_DIM; parameter OUTPUT_DIM; parameter LEARNING_RATE)
(
    input wire clk,
    input wire reset,
    input signed wire [WIDTH-1:0] input_data [0:INPUT_DIM-1],
    input signed wire [WIDTH-1:0] output_error [0:OUTPUT_DIM-1],
    output signed wire [WIDTH-1:0] output_data [0:OUTPUT_DIM-1],
    output signed wire [WIDTH-1:0] input_error [0:INPUT_DIM-1]


    // i made learning rate a parameter, but it could be an input as well in case we need to do scheduling
)

    reg signed [WIDTH-1:0] weights [0:OUTPUT_DIM-1][0:INPUT_DIM-1];
    reg signed [WIDTH-1:0] bias [0:OUTPUT_DIM-1];
    reg signed [2*WIDTH-1:0] sum [0:OUTPUT_DIM-1];

    // forward pass (combinational logic)

    always @(*) begin
        for (i = 0; i < OUTPUT_DIM; i = i + 1) begin
            output_data[i] = bias[i];
            for (j = 0; j < INPUT_DIM; j = j + 1) begin
                output_data[i] += input_data[j] * weights[i][j];
            end
        end
    end

    // backward pass (sequential logic)
    always @(posedge clk, negedge reset) begin
        if (!reset) begin // i've temporarily made these initalize to zeros, but they need to be random
            for (i = 0; i < OUTPUT_DIM; i = i + 1) begin
                bias[i] <= 0;
                for (j = 0; j < INPUT_DIM; j = j + 1) begin
                    weights[i][j] <= 0;
                end
            end
        end

        // need to finish this...

        // compute input error and weight error using output error as input from last layer
        // update weights and bias using learning rate

        // new "input layer" is used as an input to the next layer and is named as follows
        // matrix multiplication is so hard cry


    end

endmodule