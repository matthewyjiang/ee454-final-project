module cnn_top 
# (
    parameter int WIDTH = 32, 
    parameter int FIXED_POINT_INDEX = 16,
    parameter int LEARNING_RATE = 1 << (FIXED_POINT_INDEX-1), 
    parameter int CHANNELS = 10,
    parameter int KERNEL_DIM = 3,
    parameter int FCL_OUTPUT_DIM = 10,
    parameter int MAX_POOL_STRIDE = 2,
    parameter int INPUT_DIM_WIDTH = 28,
    parameter int INPUT_DIM_HEIGHT = 28,
    parameter int NUM_IMAGES = 10000,
    parameter logic signed [WIDTH-1:0] CLIP_VALUE = 20 << FIXED_POINT_INDEX
) 
(
    input  logic clk,
    input  logic reset,
    input  logic train,

    // need these to change every OTHER clock
    input  logic signed [WIDTH-1:0] input_data [INPUT_DIM_HEIGHT][INPUT_DIM_WIDTH],
    input  logic signed [WIDTH-1:0] input_labels [FCL_OUTPUT_DIM], // assumed to be 1-hot encoded for now

    output logic softmax_done,
    output logic [$clog2(NUM_IMAGES)-1:0] input_index
    
    // temp for testbench
    // input logic signed [WIDTH-1:0] fcl_output_error [FCL_OUTPUT_DIM]
);

localparam MAX_POOL_INPUT_DIM_WIDTH = INPUT_DIM_WIDTH - KERNEL_DIM + 1; // = 26
localparam MAX_POOL_INPUT_DIM_HEIGHT = INPUT_DIM_HEIGHT - KERNEL_DIM + 1;
localparam MAX_POOL_OUTPUT_DIM_HEIGHT = MAX_POOL_INPUT_DIM_HEIGHT / MAX_POOL_STRIDE; // = 13
localparam MAX_POOL_OUTPUT_DIM_WIDTH = MAX_POOL_INPUT_DIM_WIDTH / MAX_POOL_STRIDE;

localparam FCL_INPUT_DIM = MAX_POOL_OUTPUT_DIM_HEIGHT * MAX_POOL_OUTPUT_DIM_WIDTH * CHANNELS;


//signals for interfacing between conv and maxpool
logic signed [WIDTH-1:0] conv_layer_output_data [CHANNELS][MAX_POOL_INPUT_DIM_HEIGHT][MAX_POOL_INPUT_DIM_WIDTH]; // the conv output that goes to maxpool
logic signed [WIDTH-1:0] conv_layer_output_kernels [CHANNELS][KERNEL_DIM][KERNEL_DIM]; // the new values of the kernels
logic signed [WIDTH-1:0] conv_layer_input_kernels [CHANNELS][KERNEL_DIM][KERNEL_DIM]; // the old values of the kernels
logic signed [WIDTH-1:0] max_pool_input_gradient [CHANNELS][MAX_POOL_INPUT_DIM_HEIGHT][MAX_POOL_INPUT_DIM_WIDTH]; // the gradient that comes from max pool and goes to conv

//signals for interfacing between maxpool and flatten
logic signed [WIDTH-1:0] input_3D_maxpool_matrix [CHANNELS][MAX_POOL_OUTPUT_DIM_HEIGHT][MAX_POOL_OUTPUT_DIM_WIDTH]; // the error that comes from fcl to be reshaped to 3D
logic signed [WIDTH-1:0] fcl_input_error_3D_matrix [CHANNELS][MAX_POOL_OUTPUT_DIM_HEIGHT][MAX_POOL_OUTPUT_DIM_WIDTH]; // the error that comes from fcl that got reshaped to 3D
logic signed [WIDTH-1:0] output_1D_fcl_matrix [FCL_INPUT_DIM]; // the maxpool output that got flattened to 1D

//signals for interfacing between flatten and fully connected layer
logic signed [WIDTH-1:0] fcl_input_weights [FCL_INPUT_DIM+1][FCL_OUTPUT_DIM]; // the old weights of the fcl
logic signed [WIDTH-1:0] fcl_output_weights [FCL_INPUT_DIM+1][FCL_OUTPUT_DIM]; // the new weights of the fcl
logic signed [WIDTH-1:0] fcl_output_data [FCL_OUTPUT_DIM]; // the output of the fcl to go to softmax
logic signed [WIDTH-1:0] fcl_input_error [FCL_INPUT_DIM]; // the error that comes from the fcl to be reshaped to 3D for maxpool
logic signed [WIDTH-1:0] fcl_output_error [FCL_OUTPUT_DIM]; // the error that comes from the 

logic signed [WIDTH-1:0] softmax_output [FCL_OUTPUT_DIM];
logic softmax_start;    
// logic softmax_done;
logic softmax_busy;
logic signed [WIDTH-1:0] softmax_input_clipped [FCL_OUTPUT_DIM];

logic signed [$clog2(NUM_IMAGES)-1:0] correct_count;


// Instantiate a convolution module

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
    .INPUT_DIM_WIDTH(MAX_POOL_INPUT_DIM_WIDTH),
    .CHANNELS(CHANNELS)
) max_pool_layer_inst (
    .input_feature_map(conv_layer_output_data),
    .output_gradient(fcl_input_error_3D_matrix),
    .output_reduced_feature_map(input_3D_maxpool_matrix),
    .input_gradient(max_pool_input_gradient)
);

