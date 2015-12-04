//Module for cache controller 
//Implemented Pseudo LRU and MESI state machine

`include "cache_def_2.v"

module cache_controller_2(PrRd, 
                        PrWr,
                        Address,
                        Data_Bus, 
                       	LRU_replacement_proc,
			Current_MESI_state_proc,
			Current_MESI_state_snoop, 
                        Blk_accessed, 
                        Updated_MESI_state_proc,
			Updated_MESI_state_snoop,                         
 			Address_Com, 
                        Data_Bus_Com, 
                        Shared, 
                        BusRd, 
                        BusRdX,
			Invalidate);

// Signals for Processor requests
input   PrRd;
input   PrWr;

// Signal stating if the requested block is present as Shared mode or not
input 	Shared;

// Signal for Snoop requests
input   BusRd;
input   BusRdX;
input 	Invalidate;

// Outputs of MESI and LRU for both processor & Snoop requests
output 	[((`ASSOCIATIVITY)-1) : 0]	LRU_replacement_proc;		
output	[`MESI_SIZE-1 : 0]		Updated_MESI_state_proc;
output	[`MESI_SIZE-1 : 0]		Updated_MESI_state_snoop;

// Inputs from Cache_block for MESI computation
input	[`MESI_SIZE-1 :	0]		Current_MESI_state_proc;
input	[`MESI_SIZE-1 :	0]		Current_MESI_state_snoop;

// Input from Cache_block for LRU computation
input 	[((`ASSOCIATIVITY)-1) : 0]	Blk_accessed;

// Processor Address and Data_Bus - each between a processor and its IL1 or DL1 caches
input 	[`ADDRESSSIZE-1 : 0] 		Address;
input 	[`ADDRESSSIZE-1 : 0] 		Data_Bus;

// Snoop Common Address and Data Bus - Shared among all multi-processors (each for Instruction and Data caches)
input 	[`ADDRESSSIZE-1 : 0] 		Address_Com;
input 	[`ADDRESSSIZE-1 : 0] 		Data_Bus_Com;
/**********************************************************************************/



/**********************************************************************************/
// Port's Net or Reg declaration
wire 	[((`ASSOCIATIVITY)-1) : 0]	LRU_replacement_proc;		
wire	[`MESI_SIZE-1 :	0]		Current_MESI_state_proc;
wire	[`MESI_SIZE-1 :	0]		Current_MESI_state_snoop;
wire	[((`ASSOCIATIVITY)-1) : 0]	Blk_accessed;
wire 	[`ADDRESSSIZE-1 : 0] 		Address;
wire 	[`ADDRESSSIZE-1 : 0] 		Data_Bus;
wire 	[`ADDRESSSIZE-1 : 0] 		Address_Com;
wire 	[`ADDRESSSIZE-1 : 0] 		Data_Bus_Com;
wire   	PrRd;
wire   	PrWr;
wire	Shared;
wire   	BusRd;
wire   	BusRdX;
wire 	Invalidate;
reg	[`MESI_SIZE-1 : 0]		Updated_MESI_state_proc;
reg	[`MESI_SIZE-1 : 0]		Updated_MESI_state_snoop;
/**********************************************************************************/



/**********************************************************************************/
// Internal reg variables for Wrapper which gives Indes/Tag/Blk_offset details - each for Processor & Snoop requests
// For Processor
reg 	[`INDEX_SIZE-1 : 0] 		Index_proc;
reg 	[`TAG_SIZE-1 : 0] 		Tag_proc;
reg 	[`BLK_OFFSET_SIZE-1 : 0]	Blk_offset_proc;
// For Snoop
reg 	[`INDEX_SIZE-1 : 0] 		Index_snoop;
reg 	[`TAG_SIZE-1 : 0] 		Tag_snoop;
reg 	[`BLK_OFFSET_SIZE-1 : 0]	Blk_offset_snoop;

// Internal temp variable
reg	[((`ASSOCIATIVITY)-1) : 0]	LRU_replacement_proc_reg;

// Internal LRU STRUCTURE, which holds the LRU states of each cache sets
reg 	[`LRU_SIZE-1 : 0]		LRU_var	[0:`NUM_OF_SETS-1];
/**********************************************************************************/



/**********************************************************************************/
// Pseudo-LRU Block State parameters
parameter BLK1_REPLACEMENT = 3'b0x0;
parameter BLK2_REPLACEMENT = 3'b0x1;
parameter BLK3_REPLACEMENT = 3'b10x;
parameter BLK4_REPLACEMENT = 3'b11x;

