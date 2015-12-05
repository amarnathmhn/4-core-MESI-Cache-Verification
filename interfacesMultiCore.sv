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
   reg          		BusRd_reg;
  // assign BusRd = PrRd[0]||PrRd[1]||PrRd[2]||PrRd[3]||
  //                PrRd[5]||PrRd[6]||PrRd[7]||PrRd[7]||
  //                ? 1'bZ: BusRd_reg;
   wire 		        BusRdX;
  // reg  		        BusRdX_reg;
  // assign BusRdX = PrWr ? 1'bZ : BusRdX_reg;
   wire 			Invalidate;
   wire 		        Invalidation_done[`CORES-1:0];
   logic 			Shared_local[`CORES-1:0];
  //Interface between Cache/Bus and Lower Level Memory
   logic 		        Mem_wr;
   logic 		        Mem_oprn_abort;
   logic 		        Mem_write_done;
   wire		                Data_in_Bus;
   logic	                Data_in_Bus_reg;
  // assign Data_in_Bus =  (PrRd[0]||PrRd[1]||PrRd[2]||PrRd[3]||
  //                       PrRd[4]||PrRd[5]||PrRd[6]||PrRd[7]||
  //                       PrWr[0]||PrWr[1]||PrWr[2]||PrWr[3]||
  //                       PrWr[4]||PrWr[5]||PrWr[6]||PrWr[7]||)? Data_in_Bus_reg : 1'bz;
   wire [`ADDRESSSIZE-1 : 0]	Address_Com;
   logic [`ADDRESSSIZE-1 : 0]	Address_Com_reg;
  // assign Address_Com = PrRd || PrWr ? 32'hZ : Address_Com_reg; 
   wire [`ADDRESSSIZE-1 : 0]	Data_Bus_Com; 

   wire [`ADDRESSSIZE-1 : 0]	Data_Bus[2*`CORES-1:0];
   reg  [`ADDRESSSIZE-1 : 0]	Data_Bus_reg[2*`CORES-1:0];
   genvar i;
   generate
   for(i = 0;i < `CORES; i++) begin
      assign Data_Bus[i] =   PrWr[i] ? 32'hZ : Data_Bus_reg[i];
   end
   endgenerate
   
  // assign Data_Bus = PrWr ? Data_Bus_reg : 32'bZ;
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
   logic [1:0]                  Current_MESI_state_proc[`CORES-1:0];
   logic [1:0]                  Current_MESI_state_snoop[`CORES-1:0];
   logic [1:0]                  Blk_accessed[`CORES-1:0];
   logic [1:0]                  LRU_replacement_proc[`CORES-1:0];
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
   logic [1:0] Blk_access_proc[`CORES-1:0];
   logic [1:0] Blk_access_snoop[`CORES-1:0];

   logic [`LRU_SIZE-1 : 0]	LRU_var	[`CORES][0:`NUM_OF_SETS-1];

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
     bit Com_Bus_Req_snoop;
     case(core)
       0: Com_Bus_Req_snoop = Com_Bus_Req_snoop_0;
       1: Com_Bus_Req_snoop = Com_Bus_Req_snoop_1;
       2: Com_Bus_Req_snoop = Com_Bus_Req_snoop_2;
       3: Com_Bus_Req_snoop = Com_Bus_Req_snoop_3;
     endcase

     if(PrRd[core])begin
         if(Com_Bus_Req_snoop) begin
            $display("BUG:: Com_Bus_Req_Snoop is asserted while it should remain de-asserted\n");
            failed = 1;
         end
     end 
     else if(PrWr[core])  begin
         if(Com_Bus_Req_snoop) begin
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

