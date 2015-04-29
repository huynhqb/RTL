// Description
// Asynch FIFO Controller
//  
    

`timescale 1ns/1ns

module async_fifo_ctlr #(
   parameter DATA_WIDTH = 8,
   parameter PTR_WIDTH  = 11
  )
  (
  input  wire                     i_wclk, 
  input  wire                     i_wrst_n,
  input  wire                     i_push, 
  output wire [PTR_WIDTH-2:0]     o_wptr, 
  output wire                     o_wren, 
  // input  wire [DATA_WIDTH-1:0]    i_wdata, 
  input  wire                     i_rclk, 
  input  wire                     i_rrst_n, 
  output wire                     i_pop, 
  output wire [PTR_WIDTH-2:0]     o_rptr,
  output wire                     o_rden,
  output reg                      o_almost_full,
  output reg                      o_almost_empty

  );

// Declaration
   
  wire                 fifo_empty, fifo_full;

  reg  [PTR_WIDTH-1:0] wptr, rptr;
  reg  [PTR_WIDTH-1:0] wptr_g2b_synch, rptr_g2b_synch;

// Logic
  assign o_wptr     = wptr[PTR_WIDTH-2:0];
  assign o_rptr     = rptr[PTR_WIDTH-2:0];

  assign fifo_empty = {wptr_g2b_synch == o_rptr};
  assign fifo_full  = {{~wptr[PTR_WIDTH-1],wptr[PTR_WIDTH-2:0]} == rptr_g2b_synch};

  // write clock domain
  always @(posedge i_wclk) begin
    if (!i_wrst_n) begin
       wptr <= {PTR_WIDTH{1'b0}};
    end
    else begin
      if (i_push) wptr <= wptr + 1'b1;
    end
  end
  
  
  // read clock domain
  always @(posedge i_rclk)
    if (!i_rrst_n) begin
       rptr <= {PTR_WIDTH{1'b0}};
    end
    else begin
      if (i_pop) rptr <= rptr + 1'b1;
    end
  end
   

// Instantiation

endmodule
