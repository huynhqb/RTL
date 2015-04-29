// Description
// Models a dual-port RAM
//  
    

`timescale 1ns/1ns

module dp_ram #(
   parameter RAM_DEPTH  = 1024,
   parameter DATA_WIDTH = 8,
   parameter ADDR_WIDTH = 10
)
(
   input wire                   i_wclk, 
   input wire [ADDR_WIDTH-1:0]  i_waddr, 
   input wire                   i_wen, 
   input wire [DATA_WIDTH-1:0]  i_wdata, 
   input wire                   i_rclk, 
   input wire [ADDR_WIDTH-1:0]  i_raddr, 
   input wire                   i_ren, 
   input wire [DATA_WIDTH-1:0]  o_rdata

   );

// Declaration
   reg [DATA_WIDTH-1:0] dp_mem[0:RAM_DEPTH-1];

// Logic

   //write clock domain
   always @(posedge i_wclk) begin
      if (i_wen) dp_mem[i_waddr] <= i_wdata; 
   end
   
   
   //read clock domain
   always @(posedge i_rclk)
      if (i_ren) o_rdata <= dp_mem[i_raddr];
   end
   
// Instantiation

endmodule
