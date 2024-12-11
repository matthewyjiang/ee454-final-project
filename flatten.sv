module flatten 
    #(
        parameter int WIDTH = 16,                                   // bit width of input 
        parameter int CHANNELS = 3,                                 // channels
        parameter int DIM3_WIDTH = 32,                              // WIDTH of 3D Matrix
        parameter int DIM3_HEIGHT = 32                             // HEIGHT of 3D Matrix
        parameter int  DIM1_LENGTH = CHANNELS * DIM3_WIDTH * DIM3_HEIGHT;
    )
(
    input   logic signed [WIDTH-1:0] input_3D_maxpool_matrix [0:CHANNELS-1][0:DIM3_HEIGHT-1][0:DIM3_WIDTH-1],     // (from layer X-1) 
    input   logic signed [WIDTH-1:0] input_1D_fcl_matrix [0:DIM1_LENGTH-1],                     // (to layer X-1) 
    output  logic signed [WIDTH-1:0] output_3D_maxpool_matrix [0:CHANNELS-1][0:DIM3_HEIGHT-1][0:DIM3_WIDTH-1],    // (from layer X+1)
    output  logic signed [WIDTH-1:0] output_1D_fcl_matrix [0:DIM1_LENGTH-1]                     // (to layer X+1) 
);

    // Temp Vars //
    int row, col, ch, idx;

    

    always_comb begin

        /*******************************/
        /* Flatten Forward Propogation */
        /*******************************/
        
        // Flatten 3D matrix into 1D array
        idx = 0;  // Initialize 1D index
        for (ch = 0; ch < CHANNELS; ch = ch + 1) begin 
            for (row = 0; row < DIM3_HEIGHT; row = row + 1) begin
                for (col = 0; col < DIM3_WIDTH; col = col + 1) begin
                    output_1D_fcl_matrix[idx] = input_3D_maxpool_matrix[ch][row][col];
                    idx = idx + 1;
                end
            end
        end

        /*********************************/
        /* Flatten Backwards Propogation */
        /*********************************/
        
        // Expand 1D array back into 3D matrix
        idx = 0;  // Reinitialize 1D index
        for (ch = 0; ch < CHANNELS; ch = ch + 1) begin 
            for (row = 0; row < DIM3_HEIGHT; row = row + 1) begin
                for (col = 0; col < DIM3_WIDTH; col = col + 1) begin
                    output_3D_maxpool_matrix[ch][row][col] = input_1D_fcl_matrix[idx];
                    idx = idx + 1;
                end
            end
        end
    end
endmodule
