`timescale 1ns / 1ps

module fully_connected_tb;

    // Parameters
    parameter int WIDTH = 32;
    parameter int INPUT_DIM = 1;
    parameter int OUTPUT_DIM = 10;
    parameter int LEARNING_RATE = 1;

    // Inputs
    logic clk;
    logic reset;
    logic signed [WIDTH-1:0] input_data [INPUT_DIM];
    logic signed [WIDTH-1:0] output_error [OUTPUT_DIM];

    // Outputs
    logic signed [WIDTH-1:0] output_data [OUTPUT_DIM];
    logic signed [WIDTH-1:0] input_error [INPUT_DIM];

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Instantiate Unit Under Test (UUT)
    fully_connected_layer #(
        .WIDTH(WIDTH),
        .INPUT_DIM(INPUT_DIM),
        .OUTPUT_DIM(OUTPUT_DIM),
        .LEARNING_RATE(LEARNING_RATE)
    ) uut (
        .clk(clk),
        .reset(reset),
        .input_data(input_data),
        .output_error(output_error),
        .output_data(output_data),
        .input_error(input_error)
    );

    // Stimulus
    initial begin
        // Initialize Inputs
        reset = 1;
        #10;
        reset = 0;
        input_data = '{default: 32'h0};  // SystemVerilog array assignment

        // Wait for global reset
        #10;
        reset = 1;

        // Apply test vectors
        input_data = '{32'hFFCE0000}; // Assign array with a single value
        #10;
        input_data = '{32'hFFCF0000};
        #10;
        input_data = '{32'hFFD00000};
        #10;
        input_data = '{32'hFFD10000};
        #10;
        input_data = '{32'hFFD20000};
        #10;
        input_data = '{32'hFFD30000};
        #10;
        input_data = '{32'hFFD40000};
        #10;
        input_data = '{32'hFFD50000};
        #10;
        input_data = '{32'hFFD60000};
        #10;
        input_data = '{32'hFFD70000};
        #10;
        input_data = '{32'hFFD80000};
        #10;
        input_data = '{32'hFFD90000};
        #10;
        input_data = '{32'hFFDA0000};
        #10;
        input_data = '{32'hFFDB0000};
        #10;
        input_data = '{32'hFFDC0000};
        #10;
        input_data = '{32'hFFDD0000};
        #10;
        input_data = '{32'hFFDE0000};
        #10;
        input_data = '{32'hFFDF0000};
        #10;
        input_data = '{32'hFFE00000};
        #10;
        input_data = '{32'hFFE10000};
        #10;
        input_data = '{32'hFFE20000};
        #10;
        input_data = '{32'hFFE30000};
        #10;
        input_data = '{32'hFFE40000};
        #10;
        input_data = '{32'hFFE50000};
        #10;
        input_data = '{32'hFFE60000};
        #10;
        input_data = '{32'hFFE70000};
        #10;
        input_data = '{32'hFFE80000};
        #10;
        input_data = '{32'hFFE90000};
        #10;
        input_data = '{32'hFFEA0000};
        #10;
        input_data = '{32'hFFEB0000};
        #10;
        input_data = '{32'hFFEC0000};
        #10;
        input_data = '{32'hFFED0000};
        #10;
        input_data = '{32'hFFEE0000};
        #10;
        input_data = '{32'hFFEF0000};
        #10;
        input_data = '{32'hFFF00000};
        #10;
        input_data = '{32'hFFF10000};
        #10;
        input_data = '{32'hFFF20000};
        #10;
        input_data = '{32'hFFF30000};
        #10;
        input_data = '{32'hFFF40000};
        #10;
        input_data = '{32'hFFF50000};
        #10;
        input_data = '{32'hFFF60000};
        #10;
        input_data = '{32'hFFF70000};
        #10;
        input_data = '{32'hFFF80000};
        #10;
        input_data = '{32'hFFF90000};
        #10;
        input_data = '{32'hFFFA0000};
        #10;
        input_data = '{32'hFFFB0000};
        #10;
        input_data = '{32'hFFFC0000};
        #10;
        input_data = '{32'hFFFD0000};
        #10;
        input_data = '{32'hFFFE0000};
        #10;
        input_data = '{32'hFFFF0000};
        #10;
        input_data = '{32'h00000000};
        #10;
        input_data = '{32'h00010000};
        #10;
        input_data = '{32'h00020000};
        #10;
        input_data = '{32'h00030000};
        #10;
        input_data = '{32'h00040000};
        #10;
        input_data = '{32'h00050000};
        #10;
        input_data = '{32'h00060000};
        #10;
        input_data = '{32'h00070000};
        #10;
        input_data = '{32'h00080000};
        #10;
        input_data = '{32'h00090000};
        #10;
        input_data = '{32'h000A0000};
        #10;
        input_data = '{32'h000B0000};
        #10;
        input_data = '{32'h000C0000};
        #10;
        input_data = '{32'h000D0000};
        #10;
        input_data = '{32'h000E0000};
        #10;
        input_data = '{32'h000F0000};
        #10;
        input_data = '{32'h00100000};
        #10;
        input_data = '{32'h00110000};
        #10;
        input_data = '{32'h00120000};
        #10;
        input_data = '{32'h00130000};
        #10;
        input_data = '{32'h00140000};
        #10;
        input_data = '{32'h00150000};
        #10;
        input_data = '{32'h00160000};
        #10;
        input_data = '{32'h00170000};
        #10;
        input_data = '{32'h00180000};
        #10;
        input_data = '{32'h00190000};
        #10;
        input_data = '{32'h001A0000};
        #10;
        input_data = '{32'h001B0000};
        #10;
        input_data = '{32'h001C0000};
        #10;
        input_data = '{32'h001D0000};
        #10;
        input_data = '{32'h001E0000};
        #10;
        input_data = '{32'h001F0000};
        #10;
        input_data = '{32'h00200000};
        #10;
        input_data = '{32'h00210000};
        #10;
        input_data = '{32'h00220000};
        #10;
        input_data = '{32'h00230000};
        #10;
        input_data = '{32'h00240000};
        #10;
        input_data = '{32'h00250000};
        #10;
        input_data = '{32'h00260000};
        #10;
        input_data = '{32'h00270000};
        #10;
        input_data = '{32'h00280000};
        #10;
        input_data = '{32'h00290000};
        #10;
        input_data = '{32'h002A0000};
        #10;
        input_data = '{32'h002B0000};
        #10;
        input_data = '{32'h002C0000};
        #10;
        input_data = '{32'h002D0000};
        #10;
        input_data = '{32'h002E0000};
        #10;
        input_data = '{32'h002F0000};
        #10;
        input_data = '{32'h00300000};
        #10;
        input_data = '{32'h00310000};
        #10;

        // Finish simulation
        $stop;
    end

endmodule
