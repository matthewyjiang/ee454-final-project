module cnn_top 
# (
    parameter int WIDTH = 16, 
    parameter int LEARNING_RATE,
    parameter int CHANNELS = 10,
    parameter int KERNEL_DIM = 3,
    parameter int FCL_INPUT_DIM = 4,
    parameter int FCL_OUTPUT_DIM = 10,
    parameter int MAX_POOL_STRIDE = 2,
    parameter int INPUT_DIM_WIDTH = 28,
    parameter int INPUT_DIM_HEIGHT = 28,
) 
(
    input  logic clk,
    input  logic reset,
    input  logic signed [WIDTH-1:0] input_data [FCL_INPUT_DIM],
    // temp for testbench

    input logic signed [WIDTH-1:0] fcl_output_error [FCL_OUTPUT_DIM]
);

localparam MAX_POOL_INPUT_DIM_WIDTH = INPUT_DIM_WIDTH - KERNEL_DIM + 1;
localparam MAX_POOL_INPUT_DIM_HEIGHT = INPUT_DIM_HEIGHT - KERNEL_DIM + 1;
localparam MAX_POOL_OUTPUT_DIM_HEIGHT = MAX_POOL_INPUT_DIM_HEIGHT / MAX_POOL_STRIDE;
localparam MAX_POOL_OUTPUT_DIM_WIDTH = MAX_POOL_INPUT_DIM_WIDTH / MAX_POOL_STRIDE;


//signals for interfacing between conv and maxpool
logic signed [WIDTH-1:0] conv_layer_output_data [CHANNELS][MAX_POOL_INPUT_DIM_HEIGHT][MAX_POOL_INPUT_DIM_WIDTH]; // the conv output that goes to maxpool
logic signed [WIDTH-1:0] conv_layer_output_kernels [CHANNELS][KERNEL_DIM][KERNEL_DIM]; // the new values of the kernels
logic signed [WIDTH-1:0] conv_layer_input_kernels [CHANNELS][KERNEL_DIM][KERNEL_DIM]; // the old values of the kernels
logic signed [WIDTH-1:0] max_pool_input_gradient [CHANNELS][MAX_POOL_INPUT_DIM_HEIGHT][MAX_POOL_INPUT_DIM_WIDTH]; // the gradient that comes from max pool and goes to conv

//signals for interfacing between maxpool and flatten
logic signed [WIDTH-1:0] input_3D_maxpool_matrix [CHANNELS][MAX_POOL_OUTPUT_DIM_HEIGHT][MAX_POOL_OUTPUT_DIM_WIDTH]; // the error that comes from fcl to be reshaped to 3D
logic signed [WIDTH-1:0] fcl_input_error_3D_matrix [CHANNELS][MAX_POOL_OUTPUT_DIM_HEIGHT][MAX_POOL_OUTPUT_DIM_WIDTH]; // the error that comes from fcl that got reshaped to 3D
logic signed [WIDTH-1:0] output_1D_fcl_matrix [MAX_POOL_OUTPUT_DIM_HEIGHT * MAX_POOL_OUTPUT_DIM_WIDTH * CHANNELS]; // the maxpool output that got flattened to 1D



//signals for interfacing between flatten and fully connected layer
logic signed [WIDTH-1:0] fcl_input_weights [FCL_INPUT_DIM+1][FCL_OUTPUT_DIM]; // the old weights of the fcl
logic signed [WIDTH-1:0] fcl_output_weights [FCL_INPUT_DIM+1][FCL_OUTPUT_DIM]; // the new weights of the fcl
logic signed [WIDTH-1:0] fcl_output_data [FCL_OUTPUT_DIM]; // the output of the fcl to go to softmax
logic signed [WIDTH-1:0] fcl_input_error [FCL_INPUT_DIM]; // the error that comes from the fcl to be reshaped to 3D for maxpool
logic signed [WIDTH-1:0] fcl_output_error [FCL_OUTPUT_DIM]; // the error that comes from the cross entropy loss to the fcl

logic signed [WIDTH-1:0] softmax_output [FCL_OUTPUT_DIM];

// Instantiate a convolution module

/*    input   logic signed [WIDTH-1:0] input_image [INPUT_DIM_HEIGHT][INPUT_DIM_WIDTH], // Convert from 8-bit input to WIDTH-bit fixed point
    input   logic signed [WIDTH-1:0] output_error [NUM_KERNELS][OUTPUT_DIM_HEIGHT][OUTPUT_DIM_WIDTH], 
    input   logic signed [WIDTH-1:0] input_kernels [NUM_KERNELS][KERNEL_DIM][KERNEL_DIM],
    output  logic signed [WIDTH-1:0] output_data [NUM_KERNELS][OUTPUT_DIM_HEIGHT][OUTPUT_DIM_WIDTH], 
    output  logic signed [WIDTH-1:0] output_kernels [NUM_KERNELS][KERNEL_DIM][KERNEL_DIM]
*/


conv_layer #(
    .WIDTH(WIDTH),
    .NUM_KERNELS(CHANNELS),
    .KERNEL_DIM(KERNEL_DIM),
    .INPUT_DIM_WIDTH(INPUT_DIM_WIDTH),
    .INPUT_DIM_HEIGHT(INPUT_DIM_HEIGHT),
    .LEARNING_RATE(LEARNING_RATE)
) conv_layer_inst (
    .input_image(input_data),
    .output_error(max_pool_input_gradient),
    .input_kernels(conv_layer_input_kernels),
    .output_data(conv_layer_output_data),
    .output_kernels(conv_layer_output_kernels)
);

// Instantiate a maxpool module

max_pool_layer #(
    .WIDTH(WIDTH),
    .STRIDE(MAX_POOL_STRIDE),
    .INPUT_DIM_HEIGHT(MAX_POOL_INPUT_DIM_HEIGHT),
    .OUTPUT_DIM_HEIGHT(MAX_POOL_INPUT_DIM_WIDTH)
) max_pool_layer_inst (
    .input_feature_map(conv_layer_output_data),
    .output_gradient(fcl_input_error_3D_matrix),
    .output_reduced_feature_map(input_3D_maxpool_matrix),
    .input_gradient(max_pool_input_gradient)
);



flatten_layer #(
    .WIDTH(WIDTH),
    .CHANNELS(CHANNELS),
    .DIM3_WIDTH(MAX_POOL_OUTPUT_DIM_WIDTH),
    .DIM3_HEIGHT(MAX_POOL_OUTPUT_DIM_HEIGHT),
) flatten_layer_inst (
    .input_3D_maxpool_matrix(input_3D_maxpool_matrix),
    .input_1D_fcl_matrix(fcl_input_error),
    .output_3D_maxpool_matrix(fcl_input_error_3D_matrix),
    .output_1D_fcl_matrix(output_1D_fcl_matrix)
);

// Instantiate a fully connected layer module

fully_connected_layer #(
    .WIDTH(WIDTH),
    .INPUT_DIM(FCL_INPUT_DIM),
    .OUTPUT_DIM(FCL_OUTPUT_DIM),
    .LEARNING_RATE(LEARNING_RATE)
) fully_connected_layer_inst (
    .input_data(output_1D_fcl_matrix),
    .output_error(fcl_output_error),
    .input_weights(fcl_input_weights),
    .output_data(fcl_output_data),
    .input_error(fcl_input_error),
    .output_weights(fcl_output_weights)
);

// Instantiate a softmax module

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
            conv_layer_input_kernels <= conv_layer_output_kernels;
        end
    end
end

endmodule
