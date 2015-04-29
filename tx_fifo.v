// Description
// Asynch FIFO Controller
//  
    

`timescale 1ns/1ns

module tx_fifo #(
   parameter DATA_WIDTH = 8,
   parameter PTR_WIDTH  = 11
  )
  (
  input  wire                     i_wclk, 
  input  wire                     i_wrst_n,
  input  wire                     i_push, 
  input  wire [DATA_WIDTH-1:0]    i_wdata, 
  input  wire                     i_rclk, 
  input  wire                     i_rrst_n, 
  output wire                     i_pop, 
  input  wire [DATA_WIDTH-1:0]    o_rdat,
  output reg                      o_almost_full,
  output reg                      o_almost_empty

  );

// Declaration
   
  wire                 fifo_empty, fifo_full;

  reg  [PTR_WIDTH-1:0] wptr, rptr;
  reg  [PTR_WIDTH-1:0] wptr_g2b_synch, rptr_g2b_synch;

// Logic
   

// Instantiation
async_fifo_ctlr tx_fifo_ctlr
  (
  .i_wclk              (i_wclk), 
  .i_wrst_n            (i_wrst_n),
  .o_wptr              (wptr), 
  .i_push              (i_push), 
  // .i_wdata             (i_wdata), 
  .i_rclk              (i_rclk), 
  .i_rrst_n            (i_rrst_n), 
  .i_pop               (i_pop), 
  .o_rptr              (o_rptr),
  .o_almost_full       (o_almost_full),
  .o_almost_empty      (o_almost_empty)

  );

dp_ram dp_ram 
(
   .i_wclk  (i_wclk),
   .i_waddr (i_waddr), 
   .i_wen   (i_wen), 
   .i_wdata (i_wdata), 
   .i_rclk  (i_rclk),
   .i_raddr (i_raddr), 
   .i_ren   (i_ren), 
   .o_rdata (o_rdata)

   );


endmodule
