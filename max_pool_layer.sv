/* Initialization */
// stride = step size of pooling window (stride = 2 means division of input spatial dimentions by half)

/* Forward Prop */ 
// for a window (stride x stride size) in featureMap, find the biggest value
// supposed to keep "most significant" information but also down sample 

/* Backward Prop */
// error gradient propogated to the input loc that had max value in forward prop (value that was initially passed onto nexxt layer in forward prop)
// other values in the window are set to 0 (i think??)

module max_pool_layer 
    #(
        parameter int WIDTH = 16,                                       // bit width of input ata 
        parameter int CHANNELS = 2,                                       // bit width of input ata 
        parameter int STRIDE = 2,                                       // DIM of pooling window
        parameter int INPUT_DIM_WIDTH = 32,                             // WIDTH of input feature map
        parameter int INPUT_DIM_HEIGHT = 32,                            // HEIGHT of input feature map
        parameter int OUTPUT_DIM_WIDTH = INPUT_DIM_WIDTH / STRIDE,      // WIDTH of output feature map
        parameter int OUTPUT_DIM_HEIGHT = INPUT_DIM_HEIGHT / STRIDE     // HEIGHT of output feature map
    )
(
    input   logic signed [WIDTH-1:0] input_feature_map [0:CHANNELS-1][0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1], // (from layer X-1) INPUT: each value is 32-bit, array of 64 by 64 values
    input   logic signed [WIDTH-1:0] output_gradient [0:CHANNELS-1][0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1], // (to layer X-1) gradient coming from layer x + 1 (if this is layer X) 
    output  logic signed [WIDTH-1:0] output_reduced_feature_map [0:CHANNELS-1][0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1], // (from layer X+1) OUTPUT: each value is 32-bit, array of 64 by 64 values
    output  logic signed [WIDTH-1:0] input_gradient [0:CHANNELS-1][0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1] // (to layer X-1) gradient to be passed to layer x - 1 (if this is layer X)
);

    // Temp Vars //

    // related to storing the max value in the stride window + reference to its location
    // logic signed [WIDTH-1:0] largest_val_in_window; // should never be negative tho bc inputs are positive
    logic signed [WIDTH-1:0] max_sliding_value_row_idx [0:CHANNELS-1][0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1];
    logic signed [WIDTH-1:0] max_sliding_value_col_idx [0:CHANNELS-1][0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1];
    integer largest_val_in_window, temp_max_value_row_idx, temp_max_value_col_idx;

    // used for loop indices 
    integer ch, row, col;               // (entire feature map)
    integer window_row, window_col; // (entire sliding window)

    // stores 
    integer max_val_gradient, temp_gradient_row_idx, temp_gradient_col_idx;
    
    always_comb begin

        /*******************************/
        /* MaxPool Forward Propogation */
        /*******************************/

        // Input Feature Map: loop through every possible sliding window
        for (ch = 0; ch < CHANNELS; ch = ch + 1) begin
            for (row = 0; row < OUTPUT_DIM_HEIGHT; row = row + 1) begin
                for (col = 0; col < OUTPUT_DIM_WIDTH; col = col + 1) begin
                    
                    // Initialize (first) potential max value in this sliding window
                    largest_val_in_window = input_feature_map[ch][row * STRIDE][col * STRIDE]; 
                    temp_max_value_row_idx = row * STRIDE;
                    temp_max_value_col_idx = col * STRIDE;

                    // Logic to evaluate other options in the sliding window
                    for (window_row = 0; window_row < STRIDE; window_row = window_row + 1) begin
                        for (window_col = 0; window_col < STRIDE; window_col = window_col + 1) begin
                            if (input_feature_map[ch][(row * STRIDE) + window_row][(col * STRIDE) + window_col] > largest_val_in_window) begin
                                
                                // Identified a larger value in the sliding window, store as "max" value + its coordinates 
                                largest_val_in_window = input_feature_map[ch][(row * STRIDE) + window_row][(col * STRIDE) + window_col];
                                temp_max_value_row_idx = (row * STRIDE) + window_row; // update max row
                                temp_max_value_col_idx = (col * STRIDE) + window_col; // update max col
                            end
                        end
                    end

                    // Temporarily Serialize the "largest" value this window + reference to its location
                    max_sliding_value_row_idx[ch][row][col] = temp_max_value_row_idx; 
                    max_sliding_value_col_idx[ch][row][col] = temp_max_value_col_idx;
                    output_reduced_feature_map[ch][row][col] = largest_val_in_window; // identified value for output feature map
                end
            end
        end

        /*********************************/
        /* MaxPool Backwards Propogation */
        /*********************************/

        // Init all passed gradients to 0 
        for (ch = 0; ch < CHANNELS; ch = ch + 1) begin 
            for (row = 0; row < INPUT_DIM_HEIGHT; row = row + 1) begin 
                for (col = 0; col < INPUT_DIM_WIDTH; col = col + 1) begin 
                    input_gradient[ch][row][col] = 0;
                end
            end
        end

        // Loop through each gradient value 
        for (ch = 0; ch < CHANNELS; ch = ch + 1) begin 
            for (row = 0; row < OUTPUT_DIM_HEIGHT; row = row + 1) begin
                for (col = 0; col < OUTPUT_DIM_WIDTH; col = col + 1) begin
                    
                    // Pull out the gradient value 
                    max_val_gradient = output_gradient[ch][row][col];

                    if (max_val_gradient >= 0) begin 
                        // Identify idx location to store the gradient value
                        temp_gradient_row_idx = max_sliding_value_row_idx[ch][row][col]; // find the max value row idx 
                        temp_gradient_col_idx = max_sliding_value_col_idx[ch][row][col]; // find the max value col idx

                        // Store the gradient value
                        input_gradient[ch][temp_gradient_row_idx][temp_gradient_col_idx] = max_val_gradient;
                    end
                end
            end
        end
    end
endmodule
