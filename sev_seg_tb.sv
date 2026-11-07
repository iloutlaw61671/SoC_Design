
`timescale 1ns / 1ps

module sev_seg_tb;

    localparam int ADDR_W = 12;

    // --------------------------------------------------
    // Clock and reset
    // --------------------------------------------------
    logic clk;
    logic rst_n;

    // --------------------------------------------------
    // APB signals
    // --------------------------------------------------
    logic [ADDR_W-1:0] paddr;
    logic              psel;
    logic              penable;
    logic              pwrite;
    logic [31:0]       pwdata;
    logic [3:0]        pstrb;
    logic [2:0]        pprot;

    logic [31:0]       prdata;
    logic              pready;
    logic              pslverr;

    // --------------------------------------------------
    // 7-segment outputs
    // --------------------------------------------------
    logic [6:0] seg7_seg;
    logic [3:0] seg7_an;
    logic       seg7_dp;

    // --------------------------------------------------
    // APB master read data and error
    // --------------------------------------------------
    logic [31:0] read_data;
    bit error;


    // --------------------------------------------------
    // 100 MHz clock
    // Period = 10 ns
    // --------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // --------------------------------------------------
    // Provided APB master BFM
    // --------------------------------------------------
    apb_master #(
        .ADDR_WIDTH(ADDR_W),
        .DATA_WIDTH(32)
    ) master (
        .PCLK    (clk),
        .PRESETn (rst_n),

        .PADDR   (paddr),
        .PSEL    (psel),
        .PENABLE (penable),
        .PWRITE  (pwrite),
        .PWDATA  (pwdata),
        .PSTRB   (pstrb),
        .PPROT   (pprot),

        .PRDATA  (prdata),
        .PREADY  (pready),
        .PSLVERR (pslverr)
    );


    // --------------------------------------------------
    // 7-segment controller DUT
    // --------------------------------------------------
    sev_seg #(
        .ADDR_W(ADDR_W)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),

        .paddr    (paddr),
        .penable  (penable),
        .psel     (psel),
        .pwrite   (pwrite),
        .pwdata   (pwdata),

        .pready   (pready),
        .pslverr  (pslverr),
        .prdata   (prdata),

        .seg7_seg (seg7_seg),
        .seg7_an  (seg7_an),
        .seg7_dp  (seg7_dp)
    );


    // --------------------------------------------------
    // Main test sequence
    // --------------------------------------------------
    initial begin

        // Initial reset
        rst_n = 1'b0;

        repeat (5)
            @(posedge clk);

        @(negedge clk);
        rst_n = 1'b1;


        // --------------------------------------------------
        // Write VAL register = 0x1234
        //
        // DIG3 = 1
        // DIG2 = 2
        // DIG1 = 3
        // DIG0 = 4
        // --------------------------------------------------
        master.write(
            12'h004,
            32'h0000_1234,
            '0,
            3'b000,
            error
        );

        if (error)
            $fatal(1, "APB write to VAL failed");


        // --------------------------------------------------
        // Write DIM register = 15
        // Maximum brightness
        // --------------------------------------------------
        master.write(
            12'h008,
            32'h0000_000F,
            '0,
            3'b000,
            error
        );

        if (error)
            $fatal(1, "APB write to DIM failed");


        // --------------------------------------------------
        // Write CTL register = 1
        // Enable the display
        // --------------------------------------------------
        master.write(
            12'h000,
            32'h0000_0001,
            '0,
            3'b000,
            error
        );

        if (error)
            $fatal(1, "APB write to CTL failed");


        // --------------------------------------------------
        // Read VAL register
        // --------------------------------------------------
        master.read(
            12'h004,
            read_data,
            3'b000,
            error
        );

        if (error)
            $fatal(1, "APB read from VAL failed");

        if (read_data !== 32'h0000_1234)
            $fatal(1, "VAL readback incorrect: got %h", read_data);

        $display("VAL readback passed: %h", read_data);


        // --------------------------------------------------
        // Read DIM register
        // --------------------------------------------------
        master.read(
            12'h008,
            read_data,
            3'b000,
            error
        );

        if (error)
            $fatal(1, "APB read from DIM failed");

        if (read_data !== 32'h0000_000F)
            $fatal(1, "DIM readback incorrect: got %h", read_data);

        $display("DIM readback passed: %h", read_data);


        // --------------------------------------------------
        // Read CTL register
        // --------------------------------------------------
        master.read(
            12'h000,
            read_data,
            3'b000,
            error
        );

        if (error)
            $fatal(1, "APB read from CTL failed");

        if (read_data !== 32'h0000_0001)
            $fatal(1, "CTL readback incorrect: got %h", read_data);

        $display("CTL readback passed: %h", read_data);


        // --------------------------------------------------
        // Allow the display multiplexing to run
        // --------------------------------------------------
        repeat (1000)
            @(posedge clk);


        $display("All 7-segment controller tests passed.");

        $finish;

    end

endmodule
