module flatten 
    #(
        parameter int WIDTH = 16,                                    // bit width of input 
        parameter int 2D_DIM_WIDTH = 32,                             // WIDTH of 2D Matrix
        parameter int 2D_DIM_HEIGHT = 32,                            // HEIGHT of 2D Matrix
        parameter int 1D_ARRAY_LENGTH = 2D_DIM_WIDTH * 2D_DIM_HEIGHT // WIDTH of output feature map
    )
(
    input   logic clk,        // clock signal
    input   logic signed [WIDTH-1:0] input_2D_matrix [0:2D_DIM_HEIGHT-1][0:2D_DIM_WIDTH-1],     // (from layer X-1) 
    input   logic signed [WIDTH-1:0] input_1D_matrix [0:1D_ARRAY_LENGTH-1],                     // (to layer X-1) 
    output  logic signed [WIDTH-1:0] output_2D_matrix [0:2D_DIM_HEIGHT-1][0:2D_DIM_WIDTH-1],    // (from layer X+1)
    output  logic signed [WIDTH-1:0] output_1D_matrix [0:1D_ARRAY_LENGTH-1]                     // (to layer X+1) 
);

    // Temp Vars //

    always_comb begin

        /*******************************/
        /* Flatten Forward Propogation */
        /*******************************/

        /*********************************/
        /* Flatten Backwards Propogation */
        /*********************************/

    end
endmodule
