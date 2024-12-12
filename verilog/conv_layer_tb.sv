`timescale 1ns / 1ps

module conv_layer_tb;

    // Parameters
    parameter int WIDTH = 8;
    parameter int NUM_KERNELS = 2;
    parameter int KERNEL_DIM = 3;
    parameter int INPUT_DIM_WIDTH = 3;
    parameter int INPUT_DIM_HEIGHT = 3;
    parameter int LEARNING_RATE = 1;
    parameter int PERIOD = 10;
    parameter int OUTPUT_DIM_WIDTH = INPUT_DIM_WIDTH - KERNEL_DIM + 1;
    parameter int OUTPUT_DIM_HEIGHT = INPUT_DIM_HEIGHT - KERNEL_DIM + 1;

    // Inputs
    logic signed [WIDTH-1:0] input_image [INPUT_DIM_HEIGHT][INPUT_DIM_WIDTH]; // Convert from 8-bit input to WIDTH-bit fixed point
    logic signed [WIDTH-1:0] output_error [NUM_KERNELS][OUTPUT_DIM_HEIGHT][OUTPUT_DIM_WIDTH];
    logic signed [WIDTH-1:0] input_kernels [NUM_KERNELS][KERNEL_DIM][KERNEL_DIM];

    // Outputs
    logic signed [WIDTH-1:0] output_data [NUM_KERNELS][OUTPUT_DIM_HEIGHT][OUTPUT_DIM_WIDTH]; 
    logic signed [WIDTH-1:0] output_kernels [NUM_KERNELS][KERNEL_DIM][KERNEL_DIM];

    // Instantiate Unit Under Test (UUT)
    conv_layer #(
        .WIDTH(WIDTH),
        .NUM_KERNELS(NUM_KERNELS),
        .KERNEL_DIM(KERNEL_DIM),
        .INPUT_DIM_WIDTH(INPUT_DIM_WIDTH),
        .INPUT_DIM_HEIGHT(INPUT_DIM_HEIGHT),
        .LEARNING_RATE(LEARNING_RATE)
    ) uut (
        .input_image(input_image),
        .output_error(output_error),
        .input_kernels(input_kernels),
        .output_data(output_data),
        .output_kernels(output_kernels)
    );

    // Stimulus
    initial begin
        #PERIOD;
        input_image = '{'{0, 1, 2}, '{3, 4, 5}, '{6, 7, 8}};
        output_kernels = '{
            '{'{0, 0, 0}, '{1, 1, 1}, '{2, 2, 2}}, 
            '{'{0, 0, 0}, '{-1, -1, -1}, '{-2, -2, -2}}
        };
        input_kernels = '{
            '{'{0, 0, 0}, '{1, 1, 1}, '{2, 2, 2}}, 
            '{'{0, 0, 0}, '{-1, -1, -1}, '{-2, -2, -2}}
        };
        #PERIOD;
        output_error = '{'{'{1}}, '{'{2}}};         // num_kernels x 1 x 1
        #PERIOD;
        
        // input_image = '{2'b01, 2'b01, 2'b01, 2'b01};
        // #PERIOD;
        // output_error = `{2'b01, 2'b00};
        // #PERIOD;

        $stop;
    end


endmodule
