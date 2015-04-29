/****************************************************************************
   TabulaNotice [ Copyright (c) 2008 Tabula, Inc.
                | All Rights Reserved Worldwide.
                |
                | THIS PROGRAM IS CONFIDENTIAL AND PROPRIETARY
                | TO TABULA, INC. AND CONSTITUTES
                | A VALUABLE TRADE SECRET.
                |
                | Any unauthorized use, reproduction, modification, or
                | disclosure of this program is strictly prohibited.
                ]
   Filename:   [ $File: //depot/main/chips/Volcan/Vesuvius/logic/comps/bpa/src/aligner.v $ ]
   Description [ Aligner with nibble valids
               ]
   Author:     [ $Author: qhuynh $ ]
 *****************************************************************************/

module aligner (
   input  wire             clk, 
   input  wire             reset_n,

   input  wire [31:0]      aes_ptxt,
   input  wire             aes_ptxt_vld,
   output wire             aes_ptxt_rdy,

   input  wire             decAlignShift4,   
   input  wire             decAlignShift8,   
   input  wire             decAlignShift12,   
   input  wire             decAlignShift16,
   input  wire             decAlignShift20,   
   input  wire             decAlignShift24,   

   // Decoder interface
   output wire             out4Valid,
   output wire             out8Valid,
   output wire             out12Valid,
   output wire             out16Valid,
   output wire             out20Valid,
   output wire             out24Valid,

   output wire [31:0]      alignDecData
   );

   reg [31:0]  storage;
   reg [7:0]   nibbleValid;

   wire [31:0] nStorage;
   wire [7:0]  nNibbleValid;
   wire        align_rdy;
   wire        inTransfer;

