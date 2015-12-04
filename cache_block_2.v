/***************************************************************************************************************************************/
/***************************************Verilog Code to Implement Cache design**********************************************************/

// This is a generic design and can be multi-instaniated with few changes to implement a full multi-chip cache coherence system

// Designed for 4-way set associativite cache; SiZe details can be varied in cache_def.v file

// For full working system, the environment needs processor for each cache, separate multiple cache and common bus systems for Instruction & Data, common Arbiter, common L2 Data & instruction memory, All_invalidation checking block & other lower level memories

// This module contains the Cache Tag, MESI, data and the logic for cache access with both Processor and Snoop requests
// The module communicates with its processor, its cache_controller, All_invalidation checking block, Common Arbiter and Common Bus (which is shared among all caches & L2 level - separate for both Data & instruction)

`include "cache_def_2.v"

/* Cache block Module declaration*/
module cache_block_2( clk,
					PrWr,
                    PrRd,
                    Address,
                    Data_Bus,

                    CPU_stall,                    

                    Com_Bus_Req_proc,
		    Com_Bus_Gnt_proc,
		    Com_Bus_Req_snoop,
		    Com_Bus_Gnt_snoop,

		    LRU_replacement_proc,

                    Current_MESI_state_proc,
                    Current_MESI_state_snoop,

                    Blk_accessed,

                    Updated_MESI_state_proc, 
                    Updated_MESI_state_snoop, 

                    Address_Com,
                    Data_Bus_Com,

                    BusRd,
                    BusRdX,

                    Mem_wr,
                    Mem_oprn_abort,
                    Data_in_Bus,
                    Mem_write_done,
		    Invalidation_done,
                    Invalidate,
		    All_Invalidation_done,
		    Shared);

// port declaration to / from CPU
input 								clk;
input 	                                PrWr;
input                                   PrRd;
input 	[`ADDRESSSIZE-1 : 0] 		Address;
inout 	[`ADDRESSSIZE-1 : 0] 		Data_Bus;
output                                  CPU_stall;

// Signal to Controller for computing replacement - current block which is accessed
output 	[((`ASSOCIATIVITY)-1) : 0]	Blk_accessed;

// Bus Request and Grant signals for processor & snoop requests
output					Com_Bus_Req_proc;
input					Com_Bus_Gnt_proc;
output					Com_Bus_Req_snoop;
input					Com_Bus_Gnt_snoop;

