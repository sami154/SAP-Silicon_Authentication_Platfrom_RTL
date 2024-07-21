
//////////////////////////////////////////////////////////////////////////////////
// Company: FICS
// Engineer: MD Sami Ul Islam Sami
// 
// Create Date: 6/9/2023 11:29:12 AM
// Design Name: PUF_APB_Slave_Wrapper
// Module Name: ram_s05_wrapper_top
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

module ram_s05_wrapper_top(pclk_05, presetn_05, paddr_05, pwdata_05, pprot_05, psel_05, penable_05, pwrite_05, pstrb_05, pready_05, pslverr_05, prdata_05);

`include "config_pkg.vh"
  
      // Ports of APB Slave Bus Interface S00
      input wire                                pclk_05;
      input wire                                presetn_05;
      input wire    [APB_ADDR_WIDTH-1 : 0]      paddr_05;
      input wire    [APB_DATA_WIDTH-1 : 0]      pwdata_05;
      input wire    [2 : 0]                     pprot_05;
      input wire                                psel_05;
      input wire                                penable_05;
      input wire                                pwrite_05;
      input wire    [APB_STROBE_WIDTH-1 : 0]    pstrb_05; 
      output wire                               pready_05;
      output wire                               pslverr_05;
      output wire   [APB_DATA_WIDTH-1 : 0]      prdata_05;
      
	
      
    // Instantiation of APB Bus Interface S00 
     ram_apb_s05 RAM_U5(
        .PCLK(pclk_05),
        .PRESETn(presetn_05),
        .PADDR(paddr_05),
        .PWDATA(pwdata_05),
        .PPROT(pprot_05),
        .PSEL(psel_05),
        .PENABLE(penable_05),
        .PWRITE(pwrite_05),
        .PSTRB(pstrb_05),
        .PREADY(pready_05),
        .PSLVERR(pslverr_05),
        .PRDATA(prdata_05)
		
     );
         
        
endmodule

