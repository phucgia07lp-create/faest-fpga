module controller (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire zc,
    output reg  load,
    output reg  en,
    output reg  enc,
    output reg  done
);

    // Định nghĩa các trạng thái FSM
    localparam S_WAIT    = 2'b00;
    localparam S_LOAD    = 2'b01;
    localparam S_COMPUTE = 2 me0;
    localparam S_DONE    = 2'b11;

    reg [1:0] current_state, next_state;

    // 1. Thanh ghi trạng thái (Sequential Logic)
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= S_WAIT;
        else
            current_state <= next_state;
    end

    // 2. Logic chuyển trạng thái (Combinational Logic)
    always @(*) begin
        case (current_state)
            S_WAIT: begin
                if (start) next_state = S_LOAD;
                else       next_state = S_WAIT;
            end
            S_LOAD: begin
                next_state = S_COMPUTE;
            end
            S_COMPUTE: begin
                if (zc) next_state = S_DONE;
                else    next_state = S_COMPUTE;
            end
            S_DONE: begin
                next_state = S_WAIT;
            end
            default: next_state = S_WAIT;
        endcase
    end

    // 3. Logic điều khiển ngõ ra (Output Logic)
    always @(*) begin
        load = 1'b0;
        en   = 1'b0;
        enc  = 1'b0;
        done = 1'b0;

        case (current_state)
            S_WAIT: ;
            S_LOAD: begin
                load = 1'b1;
            end
            S_COMPUTE: begin
                en  = 1'b1; // Giữ en = 1 liên tục trong thời gian tính toán
                enc = 1'b1; // Bật bộ đếm counter trong datapath
            end
            S_DONE: begin
                done = 1'b1; // Báo hoàn thành khi chuyển sang S_DONE
            end
        endcase
    end

endmodule