module flatten 
    #(
        parameter int WIDTH = 16,                                    // bit width of input 
        parameter int DIM2_WIDTH = 32,                             // WIDTH of 2D Matrix
        parameter int DIM2_HEIGHT = 32,                            // HEIGHT of 2D Matrix
        parameter int DIM1_LENGTH = DIM2_WIDTH * DIM2_HEIGHT // WIDTH of output feature map
    )
(
    input   logic clk,        // clock signal
    input   logic signed [WIDTH-1:0] input_2D_maxpool_matrix [0:DIM2_HEIGHT-1][0:DIM2_WIDTH-1],     // (from layer X-1) 
    input   logic signed [WIDTH-1:0] input_1D_fcl_matrix [0:DIM1_LENGTH-1],                     // (to layer X-1) 
    output  logic signed [WIDTH-1:0] output_2D_maxpool_matrix [0:DIM2_HEIGHT-1][0:DIM2_WIDTH-1],    // (from layer X+1)
    output  logic signed [WIDTH-1:0] output_1D_fcl_matrix [0:DIM1_LENGTH-1]                     // (to layer X+1) 
);

    // Temp Vars //
    int row, col, idx;

    always_comb begin

        /*******************************/
        /* Flatten Forward Propogation */
        /*******************************/
        
        // Flatten 2D matrix into 1D array
        idx = 0;  // Initialize 1D index
        for (row = 0; row < DIM2_HEIGHT; row = row + 1) begin
            for (col = 0; col < DIM2_WIDTH; col = col + 1) begin
                output_1D_fcl_matrix[idx] = input_2D_maxpool_matrix[row][col];
                idx = idx + 1;
            end
        end

        /*********************************/
        /* Flatten Backwards Propogation */
        /*********************************/
        
        // Expand 1D array back into 2D matrix
        idx = 0;  // Reinitialize 1D index
        for (row = 0; row < DIM2_HEIGHT; row = row + 1) begin
            for (col = 0; col < DIM2_WIDTH; col = col + 1) begin
                output_2D_maxpool_matrix[row][col] = input_1D_fcl_matrix[idx];
                idx = idx + 1;
            end
        end

    end
endmodule
