//////////////////////////////////////////////////////////////////////////////////
// Company: FICS    
// Engineer: Md Sami Ul Islam Sami
// 
// Create Date: 06/09/2023 12:49:48 AM
// Design Name: PUF_APB_Slave
// Module Name: puf_apb_s04
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

// challenge and helper data are mapped to {slv_reg3, slv_reg2, slv_reg1, slv_reg0} 
// input ready signal of aes_inv_ciph_out module is mapped to slv_reg4[0]
// puf response is mapped to (slv_reg12 , slv_reg11 , slv_reg10 , slv_reg9 , slv_reg8 , slv_reg7 , slv_reg6, slv_reg5)

`include "timescale.v"

module puf_apb_s04(PCLK, PRESETn, PADDR, PWDATA, PPROT, PSEL, PENABLE, PWRITE, PSTRB, PREADY, PSLVERR, PRDATA);
      
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
      reg   [APB_DATA_WIDTH-1 : 0]  prdata;
      
      //----------------------------------
      //-- Signals for user logic registers
      //----------------------------------
      //-- Number of Slave Registers 13 
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg0;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg1;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg2;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg3;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg4;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg5;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg6;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg7;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg8;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg9;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg10;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg11;
      reg   [APB_DATA_WIDTH-1 : 0]  slv_reg12;


      //read enable for the slave registers  
      reg  slv_reg_rden;
      //write enable for the slave registers  
      reg  slv_reg_wren;
      integer   byte_index;
      reg   [APB_DATA_WIDTH-1 : 0]  reg_data_out;
   
      // Add user logic signals here
      wire done;
//      wire [PUF_CHALLENGE_WIDTH-1 : 0]    data_in;
      wire [PUF_RESPONSE_WIDTH-1 : 0]   puf_response;
      reg  busy;
      reg  busy_state;
      // User logic signals end
      
      // I/O Connections assignments 
      assign    PREADY  = pready_r;
      assign    PSLVERR = pslverr_r;
      assign    PRDATA  = reg_data_out;
      
      // Operating states of the FSM 
      reg   [1 : 0] state, next_state;
      
      localparam
      // This is the default state of the APB
      // When a transfer is required the bus moves into the SETUP state.
      // The bus only remains in SETUP state for one clock cycle and always moves to ACCESS state
      // If PREADY is 1, on the next rising edge of the clock write/read operation is done.  
                IDLE    = 2'b00,
      
                SETUP   = 2'b01,      
      
                ACCESS = 2'b10;
       
	   //FSMD of the APB4 
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
                                if ( (PADDR >= BASE_ADDR_WRITE_04) && (PADDR <= (BASE_ADDR_WRITE_04 + 4*(SLV_REGS_WRITE_04 - 1))) )
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
                                 if ( (PADDR >= BASE_ADDR_READ_04) && (PADDR <= (BASE_ADDR_READ_04 + 4*(SLV_REGS_READ_04 - 1))) )
                                    begin
                                        slv_reg_rden <= 1'b1;
                                        pready <= ~busy;
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
                                if ( (PADDR >= BASE_ADDR_WRITE_04) && (PADDR <= (BASE_ADDR_WRITE_04 + 4*(SLV_REGS_WRITE_04 - 1))) )
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
                                 if ( (PADDR >= BASE_ADDR_READ_04) && (PADDR <= (BASE_ADDR_READ_04 + 4*(SLV_REGS_READ_04 - 1))) )
                                    begin
                                        slv_reg_rden <= 1'b1;
                                        pready <= ~busy;
                                    end
                                else
                                    begin
                                        pready <= 1'b1;
                                        pslverr <= 1'b1;
                                    end
                            end   
                    end
                    
                // If PREADY is driven HIGH by the slave and another transfer follows, the bus moves directly to SETUP state        
                if( (busy == 1'b0) && (PSEL == 1'b1) )
                   begin
                       next_state <= SETUP;
                   end
                // If PREADY is driven HIGH by the slave and no more transfers are required, the bus moves to IDLE state.
                else if ( (busy == 1'b0) && (PSEL == 1'b0) ) 
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
                slv_reg1 <= 0;
                slv_reg2 <= 0;
                slv_reg3 <= 0;
                slv_reg4 <= 0;

                                                
            end
        else if ( slv_reg_wren == 1'b1 )
            begin
                // Address decoding for writing into registers
                case( paddr[ADDR_BITS_FOR_SLV_REGS_04 + 2 - 1 : 2] - BASE_ADDR_WRITE_04[ADDR_BITS_FOR_SLV_REGS_04 + 2 - 1 : 2])
                     5'h00:
                    begin
                        if( PSTRB == 0 )
                        begin
                            slv_reg0 <= pwdata;
                        end
                        else
                        begin
                            for( byte_index = 0; byte_index <= APB_STROBE_WIDTH-1; byte_index = byte_index+1)
                                if( PSTRB[byte_index] == 1 )
                                // Respective byte enables are asserted as per write strobes.
                                //Slave register 0
                                begin
                                    slv_reg0[(byte_index)*8 +: 8] <= pwdata[(byte_index)*8 +: 8];
                                end
                        end
                   end
                   5'h01:
                   begin
                        if( PSTRB == 0 )
                        begin
                            slv_reg1 <= pwdata;
                        end
                        else
                        begin
                            for( byte_index = 0; byte_index <= APB_STROBE_WIDTH-1; byte_index = byte_index+1 )
                                if( PSTRB[byte_index] == 1 )
                                // Respective byte enables are asserted as per write strobes.
                                //Slave register 1
                                begin
                                    slv_reg1[(byte_index)*8 +: 8] <= pwdata[(byte_index)*8 +: 8];
                                end
                        end
                   end         
                   5'h02:
                   begin
                        if( PSTRB == 0 )
                        begin
                            slv_reg2 <= pwdata;
                        end
                        else
                        begin
                            for( byte_index = 0; byte_index <= APB_STROBE_WIDTH-1; byte_index = byte_index+1 )
                                if( PSTRB[byte_index] == 1 )
                                // Respective byte enables are asserted as per write strobes.
                                //Slave register 2
                                begin
                                    slv_reg2[(byte_index)*8 +: 8] <= pwdata[(byte_index)*8 +: 8];
                                end
                        end
                   end         
                   5'h03:
                   begin
                        if( PSTRB == 0 )
                        begin
                            slv_reg3 <= pwdata;
                        end
                        else
                        begin
                            for( byte_index = 0; byte_index <= APB_STROBE_WIDTH-1; byte_index = byte_index+1 )
                                if( PSTRB[byte_index] == 1 )
                                // Respective byte enables are asserted as per write strobes.
                                //Slave register 3
                                begin
                                    slv_reg3[(byte_index)*8 +: 8] <= pwdata[(byte_index)*8 +: 8];
                                end
                        end
                   end         
                   5'h04:
                   begin
                        if( PSTRB == 0 )
                        begin
                            slv_reg4 <= pwdata;
                        end
                        else
                        begin
                            for( byte_index = 0; byte_index <= APB_STROBE_WIDTH-1; byte_index = byte_index+1 )
                                if( PSTRB[byte_index] == 1 )
                                // Respective byte enables are asserted as per write strobes.
                                //Slave register 4
                                begin
                                    slv_reg4[(byte_index)*8 +: 8] <= pwdata[(byte_index)*8 +: 8];
                                end
                        end
                   end         
                  
                   
                                      

                            
                   default:
                   begin
                        slv_reg0 <= slv_reg0;
                        slv_reg1 <= slv_reg1;
                        slv_reg2 <= slv_reg2;
                        slv_reg3 <= slv_reg3;
                        slv_reg4 <= slv_reg4;
                           
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
                slv_reg5 <= 0;
                slv_reg6 <= 0;
                slv_reg7 <= 0;
                slv_reg8 <= 0;
                slv_reg9 <= 0;
                slv_reg10 <= 0;
                slv_reg11 <= 0;
                slv_reg12 <= 0;
            end
        else
            begin
                //When there is a valid read address with 
                //the data at that address being valid, 
                //output the read data 
                if( slv_reg_rden == 1'b1 )
                    begin
                        // Address decoding for reading registers
                        case ( paddr[ADDR_BITS_FOR_SLV_REGS_04 + 2 - 1 : 2] - BASE_ADDR_WRITE_04[ADDR_BITS_FOR_SLV_REGS_04 + 2 - 1 : 2] )
                              5'h05: reg_data_out <= slv_reg5 ;
                              5'h06: reg_data_out <= slv_reg6 ;
                              5'h07: reg_data_out <= slv_reg7 ;
                              5'h08: reg_data_out <= slv_reg8 ;
                              5'h09: reg_data_out <= slv_reg9 ;
                              5'h0a: reg_data_out <= slv_reg10;
                              5'h0b: reg_data_out <= slv_reg11;
                              5'h0c: reg_data_out <= slv_reg12;
                              default:
                              begin 
                              // do nothing 
                              end
                        endcase
                    end
                if(done == 1'b1)
                    begin
                        {slv_reg12 , slv_reg11 , slv_reg10 , slv_reg9 , slv_reg8 , slv_reg7 , slv_reg6, slv_reg5} <= puf_response;
                    end
            end 
    end
    
        // Add user logic here
        // Instantiate HASH IP
	wrapper_puf #(
//			  .CHALLENGE_SIZE(PUF_CHALLENGE_WIDTH),
				.CHALLENGE_SIZE(32),
			  .RESPONSE_SIZE(PUF_RESPONSE_WIDTH),
			  .HELPER_DATA_SIZE(PUF_HELPER_DATA_SIZE)
			  
) puf ( 
	.CHALLENGE(slv_reg0),
	.CLK(PCLK),
	.RST(~PRESETn),
	.INPUT_READY(slv_reg4[0]),
	.HELPER_DATA({slv_reg3, slv_reg2, slv_reg1}),
	.PUF_RESPONSE(puf_response),
	.DONE(done)
 );
                   
        // extra logic to generate busy signal
        always @ ( posedge PCLK or negedge PRESETn )
        begin
            if( PRESETn == 1'b0 )
                begin
                    busy <= 1'b0;
                    busy_state <= 0;
                end
            else
                begin
                    case(busy_state)
                    1'b0:
                        if(slv_reg4[0])
                            begin
                                busy <= 1'b1;
                                busy_state <= 1;
                            end
                    1'b1:
                    begin
                       if( done == 1'b1 )
                        begin
                            busy <= 0;
                            busy_state <= 0;
                        end
                    end 
                    default:
                    begin
                    // do nothing
                    end
                    endcase 
                end
        end
           
        // extra logic end
      
      
endmodule
