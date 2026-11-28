`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Klaus Strohmayer
// 
// Create Date:    17:08:26 06/12/2014 
// Design Name: 
// Module Name:    basys3_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
//
// Description: 
//   Dice 
//     Read ADC values (1 channel) from PMOD ADC1 (SPI)
//     Send the information to via the UART to the PC (terminal)
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`default_nettype none
module basys3_top(  
  input wire   clk           , // I; Clock input (100 MHzz)
	 
  //Push Button Inputs	 
  input  wire          btnC  , // I; Center 
  input  wire          btnU  , // I; Up 
  input  wire          btnD  , // I; Down 
  input  wire          btnR  , // I; Left  
  input  wire          btnL  , // I; Right
 
  // USB-RS232 Interface
  output wire          RsTx  , // O; TXD  
  input  wire          RsRx  , // I; RXD
  
  // Switch an LEDs
  input  wire  [15:0]  sw    , // I; SW 0..15 
  output logic [15:0]  led   , // O; LED Outputs 
     
  // Seven Segment Display Outputs
  output logic  [6:0]  seg   , // O; Segment  
  output logic  [3:0]  an    , // O; Anode of Seg0 ..3
  output logic         dp      // O; Anode of decimal point
);
		

  // -------------------------------------------------------------------------
  // Definition
  // -------------------------------------------------------------------------
  // Reset
  logic       rst_n;
  logic [1:0] rst_nff;
  //logic       clr_ff;
  
  // Debounced inputs
  logic [7:0] deb_din;
  logic [7:0] deb_dout;
  logic [7:0] deb_dout_pls;
  
  // 28.10.2026
  // -----------------------------------------------------
  // AHB Port 0
  // -----------------------------------------------------
  wire [31:0] ahb_haddr;
  wire [2:0]  ahb_hburst;
  wire        ahb_hmastlock;
  wire [3:0]  ahb_hprot;
  wire [31:0] ahb_hrdata;
  wire        ahb_hready;
  wire        ahb_hresp;
  wire [2:0]  ahb_hsize;
  wire [1:0]  ahb_htrans;
  wire [31:0] ahb_hwdata;
  wire        ahb_hwrite;
