module flatten_tb;

    // init parameters
    parameter int WIDTH = 16;                                    // Bit width of input
    parameter int DIM2_WIDTH = 4;                              // WIDTH of 2D Matrix (Reduced for testing)
    parameter int DIM2_HEIGHT = 4;                             // HEIGHT of 2D Matrix
    parameter int DIM1_LENGTH = DIM2_WIDTH * DIM2_HEIGHT; // WIDTH of output feature map

    // init signals
    logic clk;
    logic signed [WIDTH-1:0] input_2D_maxpool_matrix [0:DIM2_HEIGHT-1][0:DIM2_WIDTH-1];
    logic signed [WIDTH-1:0] input_1D_fcl_matrix [0:DIM1_LENGTH-1];
    logic signed [WIDTH-1:0] output_2D_maxpool_matrix [0:DIM2_HEIGHT-1][0:DIM2_WIDTH-1];
    logic signed [WIDTH-1:0] output_1D_fcl_matrix [0:DIM1_LENGTH-1];

    // uut the flatten module
    flatten #(
        .WIDTH(WIDTH),
        .DIM2_WIDTH(DIM2_WIDTH),
        .DIM2_HEIGHT(DIM2_HEIGHT),
        .DIM1_LENGTH(DIM1_LENGTH)
    ) dut (
        .clk(clk),
        .input_2D_maxpool_matrix(input_2D_maxpool_matrix),
        .input_1D_fcl_matrix(input_1D_fcl_matrix),
        .output_2D_maxpool_matrix(output_2D_maxpool_matrix),
        .output_1D_fcl_matrix(output_1D_fcl_matrix)
    );

    // perma generate clock #5
    always #5 clk = ~clk;

    // setup 2d matrix
    task initialize_2D_matrix();
        for (int row = 0; row < DIM2_HEIGHT; row++) begin
            for (int col = 0; col < DIM2_WIDTH; col++) begin
                input_2D_maxpool_matrix[row][col] = (row * DIM2_WIDTH + col) + 1; // sets to basic incrementing values
            end
        end
    endtask

    // setup 1d matrix
    task initialize_1D_matrix();
        for (int idx = 0; idx < DIM1_LENGTH; idx++) begin
            input_1D_fcl_matrix[idx] = idx + 1; // sets to basic incrementing values.
        end
    endtask

    // pretty print functions //
    task display_2D_matrix(logic signed [WIDTH-1:0] matrix [0:DIM2_HEIGHT-1][0:DIM2_WIDTH-1]);
        $display("2D Matrix:");
        for (int row = 0; row < DIM2_HEIGHT; row++) begin
            for (int col = 0; col < DIM2_WIDTH; col++) begin
                $write("%0d ", matrix[row][col]); // pretty print
            end
            $display();
        end
    endtask

    task display_1D_matrix(logic signed [WIDTH-1:0] matrix [0:DIM1_LENGTH-1]);
        $display("1D Matrix:");
        for (int idx = 0; idx < DIM1_LENGTH; idx++) begin
            $write("%0d ", matrix[idx]); // pretty print
        end
        $display();
    endtask

    // start testbench
    initial begin
        clk = 0;
        $display("### Test: Flatten Module ###");

        initialize_2D_matrix();
        $display("\nInput 2D Matrix:");
        display_2D_matrix(input_2D_maxpool_matrix);

        #10;
        $display("\nOutput 1D Matrix (After Forward Propagation):");
        display_1D_matrix(output_1D_fcl_matrix);

        initialize_1D_matrix();
        $display("\nInput 1D Matrix (For Backward Propagation):");
        display_1D_matrix(input_1D_fcl_matrix);

        #10;
        $display("\nOutput 2D Matrix (After Backward Propagation):");
        display_2D_matrix(output_2D_maxpool_matrix);

        // stop test
        $display("\n### Test Completed ###");
        $stop;
    end
endmodule