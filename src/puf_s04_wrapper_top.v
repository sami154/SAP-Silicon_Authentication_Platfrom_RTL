
//////////////////////////////////////////////////////////////////////////////////
// Company: FICS
// Engineer: MD Sami Ul Islam Sami
// 
// Create Date: 6/9/2023 11:29:12 AM
// Design Name: PUF_APB_Slave_Wrapper
// Module Name: puf_s04_wrapper_top
// Project Name: SAP
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module puf_s04_wrapper_top(pclk_04, presetn_04, paddr_04, pwdata_04, pprot_04, psel_04, penable_04, pwrite_04, pstrb_04, pready_04, pslverr_04, prdata_04);

`include "config_pkg.vh"
  
      // Ports of APB Slave Bus Interface S00
      input wire                                pclk_04;
      input wire                                presetn_04;
      input wire    [APB_ADDR_WIDTH-1 : 0]      paddr_04;
      input wire    [APB_DATA_WIDTH-1 : 0]      pwdata_04;
      input wire    [2 : 0]                     pprot_04;
      input wire                                psel_04;
      input wire                                penable_04;
      input wire                                pwrite_04;
      input wire    [APB_STROBE_WIDTH-1 : 0]    pstrb_04; 
      output wire                               pready_04;
      output wire                               pslverr_04;
      output wire   [APB_DATA_WIDTH-1 : 0]      prdata_04;
      
      
    // Instantiation of APB Bus Interface S00 
     puf_apb_s04 PUF_U4(
        .PCLK(pclk_04),
        .PRESETn(presetn_04),
        .PADDR(paddr_04),
        .PWDATA(pwdata_04),
        .PPROT(pprot_04),
        .PSEL(psel_04),
        .PENABLE(penable_04),
        .PWRITE(pwrite_04),
        .PSTRB(pstrb_04),
        .PREADY(pready_04),
        .PSLVERR(pslverr_04),
        .PRDATA(prdata_04)
     );
         
        
endmodule

