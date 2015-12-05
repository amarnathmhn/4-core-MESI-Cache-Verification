//This document contains interfaces to various blocks in the DUT specified in Cache.
// Names of the interfaces are similar to the names of the blocks used in HAS3.0. Wherever there is deviation, explanation is provided.
//Interface containing interfacing signals between (Proc and Cache), (Cache and Memory), (Memory and Arbiter), (Cache and Bus).
// To be used for Both DL and IL. For IL 'Wr' related signals shall be ignored.Contains interfaces of internal blocks too.



interface globalInterface(input logic clk);
  //Most of the fields defined are common to cache_controller, cache_block, cache_wrapper
  //Interface between Proc and Cache
   wire 			PrRd; 
   wire 			PrWr;
   wire [`ADDRESSSIZE-1 : 0]	Address;
   logic			CPU_stall; 
  //Interface between Proc and Arbiter                     
   wire 			Com_Bus_Gnt_proc_0;
   wire                         Com_Bus_Gnt_proc_1;
   wire                         Com_Bus_Gnt_proc_2;
   wire                         Com_Bus_Gnt_proc_3;
   wire                         Com_Bus_Gnt_proc_4;
   wire                         Com_Bus_Gnt_proc_5;
   wire                         Com_Bus_Gnt_proc_6;
   wire                         Com_Bus_Gnt_proc_7;
   wire 			Com_Bus_Gnt_snoop;
  //Interface between Cache and Bus
   logic 			All_Invalidation_done;
   wire 			Shared;
   wire         		BusRd;
   wire 		        BusRdX;
   wire 			Invalidate;
   wire 		        Invalidation_done;
   logic 			Shared_local;
  //Interface between Cache/Bus and Lower Level Memory
   logic 		        Mem_wr;
   logic 		        Mem_oprn_abort;
   logic 		        Mem_write_done;
   wire		                Data_in_Bus;
   logic	                Data_in_Bus_reg;
   assign Data_in_Bus = PrRd|| PrWr ? Data_in_Bus_reg : 1'bz;
   wire [`ADDRESSSIZE-1 : 0]	Address_Com;
   logic [`ADDRESSSIZE-1 : 0]	Address_Com_reg;
   assign Address_Com = PrRd || PrWr ? 32'hZ : Address_Com_reg; 
   wire [`ADDRESSSIZE-1 : 0]	Data_Bus_Com; 

   wire [`ADDRESSSIZE-1 : 0]	Data_Bus;
   reg  [`ADDRESSSIZE-1 : 0]	Data_Bus_reg;
   assign Data_Bus = PrWr ? Data_Bus_reg : 32'bZ;
   wire                         Com_Bus_Req_proc_0;
   wire                         Com_Bus_Req_proc_1;
   wire                         Com_Bus_Req_proc_2;
   wire                         Com_Bus_Req_proc_3;
   wire                         Com_Bus_Req_proc_4;
   wire                         Com_Bus_Req_proc_5;
   wire                         Com_Bus_Req_proc_6;
   wire                         Com_Bus_Req_proc_7;
   wire 			Com_Bus_Req_snoop_0;
   wire                         Com_Bus_Req_snoop_1;
   wire                         Com_Bus_Req_snoop_2;
   wire                         Com_Bus_Req_snoop_3;
   wire                         Com_Bus_Req_snoop_4;
   wire                         Com_Bus_Gnt_snoop_0;
   wire                         Com_Bus_Gnt_snoop_1;
   wire                         Com_Bus_Gnt_snoop_2;
   wire                         Com_Bus_Gnt_snoop_3;
  //Interface between Lower Level Memory and Arbiter
   logic                        Mem_snoop_req;
   wire                         Mem_snoop_gnt;
   logic [1:0]                  Current_MESI_state_proc;
   logic [1:0]                  Current_MESI_state_snoop;
   logic [1:0]                  Blk_accessed;
   logic [1:0]                  LRU_replacement_proc;
   logic [1:0]                  Updated_MESI_state_proc;
   logic [1:0]                  Updated_MESI_state_snoop;
  //Interface of Address Segregator Block
   logic [`BLK_OFFSET_SIZE - 1 : 0] Blk_offset_proc;
   logic [`TAG_SIZE - 1 : 0]        Tag_proc;
   logic [`INDEX_SIZE - 1 : 0]      Index_proc; 
   logic [`INDEX_SIZE - 1 : 0]      Index_snoop; 
   logic [`CACHE_DATA_SIZE-1 : 0]    Cache_var	    [0 : `CACHE_DEPTH-1];
   logic [`CACHE_TAG_MESI_SIZE-1 : 0]Cache_proc_contr[0 : `CACHE_DEPTH-1];
   logic [1:0] Blk_access_proc;
   logic [1:0] Blk_access_snoop;

   logic [`LRU_SIZE-1 : 0]	LRU_var	[0:`NUM_OF_SETS-1];

   clocking ClkBlk @(posedge clk);
      output PrRd;
      output PrWr; 
      output Address;
      output Shared;
      inout Data_Bus_Com;
      inout Invalidate;
   endclocking

   logic failed;
   initial
     failed = 0; 
 //Task to check if there is any undefined behavior
  task check_UndefinedBehavior();
     if(PrRd)       begin
         if(Com_Bus_Req_snoop_0) begin
            $display("BUG:: Com_Bus_Req_Snoop is asserted while it should remain de-asserted\n");
            failed = 1;
         end
     end 
     else if(PrWr)  begin
         if(Com_Bus_Req_snoop_0) begin
            $display("BUG:: Com_Bus_Req_Snoop is asserted while it should remain de-asserted");
            failed = 1;
         end
     end
     else if(BusRd) begin
     end
     else if(BusRdX) begin
     end
  endtask : check_UndefinedBehavior  
endinterface 

