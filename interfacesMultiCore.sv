//This document contains interfaces to various blocks in the DUT specified in Cache.
// Names of the interfaces are similar to the names of the blocks used in HAS3.0. Wherever there is deviation, explanation is provided.
//Interface containing interfacing signals between (Proc and Cache), (Cache and Memory), (Memory and Arbiter), (Cache and Bus).
// To be used for Both DL and IL. For IL 'Wr' related signals shall be ignored.Contains interfaces of internal blocks too.

`define CORES  4

interface globalInterface (input logic clk);
  //Most of the fields defined are common to cache_controller, cache_block, cache_wrapper
  //Interface between Proc and Cache
   wire 			PrRd[2*`CORES-1:0]; 
   wire 			PrWr[2*`CORES-1:0];
   wire [`ADDRESSSIZE-1 : 0]	Address[2*`CORES-1:0];
   logic			CPU_stall[2*`CORES-1:0]; 
  //Interface between Proc and Arbiter                     
  logic 			Com_Bus_Gnt_proc[0:7];
  //Interface between Cache and Bus
   logic 			All_Invalidation_done;
   wire 			Shared;
   wire         		BusRd;
   reg          		BusRd_reg;
   wire 		        BusRdX;
   wire 			Invalidate;
   wire 		        Invalidation_done[`CORES-1:0];
   logic 			Shared_local[`CORES-1:0];
  //Interface between Cache/Bus and Lower Level Memory
   logic 		        Mem_wr;
   logic 		        Mem_oprn_abort;
   logic 		        Mem_write_done;
   wire		                Data_in_Bus;
   wire [`ADDRESSSIZE-1 : 0]	Address_Com;
   logic [`ADDRESSSIZE-1 : 0]	Address_Com_reg;
   wire [`ADDRESSSIZE-1 : 0]	Data_Bus_Com; 

   wire [`ADDRESSSIZE-1 : 0]	Data_Bus[2*`CORES-1:0];
   reg  [`ADDRESSSIZE-1 : 0]	Data_Bus_reg[2*`CORES-1:0];
   genvar i;
   generate
   for(i = 0;i < `CORES; i++) begin
      assign Data_Bus[i] =   PrWr[i] ? Data_Bus_reg[i]: 32'hZ;
   end
   endgenerate
   
  // assign Data_Bus = PrWr ? Data_Bus_reg : 32'bZ;
  logic                          Com_Bus_Req_proc[0:7];
  logic 			 Com_Bus_Req_snoop[0:7];
  logic                          Com_Bus_Gnt_snoop[0:7];
  //Interface between Lower Level Memory and Arbiter
   logic                        Mem_snoop_req;
   logic                         Mem_snoop_gnt;
   logic [1:0]                  Current_MESI_state_proc[`CORES-1:0];
   logic [1:0]                  Current_MESI_state_snoop[`CORES-1:0];
   logic [1:0]                  Blk_accessed[`CORES-1:0];
   logic [1:0]                  LRU_replacement_proc[2*`CORES-1:0];
   logic [1:0]                  Updated_MESI_state_proc[`CORES-1:0];
   logic [1:0]                  Updated_MESI_state_snoop[`CORES-1:0];
  //Interface of Address Segregator Block
   logic [`BLK_OFFSET_SIZE - 1 : 0]  Blk_offset_proc[2*`CORES-1:0];
   logic [`TAG_SIZE - 1 : 0]         Tag_proc[2*`CORES-1:0];
   logic [`INDEX_SIZE - 1 : 0]       Index_proc[2*`CORES-1:0]; 
   logic [`INDEX_SIZE - 1 : 0]       Index_snoop[`CORES-1:0]; 
   logic [`CACHE_DATA_SIZE-1 : 0]    Cache_var[2*`CORES][0 : `CACHE_DEPTH-1];
   logic [`CACHE_TAG_MESI_SIZE-1  : 0] Cache_proc_contr[`CORES][0 : `CACHE_DEPTH-1];
   logic [`CACHE_TAG_VALID_SIZE-1 : 0] Cache_proc_contr_IL[`CORES][0 : `CACHE_DEPTH-1];
   logic [1:0] Blk_access_proc[2*`CORES-1:0];
   logic [1:0] Blk_access_snoop[2*`CORES-1:0];

   logic [`LRU_SIZE-1 : 0]	LRU_var	[2*`CORES][0:`NUM_OF_SETS-1];

   clocking ClkBlk @(posedge clk);
      output PrRd;
      output PrWr; 
      output Address;
      //input Shared;
      inout Data_Bus_Com;
      //input Invalidate;
      inout Data_in_Bus;
   endclocking

   logic failed;
   initial
     failed = 0; 
 //Task to check if there is any undefined behavior
  task check_UndefinedBehavior(input int core);
     if(PrRd[core])begin
         if(Com_Bus_Req_snoop[core]) begin
            $display("BUG:: Com_Bus_Req_Snoop[%d] is asserted while it should remain de-asserted\n",core);
            failed = 1;
         end
     end 
     else if(PrWr[core])  begin
         if(Com_Bus_Req_snoop[core]) begin
            $display("BUG:: Com_Bus_Req_Snoop[%d] is asserted while it should remain de-asserted",core);
            failed = 1;
         end
     end
     else if(BusRd) begin
     end
     else if(BusRdX) begin
     end
   
  
  endtask : check_UndefinedBehavior  
endinterface 