/***************************** Combinatorial **********************************/
   assign    aes_ptxt_rdy = inTransfer;

   // Store 32-bit and combine it with the input to form a 64-bit word
   // Initialize the valid bit vector

   wire [15:0] tempValid = (
                            !nibbleValid[7] ? {       {8{aes_ptxt_vld}}, 8'b0} :
                            !nibbleValid[6] ? {1'b1,  {8{aes_ptxt_vld}}, 7'b0} :
                            !nibbleValid[5] ? {2'h3,  {8{aes_ptxt_vld}}, 6'b0} :
                            !nibbleValid[4] ? {3'h7,  {8{aes_ptxt_vld}}, 5'b0} :
                            !nibbleValid[3] ? {4'hF,  {8{aes_ptxt_vld}}, 4'b0} :
                            !nibbleValid[2] ? {5'h1F, {8{aes_ptxt_vld}}, 3'b0} :
                            !nibbleValid[1] ? {6'h3F, {8{aes_ptxt_vld}}, 2'b0} :
                            !nibbleValid[0] ? {7'h7F, {8{aes_ptxt_vld}}, 1'b0} :
                                              {8'hFF, {8{aes_ptxt_vld}}}) ;

   wire [63:0] tempData = ( 
                            !nibbleValid[7] ? {                aes_ptxt, 32'bx} :
                            !nibbleValid[6] ? {storage[31:28], aes_ptxt, 28'bx} :
                            !nibbleValid[5] ? {storage[31:24], aes_ptxt, 24'bx} :
                            !nibbleValid[4] ? {storage[31:20], aes_ptxt, 20'bx} :
                            !nibbleValid[3] ? {storage[31:16], aes_ptxt, 16'bx} :
                            !nibbleValid[2] ? {storage[31:12], aes_ptxt, 12'bx} :
                            !nibbleValid[1] ? {storage[31:8],  aes_ptxt, 8'bx}  :
                            !nibbleValid[0] ? {storage[31:4],  aes_ptxt, 4'bx}  :
                                              {storage[31:0],  aes_ptxt});

   assign    {out4Valid, out8Valid, out12Valid, out16Valid, out20Valid, out24Valid} = tempValid[15:10];

   assign    alignDecData = tempData[63:32];

   assign    align_rdy    = (((nibbleValid[1:0]==2'h0 )  & out24Valid & decAlignShift24) |
                             ((nibbleValid[2:0]==3'h0 )  & out20Valid & decAlignShift20) |
                             ((nibbleValid[3:0]==4'h0 )  & out16Valid & decAlignShift16) |
                             ((nibbleValid[4:0]==5'h00)  & out12Valid & decAlignShift12) |
                             ((nibbleValid[5:0]==6'h00)  & out8Valid  & decAlignShift8 ) |
                             ((nibbleValid[6:0]==7'h00)  & out4Valid  & decAlignShift4 ) |
                              (nibbleValid[7:0]==8'h00));

   assign   inTransfer = aes_ptxt_vld & align_rdy;
   
   wire [15:0] nextValid  = inTransfer ? tempValid : {nibbleValid, 8'h00};
   
   wire [63:0] nextData  = inTransfer ? tempData  : {storage,     32'bx};
   
   wire [3:0]  outShift = ((out24Valid & decAlignShift24)  ? 4'd2 :
                           (out20Valid & decAlignShift20)  ? 4'd3 :
                           (out16Valid & decAlignShift16)  ? 4'd4 :
                           (out12Valid & decAlignShift12)  ? 4'd5 :
                           (out8Valid & decAlignShift8)    ? 4'd6 :
                           (out4Valid & decAlignShift4)    ? 4'd7 : 4'd8);
   
   assign      nNibbleValid = nextValid[outShift +:8];
   
   assign      nStorage     = nextData[{outShift,2'b00} +: 32];

/*****************************   Sequential   **********************************/
   always @(posedge clk or negedge reset_n)  begin
      if (!reset_n) begin
         nibbleValid  <= 8'h00;
      end
      else begin
         nibbleValid  <= nNibbleValid;
      end
   end

   always @(posedge clk or negedge reset_n)  begin
      if (!reset_n) begin
         storage <= 32'd0;
      end
      else begin
         storage <= nStorage;
      end
   end

/*****************************   Assertions   **********************************/
   
   // synopsys translate_off
`ifdef ASSERT_ON
   //-- check that the input (downAlign) is proper 2-phase
   pc_2Phase  da_2Phase (.clk(clk), .reset_n(reset_n), .valid1(aes_ptxt_vld), .valid2(aes_ptxt_rdy));
   //-- check that out{8|12|16}Valid is a thermometer code
   assert_implication #(0,0,"out24Valid thermometer")  assert_o24 (clk, reset_n, out24Valid, out20Valid);
   assert_implication #(0,0,"out20Valid thermometer")  assert_o20 (clk, reset_n, out20Valid, out16Valid);
   assert_implication #(0,0,"out16Valid thermometer")  assert_o16 (clk, reset_n, out16Valid, out12Valid);
   assert_implication #(0,0,"out12Valid thermometer")  assert_o12 (clk, reset_n, out12Valid, out8Valid);
   assert_implication #(0,0,"out8Valid thermometer")   assert_o8 (clk, reset_n, out8Valid, out4Valid);
   //-- check that output shifts are one-hot
   assert_zero_one_hot #(0,6,0,"decAlignShift one-hot")  
   assert_decAlignShiftOneHot (clk, reset_n, {decAlignShift24, decAlignShift20, decAlignShift16,
                                              decAlignShift12, decAlignShift8, decAlignShift4});
   //-- check that the output (decoder) is proper 2-phase
   pc_2Phase  dec_2Phase (.clk(clk), .reset_n(reset_n), 
                          .valid1(|{out24Valid, out20Valid, out16Valid, out12Valid, out8Valid,  out4Valid}), 
                          .valid2(|{decAlignShift24, decAlignShift20, decAlignShift16,
                                    decAlignShift12, decAlignShift8, decAlignShift4}));
   
`endif
   // synopsys translate_on
endmodule // aligner
