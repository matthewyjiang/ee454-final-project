module softmax
#(
    parameter int WIDTH = 16,
    parameter int DIMENSION = 10,
    parameter int FIXED_POINT_INDEX = 8,
    parameter int TERMS = 7
) 

(
    input  logic clk,
    input  logic reset,
    input  logic signed [WIDTH-1:0] input_data [DIMENSION],
    input  logic start,
    output logic signed [WIDTH-1:0] output_data [DIMENSION],
    output logic done,
    output logic busy
);

logic signed [WIDTH-1:0] sum;
logic signed [WIDTH-1:0] exp_result [DIMENSION];

logic norm_div_start;  // start calculation
logic norm_div_busy;   // calculation in progress
logic norm_div_done;   // calculation is complete (high for one tick)
logic norm_div_valid;  // result is valid
logic norm_div_dbz;    // divide by zero
logic norm_div_ovf;    // overflow
logic signed [WIDTH-1:0] norm_div_a;   // dividend (numerator)
logic signed [WIDTH-1:0] norm_div_b;   // divisor (denominator)
logic signed [WIDTH-1:0] norm_div_val;  // result value: quotient

div #(.WIDTH(WIDTH), .FBITS(FIXED_POINT_INDEX)) norm_div_inst (
    .clk(clk),
    .rst(reset),
    .start(norm_div_start),
    .busy(norm_div_busy),
    .done(norm_div_done),
    .valid(norm_div_valid),
    .dbz(norm_div_dbz),
    .ovf(norm_div_ovf),
    .a(norm_div_a),
    .b(norm_div_b),
    .val(norm_div_val)
);

logic signed [WIDTH-1:0] exp_taylor_input_x ;
logic signed [WIDTH-1:0] exp_taylor_result ;
logic exp_taylor_start;
logic exp_taylor_done;
logic exp_taylor_busy;

exp_taylor #(.WIDTH(WIDTH), .FIXED_POINT_INDEX(FIXED_POINT_INDEX), .TERMS(TERMS)) exp_taylor_inst (
    .clk(clk),
    .reset(reset),
    .start(exp_taylor_start),
    .x(exp_taylor_input_x),
    .result(exp_taylor_result),
    .done(exp_taylor_done),
    .busy(exp_taylor_busy)
);


typedef enum {INIT, COMPUTE, NORM_DIV, NORM_DIV_WAITING, DONE} state_t;
state_t state;
logic [$clog2(DIMENSION):0] i;

always_ff @(posedge clk or negedge reset) begin
    // test division
    if (!reset) begin
        state <= INIT;
        busy <= 0;
        done <= 0;
    end
    else begin
        case (state)
            INIT: begin
                sum <= 0;
                i <= 0;
                done <= 0;
                if (start) begin
                    state <= COMPUTE;
                    busy <= 1;
                end
            end
            COMPUTE: begin
                if (i < DIMENSION) begin
                    exp_taylor_input_x <= input_data[i];
                    if (exp_taylor_busy) begin
                        exp_taylor_start <= 0;
                    end else begin
                        exp_taylor_start <= 1;
                    end
                    if (exp_taylor_done && !exp_taylor_busy) begin
                        exp_result[i] <= exp_taylor_result;
                        sum <= sum + exp_taylor_result;
                        exp_taylor_start <= 0;
                        i <= i + 1;
                    end
                end
                else begin
                    state <= NORM_DIV;
                    i <= 0;
                end
            end
            NORM_DIV: begin
                norm_div_a <= exp_result[i];
                norm_div_b <= sum;
                norm_div_start <= 1;
                state <= NORM_DIV_WAITING;
            end
            NORM_DIV_WAITING: begin
                norm_div_start <= 0;
                if (norm_div_done) begin
                    if (i < DIMENSION) begin
                        if (norm_div_valid) begin
                            output_data[i] <= norm_div_val;
                            state <= NORM_DIV;
                            i <= i + 1;
                        end
                    end
                    else begin
                        state <= DONE;
                    end
                end
            end
            DONE: begin
                done <= 1;
                busy <= 0;
                state <= INIT;
            end
        endcase
    end
end



endmodule