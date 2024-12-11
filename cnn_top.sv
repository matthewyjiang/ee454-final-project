module cnn_top 
# (
    parameter int WIDTH = 16, 
    parameter int LEARNING_RATE,
    parameter int FCL_INPUT_DIM = 4,
    parameter int FCL_OUTPUT_DIM = 10,
) 

(
    input  logic clk,
    input  logic reset,
);


signed logic [WIDTH-1:0] fcl_input_weights [FCL_OUTPUT_DIM][FCL_INPUT_DIM];
signed logic [WIDTH-1:0] fcl_output_weights [FCL_OUTPUT_DIM][FCL_INPUT_DIM];

module fully_connected_layer 
    #(
        .WIDTH(WIDTH),
        .INPUT_DIM(FCL_INPUT_DIM),
        .OUTPUT_DIM(FCL_OUTPUT_DIM),
        .LEARNING_RATE(LEARNING_RATE)
    )
    fully_connected_layer_inst (
        .clk(clk),
        .reset(reset),
        .input_data(),
        .output_error(),
        .input_weights(fcl_input_weights),
        .output_data(),
        .input_error(),
        .output_weights(fcl_output_weights)
    );

logic [WIDTH*OUTPUT_DIM-1:0] lfsr_out;
// Instantiate a LFSR module
LFSR #(.WIDTH(WIDTH*OUTPUT_DIM)) lfsr (
    .clk(clk),
    .rst(reset),
    .out(lfsr_out)
);

state_t state;
typedef enum {INIT, RUN} state_t;
logic [$clog2(INPUT_DIM)-1:0] j;

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        state <= 0;
        j <= 0;
    end else begin
        if(state == INIT) begin
            // Initialize weights and biases to zero (or random later)
            for(int i = 0; i < OUTPUT_DIM; i++) begin
                weights[j][i] <= lfsr_out[i*WIDTH-1 +: WIDTH];
            end
            j <= j + 1;

            if(j == INPUT_DIM) begin
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