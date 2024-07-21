//////////////////////////////////////////////////////////////////////////////////
// Company: FICS
// Engineer: Md Sami Ul Islam sami
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

module odometer_s02_wrapper_top(pclk_02, presetn_02, paddr_02, pwdata_02, pprot_02, psel_02, penable_02, pwrite_02, pstrb_02, pready_02, pslverr_02, prdata_02);

`include "config_pkg.vh"
  
      // Ports of APB Slave Bus Interface S00
      input wire                                pclk_02;
      input wire                                presetn_02;
      input wire    [APB_ADDR_WIDTH-1 : 0]      paddr_02;
      input wire    [APB_DATA_WIDTH-1 : 0]      pwdata_02;
      input wire    [2 : 0]                     pprot_02;
      input wire                                psel_02;
      input wire                                penable_02;
      input wire                                pwrite_02;
      input wire    [APB_STROBE_WIDTH-1 : 0]    pstrb_02; 
      output wire                               pready_02;
      output wire                               pslverr_02;
      output wire   [APB_DATA_WIDTH-1 : 0]      prdata_02;
      
      
    // Instantiation of APB Bus Interface S00 
     odometer_apb_s02 U2(
        .PCLK(pclk_02),
        .PRESETn(presetn_02),
        .PADDR(paddr_02),
        .PWDATA(pwdata_02),
        .PPROT(pprot_02),
        .PSEL(psel_02),
        .PENABLE(penable_02),
        .PWRITE(pwrite_02),
        .PSTRB(pstrb_02),
        .PREADY(pready_02),
        .PSLVERR(pslverr_02),
        .PRDATA(prdata_02)
     );
         
        
endmodule

