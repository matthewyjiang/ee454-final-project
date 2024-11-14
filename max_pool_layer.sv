/* Initialization */
// stride = step size of pooling window (stride = 2 means division of input spatial dimentions by half)

/* Forward Prop */ 
// for a window (stride x stride size) in featureMap, find the biggest value
// supposed to keep "most significant" information but also down sample 

/* Backward Prop */
// error gradient propogated to the input loc that had max value in forward prop (value that was initially passed onto nexxt layer in forward prop)
// other values in the window are set to 0 (i think??)

module max_pool_layer #(
    parameter WIDTH = 16,
    parameter STRIDE = 2, 
    parameter INPUT_DIM_WIDTH = 32,
    parameter INPUT_DIM_HEIGHT = 32,
    parameter OUTPUT_DIM_WIDTH = INPUT_DIM_WIDTH / STRIDE,
    parameter OUTPUT_DIM_HEIGHT = INPUT_DIM_HEIGHT / STRIDE,
)(
    input logic clk,        // clock signal
    input logic rst,        // reset signal 
    input signed logic [WIDTH-1:0] input_feature_map [0:INPUT_DIM_HEIGHT-1][0:INPUT_DIM_WIDTH-1], // INPUT: each value is 32-bit, array of 64 by 64 values
    output signed logic [WIDTH-1:0] output_feature_map [0:OUTPUT_DIM_HEIGHT-1][0:OUTPUT_DIM_WIDTH-1] // OUTPUT: each value is 32-bit, array of 64 by 64 values
);

    // Temp Vars //
    logic signed [WIDTH-1:0] max_value; // should never be negative tho bc inputs are positive
    integer output_row, output_col, x, y; // Loop indices

    // use always_ff to signify sequential logic in SystemVerilog
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // make output = 0 (get rid of trash values)
            for (output_row = 0; output_row < OUTPUT_DIM_HEIGHT; output_row = output_row + 1) begin
                for (output_col = 0; output_col < OUTPUT_DIM_WIDTH; output_col = output_col + 1) begin
                    output_feature_map[output_row][output_col] <= 0;
                end
            end
        end else begin 
            // max pool time LETS GET IT POG!!!
            // okay idk how to write max pool code im so happy rn!! 
        end
    end


endmodule
