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
    output  logic signed [WIDTH-1:0] output_reduced_feature_map [0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1] // OUTPUT: each value is 32-bit, array of 64 by 64 values
);

    // Temp Vars //
    logic signed [WIDTH-1:0] max_value; // should never be negative tho bc inputs are positive
    integer row, col, window_row, window_col; // Loop indices

    // use always_ff to signify sequential logic in SystemVerilog
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // make output = 0 (get rid of trash values)
            for (row = 0; row < OUTPUT_DIM_HEIGHT; row = row + 1) begin
                for (col = 0; col < OUTPUT_DIM_WIDTH; col = col + 1) begin
                    output_reduced_feature_map[row][col] <= 0;
                end
            end
        end else begin 
            // max pool time LETS GET IT POG!!!
            // okay idk how to write max pool code im so happy rn!! 

            for (row = 0; row < OUTPUT_DIM_HEIGHT; row = row + 1) begin
                for (col = 0; col < OUTPUT_DIM_WIDTH; col = col + 1) begin
                    max_value = input_feature_map[row * STRIDE][col * STRIDE]; // first value per window is ur default max value
                    for (window_row = 0; window_row < STRIDE; window_row = window_row + 1) begin
                        for (window_col = 0; window_col < STRIDE; window_col = window_col + 1) begin
                            // within 2D stride window ... find the max value!!
                            if (input_feature_map[(row * STRIDE) + window_row][(col * STRIDE) + window_col] > max_value) begin
                                max_value = input_feature_map[(row * STRIDE) + window_row][(col * STRIDE) + window_col];
                            end
                        end
                    end
                    // for each (row, col) in output, find the max value in the stride window
                    output_reduced_feature_map[row][col] <= max_value;
                end
            end
        end
    end
endmodule