wire [31:0] gpio_out;
wire [15:0] ledcntrl_led;
 assign led = sw[12] ? {8'h00, gpio_out[7:0]} : ledcntrl_led;
  // 28.10.2026
wire [31:0] version;


  // Testmux
  //                         logic [15:0] test_mux_din  [3:0];
  // (* MARK_DEBUG="TRUE" *) logic [1:0]  test_mux_sel;
  // (* MARK_DEBUG="TRUE" *) logic [15:0] test_mux_out;


  // -------------------------------------------------------------------------
  // Implementation
  // -------------------------------------------------------------------------
  
  // Reset generation
  always @(negedge clk or negedge sw[4]) begin
    if (!sw[4]) begin
      rst_nff <= 2'b00;
    end else begin
     rst_nff <= {rst_nff[0], 1'b1};
    end  
  end
  assign rst_n = rst_nff[1];
  assign version = 32'd1;
  // Handling of all IOs: sync debounce and pulse geeration (if required)
  assign deb_din = {sw[15], btnC, sw[3], sw[2], sw[1], sw[0], btnD, btnU};
  ste_debounce_array #(
    .NBR      (8),
    .SYNC     (8'b11_1_11_111),
    .CNT_W    (4),
    .PLS_RISE (8'b00_0_00_011),
    .PLS_FALL (8'b00_0_00_000)
  ) u_ste_debounce_array(
    .clk       (clk          ), // I; System clock 
    .rst_n     (rst_n        ), // I; active loaw reset 
    .din_i     (deb_din      ), // I; Data in to be debounced
    .deb_rise_i(4'hf         ), // I; maximal count value
    .deb_fall_i(4'hf         ), // I; maximal count value
    .dout_pls_o(deb_dout_pls ), // O; Debounced output pulse 
    .dout_o    (deb_dout     )  // O; Debounced data out
  );
    

  //assign led = sw;

  // 28.10.2026
  // -----------------------------------------------------
  // LED Controller (AHB)
  // Verify port names against ledcntrl_top.sv
  // -----------------------------------------------------
ledcntrl_top u_ledcntrl_top (
  .clk   (clk),
  .reset_n (rst_n),

  .haddr    (ahb_haddr),
  .hrdata   (ahb_hrdata),
  .hready   (ahb_hready),
  .hready_out (ahb_hready),
  .hresp    (ahb_hresp),
  .htrans   (ahb_htrans),
  .hwdata   (ahb_hwdata),
  .hwrite   (ahb_hwrite),
  .hsel     (1'b1),
  .led_out  (ledcntrl_led)
  );

  // 28.10.2026
    
  // SoC
  wire [31:0]apb_0_paddr;
  wire apb_0_penable;
  wire [31:0]apb_0_prdata;
  wire [0:0]apb_0_pready;
  wire [0:0]apb_0_psel;
  wire [0:0]apb_0_pslverr;
  wire [31:0]apb_0_pwdata;
  wire apb_0_pwrite;
  wire [31:0]apb_1_paddr;
  wire apb_1_penable;
  wire [31:0]apb_1_prdata;
  wire [0:0]apb_1_pready;
  wire [0:0]apb_1_psel;
  wire [0:0]apb_1_pslverr;
  wire [31:0]apb_1_pwdata;
  wire apb_1_pwrite;

  
  assign apb_1_prdata  = 32'ha5a5_5a5a;
  assign apb_1_pready  = 1'b1;
  assign apb_1_pslverr = 1'b0; 


  sev_seg #(
    .ADDR_W(12)
  ) u_seg7_top(
    .clk  (clk  ),
    .rst_n(rst_n),
  
    .paddr  (apb_0_paddr  ),
    .penable(apb_0_penable),
    .psel   (apb_0_psel   ),
    .pwrite (apb_0_pwrite ),
    .pwdata (apb_0_pwdata ),
    .pready (apb_0_pready ),
    .pslverr(apb_0_pslverr),  
    .prdata (apb_0_prdata ),

    // Seven Segment Display Outputs
    .seg7_seg   (seg), // O; Segment  
    .seg7_an    (an ), // O; Anode of Seg0 ..3
    .seg7_dp    (dp )  // O; Anode of decimal point  
  );

  
soc_top soc_top (
  .apb_0_paddr  (apb_0_paddr  ),
  .apb_0_penable(apb_0_penable),
  .apb_0_prdata (apb_0_prdata ),
  .apb_0_pready (apb_0_pready ),
  .apb_0_psel   (apb_0_psel   ),
  .apb_0_pslverr(apb_0_pslverr),
  .apb_0_pwdata (apb_0_pwdata ),
  .apb_0_pwrite (apb_0_pwrite ),
  .apb_1_paddr  (apb_1_paddr  ),
  .apb_1_penable(apb_1_penable),
  .apb_1_prdata (apb_1_prdata ),
  .apb_1_pready (apb_1_pready ),
  .apb_1_psel   (apb_1_psel   ),
  .apb_1_pslverr(apb_1_pslverr),
  .apb_1_pwdata (apb_1_pwdata ),
  .apb_1_pwrite (apb_1_pwrite ),
  .clk_100mhz    (clk),
  .gpio_0_tri_i (deb_dout),
  .gpio_0_tri_o (gpio_out),
  .gpio_0_tri_t (),
  .GPIO2_tri_i (version),
  .GPIO2_tri_o (),
  .pwm          (),
  .reset_n      (rst_n),
  .uart_0_rxd     (RsRx),
  .uart_0_txd     (RsTx),

  // AHB 0
  .ahb_haddr    (ahb_haddr),
  .ahb_hburst   (ahb_hburst),
  .ahb_hmastlock(ahb_hmastlock),
  .ahb_hprot    (ahb_hprot),
  .ahb_hrdata   (ahb_hrdata),
  .ahb_hready   (ahb_hready),
  .ahb_hresp    (ahb_hresp),
  .ahb_hsize    (ahb_hsize),
  .ahb_htrans   (ahb_htrans),
  .ahb_hwdata   (ahb_hwdata),
  .ahb_hwrite   (ahb_hwrite)
 
);  
  
endmodule
`default_nettype wire 


