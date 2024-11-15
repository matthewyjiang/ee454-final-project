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
        parameter int WIDTH = 16,
        parameter int STRIDE = 2, 
        parameter int INPUT_DIM_WIDTH = 32,
        parameter int INPUT_DIM_HEIGHT = 32,
        parameter int OUTPUT_DIM_WIDTH = INPUT_DIM_WIDTH / STRIDE,
        parameter int OUTPUT_DIM_HEIGHT = INPUT_DIM_HEIGHT / STRIDE,
    )
(
    input   logic clk,        // clock signal
    input   logic rst,        // reset signal 
    input   logic signed [WIDTH-1:0] input_feature_map [0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1], // INPUT: each value is 32-bit, array of 64 by 64 values
    input   logic signed [WIDTH-1:0] input_gradient [0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1], // gradient coming from layer x + 1 (if this is layer X) 
    output  logic signed [WIDTH-1:0] output_reduced_feature_map [0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1] // OUTPUT: each value is 32-bit, array of 64 by 64 values
    output  logic signed [WIDTH-1:0] output_gradient [0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1] // gradient to be passed to layer x - 1 (if this is layer X)
);

    // Temp Vars //
    logic signed [WIDTH-1:0] max_value; // should never be negative tho bc inputs are positive
    integer row, col, window_row, window_col; // Loop indices
    integer max_row, max_col; // store the temprow and col of the max value in the stride window
    logic signed [WIDTH-1:0] max_value_row_idx [0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1];
    logic signed [WIDTH-1:0] max_value_col_idx [0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1];

    // use always_ff to signify sequential logic in SystemVerilog
    /* FORWARD PROP: Max Pool .... is continous (but inputs are clocked) */
    always_comb begin
        if (rst) begin
            // make output = 0 (get rid of trash values)
            for (row = 0; row < OUTPUT_DIM_HEIGHT; row = row + 1) begin
                for (col = 0; col < OUTPUT_DIM_WIDTH; col = col + 1) begin
                    output_reduced_feature_map[row][col] = 0;
                end
            end
        end else begin 
            // max pool time LETS GET IT POG!!!
            // okay idk how to write max pool code im so happy rn!! 

            for (row = 0; row < OUTPUT_DIM_HEIGHT; row = row + 1) begin
                for (col = 0; col < OUTPUT_DIM_WIDTH; col = col + 1) begin

                    // current temp (first value) max_value of sliding window
                    max_value = input_feature_map[row * STRIDE][col * STRIDE]; 

                    // current temp loc of the max value
                    max_value_row_idx = row * STRIDE;
                    max_value_col_idx = col * STRIDE;

                    for (window_row = 0; window_row < STRIDE; window_row = window_row + 1) begin
                        for (window_col = 0; window_col < STRIDE; window_col = window_col + 1) begin
                            // within 2D stride window ... find the max value!!
                            if (input_feature_map[(row * STRIDE) + window_row][(col * STRIDE) + window_col] > max_value) begin
                                max_value = input_feature_map[(row * STRIDE) + window_row][(col * STRIDE) + window_col];
                                max_row = (row * STRIDE) + window_row; // update max row
                                max_col = (col * STRIDE) + window_col; // update max col
                            end
                        end
                    end
                    // for each (row, col) in output, find the max value (store their index row/col positions) in the stride window
                    max_value_row_idx[row][col] = max_row; 
                    max_value_col_idx[row][col] = max_col;
                    output_reduced_feature_map[row][col] = max_value;
                end
            end
        end
    end

    /* BACKWARD PROP: Gradient propagation ... is clocked */
    logic signed [WIDTH-1:0] max_gradient; // stores the gradient of the max value
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // make gradient_output = 0 (get rid of trash values)
            for (row = 0; row < INPUT_DIM_HEIGHT; row = row + 1) begin
                for (col = 0; col < INPUT_DIM_WIDTH; col = col + 1) begin
                    output_gradient[row][col] <= 0;
                end
            end
        end else begin 
            // summary: propgating layer x + 1 gradients into input loc of the layer X max_layer that was passed down
            // write BACKPROP code here ...
            for (row = 0; row < OUTPUT_DIM_HEIGHT; row = row + 1) begin
                for (col = 0; col < OUTPUT_DIM_WIDTH; col = col + 1) begin
                    max_val_gradient <= input_gradient[row][col];
                    // max_row = max_value_row_idx[row][col]; // find the max value row idx 
                    // max_col = max_value_col_idx[row][col]; // find the max value col idx
                    output_gradient[max_value_row_idx[row][col]][max_value_col_idx[row][col]] <= max_gradient; // stores the gradient of the max value in the original input loc
                end
            end
        end
    end
endmodule
