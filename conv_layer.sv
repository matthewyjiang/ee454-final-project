module conv_layer 
    #(
        parameter int WIDTH = 16,                                               // bit width of input data 
        parameter int NUM_KERNELS = 10,                                         // number of kernels
        parameter int KERNEL_DIM = 3,                                           // width of kernel
        parameter int INPUT_DIM_WIDTH = 28,                                     // WIDTH of input feature map
        parameter int INPUT_DIM_HEIGHT = 28,                                    // HEIGHT of input feature map
        parameter int OUTPUT_DIM_WIDTH = INPUT_DIM_WIDTH - KERNEL_DIM + 1,      // WIDTH of output feature map
        parameter int OUTPUT_DIM_HEIGHT = INPUT_DIM_HEIGHT - KERNEL_DIM + 1,    // HEIGHT of output feature map
        parameter int LEARNING_RATE = 1                                         // learning rate
    )
(
    input   logic signed [WIDTH-1:0] input_image [INPUT_DIM_HEIGHT][INPUT_DIM_WIDTH], // Convert from 8-bit input to WIDTH-bit fixed point
    input   logic signed [WIDTH-1:0] output_error [NUM_KERNELS][OUTPUT_DIM_HEIGHT][OUTPUT_DIM_WIDTH], 
    input   logic signed [WIDTH-1:0] input_kernels [NUM_KERNELS][KERNEL_DIM][KERNEL_DIM],
    output  logic signed [WIDTH-1:0] output_data [NUM_KERNELS][OUTPUT_DIM_HEIGHT][OUTPUT_DIM_WIDTH], 
    output  logic signed [WIDTH-1:0] output_kernels [NUM_KERNELS][KERNEL_DIM][KERNEL_DIM]
);

    // used for loop indices 
    integer row, col;               // entire feature map
    integer window_row, window_col; // entire kernel
    integer kernel_idx;             // number of kernels

    always_comb begin
        /****************/
        /* Forward Pass */
        /****************/
        // loop through every kernel
        for (kernel_idx = 0; kernel_idx < NUM_KERNELS; kernel_idx = kernel_idx + 1) begin
            // loop through every possible kernel window
            for (row = 0; row < OUTPUT_DIM_HEIGHT; row = row + 1) begin
                for (col = 0; col < OUTPUT_DIM_WIDTH; col = col + 1) begin
                    // compute kernel conv
                    integer sum = 0;
                    for (window_row = 0; window_row < KERNEL_DIM; window_row = window_row + 1) begin
                        for (window_col = 0; window_col < KERNEL_DIM; window_col = window_col + 1) begin
                            sum = sum + input_image[row + window_row][col + window_col] * input_kernels[kernel_idx][window_row][window_col];
                        end
                    end
                    output_data[kernel_idx][row][col] = sum;
                end
            end
        end

        /*****************/
        /* Backward Pass */
        /*****************/
        // loop through every kernel
        for (kernel_idx = 0; kernel_idx < NUM_KERNELS; kernel_idx = kernel_idx + 1) begin
            // loop through every possible kernel window
            for (row = 0; row < OUTPUT_DIM_HEIGHT; row = row + 1) begin
                for (col = 0; col < OUTPUT_DIM_WIDTH; col = col + 1) begin
                    for (window_row = 0; window_row < KERNEL_DIM; window_row = window_row + 1) begin
                        for (window_col = 0; window_col < KERNEL_DIM; window_col = window_col + 1) begin
                            output_kernels[kernel_idx][window_row][window_col] += LEARNING_RATE*output_error[kernel_idx][row][col] * input_image[row + window_row][col + window_col];
                        end
                    end
                end
            end
        end
    end
endmodule
