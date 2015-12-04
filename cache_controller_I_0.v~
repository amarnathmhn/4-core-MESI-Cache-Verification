//Module for cache controller 
//Implemented Pseudo LRU and MESI state machine

`include "cache_def_I_0.v"

module cache_controller_I_0(            PrRd, 
                                    Address,
                       	            LRU_replacement_proc,
                                    Blk_accessed, 
 			                           Address_Com, 
                                    Data_Bus_Com 
			               );

// Signals for Processor requests
input                               PrRd;

// Outputs of MESI and LRU for both processor & Snoop requests
output 	[((`ASSOCIATIVITY)-1) : 0]	LRU_replacement_proc;		

// Input from Cache_block for LRU computation
input 	[((`ASSOCIATIVITY)-1) : 0]	Blk_accessed;

// Processor Address and Data_Bus - each between a processor and its IL1 or DL1 caches
input 	[`ADDRESSSIZE-1 : 0] 		Address;

// Snoop Common Address and Data Bus - Shared among all multi-processors (each for Instruction and Data caches)
input 	[`ADDRESSSIZE-1 : 0] 		Address_Com;
input 	[`ADDRESSSIZE-1 : 0] 		Data_Bus_Com;
/**********************************************************************************/

/**********************************************************************************/
// Port's Net or Reg declaration
wire 	[((`ASSOCIATIVITY)-1) : 0]	   LRU_replacement_proc;		
wire	[((`ASSOCIATIVITY)-1) : 0]	   Blk_accessed;
wire 	[`ADDRESSSIZE-1 : 0] 		   Address;
wire 	[`ADDRESSSIZE-1 : 0] 		   Address_Com;
wire 	[`ADDRESSSIZE-1 : 0] 		   Data_Bus_Com;
wire   	                           PrRd;
/**********************************************************************************/

/**********************************************************************************/
// Internal reg variables for Wrapper which gives Indes/Tag/Blk_offset details - each for Processor & Snoop requests
// For Processor
reg 	[`INDEX_SIZE-1 : 0] 		      Index_proc;
reg 	[`TAG_SIZE-1 : 0] 	   	   Tag_proc;
reg 	[`BLK_OFFSET_SIZE-1 : 0]	   Blk_offset_proc;

// Internal temp variable
reg	[((`ASSOCIATIVITY)-1) : 0]	   LRU_replacement_proc_reg;

// Internal LRU STRUCTURE, which holds the LRU states of each cache sets
reg 	[`LRU_SIZE-1 : 0]		         LRU_var	[0:`NUM_OF_SETS-1];
/**********************************************************************************/

/**********************************************************************************/
// Pseudo-LRU Block State parameters
parameter BLK1_REPLACEMENT = 3'b00x;
parameter BLK2_REPLACEMENT = 3'b01x;
parameter BLK3_REPLACEMENT = 3'b1x0;
parameter BLK4_REPLACEMENT = 3'b1x1;
/**********************************************************************************/

/**********************************************************************************/
// Address to Index/Tag/Blk_offset wrapping  - each for processor & snoop
// Index, Blk, Tag extraction from the address of Processor bus
always @ *
begin
        Index_proc 		   = Address[`INDEX_MSB : `INDEX_LSB];
        Tag_proc 		      = Address[TAG_MSB : `TAG_LSB];
        Blk_offset_proc 	= Address[`BLK_OFFSET_MSB : `BLK_OFFSET_LSB];
end
/**********************************************************************************/


/**********************************************************************************/
//Driving of LRU_replacement output by internal temp LRU_replacement variable
assign LRU_replacement_proc = LRU_replacement_proc_reg;
/**********************************************************************************/


/****************************Pseudo-LRU Block*************************************/

// Code for finding the replacement block based on current LRU state
always @ *
begin
	casex (LRU_var[Index_proc])				// Current LRU state
		BLK1_REPLACEMENT:
		begin
			LRU_replacement_proc_reg = 2'b00;	
		end
		BLK2_REPLACEMENT:
		begin
			LRU_replacement_proc_reg = 2'b01;	
		end
		BLK3_REPLACEMENT:
		begin
			LRU_replacement_proc_reg = 2'b10;	
		end
		BLK4_REPLACEMENT:
		begin
			LRU_replacement_proc_reg = 2'b11;	
		end
		default:
		begin
			LRU_replacement_proc_reg = 2'b00;	
		end
	endcase
end


// Code for deduction of LRU_next state based on block being accessed   
always @ *
begin
	case (Blk_accessed)		// Block which is accessed now - accordingly the next replacement is deducted
		2'b00:
		begin			
			LRU_var[Index_proc][2:1]= 2'b11;	
		end
		2'b01:
		begin
			LRU_var[Index_proc][2:1]= 2'b10;	
		end
		2'b10:
		begin
			LRU_var[Index_proc][2] 	= 1'b0;	
			LRU_var[Index_proc][0] 	= 1'b1;	
		end
		2'b11:		
		begin
			LRU_var[Index_proc][2] 	= 1'b0;	
			LRU_var[Index_proc][0] 	= 1'b0;
		end	
		default:
		begin
			LRU_var[Index_proc]	= 3'b000;
		end	
	endcase
end
/*********************************************************************************/

endmodule

