// Description
// FIFO for fully asynchronous clock domains
//  
    

`timescale 1ns/1ns

module async_fifo_ctrl #(
   parameter DATA_WIDTH = 8,
   parameter PTR_WIDTH  = 10
)
(
   input  wire                     i_wclk, 
   output reg  [PTR_WIDTH-1:0]     o_wptr, 
   input  wire                     i_wen, 
   input  wire [DATA_WIDTH-1:0]    i_din, 
   input  wire                     i_rclk, 
   output wire                     i_ren, 
   output reg  [PTR_WIDTH-1:0]     o_rptr,
   input  wire [DATA_WIDTH-1:0]    o_dout 

   );

// Declaration
   reg [DATA_WIDTH-1:0] dp_mem[0:RAM_DEPTH-1];

// Instantiation


//----------------------------------------------

   //write clock domain
   always @(posedge i_wclk) begin
      if (i_wen) dp_mem[i_waddr] <= d_in; 
   end
   
   
   //read clock domain
   always @(posedge i_rclk)
      if (r_en) o_dout <= dp_mem[i_raddr];
   end
   

endmodule
