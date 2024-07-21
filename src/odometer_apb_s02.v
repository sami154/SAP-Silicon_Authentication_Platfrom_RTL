//////////////////////////////////////////////////////////////////////////////////
// Company: FICS
// Engineer: Md Sami Ul Islam Sami
// 
// Create Date: 05/09/2022 11:16:52 PM
// Design Name: AES_APB_Slave
// Module Name: odometer_apb_s02
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
///////////////////////////////////////////////////////////////////////////////////

// ODO_SEL_MUX is mapped to slv_reg0[2:0]
//mode is mapped to slv_reg0[4:3]
//freq diff is mapped to slv_reg1[7:0] 

`include "timescale.v"  

module odometer_apb_s02(PCLK, PRESETn, PADDR, PWDATA, PPROT, PSEL, PENABLE, PWRITE, PSTRB, PREADY, PSLVERR, PRDATA);

`include "config_pkg.vh" 

      // Global Clock Signal 
      input wire    PCLK;
      // Global Reset Signal. This Signal is Active LOW 
      input wire    PRESETn;    
      
      // Write address (issued by master, acceped by Slave)
      input wire    [APB_ADDR_WIDTH-1 : 0]  PADDR;
      // Write data (issued by master, acceped by Slave)
      input wire    [APB_DATA_WIDTH-1 : 0]  PWDATA;
      // This signal indicates the privilege and
      // security level of the transaction.
      input wire    [2 : 0] PPROT;
      // It indicates that the slave device is selected and 
      // that a data transfer is required.
      input wire    PSEL;
      // Enable. This signal indicates the second and subsequent cycles
      // of an APB transfer.
      input wire    PENABLE;
      // This signal indicates an APB write access when HIGH and an APB 
      // read access when LOW.
      input wire    PWRITE;
      // It enables sparse data transfer on the write data bus.
      input wire  [APB_STROBE_WIDTH-1 : 0]  PSTRB;
      
      // Indicates completion of an APB transfer 
      output wire    PREADY;
      // Indicates a transfer failure 
      output wire    PSLVERR;
      // Read data (issued by slave)
      output wire    [APB_DATA_WIDTH-1 : 0] PRDATA;
      
      // APB4 signals
      reg   [APB_ADDR_WIDTH-1 : 0]  paddr;
      reg   [APB_DATA_WIDTH-1 : 0]  pwdata;
      reg   pready, pready_r;
      reg   pslverr, pslverr_r;
//      reg   [APB_DATA_WIDTH-1 : 0]  prdata;
      
      //----------------------------------
      //--user logic registers
      //----------------------------------
      //-- Number of Slave Registers 8 
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg0;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg1;
      
      //read enable for the slave registers  
      reg  slv_reg_rden;
      //write enable for the slave registers  
      reg  slv_reg_wren;
      //index for bytes incase of strobe transactions
      integer   byte_index;
      reg   [APB_DATA_WIDTH-1 : 0]  reg_data_out;
   
      // Add additional logic signals here
      wire [ODOMETER_OUT_WIDTH-1:0] freq_diff;
