
`timescale 1ns / 1ps

module basys3_tb;

    // Clock and inputs
    logic clk = 0;
    logic btnC = 0;
    logic btnU = 0;
    logic btnD = 0;
    logic btnR = 0;
    logic btnL = 0;
    logic RsRx = 1;
    logic [15:0] sw = 0;

    // Outputs
    wire RsTx;
    wire [15:0] led;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;

    // DUT
    basys3_top dut (
        .clk  (clk),
        .btnC (btnC),
        .btnU (btnU),
        .btnD (btnD),
        .btnR (btnR),
        .btnL (btnL),
        .RsTx (RsTx),
        .RsRx (RsRx),
        .sw   (sw),
        .led  (led),
        .seg  (seg),
        .an   (an),
        .dp   (dp)
    );

    // 100 MHz clock (10 ns period)
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        btnC = 1;          // Apply reset
        #100;
        btnC = 0;          // Release reset

        $display("Reset released at %0t", $time);

        #100000;           // Simulate 100 us

        $display("Simulation finished");
        $finish;
    end

endmodule
