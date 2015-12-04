/***************************************************************************************************************************************/
/***************************************Verilog Code to Implement Cache design**********************************************************/

// This is a generic design and can be multi-instaniated with few changes to implement a full multi-chip cache coherence system

// Designed for 4-way set associativite cache; SiZe details can be varied in cache_def.v file

// For full working system, the environment needs processor for each cache, separate multiple cache and common bus systems for Instruction & Data, common Arbiter, common L2 Data & instruction memory, All_invalidation checking block & other lower level memories

// This module contains the Cache Tag, MESI, data and the logic for cache access with both Processor and Snoop requests
// The module communicates with its processor, its cache_controller, All_invalidation checking block, Common Arbiter and Common Bus (which is shared among all caches & L2 level - separate for both Data & instruction)

`include "cache_def_I_2.v"

/* Cache block Module declaration*/
module cache_block_I_2 ( clk,
					PrRd,
                     Address,
                     Data_Bus,
                     CPU_stall,                    
                     Com_Bus_Req_proc,
		               Com_Bus_Gnt_proc,

   		            LRU_replacement_proc,

                     Blk_accessed,

                     Address_Com,
                     Data_Bus_Com,

                     Data_in_Bus
		               );

// port declaration to / from CPU
input 								clk;
input                                  PrRd;
input 	[`ADDRESSSIZE-1 : 0] 		   Address;
inout 	[`ADDRESSSIZE-1 : 0] 		   Data_Bus;
output                                 CPU_stall;

// Signal to Controller for computing replacement - current block which is accessed
output 	[((`ASSOCIATIVITY)-1) : 0]	   Blk_accessed;

// Bus Request and Grant signals for processor & snoop requests
output					                  Com_Bus_Req_proc;
input					                     Com_Bus_Gnt_proc;

// ports to or from Cache_Controller for LRU and MESI
input 	[((`ASSOCIATIVITY)-1) : 0]	   LRU_replacement_proc;		

// Ports to or from Common Data Bus
// Inout signals
inout 	[`ADDRESSSIZE-1 : 0] 		   Address_Com;
inout 	[`ADDRESSSIZE-1 : 0] 		   Data_Bus_Com;
inout                                  Data_in_Bus;

//Net or Reg declaration
wire 	                                 PrRd;
wire 	   [`ADDRESSSIZE-1 : 0] 		   Address;
wire 	   [`ADDRESSSIZE-1 : 0] 		   Data_Bus;
wire     [`ADDRESSSIZE-1 : 0]          Address_Com;
wire     [`ADDRESSSIZE-1 : 0]          Data_Bus_Com;
wire					                     Com_Bus_Gnt_proc;
wire                                   Data_in_Bus;
wire     [(`ASSOCIATIVITY)-1 : 0]      LRU_replacement_proc;
reg                                    CPU_stall;
reg					                     Com_Bus_Req_proc;
reg 	   [((`ASSOCIATIVITY)-1) : 0]	   Blk_accessed;
reg	   [`ADDRESSSIZE-1 : 0] 		   Data_Bus_reg;
reg      [`ADDRESSSIZE-1 : 0]          Data_Bus_Com_reg;
reg 	   [`ADDRESSSIZE-1 : 0] 		   Address_Com_reg;
reg                                    Data_in_Bus_reg;

// Internal variables for wrapping Index/Tag/Block_offset details - each for processor & Snoop
// For Processor
reg 	   [`INDEX_SIZE-1 : 0] 		      Index_proc;
reg 	   [`TAG_SIZE-1 : 0] 		      Tag_proc;
reg 	   [`BLK_OFFSET_SIZE-1 : 0]	   Blk_offset_proc;

// Internal variables for Various computations - Processor & snoop separately 
// For Processor
reg                                    Block_Hit_proc;
reg                                    blk_free_proc;
reg   [(`ASSOCIATIVITY-1):0]           Free_blk_proc;
reg   [(`ASSOCIATIVITY-1):0]           Blk_access_proc;
reg 	[((1<<(`ASSOCIATIVITY))-1) : 0]	Access_blk_proc;
/***************************************************************************************************************/


/************************************** Parameter Block ********************************************************/
//Parameter indicating Block which has been accessed
// One hot encoding used to enable parallel computation of four blocks in each sets (ParameteriZed for 4 way associative cache)
parameter ACCESS_BLK1	= 4'b1110;
parameter ACCESS_BLK2	= 4'b1101;
parameter ACCESS_BLK3	= 4'b1011;
parameter ACCESS_BLK4	= 4'b0111;
parameter ACCESS_MISS	= 4'b1111;

parameter INVALID       = 1'b0;
parameter VALID         = 1'b1;
//Parameter for Block Number
parameter BLK1          = 2'b00;
parameter BLK2          = 2'b01;
parameter BLK3          = 2'b10;
parameter BLK4          = 2'b11;
/***************************************************************************************************************/