//      reg   busy;
//      reg [1:0] busy_state;
      // additional logic signals end
      
      // I/O Connections assignments 
      assign    PREADY  = pready_r;
      assign    PSLVERR = pslverr_r;
      assign    PRDATA  = reg_data_out;
      
      // Operating states of the FSM 
      reg   [1 : 0] state, next_state;
      
      localparam
      // IDLE is the default state of the APB
      // When a transfer is required the bus moves into the SETUP state.
      // The bus only remains in SETUP state for one clock cycle and always moves to ACCESS state
      // If PREADY is 1, on the next rising edge of the clock write/read operation is done.  
                IDLE    = 2'b00,
      
                SETUP   = 2'b01,      
      
                ACCESS = 2'b10;
        
        
      always @ ( posedge PCLK or negedge PRESETn )
      begin
        if ( PRESETn == 1'b0 )
            begin
                pready_r <= 0;
                pslverr_r <= 0;
            end
        else
            begin
                // PREADY needs to be driven LOW during SETUP state.
                case(next_state)
                IDLE: 
                begin
                    pready_r <= 1;
                    pslverr_r <= 0;
                end
                SETUP:
                begin
                    pready_r <= 0;
                    pslverr_r <= 0;
                end
                ACCESS:
                begin
                    pready_r <= pready;
                    pslverr_r <= pslverr;
                end
                default: 
                begin 
                    pready_r <= pready;
                    pslverr_r <= pslverr;
                end
                endcase
            end
      end
               
      //FSMD of the APB4 controller
      always @ ( posedge PCLK or negedge PRESETn )
      begin
        if ( PRESETn == 1'b0 )
            begin
                state <= IDLE;
            end
        else
            begin
                state <= next_state;
            end
      end
      
     always@(*)
     begin 
        next_state  <= state;
        pslverr     <= 1'b0;
        pready      <= 1'b0;
        slv_reg_rden <= 1'b0;
        slv_reg_wren <= 1'b0;
        pwdata      <= PWDATA;
        paddr       <= PADDR;
        case ( state ) 
            IDLE: 
            begin
                if ( PSEL == 1'b1 )
                // PSEL indicates a data transfer is required.
                // When a transfer is required the bus moves into the SETUP state. 
                    begin
                        next_state <= SETUP;
                    end
            end   
            SETUP:
            begin
                //paddr <= PADDR;
                
                // Enable is asserted by the master during the SETUP state.
                // A write/read transfer starts with a valid PADDR.
                if ( (PSEL == 1'b1) && (PENABLE == 1'b1) )
                    begin
                        if ( PWRITE == 1'b1 )
                        // PWRITE, when HIGH indicates write transfer.
                        // When the address provided by master is not valid,
                        // pready is asserted and pslverr will be asserted in the next state.
                            begin
                                if ( (PADDR >= BASE_ADDR_WRITE_02) && (PADDR <= (BASE_ADDR_WRITE_02 + 4*(SLV_REGS_WRITE_02 - 1))) )
                                    begin
                                        slv_reg_wren <= 1'b1;
                                        pready <= 1'b1;
                                    end
                                else
                                    begin
                                        pready <= 1'b1;
                                        pslverr <= 1'b1;
                                    end
                            end
                        else
                        // PWRITE, when LOW indicates read transfer.
                            begin
                                 if ( (PADDR >= BASE_ADDR_READ_02) && (PADDR <= (BASE_ADDR_READ_02 + 4*(SLV_REGS_READ_02 - 1))) )
                                    begin
                                        slv_reg_rden <= 1'b1;
                                        pready <= 1'b1;
                                    end
                                else
                                    begin
                                        pready <= 1'b1;
                                        pslverr <= 1'b1; 
                                    end
                            end   
                    end
                
                next_state <= ACCESS;
            end
            ACCESS:
            begin
                paddr <= PADDR;
                if ( (PSEL == 1'b1) && (PENABLE == 1'b1) )
                    begin
                        if ( PWRITE == 1'b1 )
                        // PWRITE, when HIGH indicates write transfer.
                        // When the address provided by master is not valid,
                        // pready is asserted and pslverr will be asserted in the next state.
                            begin
                                if ( (PADDR >= BASE_ADDR_WRITE_02) && (PADDR <= (BASE_ADDR_WRITE_02 + 4*(SLV_REGS_WRITE_02 - 1))) )
                                    begin
                                        slv_reg_wren <= 1'b1;
                                        pready <= 1'b1;
                                    end
                                else
                                    begin
                                        pready <= 1'b1;
                                        pslverr <= 1'b1;
                                    end
                            end
                        else
                        // PWRITE, when LOW indicates read transfer.
                            begin
                                 if ( (PADDR >= BASE_ADDR_READ_02) && (PADDR <= (BASE_ADDR_READ_02 + 4*(SLV_REGS_READ_02 - 1))) )
                                    begin
                                        slv_reg_rden <= 1'b1;
                                         pready <= 1'b1;
                                    end
                                else
                                    begin
                                        pready <= 1'b1;
                                        pslverr <= 1'b1;
                                    end
                            end   
                    end
                    
                // If PREADY is driven HIGH by the slave and another transfer follows, the bus moves directly to SETUP state        
                if( (PSEL == 1'b1) )
                   begin
                       next_state <= SETUP;
                   end
                // If PREADY is driven HIGH by the slave and no more transfers are required, the bus moves to IDLE state.
                else if ( (PSEL == 1'b0) ) 
                   begin
                       next_state <= IDLE;
                   end
                
            end 
            default:
            begin
                next_state <= IDLE;
            end 
            
        endcase
    end 
    
    // Implement memory mapped register select and write logic generation.
    // These registers are cleared when reset(active low) is applied.
    // Slave register write enable is asserted when valid valid address, data and other 
    //control signals are asserted by master.
    //Write strobes are used to select byte enables of slave registers while writing.
    always @ ( posedge PCLK or negedge PRESETn)
    begin
        if( PRESETn == 1'b0 )
            begin
                slv_reg0 <= 0;
                             
            end
        else if ( slv_reg_wren == 1'b1 )
            begin
                // Address decoding for writing into registers
                case( paddr[ADDR_BITS_FOR_SLV_REGS_02 + 2 - 1 : 2] - BASE_ADDR_WRITE_02[ADDR_BITS_FOR_SLV_REGS_02 + 2 - 1 : 2])
                     5'h00:
                    begin
                        if( PSTRB == 0 )
                        begin
                            slv_reg0 <= pwdata;
                        end
                        else
                        begin
                            for( byte_index = 0; byte_index <= APB_STROBE_WIDTH-1; byte_index = byte_index+1 )
                                if( PSTRB[byte_index] == 1 )
                                // Respective byte enables are asserted as per write strobes.
                                //Slave register 0
                                begin
                                    slv_reg0[(byte_index)*8 +: 8] <= pwdata[(byte_index)*8 +: 8];
                                end
                        end
                   end
                            
                   default:
                   begin
                        slv_reg0 <= slv_reg0;
                      
                   end
                               
            endcase
        end
                
    end 
    
    // Implement memory mapped register select and read logic generation 
    // Slave register read enable is asserted when valid address and control
    // signals are asserted by master.
    always @( posedge PCLK or negedge PRESETn )
    begin
        if ( PRESETn == 1'b0 )
            begin
                reg_data_out <= 0;
                slv_reg1 <= 0;
 
            end
        else
            begin
                //When there is a valid read address with 
                //the data at that address being valid, 
                //output the read data 
                if( slv_reg_rden == 1'b1 )
                    begin
                        // Address decoding for reading registers
                        case ( paddr[ADDR_BITS_FOR_SLV_REGS_02 + 2 - 1 : 2] - BASE_ADDR_WRITE_02[ADDR_BITS_FOR_SLV_REGS_02 + 2 - 1 : 2] )
                              5'h01: reg_data_out <= slv_reg1;
                              default:
                              begin 
                              // do nothing 
                              end
                        endcase
                    end
                    slv_reg1[7:0] <= freq_diff;

            end 
    end
    
        // Add user logic here
        // Instantiate AES cipher for encoding
        SN_CDIR_DECODER odometer(.clk(PCLK), 
                                .ODO_SEL_MUX(slv_reg0[2:0]), 
                                .mode(slv_reg0[4:3]), 
                                .freq_diff(freq_diff));
        
//    reg kld_s;
//        // extra logic to generate busy signal
//        always @ ( posedge PCLK or negedge PRESETn )
//        begin
//            if( PRESETn == 1'b0 )
//                begin
//                    busy <= 1'b0;
//                    busy_state <= 2'b00;
//                end
//            else
//                begin
//                    case(busy_state)
//                    2'b00:
//                        if(slv_reg8[0])
//                            begin
//                                busy <= 1'b1;
//                                busy_state <= 2'b01;
//                            end
//                    2'b01:
//                    begin
//                        if(slv_reg8[16] == 1'b1) begin
//                            busy_state <= 2'b10;
//                        end
//                        else if( done == 1'b1 )
//                            begin 
//                                busy_state <= 2'b11;
//                            end
//                    end 
//                    2'b10:
//                    begin
//                        if( done_inv == 1'b1 )
//                            begin
//                                busy_state <= 2'b11;
//                            end
//                    end    
//                    2'b11:
//                    begin
//                        busy <= 1'b0;
//                        busy_state <= 2'b00;
//                    end
//                    endcase 
//                end
//        end
           
        // extra logic end
      
      
endmodule