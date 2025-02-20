//--Slave Parameters     
     //Width of S_APB address bus 
    parameter integer APB_ADDR_WIDTH = 32;
    // Width of S_APB data bus 
    parameter integer APB_DATA_WIDTH = 32;
    // WIDTH of Strobe signal 
    parameter integer APB_STROBE_WIDTH = $ceil(APB_DATA_WIDTH/8);    
    
    
    //number of user logic slave registers with write access for respective slaves
    //AES
    parameter integer SLV_REGS_WRITE_00 = 9;
    //HASH
    parameter integer SLV_REGS_WRITE_01 = 17;
    //Odometer
    parameter integer SLV_REGS_WRITE_02 = 1;
    //TRNG
    parameter integer SLV_REGS_WRITE_03 = 1;
	//PUF
    parameter integer SLV_REGS_WRITE_04 = 5;
    //RAM
    parameter integer SLV_REGS_WRITE_05 = 3;
    
    //number of user logic slave registers with read access for respective slaves
    //AES
    parameter integer SLV_REGS_READ_00 = 8;
    //HASH
    parameter integer SLV_REGS_READ_01 = 8;
    //Odometer
    parameter integer SLV_REGS_READ_02 = 1;
    //TRNG
    parameter integer SLV_REGS_READ_03 = 4;
	//PUF
    parameter integer SLV_REGS_READ_04 = 8;
	//RAM
    parameter integer SLV_REGS_READ_05 = 1;
    
    
    // number of bits required to address user logic slave registers for respective slaves
    //AES
    parameter integer ADDR_BITS_FOR_SLV_REGS_00 = $clog2(SLV_REGS_READ_00 + SLV_REGS_WRITE_00);
    //HASH
    parameter integer ADDR_BITS_FOR_SLV_REGS_01 = $clog2(SLV_REGS_READ_01 + SLV_REGS_WRITE_01);
    //Odometer
    parameter integer ADDR_BITS_FOR_SLV_REGS_02 = $clog2(SLV_REGS_READ_02 + SLV_REGS_WRITE_02);
    //TRNG
    parameter integer ADDR_BITS_FOR_SLV_REGS_03 = $clog2(SLV_REGS_READ_03 + SLV_REGS_WRITE_03);
    //PUF
    parameter integer ADDR_BITS_FOR_SLV_REGS_04 = $clog2(SLV_REGS_READ_04 + SLV_REGS_WRITE_04);
    //RAM
    parameter integer ADDR_BITS_FOR_SLV_REGS_05 = $clog2(SLV_REGS_READ_05 + SLV_REGS_WRITE_05);
    
    // base address to write to the user logic registers for respective slaves
    //AES
    parameter BASE_ADDR_WRITE_00 = 32'h00000000;
    //HASH
    parameter BASE_ADDR_WRITE_01 = BASE_ADDR_WRITE_00 + (SLV_REGS_WRITE_00 + SLV_REGS_READ_00)*4;
    //Odometer
    parameter BASE_ADDR_WRITE_02 = BASE_ADDR_WRITE_01 + (SLV_REGS_WRITE_01 + SLV_REGS_READ_01)*4;
    //TRNG
    parameter BASE_ADDR_WRITE_03 = BASE_ADDR_WRITE_02 + (SLV_REGS_WRITE_02 + SLV_REGS_READ_02)*4;
	//PUF
    parameter BASE_ADDR_WRITE_04 = BASE_ADDR_WRITE_03 + (SLV_REGS_WRITE_03 + SLV_REGS_READ_03)*4;
    //RAM
    parameter BASE_ADDR_WRITE_05 = BASE_ADDR_WRITE_04 + (SLV_REGS_WRITE_04 + SLV_REGS_READ_04)*4;
	
    // base address to read from the user logic registers for respective slaves
    //AES
    parameter BASE_ADDR_READ_00 = BASE_ADDR_WRITE_00 + SLV_REGS_WRITE_00*4;
    //HASH
    parameter BASE_ADDR_READ_01 = BASE_ADDR_WRITE_01 + SLV_REGS_WRITE_01*4;
    //Odometer
    parameter BASE_ADDR_READ_02 = BASE_ADDR_WRITE_02 + SLV_REGS_WRITE_02*4;
    //TRNG
    parameter BASE_ADDR_READ_03 = BASE_ADDR_WRITE_03 + SLV_REGS_WRITE_03*4;
    //PUF
    parameter BASE_ADDR_READ_04 = BASE_ADDR_WRITE_04 + SLV_REGS_WRITE_04*4;
	//RAM
    parameter BASE_ADDR_READ_05 = BASE_ADDR_WRITE_05 + SLV_REGS_WRITE_05*4;
//--Master  parameters
    
    //Number of Slaves
    parameter integer NUMBER_OF_SLAVES = 7;
    
    //input and output widths of IPs
    parameter integer AES_TEXT_IN_WIDTH = 128;
    parameter integer AES_KEY_WIDTH = 128;
    parameter integer AES_CIPH_OUT_WIDTH = 128;
    parameter integer AES_INV_CIPH_OUT_WIDTH = 128;
    parameter integer HASH_IN_WIDTH = 512;
    parameter integer HASH_OUT_WIDTH = 256;
    parameter integer PUF_CHALLENGE_WIDTH = 32; 
    parameter integer PUF_RESPONSE_WIDTH = 256;
	parameter integer PUF_HELPER_DATA_SIZE = 96;
    parameter integer TRNG_OUT_WIDTH = 128;
    parameter integer MULT_INP_WIDTH = 128;
    parameter integer MULT_OUT_WIDTH = 128;
    parameter integer ODOMETER_IN_WIDTH = 5;
    parameter integer ODOMETER_OUT_WIDTH = 8;
    parameter integer ECC_OUT_WIDTH = 128;
	parameter integer RAM_ADDR_WIDTH = 6;
	parameter integer RAM_DATA_WIDTH = 32;
	parameter integer RAM_DEPTH = 64;
    
    //width of the opertaion_type signal which is log2(#of operation types) and #of operation types = 17
    parameter integer OPERATION_TYPE_WIDTH = 5;
    
    //width of PSELx signal
    parameter integer PSELx_WIDTH = $clog2(NUMBER_OF_SLAVES);
    
    
    //HOST data parameters
    parameter integer MAX_INPUT_DATA_SIZE = 512;
    parameter integer MAX_OUTPUT_DATA_SIZE = 512;
    parameter integer HOST_INSTRUCT_SIZE = 6;