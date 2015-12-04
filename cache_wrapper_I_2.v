/* Wrapper for Cache_Controller and Cache_block to make them as a single unit */
`include "cache_block_I_2.v" 
`include "cache_controller_I_2.v"
`include "cache_def_I_2.v"

module cache_wrapper_I_2 (clk,
						PrRd,
                        Address,
                        Data_Bus,
                        CPU_stall,
                        Com_Bus_Req_proc,
                        Com_Bus_Gnt_proc,
                        Address_Com,
                        Data_Bus_Com,
                        Data_in_Bus
                        );
input 							clk;
input								         PrRd;
input 	[`ADDRESSSIZE-1 : 0] 		Address;
inout 	[`ADDRESSSIZE-1 : 0] 		Data_Bus;
output								      CPU_stall;
output								      Com_Bus_Req_proc;
input								         Com_Bus_Gnt_proc;
inout 	[`ADDRESSSIZE-1 : 0] 		Address_Com;
inout 	[`ADDRESSSIZE-1 : 0] 		Data_Bus_Com;
inout                               Data_in_Bus;

wire 	[((`ASSOCIATIVITY)-1) : 0]	   LRU_replacement_proc;		
wire 	[((`ASSOCIATIVITY)-1) : 0]	   Blk_accessed;

cache_block_I_2	cb (     clk,
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

            
cache_controller_I_2 cc ( 	PrRd, 
						      Address,
						      LRU_replacement_proc,
                        Blk_accessed, 
						      Address_Com, 
                        Data_Bus_Com
						      );
				
endmodule
