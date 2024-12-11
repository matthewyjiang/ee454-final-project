module cnn_top 
# (
    parameter int WIDTH = 16, 
    parameter int LEARNING_RATE,
    parameter int FCL_INPUT_DIM = 4,
    parameter int FCL_OUTPUT_DIM = 10
) 
(
    input  logic clk,
    input  logic reset,
    input  logic signed [WIDTH-1:0] input_data [FCL_INPUT_DIM],
    // temp for testbench

    input logic signed [WIDTH-1:0] fcl_output_error [FCL_OUTPUT_DIM]
);

logic signed [WIDTH-1:0] fcl_input_weights [FCL_INPUT_DIM+1][FCL_OUTPUT_DIM];
logic signed [WIDTH-1:0] fcl_output_weights [FCL_INPUT_DIM+1][FCL_OUTPUT_DIM];
logic signed [WIDTH-1:0] fcl_output_data [FCL_OUTPUT_DIM];
logic signed [WIDTH-1:0] fcl_input_error [FCL_INPUT_DIM];
// logic signed [WIDTH-1:0] fcl_output_error [FCL_OUTPUT_DIM];

logic signed [WIDTH-1:0] softmax_output [FCL_OUTPUT_DIM];

fully_connected_layer #(
    .WIDTH(WIDTH),
    .INPUT_DIM(FCL_INPUT_DIM),
    .OUTPUT_DIM(FCL_OUTPUT_DIM),
    .LEARNING_RATE(LEARNING_RATE)
) fully_connected_layer_inst (
    .clk(clk),
    .reset(reset),
    .input_data(input_data),
    .output_error(fcl_output_error),
    .input_weights(fcl_input_weights),
    .output_data(fcl_output_data),
    .input_error(fcl_input_error),
    .output_weights(fcl_output_weights)
);

softmax #(
    .WIDTH(WIDTH),
    .DIMENSION(FCL_OUTPUT_DIM)
) softmax_inst (
    .input_data(fcl_output_data),
    .output_data(softmax_output)
);

logic [WIDTH*FCL_OUTPUT_DIM-1:0] lfsr_out;
// Instantiate a LFSR module
LFSR #(.WIDTH(WIDTH*FCL_OUTPUT_DIM)) lfsr (
    .clk(clk),
    .rst(reset),
    .out(lfsr_out)
);

typedef enum {LFSR_INIT, INIT, RUN} state_t;
state_t state;
logic [$clog2(FCL_INPUT_DIM):0] i;

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        state <= LFSR_INIT;
    end 
    else if (state == LFSR_INIT) begin
        state <= INIT;
        i <= 0;
    end
    else begin
        if(state == INIT) begin
            // Initialize weights and biases to random
            for(int j = 0; j < FCL_OUTPUT_DIM; j++) begin
                fcl_input_weights[i][j] <= lfsr_out[j*WIDTH +: WIDTH];
            end
            i <= i + 1;

            if(i == FCL_INPUT_DIM+1) begin
                state <= RUN;
            end
        end
        else if(state == RUN) begin
            // update weights
            fcl_input_weights <= fcl_output_weights;
        end
    end
end

endmodule