// ports to or from Cache_Controller for LRU and MESI
input 	[((`ASSOCIATIVITY)-1) : 0]	LRU_replacement_proc;		
output	[`MESI_SIZE-1 :	0]		Current_MESI_state_proc;
input	[`MESI_SIZE-1 : 0]		Updated_MESI_state_proc;
output	[`MESI_SIZE-1 :	0]		Current_MESI_state_snoop;
input	[`MESI_SIZE-1 : 0]		Updated_MESI_state_snoop;

// Ports to or from Common Data Bus
// Inout signals
inout 	[`ADDRESSSIZE-1 : 0] 		Address_Com;
inout 	[`ADDRESSSIZE-1 : 0] 		Data_Bus_Com;
inout                                   BusRd;
inout                                   BusRdX;
inout                                   Invalidate;
inout                                   Data_in_Bus;

// Signals to and from L2 memory	
output                                  Mem_wr;
output                                  Mem_oprn_abort;
input                                   Mem_write_done;

// Signal for Invalidation process - And of all Invalidation_done (only which shares the block) gives All_invalidation_done
output                                  Invalidation_done;
input					All_Invalidation_done;

// Signal to indicate if the snoop block is Shared state or not
output					Shared;

//Net or Reg declaration
wire 	                                PrRd;
wire                                    PrWr;
wire 	[`ADDRESSSIZE-1 : 0] 		Address;
wire 	[`ADDRESSSIZE-1 : 0] 		Data_Bus;
wire    [`ADDRESSSIZE-1 : 0]            Address_Com;
wire    [`ADDRESSSIZE-1 : 0]            Data_Bus_Com;
wire					Com_Bus_Gnt_proc;
wire					Com_Bus_Gnt_snoop;
wire                                    BusRd;
wire                                    BusRdX;
wire                                    Mem_wr;
wire                                    Mem_oprn_abort;
wire                                    Data_in_Bus;
reg                                    Invalidation_done;
wire                                    Invalidate;
wire					All_Invalidation_done;
wire    [(`ASSOCIATIVITY)-1 : 0]        LRU_replacement_proc;
wire    [(`MESI_SIZE)-1 : 0]            Updated_MESI_state_proc;
wire    [(`MESI_SIZE)-1 : 0]	        Updated_MESI_state_snoop;
reg                                     CPU_stall;
reg					Com_Bus_Req_proc;
reg					Com_Bus_Req_snoop;
reg 	[((`ASSOCIATIVITY)-1) : 0]	Blk_accessed;
reg     [(`MESI_SIZE)-1 : 0]            Current_MESI_state_proc;
reg     [(`MESI_SIZE)-1 : 0]            Current_MESI_state_snoop;
reg	[`ADDRESSSIZE-1 : 0] 		Data_Bus_reg;
reg     [`ADDRESSSIZE-1 : 0]            Data_Bus_Com_reg;
reg 	[`ADDRESSSIZE-1 : 0] 		Address_Com_reg;
reg                                     BusRd_reg;
reg                                     BusRdX_reg;
reg                                     Mem_wr_reg;
reg                                     Mem_oprn_abort_reg;
reg                                     Data_in_Bus_reg;
//reg                                     Invalidation_done_reg;
reg                                     Invalidate_reg;
reg					Shared;

// Internal variables for wrapping Index/Tag/Block_offset details - each for processor & Snoop
// For Processor
reg 	[`INDEX_SIZE-1 : 0] 		Index_proc;
reg 	[`TAG_SIZE-1 : 0] 		Tag_proc;
reg 	[`BLK_OFFSET_SIZE-1 : 0]	Blk_offset_proc;
// For Snoop
reg 	[`INDEX_SIZE-1 : 0] 		Index_snoop;
reg 	[`TAG_SIZE-1 : 0] 		Tag_snoop;
reg 	[`BLK_OFFSET_SIZE-1 : 0]	Blk_offset_snoop;

// Internal variables for Various computations - Processor & snoop separately 
// For Processor
reg                                     Block_Hit_proc;
reg                                     blk_free_proc;
reg     [(`ASSOCIATIVITY-1):0]          Free_blk_proc;
reg     [(`ASSOCIATIVITY-1):0]          Blk_access_proc;
reg 	[((1<<(`ASSOCIATIVITY))-1) : 0]	Access_blk_proc;
// For Snoop
reg                                     Block_Hit_snoop;
reg                                     blk_free_snoop;
reg     [(`ASSOCIATIVITY-1):0]          Free_blk_snoop;
reg     [(`ASSOCIATIVITY-1):0]          Blk_access_snoop;
reg 	[((1<<(`ASSOCIATIVITY))-1) : 0]	Access_blk_snoop;
/***************************************************************************************************************/



/************************************** Parameter Block ********************************************************/
//Parameter indicating Block which has been accessed
// One hot encoding used to enable parallel computation of four blocks in each sets (ParameteriZed for 4 way associative cache)
parameter ACCESS_BLK1	= 4'b1110;
parameter ACCESS_BLK2	= 4'b1101;
parameter ACCESS_BLK3	= 4'b1011;
parameter ACCESS_BLK4	= 4'b0111;
parameter ACCESS_MISS	= 4'b1111;

//Parameter for MESI protocol
parameter INVALID 	= 2'b00;
parameter SHARED	= 2'b01;
parameter EXCLUSIVE	= 2'b10;
parameter MODIFIED 	= 2'b11;

//Parameter for Block Number
parameter BLK1          = 2'b00;
parameter BLK2          = 2'b01;
parameter BLK3          = 2'b10;
parameter BLK4          = 2'b11;
/***************************************************************************************************************/



/***********************************Internal Cache Structure***************************************************/
//Cache & LRU memory structure
reg 	[`CACHE_DATA_SIZE-1 : 0]        Cache_var	    	[0 : `CACHE_DEPTH-1];
reg 	[`CACHE_TAG_MESI_SIZE-1 : 0]    Cache_proc_contr    [0 : `CACHE_DEPTH-1];
/***************************************************************************************************************/

integer i;

initial 
begin
	for (i = 0; i < `CACHE_DEPTH-1; i = i+1)
	begin
		Cache_var [i] 			= {`CACHE_DATA_SIZE{1'b0}};
		Cache_proc_contr [i]	= {`CACHE_TAG_MESI_SIZE{1'b0}};
	end
end

reg [31:0] zeros = 32'h00000000;


	

/***************************************Driving of Bus**********************************************************/
// Driving of Data Bus
assign Data_Bus = (PrRd) ? Data_Bus_reg : 32'hZ;
/***************************************************************************************************************/



/***************************************Driving of Common Bus **************************************************/
// Driving of Common Busses when Grant is given by arbiter - Reg values are updated as per the request granted (i.e. processor or snoop)
assign Data_Bus_Com        = Data_Bus_Com_reg;
assign Address_Com         = Address_Com_reg;
assign BusRd               = BusRd_reg;
assign BusRdX              = BusRdX_reg;
assign Mem_wr              = Mem_wr_reg;
assign Mem_oprn_abort      = Mem_oprn_abort_reg;
assign Data_in_Bus         = Data_in_Bus_reg;
//assign Invalidation_done   ? Invalidation_done_reg : 1'bZ;
assign Invalidate          = Invalidate_reg;
/***************************************************************************************************************/



/***************************************************************************************************************/
/*Index, Blk, Tag extraction from the address*/
// Processor request wrapping
always @ *
begin
    if(PrRd || PrWr)
    begin
        Index_proc 		= Address[`INDEX_MSB : `INDEX_LSB];
        Tag_proc 		= Address[`TAG_MSB : `TAG_LSB];
        Blk_offset_proc 	= Address[`BLK_OFFSET_MSB : `BLK_OFFSET_LSB];
    end
	else
	begin
		Index_proc 		= zeros[`INDEX_MSB : `INDEX_LSB];
        Tag_proc 		= zeros[`TAG_MSB : `TAG_LSB];
        Blk_offset_proc 	= zeros[`BLK_OFFSET_MSB : `BLK_OFFSET_LSB];
	end
end
// Snooping request wrapping
always @ *
begin
    if ((BusRd || BusRdX || Invalidate)) //Snooping Bus request
    begin
        Index_snoop 		= Address_Com[`INDEX_MSB : `INDEX_LSB];
        Tag_snoop 		= Address_Com[`TAG_MSB : `TAG_LSB];
        Blk_offset_snoop 	= Address_Com[`BLK_OFFSET_MSB : `BLK_OFFSET_LSB];
    end
	else
	begin
		Index_snoop 		= zeros[`INDEX_MSB : `INDEX_LSB];
        Tag_snoop 		= zeros[`TAG_MSB : `TAG_LSB];
        Blk_offset_snoop 	= zeros[`BLK_OFFSET_MSB : `BLK_OFFSET_LSB];
	end
end
/***************************************************************************************************************/



/**************** Code to check if the requested block is present in Cache - processor request******************/
/*Compare the tags to see if there is a match in any of the cache blocks in the set - designed for 4 way associativity*/
always @ *
begin
if(PrRd || PrWr)
begin
    if((Cache_proc_contr[{Index_proc,BLK1}][`CACHE_MESI_MSB : `CACHE_MESI_LSB] != INVALID) && (Cache_proc_contr[{Index_proc,BLK1}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_proc))
    begin
	Access_blk_proc[0]   <= 1'b1;
    end
    else
    begin 
        Access_blk_proc[0]   <= 1'b0;
    end
    if((Cache_proc_contr[{Index_proc,BLK2}][`CACHE_MESI_MSB : `CACHE_MESI_LSB] != INVALID) && (Cache_proc_contr[{Index_proc,BLK2}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_proc))
    begin
	Access_blk_proc[1]   <= 1'b1;
    end
    else
    begin
	Access_blk_proc[1]   <= 1'b0;
end
    if((Cache_proc_contr[{Index_proc,BLK3}][`CACHE_MESI_MSB : `CACHE_MESI_LSB] != INVALID) && (Cache_proc_contr[{Index_proc,BLK3}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_proc))
    begin
	Access_blk_proc[2]   <= 1'b1;
    end
    else
    begin
	Access_blk_proc[2]   <= 1'b0;
 end
    if((Cache_proc_contr[{Index_proc,BLK4}][`CACHE_MESI_MSB : `CACHE_MESI_LSB] != INVALID) && (Cache_proc_contr[{Index_proc,BLK4}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_proc))
    begin
	Access_blk_proc[3]   <= 1'b1;
    end
    else
    begin
        Access_blk_proc[3]   <= 1'b0;
   end
end
else
begin
	Access_blk_proc <= 4'b0000;
end
end
/***************************************************************************************************************/



/***************************************************************************************************************/
// Block hit computation based on Access_blk value - processor request
always @ *
begin
if(PrRd || PrWr)
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
    if      (Cache_proc_contr[{Index_proc,BLK1}][`CACHE_MESI_MSB :`CACHE_MESI_LSB] == INVALID)
    begin
        Free_blk_proc    = BLK1;	
        blk_free_proc    = 1'b1;

    end
    else if (Cache_proc_contr[{Index_proc,BLK2}][`CACHE_MESI_MSB :`CACHE_MESI_LSB] == INVALID)	
    begin
        Free_blk_proc    = BLK2;	
        blk_free_proc    = 1'b1;
    end
    else if (Cache_proc_contr[{Index_proc,BLK3}][`CACHE_MESI_MSB :`CACHE_MESI_LSB] == INVALID)	
    begin
        Free_blk_proc    = BLK3;	
        blk_free_proc    = 1'b1;

    end
    else if (Cache_proc_contr[{Index_proc,BLK4}][`CACHE_MESI_MSB :`CACHE_MESI_LSB] == INVALID)	
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
always @ (Index_proc or Tag_proc or Blk_offset_proc or PrRd or PrWr or Block_Hit_proc or blk_free_proc or Access_blk_proc or Free_blk_proc or LRU_replacement_proc)
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



/********************* Code to check if the requested block is present in Cache - Snoop request******************************/
// Compare the tags to see if there is a match in any of the cache blocks in the set - Snoop request
//always @ (Index_snoop or Tag_snoop or Blk_offset_snoop or BusRd or BusRdX or Invalidate)
always @ *
begin
if ((BusRd || BusRdX || Invalidate))
begin
    if((Cache_proc_contr[{Index_snoop,BLK1}][`CACHE_MESI_MSB : `CACHE_MESI_LSB] != INVALID) && (Cache_proc_contr [{Index_snoop,BLK1}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_snoop))
    begin
	Access_blk_snoop[0]   <= 1'b0;
    end
    else
    begin 
        Access_blk_snoop[0]   <= 1'b1;
    end
    if((Cache_proc_contr[{Index_snoop,BLK2}][`CACHE_MESI_MSB : `CACHE_MESI_LSB] != INVALID) && (Cache_proc_contr[{Index_snoop,BLK2}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_snoop))
    begin
	Access_blk_snoop[1]   <= 1'b0;
    end
    else
    begin
	Access_blk_snoop[1]   <= 1'b1;
    end
    if((Cache_proc_contr[{Index_snoop,BLK3}][`CACHE_MESI_MSB : `CACHE_MESI_LSB] != INVALID) && (Cache_proc_contr[{Index_snoop,BLK3}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_snoop))
    begin
	Access_blk_snoop[2]   <= 1'b0;
    end
    else
    begin
	Access_blk_snoop[2]   <= 1'b1;
    end
    if((Cache_proc_contr[{Index_snoop,BLK4}][`CACHE_MESI_MSB : `CACHE_MESI_LSB] != INVALID) && (Cache_proc_contr[{Index_snoop,BLK4}][`CACHE_TAG_MSB : `CACHE_TAG_LSB] == Tag_snoop))
    begin
	Access_blk_snoop[3]   <= 1'b0;
    end
    else
    begin
        Access_blk_snoop[3]   <= 1'b1;
    end
end
else
begin
	Access_blk_snoop <= 4'b1111;
end
end
/***************************************************************************************************************/




/***************************************************************************************************************/
// Block hit computation based on Access_blk value - snoop request
always @ *
begin
if((BusRd || BusRdX || Invalidate))
begin
	if(Access_blk_snoop == 4'b1110 || Access_blk_snoop == 4'b1101 || Access_blk_snoop == 4'b1011 || Access_blk_snoop == 4'b0111)
	begin
		Block_Hit_snoop <= 1'b1;	
	end
	else
	begin
		Block_Hit_snoop <= 1'b0;
	end
end
else
begin
	Block_Hit_snoop <= 1'b0;
end
end
/***************************************************************************************************************/



/***************************************************************************************************************/
/*If a cache hit is encountered, this block determines which block in the set is to be accessed*/
// No Free block or Replacement computation for Snooping
always @ (Index_snoop or Tag_snoop or Blk_offset_snoop or BusRd or BusRdX or Invalidate or Block_Hit_snoop or Access_blk_snoop)
begin
    if (Block_Hit_snoop)
        case (Access_blk_snoop)
            ACCESS_BLK1:
                Blk_access_snoop <=   BLK1; 
            ACCESS_BLK2:
                Blk_access_snoop <=   BLK2;
            ACCESS_BLK3:
                Blk_access_snoop <=   BLK3;
            ACCESS_BLK4:
                Blk_access_snoop <=   BLK4;
            default:
                Blk_access_snoop <=   BLK1;
        endcase
end
/***************************************************************************************************************/



/***************************************************************************************************************/
// Propogation of Current MESI state to controller for Next MESI state computation - Processor request
always @ (Index_proc or Tag_proc or Blk_offset_proc or PrRd or PrWr or Block_Hit_proc)
begin
    if(Block_Hit_proc == 1)
    begin
        Current_MESI_state_proc  = Cache_proc_contr [{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB];    
    end
    else
    begin
        Current_MESI_state_proc  = INVALID;      
    end
end
// Propogation of Current MESI state to controller for Next MESI state computation - Snoop request
always @ (Index_snoop or Tag_snoop or Blk_offset_snoop or BusRd or BusRdX or Invalidate or Block_Hit_snoop)
begin
    if(Block_Hit_snoop)
    begin
        Current_MESI_state_snoop  <= Cache_proc_contr [{Index_snoop,Blk_access_snoop}][`CACHE_MESI_MSB:`CACHE_MESI_LSB];
    end
    else
    begin
        Current_MESI_state_snoop  <= INVALID;      
    end
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
BusRd_reg               = 1'bZ;
BusRdX_reg              = 1'bZ;
Mem_wr_reg              = 1'bZ;
Mem_oprn_abort_reg      = 1'bZ;
Data_in_Bus_reg         = 1'bZ;
Invalidation_done = 1'b0;
Invalidate_reg          = 1'bZ;    
Com_Bus_Req_proc	= 1'b0;
//CPU_stall               = 1'b1;
Com_Bus_Req_snoop	= 1'b0;
Shared 			= 1'b0;

	/*Processor read & cache hit*/
	// Once the Block is available in Cache, it is provided to Processor
	if(PrRd && Block_Hit_proc)
	begin    
		Data_Bus_reg    = Cache_var [{Index_proc,Blk_access_proc}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
		CPU_stall       = 1'b0;
		Blk_accessed 	= Blk_access_proc;
		Com_Bus_Req_proc = 1'b0;
	end
	/*Processor read & cache miss*/
	// Cache is missed and its requested from lower memories
	else if (PrRd && !Block_Hit_proc)
	begin
		Com_Bus_Req_proc 	= 1'b1;
		CPU_stall = 1'b1;
		// Free Block is available for requested block and it is stored in cache, which is then sensed as Block_hit
		if (blk_free_proc)
		begin		
			if(Com_Bus_Gnt_proc == 1'b1)
			begin
				BusRd_reg       	= 1'b1;         
				Address_Com_reg 	= {Tag_proc, Index_proc, 2'b00};
				if (Data_in_Bus)	// Signal from Other shared cache block or lower level L2 memory
				begin
					Cache_var[{Index_proc,Blk_access_proc}][`CACHE_DATA_MSB:`CACHE_DATA_LSB] 	= Data_Bus_Com;
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = Updated_MESI_state_proc;
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_TAG_MSB:`CACHE_TAG_LSB] 	= Tag_proc;
					//Blk_accessed 									= Blk_access_proc;	// Block accessed is assigned
			//		Com_Bus_Req_proc								= 1'b0;			// Bus request is released
				end
			end
		end
		// no free block is available - some block to be replaced - Once replaced the block is taken as free - then data is requested from L2 and stored in that block, which will then become hit
		else if (!blk_free_proc)
		begin
			case (Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB])
				// Shared or exclusive - it is invalidated
				SHARED:
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = INVALID; 
				EXCLUSIVE:
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = INVALID;
				// If modified then it is written to memory first, then the block is invalidated
				MODIFIED:
				begin
					//Com_Bus_Req_proc 	= 1'b1;
					if(Com_Bus_Gnt_proc == 1'b1)
					begin
						Address_Com_reg = {Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_TAG_MSB:`CACHE_TAG_LSB],Index_proc,2'b00};
						Mem_wr_reg      = 1'b1;		// Informing lower level memory to perform a write operation
						Data_Bus_Com_reg = Cache_var[{Index_proc,Blk_access_proc}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
						if(Mem_write_done)		// Once the memory write is done
						begin
							Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = INVALID;	// Invalidated
				//			Com_Bus_Req_proc								= 1'b0;
						end
					end
				end
				default:
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = INVALID;
			endcase
		end
	end
    	// Processor Write Request Code
	if (PrWr)
	begin
		Com_Bus_Req_proc = 1'b1;
		CPU_stall = 1'b1;
		// If Block is hit
		if(Block_Hit_proc == 1)
		begin
			case (Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB])
				// If Modified then no change in State, Just data updated
				MODIFIED:
				begin
					Cache_var[{Index_proc,Blk_access_proc}][`CACHE_DATA_MSB:`CACHE_DATA_LSB] 	= Data_Bus;
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]	= Updated_MESI_state_proc;
					CPU_stall 									= 1'b0;
					Blk_accessed 									= Blk_access_proc;
					Com_Bus_Req_proc 								= 1'b0;
				end
				// If Shared, Other shared blocks are invalidated then data is written
				SHARED:
				begin   
					if(Com_Bus_Gnt_proc == 1'b1)
					begin
						Invalidate_reg = 1'b1;
						Address_Com_reg     = {Tag_proc,Index_proc,2'b00}; 
						if(All_Invalidation_done)
						begin
							Cache_var[{Index_proc,Blk_access_proc}][`CACHE_DATA_MSB:`CACHE_DATA_LSB] 	= Data_Bus;
							Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = Updated_MESI_state_proc;
							CPU_stall 									= 1'b0;  
							Blk_accessed 									= Blk_access_proc;
							Com_Bus_Req_proc 								= 1'b0;
						end
					end
				end
				// If exclusive, directly data is written and MESI state is updated (to modified)
				EXCLUSIVE:
				begin
					Cache_var[{Index_proc,Blk_access_proc}][`CACHE_DATA_MSB:`CACHE_DATA_LSB] 	= Data_Bus;
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = Updated_MESI_state_proc;
					CPU_stall 									= 1'b0;                            
					Blk_accessed 									= Blk_access_proc;
					Com_Bus_Req_proc 								= 1'b0;
				end
			endcase
		end
	
	// If cache block is not in Cache - to be requested from Lower memory
	else if (Block_Hit_proc == 0)
	begin
	CPU_stall = 1'b1;
		// If free block available
		if(blk_free_proc == 1)
		begin
			//Com_Bus_Req_proc 	= 1'b1;
			if(Com_Bus_Gnt_proc == 1'b1)
			begin
				BusRdX_reg          = 1'b1;			// Bus Read with Intent to modify is raised
				Address_Com_reg     = {Tag_proc,Index_proc,2'b00}; 
				if(Data_in_Bus)					// Data available in bus - provided by lower level memory or some other cache
				begin
					Cache_var[{Index_proc,Blk_access_proc}][`CACHE_DATA_MSB:`CACHE_DATA_LSB] 	= Data_Bus_Com;
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = Updated_MESI_state_proc;
					Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_TAG_MSB:`CACHE_TAG_LSB] 	= Tag_proc;
					//Blk_accessed 									= Blk_access_proc;		
					//Com_Bus_Req_proc								= 1'b0;
				end
			end
		end
		// If free block is not available - replacement to be done 
		else if (blk_free_proc == 0)
		begin
			case (Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB])
			// If Shared or Exclusive, then invalidated
			SHARED:
				Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = INVALID; 
			EXCLUSIVE:
				Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = INVALID;
			// If Modified, the data is upadted in to lower level memory and then the block is invalidated
			MODIFIED:
			begin
				//Com_Bus_Req_proc 	= 1'b1;
				if(Com_Bus_Gnt_proc == 1'b1)
				begin
					Address_Com_reg     = {Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_TAG_MSB:`CACHE_TAG_LSB],Index_proc,2'b00};
					Mem_wr_reg          = 1'b1;			// Memory write signal to lower level memory
					Data_Bus_Com_reg    = Cache_var[{Index_proc,Blk_access_proc}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
					if(Mem_write_done)				// Memory write is asserted by memory to cache
					begin
						Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = INVALID;
						//Com_Bus_Req_proc								= 1'b0;
					end
				end
			end
			default:
				Cache_proc_contr[{Index_proc,Blk_access_proc}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] = INVALID;
			endcase
		end
	end 
	end
	// Code for Snoop functionalities
	// Snoop based actions are taken only if the requested block is in Cache 
	if(Block_Hit_snoop)
	begin
		if (Invalidate && Com_Bus_Gnt_proc != 1'b1)
		begin
			// Block is invalidated and Invalidation_done signal is asserted
			Shared = 1'b1;
			Cache_proc_contr[{Index_snoop,Blk_access_snoop}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] 	= INVALID;
			Invalidation_done 									= 1'b1;            
			//Com_Bus_Req_snoop 									= 1'b0;
		end
		// If Snoop request is with intention to write, Data
		// is provided by Memory only
		else if (BusRdX)
		begin
			case(Cache_proc_contr[{Index_snoop,Blk_access_snoop}][`CACHE_MESI_MSB:`CACHE_MESI_LSB])
				// If Shared, MESI is appropriately updated
				SHARED:
				begin
					Shared 											= 1'b1;
					Cache_proc_contr[{Index_snoop,Blk_access_snoop}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] 	= Updated_MESI_state_snoop;
				end
				// If Modified, lower level memory is first updated then data is provided to requested Cache by Memory with MESI approproately updated by Cache_controller
				MODIFIED:
				begin
					Com_Bus_Req_snoop = 1'b1;		
					if(Com_Bus_Gnt_snoop == 1'b1)
					begin
						Data_Bus_Com_reg	= Cache_var[{Index_snoop,Blk_access_snoop}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
						Mem_wr_reg 		= 1'b1;
						if(Mem_write_done)
						begin
							Cache_proc_contr[{Index_snoop,Blk_access_snoop}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] 	= Updated_MESI_state_snoop;
							Com_Bus_Req_snoop 									= 1'b0;
						end
					end
				end
				// If Exclusive, MESI is appropriately updated
				EXCLUSIVE:
				begin
					Cache_proc_contr[{Index_snoop,Blk_access_snoop}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] 	= Updated_MESI_state_snoop;
				end 
			endcase             
		end
		else if(BusRd)
		begin
		// If Request if for BusRd - Only for read operation	
			Com_Bus_Req_snoop = 1'b1;
			if (Data_in_Bus_reg)
				Com_Bus_Req_snoop = 1'b0;		
			if(Com_Bus_Gnt_snoop == 1'b1)
			begin
				Mem_oprn_abort_reg = 1'b1; // Memory is prevented from giving the data, as one of the cache has the data
				case(Cache_proc_contr[{Index_snoop,Blk_access_snoop}][`CACHE_MESI_MSB:`CACHE_MESI_LSB])
					// If Shared then data provided to requested Cache
					SHARED:
					begin
						Shared 			= 1'b1;
						Data_Bus_Com_reg    	= Cache_var[{Index_snoop,Blk_access_snoop}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
						Data_in_Bus_reg     	= 1'b1;               
						Com_Bus_Req_snoop 	= 1'b0;
					end
					// If in Modified, lower level memory is updated first then data is provided to requested cache alongwith updating its current MESI state
					MODIFIED:
					begin
						Data_Bus_Com_reg    	= Cache_var[{Index_snoop,Blk_access_snoop}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
						Mem_wr_reg 		= 1'b1;
							if(Mem_write_done)
							begin
								Shared	= 1'b1;
								Data_in_Bus_reg 									= 1'b1;           
								Cache_proc_contr[{Index_snoop,Blk_access_snoop}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] 	= Updated_MESI_state_snoop;
								Com_Bus_Req_snoop 									= 1'b0;
							end                      
					end
					// If Exclusive, then Data is provided to other cache with update in its MESI state
					EXCLUSIVE:
					begin
						Shared	= 1'b1;
						Data_Bus_Com_reg    									= Cache_var[{Index_snoop,Blk_access_snoop}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
						Data_in_Bus_reg     									= 1'b1;
						Cache_proc_contr[{Index_snoop,Blk_access_snoop}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] 	= Updated_MESI_state_snoop;
						Com_Bus_Req_snoop 									= 1'b0;
					end
				endcase
			end
			/*	// If snoop request is for invalidation
				else if (Invalidate)
				begin
					// Block is invalidated and Invalidation_done signal is asserted
					Shared = 1'b1;
					Cache_proc_contr[{Index_snoop,Blk_access_snoop}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] 	= INVALID;
					Invalidation_done_reg 									= 1'b1;            
					Com_Bus_Req_snoop 									= 1'b0;
				end*/
		end
			//Com_Bus_Req_snoop = 1'b0;
	end
end
/***************************************************************************************************************/


endmodule
