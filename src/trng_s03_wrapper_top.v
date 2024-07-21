//////////////////////////////////////////////////////////////////////////////////
// Company: FICS
// Engineer: Md Sami Ul Islam Sami
// 
// Create Date: 05/09/2022 04:05:17 PM
// Design Name: Odometer_APB_Slave_Wrapper
// Module Name: odometer_s02_wrapper_top
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

module trng_s03_wrapper_top(pclk_03, presetn_03, paddr_03, pwdata_03, pprot_03, psel_03, penable_03, pwrite_03, pstrb_03, pready_03, pslverr_03, prdata_03);

`include "config_pkg.vh"
  
      // Ports of APB Slave Bus Interface S00
      input wire                                pclk_03;
      input wire                                presetn_03;
      input wire    [APB_ADDR_WIDTH-1 : 0]      paddr_03;
      input wire    [APB_DATA_WIDTH-1 : 0]      pwdata_03;
      input wire    [2 : 0]                     pprot_03;
      input wire                                psel_03;
      input wire                                penable_03;
      input wire                                pwrite_03;
      input wire    [APB_STROBE_WIDTH-1 : 0]    pstrb_03; 
      output wire                               pready_03;
      output wire                               pslverr_03;
      output wire   [APB_DATA_WIDTH-1 : 0]      prdata_03;
      
      
    // Instantiation of APB Bus Interface S00 
     trng_apb_s03 U3(
        .PCLK(pclk_03),
        .PRESETn(presetn_03),
        .PADDR(paddr_03),
        .PWDATA(pwdata_03),
        .PPROT(pprot_03),
        .PSEL(psel_03),
        .PENABLE(penable_03),
        .PWRITE(pwrite_03),
        .PSTRB(pstrb_03),
        .PREADY(pready_03),
        .PSLVERR(pslverr_03),
        .PRDATA(prdata_03)
     );
         
        
endmodule


