/* Wrapper for Cache_Controller and Cache_block to make them as a single unit */
`include "cache_block_0.v" 
`include "cache_controller_0.v"
`include "cache_def_0.v"

module cache_wrapper_0 (clk,
                        PrWr,
                        PrRd,
                        Address,
                        Data_Bus,
                        CPU_stall,
                        Com_Bus_Req_proc,
                        Com_Bus_Gnt_proc,
                        Com_Bus_Req_snoop,
                        Com_Bus_Gnt_snoop,
                        Address_Com,
                        Data_Bus_Com,
                        BusRd,
                        BusRdX,
                        Invalidate,
                        Data_in_Bus,
                        Mem_wr,
                        Mem_oprn_abort,
                        Mem_write_done,
                        Invalidation_done,
                        All_Invalidation_done,
                        Shared_local,
                        Shared
);
input 							clk;
input								         PrWr;
input								         PrRd;
input 	[`ADDRESSSIZE-1 : 0] 		Address;
inout 	[`ADDRESSSIZE-1 : 0] 		Data_Bus;
output								      CPU_stall;
output								      Com_Bus_Req_proc;
input								         Com_Bus_Gnt_proc;
output								      Com_Bus_Req_snoop;
input								         Com_Bus_Gnt_snoop;
inout 	[`ADDRESSSIZE-1 : 0] 		Address_Com;
inout 	[`ADDRESSSIZE-1 : 0] 		Data_Bus_Com;
inout                               BusRd;
inout                               BusRdX;
inout                               Invalidate;
inout                               Data_in_Bus;
output                              Mem_wr;
output                              Mem_oprn_abort;
input                               Mem_write_done;
output                              Invalidation_done;
input								         All_Invalidation_done;
input                               Shared;
output                              Shared_local;

wire 	[((`ASSOCIATIVITY)-1) : 0]	   LRU_replacement_proc;		
wire	[`MESI_SIZE-1 : 0]			   Updated_MESI_state_proc;
wire	[`MESI_SIZE-1 : 0]			   Updated_MESI_state_snoop;
wire	[`MESI_SIZE-1 :	0]			   Current_MESI_state_proc;
wire	[`MESI_SIZE-1 :	0]			   Current_MESI_state_snoop;
wire 	[((`ASSOCIATIVITY)-1) : 0]	   Blk_accessed;

cache_block_0	cb (        clk,
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
				            Shared_local);

            
cache_controller_0 cc ( 	PrRd, 
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
				
endmodule