flatten #(
    .WIDTH(WIDTH),
    .CHANNELS(CHANNELS),
    .DIM3_WIDTH(MAX_POOL_OUTPUT_DIM_WIDTH),
    .DIM3_HEIGHT(MAX_POOL_OUTPUT_DIM_HEIGHT)
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
    .LEARNING_RATE(LEARNING_RATE),
    .FIXED_POINT_INDEX(FIXED_POINT_INDEX)
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
    .DIMENSION(FCL_OUTPUT_DIM), 
    .FIXED_POINT_INDEX(FIXED_POINT_INDEX)
) softmax_inst (
    .clk(clk),
    .reset(reset),
    .start(softmax_start),
    .input_data(softmax_input_clipped),
    .output_data(softmax_output),
    .done(softmax_done),
    .busy(softmax_busy)
);

// Instantiate a cross entropy loss module

cross_entropy_loss #(
    .WIDTH(WIDTH),
    .DIMENSION(FCL_OUTPUT_DIM)
) cross_entropy_loss_inst (
    .probs(softmax_output),
    .labels(input_labels),
    .input_error(fcl_output_error),
    .loss()
);

logic [WIDTH*FCL_OUTPUT_DIM-1:0] lfsr_out;
// Instantiate a LFSR module
LFSR #(.WIDTH(WIDTH*FCL_OUTPUT_DIM)) lfsr (
    .clk(clk),
    .rst(reset),
    .out(lfsr_out)
);

typedef enum {LFSR_INIT, CONV_INIT, FCL_INIT, RUN, UPDATE_WEIGHTS, WAITING} state_t;
state_t state;
logic [$clog2(FCL_INPUT_DIM):0] fcl_i;
logic [$clog2(CHANNELS):0] conv_i;
logic signed [WIDTH-1:0] max_value;
logic [$clog2(FCL_OUTPUT_DIM)-1:0] max_index;

always_comb begin
    
    for (int i = 0; i < FCL_OUTPUT_DIM; i++) begin
        softmax_input_clipped[i] = fcl_output_data[i] >> 6;
        if (softmax_input_clipped[i] > CLIP_VALUE) begin
            softmax_input_clipped[i] = CLIP_VALUE;
        end else if (softmax_input_clipped[i] < -CLIP_VALUE) begin
            softmax_input_clipped[i] = -CLIP_VALUE;
        end 
    end
end

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        state <= LFSR_INIT;
        input_index <= 0;
        
    end 
    else begin
        case (state)
            LFSR_INIT: begin
                state <= CONV_INIT;
                conv_i <= 0;
                fcl_i <= 0;
            end

            CONV_INIT: begin
                // Initialize kernels to random (am assuming k^2 < FCL_OUTPUT_DIM -- if not, instantiate new lfsr for kernel init)
                for (int j = 0; j < KERNEL_DIM; j++) begin
                    for (int k = 0; k < KERNEL_DIM; k++) begin
                        conv_layer_input_kernels[conv_i][j][k] <= (lfsr_out[j*KERNEL_DIM*WIDTH + k*WIDTH +: WIDTH]) >> (WIDTH-FIXED_POINT_INDEX/2+3);
                    end
                end

                conv_i <= conv_i + 1;

                if (conv_i == CHANNELS-1) begin
                    state <= FCL_INIT;
                end
            end

            FCL_INIT: begin
                // Initialize weights and biases to random
                for (int j = 0; j < FCL_OUTPUT_DIM; j++) begin
                    fcl_input_weights[fcl_i][j] <= (lfsr_out[j*WIDTH +: WIDTH]) >> (WIDTH-FIXED_POINT_INDEX/2+3);
                end

                fcl_i <= fcl_i + 1;

                if (fcl_i == FCL_INPUT_DIM) begin // Question: should this be FCL_INPUT_DIM or FCL_INPUT_DIM+1? since 0-indexing
                    state <= RUN;
                end
            end

            RUN: begin
                // dummy state for propagation delay
                state <= WAITING;
            end

            WAITING: begin
                // wait for softmax to finish
                if (!softmax_busy) begin
                    softmax_start <= 1;
                end else begin
                    softmax_start <= 0;
                end

                if (softmax_done) begin
                    state <= UPDATE_WEIGHTS;
                end

            end

            UPDATE_WEIGHTS: begin
                // update weights
                if (train) begin
                    fcl_input_weights <= fcl_output_weights;
                    conv_layer_input_kernels <= conv_layer_output_kernels;
                end
                
                // update correct count
                max_index = 0;
                max_value = fcl_output_data[0];

                for (int i = 1; i < FCL_OUTPUT_DIM; i++) begin
                    if (fcl_output_data[i] > max_value) begin
                        max_value = fcl_output_data[i];
                        max_index = i;                 
                    end
                end

                if (input_labels[max_index] == 1) begin
                    correct_count <= correct_count + 1;
                end

                // display accuracy
                $display("Accuracy: %d/%d", correct_count, input_index);

                // change the image
                input_index <= input_index + 1;
                state <= RUN;
            end

        endcase
    end

end

endmodule
