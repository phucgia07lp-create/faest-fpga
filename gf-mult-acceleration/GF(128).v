module gf#(
    parameter WIDTH = 128
)(
    input  wire             clk,     // Clock hệ thống
    input  wire             rst,     // Reset hệ thống
    input  wire             start,   // Tín hiệu bắt đầu tính toán từ ngoài
    input  wire [WIDTH-1:0] A,       // Số nhân A (128-bit)
    input  wire [WIDTH-1:0] B,       // Số nhân B (128-bit)
    output wire [WIDTH-1:0] Y,       // Kết quả phép nhân Y (128-bit)
    output wire             done     // Báo hoàn thành phép tính
);

    // 1. Khai báo các đường dây nối NỘI BỘ giữa Datapath và Controller
    wire load;
    wire en;
    wire enc;
    wire zc;

    // 2. Khai báo và nối dây cho khối DATAPATH
    datapath #(
        .WIDTH(WIDTH),
        .L(16)                  // 16 chu kỳ cho 128-bit
    ) u_datapath (
        .clk(clk),              // Nối clk chung
        .rst(rst),              // Nối rst chung
        .A(A),                  // Nối A từ Top-level
        .B(B),                  // Nối B từ Top-level
        .load(load),            // Nối dây load từ Controller sang
        .en(en),                // Nối dây en từ Controller sang
        .enc(enc),              // Nối dây enc từ Controller sang
        .zc(zc),                // Xuất tín hiệu zc sang Controller
        .Y(Y)                   // Xuất kết quả Y ra Top-level
    );

    // 3. Khai báo và nối dây cho khối CONTROLLER
    controller u_controller (
        .clk(clk),              // Nối clk chung
        .rst(rst),              // Nối rst chung
        .start(start),          // Nối start từ Top-level
        .zc(zc),                // Nhận tín hiệu zc từ Datapath báo về
        .load(load),            // Xuất tín hiệu load sang Datapath
        .en(en),                // Xuất tín hiệu en sang Datapath
        .enc(enc),              // Xuất tín hiệu enc sang Datapath
        .done(done)             // Xuất tín hiệu done ra Top-level
    );

endmodule
