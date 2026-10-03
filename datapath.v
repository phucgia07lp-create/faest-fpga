module datapath #(
    parameter WIDTH = 128,
    parameter L = 8 // 128 bit / 16 bit-per-cycle = 8 chu kỳ
)(
    input  wire             clk,
    input  wire             rst,
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    input  wire             load,
    input  wire             en,
    input  wire             enc,
    output wire             zc,
    output wire [WIDTH-1:0] Y
);

    reg [WIDTH-1:0] Pa_reg;
    reg [WIDTH-1:0] Pb_reg;
    reg [WIDTH-1:0] accum_reg;
    reg [3:0]       counter;

    wire [WIDTH-1:0] A_stage [0:16];
    wire [WIDTH-1:0] mux_out [0:15];
    reg  [WIDTH-1:0] xor_sum;

    // Nạp & Dịch dữ liệu
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Pa_reg <= {WIDTH{1'b0}};
            Pb_reg <= {WIDTH{1'b0}};
        end else if (load) begin
            Pa_reg <= A;
            Pb_reg <= B;
        end else if (en) begin
            Pa_reg <= A_stage[16]; // A * x^16 sau 16 bước MultX
            Pb_reg <= {Pb_reg[15:0], Pb_reg[WIDTH-1:16]}; // Dịch 16 bit
        end
    end

    // Chuỗi 16 bộ MultX (nhân x và khử mod)
    assign A_stage[0] = Pa_reg;
    genvar k;
    generate
        for (k = 0; k < 16; k = k + 1) begin : gen_multx_chain
            // Đa thức mod FAEST: x^128 + x^7 + x^2 + x + 1 (hoặc theo fields.h)
            wire msb = A_stage[k][WIDTH-1];
            assign A_stage[k+1] = (A_stage[k] << 1) ^ (msb ? 128'h87 : 128'h0);
        end
    endgenerate

    // MUX chọn tích theo 16 bit thấp của Pb_reg
    integer i;
    always @(*) begin
        xor_sum = {WIDTH{1'b0}};
        for (i = 0; i < 16; i = i + 1) begin
            if (Pb_reg[i]) begin
                xor_sum = xor_sum ^ A_stage[i];
            end
        end
    end

    // Thanh ghi tích lũy Accumulator
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            accum_reg <= {WIDTH{1'b0}};
        end else if (load) begin
            accum_reg <= {WIDTH{1'b0}};
        end else if (en) begin
            accum_reg <= accum_reg ^ xor_sum;
        end
    end

    assign Y = accum_reg;

    // Counter đếm 8 chu kỳ
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 4'd0;
        end else if (load) begin
            counter <= 4'd0;
        end else if (enc) begin
            counter <= counter + 1'b1;
        end
    end

    assign zc = (counter == (L - 1));

endmodule