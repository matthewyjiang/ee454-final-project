`timescale 1ps / 1ps

module top_tb;

    // Parameters
    parameter int WIDTH = 32;
    parameter int INPUT_DIM_HEIGHT = 28;
    parameter int INPUT_DIM_WIDTH = 28;
    parameter int FCL_OUTPUT_DIM = 10;
    parameter int PERIOD = 4;
    parameter int TEST_LENGTH = 100;
    parameter int INPUT_SIZE = INPUT_DIM_HEIGHT * INPUT_DIM_WIDTH;

    // Inputs
    logic clk;
    logic reset;
    logic signed [WIDTH-1:0] input_data  [INPUT_DIM_HEIGHT][INPUT_DIM_WIDTH];
    logic signed [WIDTH-1:0] input_labels [FCL_OUTPUT_DIM];
    // Clock generation
    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end

    // Instantiate Unit Under Test (UUT)
    cnn_top #(
        .WIDTH(WIDTH),
        .INPUT_DIM_HEIGHT(INPUT_DIM_HEIGHT),
        .INPUT_DIM_WIDTH(INPUT_DIM_WIDTH),
        .FCL_OUTPUT_DIM(FCL_OUTPUT_DIM)
    ) uut (
        .clk(clk),
        .reset(reset),
        .input_data(input_data),
        .input_labels(input_labels)
    );

    logic signed [WIDTH-1:0] mem [TEST_LENGTH*INPUT_SIZE];

    // Stimulus
    initial begin
        // Initialize Inputs

        string filename = "verilog/test.mem";
        $readmemh(filename, mem);
        
        reset = 1;
        #10;
        reset = 0;
        #10;
        reset = 1;


        // IMPORTANT: Input needs to be ready before changing to RUN state. else will overwrite everything with X
        #(1700*PERIOD); // wait for initialization
        // = 10 kernels + 28-3+1 = 26x26 => 13x13 = 169*10 + 10
        // #75;

        for (int i = 0; i < 5; i++) begin
            
            // read input data from mem file
            // $readmemh("C:/Users/cl917/OneDrive/Documents/Classes/ee454/ee454-final-project/verilog/test.mem", input_data, start_index, start_index + n - 1);
            // start_index = start_index + n;

            // loop thru input data
            for(int row = 0; row < INPUT_DIM_HEIGHT; row++) begin
                for(int col = 0; col < INPUT_DIM_WIDTH; col++) begin
                    input_data[row][col] = mem[i * INPUT_SIZE + row * INPUT_DIM_WIDTH + col];
                end
            end

            // set input labels
            input_labels = '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            input_labels[i % FCL_OUTPUT_DIM] = 1;

            // two clocks for forward, backward pass
            #(PERIOD*2);
        end

        // #1000;

        // input_data = '{default: 32'h0};  // SystemVerilog array assignment

        // Finish simulation
        $stop;
    end


endmodule
