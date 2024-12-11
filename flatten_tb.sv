module flatten_tb;

    // init parameters
    parameter int WIDTH = 16;                                    // Bit width of input
    parameter int CHANNELS = 2;                                    // # of channels
    parameter int DIM3_WIDTH = 4;                              // WIDTH of 3D Matrix (Reduced for testing)
    parameter int DIM3_HEIGHT = 4;                             // HEIGHT of 3D Matrix
    parameter int DIM1_LENGTH = CHANNELS * DIM3_WIDTH * DIM3_HEIGHT; // WIDTH of output feature map

    // init signals
    logic clk;
    logic signed [WIDTH-1:0] input_3D_maxpool_matrix [0:CHANNELS-1][0:DIM3_HEIGHT-1][0:DIM3_WIDTH-1];
    logic signed [WIDTH-1:0] input_1D_fcl_matrix [0:DIM1_LENGTH-1];
    logic signed [WIDTH-1:0] output_3D_maxpool_matrix [0:CHANNELS-1][0:DIM3_HEIGHT-1][0:DIM3_WIDTH-1];
    logic signed [WIDTH-1:0] output_1D_fcl_matrix [0:DIM1_LENGTH-1];

    // uut the flatten module
    flatten #(
        .WIDTH(WIDTH),
        .CHANNELS(CHANNELS),
        .DIM3_WIDTH(DIM3_WIDTH),
        .DIM3_HEIGHT(DIM3_HEIGHT),
        .DIM1_LENGTH(DIM1_LENGTH)
    ) dut (
        .clk(clk),
        .input_3D_maxpool_matrix(input_3D_maxpool_matrix),
        .input_1D_fcl_matrix(input_1D_fcl_matrix),
        .output_3D_maxpool_matrix(output_3D_maxpool_matrix),
        .output_1D_fcl_matrix(output_1D_fcl_matrix)
    );

    // perma generate clock #5
    always #5 clk = ~clk;

    // setup 3D matrix
    task initialize_3D_matrix();
        for (int ch = 0; ch < CHANNELS; ch++) begin
            for (int row = 0; row < DIM3_HEIGHT; row++) begin
                for (int col = 0; col < DIM3_WIDTH; col++) begin
                    input_3D_maxpool_matrix[ch][row][col] = (ch * DIM3_WIDTH * DIM3_HEIGHT) + (row * DIM3_WIDTH * col) + 1; // sets to basic incrementing values
                end
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
    task display_3D_matrix(logic signed [WIDTH-1:0] matrix [0:CHANNELS-1][0:DIM3_HEIGHT-1][0:DIM3_WIDTH-1]);
        $display("3D Matrix:");
        for (int ch = 0; ch < CHANNELS; ch++) begin
            $display("Channel %0d:", ch);
            for (int row = 0; row < DIM3_HEIGHT; row++) begin
                for (int col = 0; col < DIM3_WIDTH; col++) begin
                    $write("%0d ", matrix[ch][row][col]); // pretty print
                end
                $display();
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

        initialize_3D_matrix();
        $display("\nInput 3D Matrix:");
        display_3D_matrix(input_3D_maxpool_matrix);

        #10;
        $display("\nOutput 1D Matrix (After Forward Propagation):");
        display_1D_matrix(output_1D_fcl_matrix);

        initialize_1D_matrix();
        $display("\nInput 1D Matrix (For Backward Propagation):");
        display_1D_matrix(input_1D_fcl_matrix);

        #10;
        $display("\nOutput 3D Matrix (After Backward Propagation):");
        display_3D_matrix(output_3D_maxpool_matrix);

        // stop test
        $display("\n### Test Completed ###");
        $stop;
    end
endmodule