// Parameters for MESI protocol
parameter INVALID 	= 2'b00;
parameter SHARED	= 2'b01;
parameter EXCLUSIVE	= 2'b10;
parameter MODIFIED 	= 2'b11;
/**********************************************************************************/



/**********************************************************************************/
// Address to Index/Tag/Blk_offset wrapping  - each for processor & snoop
// Index, Blk, Tag extraction from the address of Processor bus
always @ *
begin
    if(PrRd || PrWr) 
    begin
        Index_proc 		= Address[`INDEX_MSB : `INDEX_LSB];
        Tag_proc 		= Address[`TAG_MSB : `TAG_LSB];
        Blk_offset_proc 	= Address[`BLK_OFFSET_MSB : `BLK_OFFSET_LSB];
    end
end

// Index, Blk, Tag extraction from the address of Snoop bus
always @ *
begin
    if ((BusRd || BusRdX || Invalidate)) //Snooping Bus request
    begin
        Index_snoop 		= Address_Com[`INDEX_MSB : `INDEX_LSB];
        Tag_snoop 		= Address_Com[`TAG_MSB : `TAG_LSB];
        Blk_offset_snoop 	= Address_Com[`BLK_OFFSET_MSB : `BLK_OFFSET_LSB];
    end
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



/**********************************************************************************
                       MESI STATE DIAGRAM IMPLEMENTATION - Processor
**********************************************************************************/

always @ *
begin
    Updated_MESI_state_proc  <= INVALID;
    
    case (Current_MESI_state_proc)
        MODIFIED:
        begin
            if (PrRd || PrWr)
            begin
                Updated_MESI_state_proc  <= MODIFIED; 
            end 
            else
            begin
                Updated_MESI_state_proc  <= MODIFIED;
            end
        end    
        EXCLUSIVE:
        begin
            if (PrRd)
            begin
                Updated_MESI_state_proc  <= EXCLUSIVE;            
            end
            else if (PrWr)
            begin
                Updated_MESI_state_proc  <= MODIFIED;
            end
            else
            begin
                Updated_MESI_state_proc  <= EXCLUSIVE;
            end
        end
        SHARED:
        begin
            if (PrRd)
            begin
                Updated_MESI_state_proc  <= SHARED;
            end
            else if (PrWr)
            begin
                Updated_MESI_state_proc  <= MODIFIED;
            end
            else
	    begin
                Updated_MESI_state_proc  <= SHARED;
            end
        end
        INVALID:
        begin
            if (PrRd && Shared)
            begin
                 Updated_MESI_state_proc <= SHARED;
            end
            else if (PrRd && !Shared)
            begin
                Updated_MESI_state_proc  <= EXCLUSIVE;
            end
            else if (PrWr)
            begin
                Updated_MESI_state_proc  <= MODIFIED;
            end
            else
            begin
                Updated_MESI_state_proc  <= INVALID;
            end
        end
        default:
        begin
                Updated_MESI_state_proc  <= INVALID;
        end
    endcase
end
/************** end of MESI implementation for proc ***************************/



/*******************************************************************************
                   MESI STATE DIAGRAM IMPLEMENTATION - Snoop
*******************************************************************************/
always @ *
begin
    Updated_MESI_state_snoop  <= INVALID;
    
    case (Current_MESI_state_snoop)
        MODIFIED:
        begin
            if (BusRd)
            begin
                Updated_MESI_state_snoop  <= SHARED;
            end
            else if (BusRdX)
            begin
                Updated_MESI_state_snoop  <= INVALID;
            end
            else
            begin
                Updated_MESI_state_snoop  <= MODIFIED;
            end
        end    
        EXCLUSIVE:
        begin
            if (BusRd)
            begin
                Updated_MESI_state_snoop  <= SHARED;
            end
            else if (BusRdX)
            begin
                Updated_MESI_state_snoop  <= INVALID;
            end
            else
            begin
                Updated_MESI_state_snoop  <= EXCLUSIVE;
            end
        end
        SHARED:
        begin
            if (BusRdX)
            begin
                Updated_MESI_state_snoop  <= INVALID;
            end
            else if (Invalidate)
	    begin
	    	Updated_MESI_state_snoop <= INVALID;
	    end
            else
	    begin
                Updated_MESI_state_snoop  <= SHARED;
            end
        end
        INVALID:
        begin
                Updated_MESI_state_snoop  <= INVALID;
        end
        default:
        begin
                Updated_MESI_state_snoop  <= INVALID;
        end
    endcase
end
/************** end of MESI implementation for Snoop *************************/

endmodule