/***********************************Internal Cache Structure***************************************************/
//Cache & LRU memory structure
reg 	[`CACHE_DATA_SIZE-1 : 0]        Cache_var	         [0 : `CACHE_DEPTH-1];
reg 	[`CACHE_TAG_VALID_SIZE-1 : 0]    Cache_proc_contr   [0 : `CACHE_DEPTH-1];
/***************************************************************************************************************/

integer i;

initial 
begin
	for (i = 0; i < `CACHE_DEPTH-1;  i = i+1)
	begin
		Cache_var [i] 			= {`CACHE_DATA_SIZE{1'b0}};
		Cache_proc_contr [i]	= {`CACHE_TAG_VALID_SIZE{1'b0}};
	end
end
reg [31:0] zeros = 32'h00000000;



/***************************************Driving of Bus**********************************************************/
// Driving of Data Bus
assign Data_Bus = (PrRd) ? Data_Bus_reg : 32'hZ;
/***************************************************************************************************************/

/***************************************Driving of Common Bus **************************************************/
// Driving of Common Busses when Grant is given by arbiter - Reg values are updated as per the request granted (i.e. processor or snoop)
assign Data_Bus_Com        = Data_Bus_Com_reg  ;
assign Address_Com         = Address_Com_reg   ;


assign Data_in_Bus         = Data_in_Bus_reg   ;
 
/***************************************************************************************************************/

/***************************************************************************************************************/
/*Index, Blk, Tag extraction from the address*/
// Processor request wrapping
always @ *
begin
if (PrRd)
	begin
		Index_proc 		   = Address [`INDEX_MSB      : `INDEX_LSB];
		Tag_proc 		   = Address [`TAG_MSB        : `TAG_LSB];
		Blk_offset_proc 	= Address [`BLK_OFFSET_MSB : `BLK_OFFSET_LSB];
	end
	else
	begin
		Index_proc 		= zeros[`INDEX_MSB : `INDEX_LSB];
        Tag_proc 		= zeros[`TAG_MSB : `TAG_LSB];
        Blk_offset_proc 	= zeros[`BLK_OFFSET_MSB : `BLK_OFFSET_LSB];
	end
end

/***************************************************************************************************************/


/**************** Code to check if the requested block is present in Cache - processor request******************/
/*Compare the tags to see if there is a match in any of the cache blocks in the set - designed for 4 way associativity*/
always @ *
begin
if(PrRd)
begin
    if((Cache_proc_contr[{Index_proc,BLK1}][`CACHE_VALID_BIT_MSB : `CACHE_VALID_BIT_LSB] != INVALID) && (Cache_proc_contr[{Index_proc,BLK1}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_proc))
    begin
	      Access_blk_proc[0]   <= 1'b0;
    end
    else
    begin 
         Access_blk_proc[0]   <= 1'b1;
    end
    if((Cache_proc_contr[{Index_proc,BLK2}][`CACHE_VALID_BIT_MSB : `CACHE_VALID_BIT_LSB] != INVALID) && (Cache_proc_contr[{Index_proc,BLK2}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_proc))
    begin
	      Access_blk_proc[1]   <= 1'b0;
    end
    else
    begin
	      Access_blk_proc[1]   <= 1'b1;
end
    if((Cache_proc_contr[{Index_proc,BLK3}][`CACHE_VALID_BIT_MSB : `CACHE_VALID_BIT_LSB] != INVALID) && (Cache_proc_contr[{Index_proc,BLK3}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_proc))
    begin
   	   Access_blk_proc[2]   <= 1'b0;
    end
    else
    begin
	      Access_blk_proc[2]   <= 1'b1;
 end
    if((Cache_proc_contr[{Index_proc,BLK4}][`CACHE_VALID_BIT_MSB : `CACHE_VALID_BIT_LSB] != INVALID) && (Cache_proc_contr[{Index_proc,BLK4}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_proc))
    begin
	      Access_blk_proc[3]   <= 1'b0;
    end
    else
    begin
         Access_blk_proc[3]   <= 1'b1;
   end
end
else
begin
	Access_blk_proc <= 4'b1111;
end
end
/***************************************************************************************************************/



/***************************************************************************************************************/
// Block hit computation based on Access_blk value - processor request
always @ *
begin
if(PrRd)
begin
	if(Access_blk_proc == 4'b1110 || Access_blk_proc == 4'b1101 || Access_blk_proc == 4'b1011 || Access_blk_proc == 4'b0111)
	begin
		Block_Hit_proc <= 1'b1;	
	end
	else
	begin
		Block_Hit_proc <= 1'b0;
	end
end
else
begin
	Block_Hit_proc <= 1'b0;
end
end

/***************************************************************************************************************/


/***************************************************************************************************************/
/* If requested data block is absent in the cache, see if a block is free in the set to bring it from stub L2 cache*/
/* Free block is checked prior to using replacement policy to replace a block in the set (pseudo-LRU)*/
always @ *
begin
if (Block_Hit_proc == 0)
begin
    if      (Cache_proc_contr[{Index_proc,BLK1}][`CACHE_VALID_BIT_MSB :`CACHE_VALID_BIT_LSB] == INVALID)
    begin
        Free_blk_proc    = BLK1;	
        blk_free_proc    = 1'b1;

    end
    else if (Cache_proc_contr[{Index_proc,BLK2}][`CACHE_VALID_BIT_MSB :`CACHE_VALID_BIT_LSB] == INVALID)	
    begin
        Free_blk_proc    = BLK2;	
        blk_free_proc    = 1'b1;
    end
    else if (Cache_proc_contr[{Index_proc,BLK3}][`CACHE_VALID_BIT_MSB :`CACHE_VALID_BIT_LSB] == INVALID)	
    begin
        Free_blk_proc    = BLK3;	
        blk_free_proc    = 1'b1;

    end
    else if (Cache_proc_contr[{Index_proc,BLK4}][`CACHE_VALID_BIT_MSB :`CACHE_VALID_BIT_LSB] == INVALID)	
    begin
        Free_blk_proc    = BLK4;	
        blk_free_proc    = 1'b1;
    end
	else
	begin
		blk_free_proc = 1'b0;
		Free_blk_proc = BLK1;
	end
end
else if(Block_Hit_proc == 1)
begin
	blk_free_proc = 1'b0;
		Free_blk_proc = BLK1;	
end
end
/***************************************************************************************************************/



/***************************************************************************************************************/
// This always block determines which block in the set is to be accessed - Block which is hit or which is free or which is to be replaced
//always @ (Index_proc or Tag_proc or Blk_offset_proc or PrRd or Block_Hit_proc or blk_free_proc or Access_blk_proc)
always @ *
begin
    if (Block_Hit_proc)
    begin
	    case (Access_blk_proc)
            ACCESS_BLK1:
                Blk_access_proc <=   BLK1; 
            ACCESS_BLK2:
                Blk_access_proc <=   BLK2;
            ACCESS_BLK3:
                Blk_access_proc <=   BLK3;
            ACCESS_BLK4:
                Blk_access_proc <=   BLK4;
            default:
                Blk_access_proc <=   BLK1;
        endcase
    end
    else if (blk_free_proc)
        	Blk_access_proc <= Free_blk_proc;
    else
        	Blk_access_proc <= LRU_replacement_proc;
end
/***************************************************************************************************************/


/***************************************************************************************************************/
// Code for all access computations 
// Processor requests are given higher priority, however, arbiter should handle requests raising on same instances based on coherence rules 
// (among processor & snoop requests and among various requests from multi-processors
always @ (posedge clk)
begin

Data_Bus_reg            = 32'bZ;
Data_Bus_Com_reg        = 32'bZ;   
Address_Com_reg         = 32'bZ;
Data_in_Bus_reg         = 1'bZ;
Com_Bus_Req_proc	= 1'b0;
//CPU_stall               = 1'b1;


	/*Processor read & cache hit*/
	// Once the Block is available in Cache, it is provided to Processor
	if(PrRd && Block_Hit_proc)
	begin    
		Data_Bus_reg      = Cache_var [{Index_proc,Blk_access_proc}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
		CPU_stall         = 1'b0;
		Blk_accessed 	   = Blk_access_proc;
		Com_Bus_Req_proc	= 1'b0;			// Bus request is released
	end
	/*Processor read & cache miss*/
	// Cache is missed and its requested from lower memories
	else if (PrRd && !Block_Hit_proc)
	begin
				CPU_stall = 1'b1;
		// Free Block is available for requested block and it is stored in cache, which is then sensed as Block_hit
		if (blk_free_proc)
		begin
			Com_Bus_Req_proc 	= 1'b1;
			if(Com_Bus_Gnt_proc == 1'b1)
			begin
				Address_Com_reg 	= {Tag_proc, Index_proc, 2'b00};
				if (Data_in_Bus)	// Signal from Other shared cache block or lower level L2 memory
				begin
					Cache_var[{Index_proc,Blk_access_proc}][`CACHE_DATA_MSB:`CACHE_DATA_LSB] 	               = Data_Bus_Com;
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_VALID_BIT_MSB:`CACHE_VALID_BIT_LSB] = VALID;
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_TAG_MSB:`CACHE_TAG_LSB] 	         = Tag_proc;
					//Blk_accessed 									= Blk_access_proc;	// Block accessed is assigned
					//Com_Bus_Req_proc								= 1'b0;			// Bus request is released
				end
			end
		end
		// no free block is available - some block to be replaced - Once replaced the block is taken as free - then data is requested from L2 and stored in that block, which will then become hit
		else if (!blk_free_proc)
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_VALID_BIT_MSB:`CACHE_VALID_BIT_LSB] = INVALID; 
	end
end
/***************************************************************************************************************/


endmodule
