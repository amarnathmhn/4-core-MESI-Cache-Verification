//IMPORTANT: This documents contains top module which does Simulation Based verification of DUT. The test cases used are taken from TestCases.sv file.
//Test Cases for IL are a subset of Test Cases for DL. MESI and Snoop based
//testing are only applicable for DL. So IL can be tested by following steps
//similar to that of DL

`timescale 1ps/1ps
//include Design Files
`include "cache_multi_config_1.v" //DUT design file 
`include "arbiter.v"
//`include "interfacesMultiCore.sv"
`include "TestCasesMultiCore.sv"
//define half clock period
`define HALF_PERIOD 100

module top_C1();

reg clk;
 //Global interface containing all the signals that need to be
 //driven/monitored
 globalInterface g_intf (.clk(clk));
always 
begin
	#1 clk = 1'b0;
	#1 clk = 1'b1;
end

 //Virtual interface for global interface
 virtual interface globalInterface local_intf;
 //Connect internal registers of DUT to interface
assign g_intf.Cache_var[0]            = CMC.P1_DL.cb.Cache_var;
 assign g_intf.Cache_proc_contr[0]    = CMC.P1_DL.cb.Cache_proc_contr;
 assign g_intf.LRU_var[0]              = CMC.P1_DL.cc.LRU_var;
 assign g_intf.LRU_replacement_proc[0] = CMC.P1_DL.LRU_replacement_proc;

assign g_intf.Cache_var[1]            = CMC.P2_DL.cb.Cache_var;
 assign g_intf.Cache_proc_contr[1]     = CMC.P2_DL.cb.Cache_proc_contr;
 assign g_intf.LRU_var[1]              = CMC.P2_DL.cc.LRU_var;
 assign g_intf.LRU_replacement_proc[1] = CMC.P2_DL.LRU_replacement_proc;

assign g_intf.Cache_var[2]            = CMC.P3_DL.cb.Cache_var;
 assign g_intf.Cache_proc_contr[2]     = CMC.P3_DL.cb.Cache_proc_contr;
 assign g_intf.LRU_var[2]              = CMC.P3_DL.cc.LRU_var;
 assign g_intf.LRU_replacement_proc[2] = CMC.P3_DL.LRU_replacement_proc;

assign g_intf.Cache_var[3]            = CMC.P4_DL.cb.Cache_var;
 assign g_intf.Cache_proc_contr[3]     = CMC.P4_DL.cb.Cache_proc_contr;
 assign g_intf.LRU_var[3]              = CMC.P4_DL.cc.LRU_var;
 assign g_intf.LRU_replacement_proc[3] = CMC.P4_DL.LRU_replacement_proc;

assign g_intf.Cache_var[4]            =  CMC.P1_IL.cb.Cache_var;
// assign g_intf.Cache_proc_contr_IL[0]     = CMC.P1_IL.cb.Cache_proc_contr;
 assign g_intf.LRU_var[4]              = CMC.P1_IL.cc.LRU_var;
 assign g_intf.LRU_replacement_proc[4] = CMC.P1_IL.LRU_replacement_proc;

assign g_intf.Cache_var[5]             = CMC.P2_IL.cb.Cache_var;
 assign g_intf.Cache_proc_contr_IL[1]     = CMC.P2_IL.cb.Cache_proc_contr;
 assign g_intf.LRU_var[5]              = CMC.P2_IL.cc.LRU_var;
 assign g_intf.LRU_replacement_proc[5] = CMC.P2_IL.LRU_replacement_proc;

assign g_intf.Cache_var[6]            =  CMC.P3_IL.cb.Cache_var;
 assign g_intf.Cache_proc_contr_IL[2]     = CMC.P3_IL.cb.Cache_proc_contr;
 assign g_intf.LRU_var[6]              = CMC.P3_IL.cc.LRU_var;
 assign g_intf.LRU_replacement_proc[6] = CMC.P3_IL.LRU_replacement_proc;

assign g_intf.Cache_var[7]             = CMC.P4_IL.cb.Cache_var;
 assign g_intf.Cache_proc_contr_IL[3]     = CMC.P4_IL.cb.Cache_proc_contr;
 assign g_intf.LRU_var[7]              = CMC.P4_IL.cc.LRU_var;
 assign g_intf.LRU_replacement_proc[7] = CMC.P4_IL.LRU_replacement_proc; 

assign g_intf.BusRd                    = CMC.BusRd;
assign g_intf.BusRdX                   = CMC.BusRdX;
assign g_intf.Invalidate               = CMC.Invalidate;
assign g_intf.Shared                   = CMC.Shared;



//always @(g_intf.clk) begin

 assign g_intf.Updated_MESI_state_proc[0]  = CMC.P1_DL.cb.Updated_MESI_state_proc; 
 assign g_intf.Blk_access_proc[0]          = CMC.P1_DL.cb.Blk_access_proc;
 assign g_intf.Blk_access_snoop[0]         = CMC.P1_DL.cb.Blk_access_snoop;
 assign g_intf.Index_snoop[0]              = CMC.P1_DL.cb.Index_snoop;

 assign g_intf.Updated_MESI_state_proc[1]  = CMC.P2_DL.cb.Updated_MESI_state_proc; 
 assign g_intf.Blk_access_proc[1]          = CMC.P2_DL.cb.Blk_access_proc;
 assign g_intf.Blk_access_snoop[1]         = CMC.P2_DL.cb.Blk_access_snoop;
 assign g_intf.Index_snoop[1]              = CMC.P2_DL.cb.Index_snoop; 

 assign g_intf.Updated_MESI_state_proc[2]  = CMC.P3_DL.cb.Updated_MESI_state_proc; 
 assign g_intf.Blk_access_proc[2]          = CMC.P3_DL.cb.Blk_access_proc;
 assign g_intf.Blk_access_snoop[2]         = CMC.P3_DL.cb.Blk_access_snoop;
 assign g_intf.Index_snoop[2]              = CMC.P3_DL.cb.Index_snoop;

 assign g_intf.Updated_MESI_state_proc[3]  = CMC.P4_DL.cb.Updated_MESI_state_proc; 
 assign g_intf.Blk_access_proc[3]          = CMC.P4_DL.cb.Blk_access_proc;
 assign g_intf.Blk_access_snoop[3]         = CMC.P4_DL.cb.Blk_access_snoop;
 assign g_intf.Index_snoop[3]              = CMC.P4_DL.cb.Index_snoop;

  //g_intf.Updated_MESI_state_proc[4]  = CMC.P1_IL.cb.Updated_MESI_state_proc; 
 assign g_intf.Blk_access_proc[4]          = CMC.P1_IL.cb.Blk_access_proc;
  //g_intf.Blk_access_snoop[4]         = CMC.P1_IL.cb.Blk_access_snoop;
  //g_intf.Index_snoop[4]              = CMC.P1_IL.cb.Index_snoop;

  //g_intf.Updated_MESI_state_proc[5]  = CMC.P2_IL.cb.Updated_MESI_state_proc; 
 assign g_intf.Blk_access_proc[5]          = CMC.P2_IL.cb.Blk_access_proc;
  //g_intf.Blk_access_snoop[5]         = CMC.P2_IL.cb.Blk_access_snoop;
  //g_intf.Index_snoop[5]              = CMC.P2_IL.cb.Index_snoop;

  //g_intf.Updated_MESI_state_proc[6]  = CMC.P3_IL.cb.Updated_MESI_state_proc; 
 assign  g_intf.Blk_access_proc[6]          = CMC.P3_IL.cb.Blk_access_proc;
  //g_intf.Blk_access_snoop[6]         = CMC.P3_IL.cb.Blk_access_snoop;
  //g_intf.Index_snoop[6]              = CMC.P3_IL.cb.Index_snoop;

  //g_intf.Updated_MESI_state_proc[7]  = CMC.P4_IL.cb.Updated_MESI_state_proc; 
 assign g_intf.Blk_access_proc[7]          = CMC.P4_IL.cb.Blk_access_proc;
  //g_intf.Blk_access_snoop[7]         = CMC.P4_IL.cb.Blk_access_snoop;
  //g_intf.Index_snoop[7]              = CMC.P4_IL.cb.Index_snoop;

// end


//The port connections are made without the knowledge of the actual design. It is supposed to change later.
cache_multi_config_1 CMC (
                                                                g_intf.clk,
								g_intf.PrWr[0]              ,
								g_intf.PrRd[0]              ,
								g_intf.Address[0]           ,
								g_intf.Data_Bus[0]          ,
								g_intf.CPU_stall[0]         ,
								g_intf.Com_Bus_Req_proc[0],
								g_intf.Com_Bus_Gnt_proc[0],
								g_intf.Com_Bus_Req_snoop[0],
								g_intf.Com_Bus_Gnt_snoop[0],
								g_intf.PrWr[1]              ,
								g_intf.PrRd[1]              ,
								g_intf.Address[1]           ,
								g_intf.Data_Bus[1]          ,
								g_intf.CPU_stall[1]         ,
								g_intf.Com_Bus_Req_proc[1]  ,
								g_intf.Com_Bus_Gnt_proc[1]  ,
								g_intf.Com_Bus_Req_snoop[1] ,
								g_intf.Com_Bus_Gnt_snoop[1] ,
								g_intf.PrWr[2]              ,
								g_intf.PrRd[2]              ,
								g_intf.Address[2]           ,
								g_intf.Data_Bus[2]          ,
								g_intf.CPU_stall[2]         ,
								g_intf.Com_Bus_Req_proc[2]  ,
								g_intf.Com_Bus_Gnt_proc[2]  ,
								g_intf.Com_Bus_Req_snoop[2] ,
								g_intf.Com_Bus_Gnt_snoop[2] ,
								g_intf.PrWr[3]              ,
								g_intf.PrRd[3]              ,
								g_intf.Address[3]           ,
								g_intf.Data_Bus[3]          ,
								g_intf.CPU_stall[3]         ,
								g_intf.Com_Bus_Req_proc[3]  ,
								g_intf.Com_Bus_Gnt_proc[3]  ,
								g_intf.Com_Bus_Req_snoop[3] ,
								g_intf.Com_Bus_Gnt_snoop[3] ,
								g_intf.Address_Com,
								g_intf.Data_Bus_Com,
								g_intf.Data_in_Bus,
								g_intf.Mem_wr,
								g_intf.Mem_oprn_abort,
								g_intf.Mem_write_done,
								g_intf.PrWr[4]              ,
								g_intf.PrRd[4]              ,
								g_intf.Address[4]           ,
								g_intf.Data_Bus[4]          ,
								g_intf.CPU_stall[4]         ,
								g_intf.Com_Bus_Req_proc[4]  ,
								g_intf.Com_Bus_Gnt_proc[4]  ,
								g_intf.PrWr[5]              ,
								g_intf.PrRd[5]              ,
								g_intf.Address[5]           ,
								g_intf.Data_Bus[5]          ,
								g_intf.CPU_stall[5]         ,
								g_intf.Com_Bus_Req_proc[5]  ,
								g_intf.Com_Bus_Gnt_proc[5]  ,
								g_intf.PrWr[6]              ,
								g_intf.PrRd[6]              ,
								g_intf.Address[6]           ,
								g_intf.Data_Bus[6]          ,
								g_intf.CPU_stall[6]         ,
								g_intf.Com_Bus_Req_proc[6]  ,
								g_intf.Com_Bus_Gnt_proc[6]  ,
								g_intf.PrWr[7]              ,
								g_intf.PrRd[7]              ,
								g_intf.Address[7]           ,
								g_intf.Data_Bus[7]          ,
								g_intf.CPU_stall[7]         ,
								g_intf.Com_Bus_Req_proc[7]  ,
								g_intf.Com_Bus_Gnt_proc[7]  

);
 
//Instantiate  Top level direct testcase object. Please consider that these
//test cases consider more than 1 scenario specified in Test Plan and As
//commented in TestCases.sv file
topLocal_NonLocalCoreTest topLocal_NonLocalCoreTest_inst;
topWriteHit topWriteHit_inst;
topReadHit  topReadHit_inst;
topReadMiss  topReadMiss_inst;
task testLocal_NonLocalCore(virtual interface globalInterface local_intf,input [3:0] local_cache, input [3:0] other_cache, input commandType local_operation, input [31:0] Address, input mesiStateType blockStateOtherCache, input hitMissType hitMiss );
    topLocal_NonLocalCoreTest_inst                      = new();
    topLocal_NonLocalCoreTest_inst.reset_DUT_inputs(local_intf);
    topLocal_NonLocalCoreTest_inst.Max_Resp_Delay       = 10;
    topLocal_NonLocalCoreTest_inst.local_cache          = local_cache;
    topLocal_NonLocalCoreTest_inst.other_cache          = other_cache;
    topLocal_NonLocalCoreTest_inst.operation            = local_operation;
    topLocal_NonLocalCoreTest_inst.Address              = Address;
    topLocal_NonLocalCoreTest_inst.blockStateOtherCache = blockStateOtherCache;
    topLocal_NonLocalCoreTest_inst.hitMiss              = hitMiss;
    topLocal_NonLocalCoreTest_inst.testLocal_NonLocalCore(local_intf);
    topLocal_NonLocalCoreTest_inst.reset_DUT_inputs(local_intf);
endtask : testLocal_NonLocalCore
//Task to write data directly into Cache_var
task writeCacheVarProcContr(input [3:0] core, input [31:0] Address,input [31:0] Data, input mesiStateType mst, input [1:0] line);
    reg [`TAG_SIZE-1:0]   tag;
    reg [`INDEX_SIZE-1:0] index;
    begin
     tag   = Address[`TAG_MSB:`TAG_LSB];
     index = Address[`INDEX_MSB:`INDEX_LSB];
    case (core)
       3'd0: begin 
             CMC.P1_DL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB]           = Data;
             CMC.P1_DL.cb.Cache_proc_contr[{index,line[1:0]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]    = mst;
             CMC.P1_DL.cb.Cache_proc_contr[{index,line[1:0]}][`CACHE_TAG_MSB:`CACHE_TAG_LSB]      = tag;
             end
       3'd1: begin
             CMC.P2_DL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB]           = Data;
             CMC.P2_DL.cb.Cache_proc_contr[{index,line[1:0]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]    = mst;
             CMC.P2_DL.cb.Cache_proc_contr[{index,line[1:0]}][`CACHE_TAG_MSB:`CACHE_TAG_LSB]      = tag;
             end
       3'd2: begin 
             CMC.P3_DL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB]           = Data;
             CMC.P3_DL.cb.Cache_proc_contr[{index,line[1:0]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]    = mst;
             CMC.P3_DL.cb.Cache_proc_contr[{index,line[1:0]}][`CACHE_TAG_MSB:`CACHE_TAG_LSB]      = tag;
             end
       3'd3: begin 
             CMC.P4_DL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB]           = Data;
             CMC.P4_DL.cb.Cache_proc_contr[{index,line[1:0]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]    = mst;
             CMC.P4_DL.cb.Cache_proc_contr[{index,line[1:0]}][`CACHE_TAG_MSB:`CACHE_TAG_LSB]      = tag;
             end
    endcase
    end
endtask : writeCacheVarProcContr
//Task to display data directly from Cache_var
task dispCacheVarData(input [3:0] core, input [31:0] Address);
    reg [`TAG_SIZE-1:0]   tag;
    reg [`INDEX_SIZE-1:0] index;
    reg [2:0] line;
    reg [31:0] Data;
    begin
     tag   = Address[`TAG_MSB:`TAG_LSB];
     index = Address[`INDEX_MSB:`INDEX_LSB];
    for(line = 0; line <=3; line++) begin
    case (core)
       3'd0: begin 
             Data = CMC.P1_DL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
             end
       3'd1: begin
             Data = CMC.P2_DL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
             end
       3'd2: begin 
             Data = CMC.P3_DL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
             end
       3'd3: begin 
             Data = CMC.P4_DL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
             end
       3'd4: begin 
             Data = CMC.P1_IL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
             end
       3'd5: begin
             Data = CMC.P2_IL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
             end
       3'd6: begin 
             Data = CMC.P3_IL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
             end
       3'd7: begin 
             Data = CMC.P4_IL.cb.Cache_var[{index,line[1:0]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
             end
    endcase
    $display("Data stored in core %d in set %d in line %d is %x",core,index,line,Data);
    end//for
    end
endtask : dispCacheVarData
//display mesi states of all blocks in a given set
task dispMesiStates(input [3:0] core,input [31:0] Address);
   reg [2:0] line;
   mesiStateType mst;
   reg [`TAG_SIZE-1:0] tag;
   for(line = 3'b000; line <= 3'b011; line++) begin
    case (core)
       3'd0: begin 
             mst = mesiStateType'(CMC.P1_DL.cb.Cache_proc_contr[{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
             tag = CMC.P1_DL.cb.Cache_proc_contr[{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_TAG_MSB:`CACHE_TAG_LSB];
             end
       3'd1: begin
             mst = mesiStateType'(CMC.P2_DL.cb.Cache_proc_contr[{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
             tag = CMC.P2_DL.cb.Cache_proc_contr[{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_TAG_MSB:`CACHE_TAG_LSB];
             end
       3'd2: begin 
             mst = mesiStateType'(CMC.P3_DL.cb.Cache_proc_contr[{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
             tag = CMC.P3_DL.cb.Cache_proc_contr[{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_TAG_MSB:`CACHE_TAG_LSB];
             end
       3'd3: begin 
             mst = mesiStateType'(CMC.P4_DL.cb.Cache_proc_contr[{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
             tag = CMC.P4_DL.cb.Cache_proc_contr[{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_TAG_MSB:`CACHE_TAG_LSB];
             end
    endcase
      $display("MESI State of block %d in Core %d with Tag %x set %x is %s",line,core,tag,Address[`INDEX_MSB:`INDEX_LSB],mst);
   end
   $display("\n");
endtask :dispMesiStates

//display mesi states of all blocks in a given set
task dispLRUvar(input [3:0] core,input [31:0] Address);
   reg [2:0] plru;
    case (core)
       3'd0: begin 
             plru = CMC.P1_DL.cc.LRU_var[Address[`INDEX_MSB:`INDEX_LSB]];
             end
       3'd1: begin
             plru = CMC.P2_DL.cc.LRU_var[Address[`INDEX_MSB:`INDEX_LSB]];
             end
       3'd2: begin 
             plru = CMC.P3_DL.cc.LRU_var[Address[`INDEX_MSB:`INDEX_LSB]];
             end
       3'd3: begin 
             plru = CMC.P4_DL.cc.LRU_var[Address[`INDEX_MSB:`INDEX_LSB]];
             end
       3'd4: begin 
             plru = CMC.P1_IL.cc.LRU_var[Address[`INDEX_MSB:`INDEX_LSB]];
             end
       3'd5: begin
             plru = CMC.P2_IL.cc.LRU_var[Address[`INDEX_MSB:`INDEX_LSB]];
             end
       3'd6: begin 
             plru = CMC.P3_IL.cc.LRU_var[Address[`INDEX_MSB:`INDEX_LSB]];
             end
       3'd7: begin 
             plru = CMC.P4_IL.cc.LRU_var[Address[`INDEX_MSB:`INDEX_LSB]];
             end
    endcase
      $display("PLRU of the set with Set ID %x is %b",Address[`INDEX_MSB:`INDEX_LSB],plru);
   $display("\n");
endtask :dispLRUvar

reg[31:0] temp_addr;
reg[31:0] temp_data;
reg [7:0] test_no;
reg tmp_blk_access;

reg [3:0] other_cache;
reg [3:0] local_cache;
commandType local_operation;
mesiStateType blockStateOtherCache[0:3];
mesiStateType mst;
reg [31:0] Address;
reg [2:0] line;
initial
 begin
 #20;
 local_intf         = g_intf;
 
 other_cache = 1;
 local_cache = 0;
 Address     = 32'hDEADBEEF;
 for(int i=0; i <=3 ; i++) begin
    blockStateOtherCache[i] = mesiStateType'(i); 
 end
/*
while(other_cache <=3) begin
//Test 1 in the test plan. local cache read miss while other cache contains block in invalid state and free  block is available
$display("*** START Testing for the combination local_cache = %d, other_cache = %d",local_cache,other_cache);
$display("*********** START OF TEST %d",1);
    local_operation = PrRd;
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(other_cache),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(INVALID),
                           .hitMiss(MISS)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
  
$display("*********** END OF TEST %d\n",1);

//Test 2 in the test plan. local cache read miss while other cache contains block in EXCLUSIVE state and free  block is available
$display("*********** START OF TEST %d",2);
    Address[`INDEX_MSB:`INDEX_LSB] += 1;
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(other_cache),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(EXCLUSIVE),
                           .hitMiss(MISS)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
  
 $display("*********** END OF TEST %d\n",2);

//Test 6 in the test plan. local cache read miss while other cache contains block in SHARED state and free  block is available
  $display("*********** START OF TEST %d",6);
    Address[`INDEX_MSB:`INDEX_LSB] += 1;
    //Address += 32'h10000000;
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(other_cache),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(SHARED),
                           .hitMiss(MISS)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
  
 $display("*********** END OF TEST %d\n",6);

//Test 4 in the test plan. local cache read miss while other cache contains block in MODIFIED state and free  block is available
  $display("*********** START OF TEST %d",4);
    Address[`INDEX_MSB:`INDEX_LSB] += 1;
    //Address += 32'h10000000;
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(other_cache),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(MODIFIED),
		           .hitMiss(MISS)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
  
 $display("*********** END OF TEST %d\n",4);

//Test 8 in the test plan. local cache write miss while other cache contains block in INVALID state and free  block is available
  $display("*********** START OF TEST %d",8);
    Address[`INDEX_MSB:`INDEX_LSB] += 1;
    
    //Address += 32'h12345678;
    local_operation = PrWr;
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(other_cache),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(INVALID),
			   .hitMiss(MISS)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
  
 $display("*********** END OF TEST %d\n",8);

//Test 9 in the test plan. local cache write miss while other cache contains block in EXCLUSIVE state and free  block is available
  $display("*********** START OF TEST %d",9);
    Address[`INDEX_MSB:`INDEX_LSB] += 1;
    
   // Address += 32'h10000000;
    local_operation = PrWr;
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(other_cache),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(EXCLUSIVE),
                           .hitMiss(MISS)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
  
 $display("*********** END OF TEST %d\n",9);

//Test 11 in the test plan. local cache write miss while other cache contains block in MODIFIED state and free  block is available
  $display("*********** START OF TEST %d",11);
    Address[`INDEX_MSB:`INDEX_LSB] += 1;
    
   // Address += 32'h10000000;
    local_operation = PrWr;
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(other_cache),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(MODIFIED),
                           .hitMiss(MISS)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
  
 $display("*********** END OF TEST %d\n",11); 

//Test 13 in the test plan. local cache write miss while other cache contains block in SHARED state and free  block is available
  $display("*********** START OF TEST %d",13);
    Address[`INDEX_MSB:`INDEX_LSB] += 1;
    
   // Address = 32'h87654321;
    local_operation = PrWr;
    
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(other_cache),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(SHARED),
                           .hitMiss(MISS)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
    
  Address[`INDEX_MSB:`INDEX_LSB] += 1;
  
 $display("*********** END OF TEST %d\n",13);
 $display("************ END of tests for combination local_cache %d, other_cache %d",local_cache,other_cache);
  other_cache += 1;
end//while */

//Test 2 with local cache = 0,  other cache = 2
/*$display("*********** START OF TEST %d",2);
    Address[`INDEX_MSB:`INDEX_LSB] =32'hdeadbeef;
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(2),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(EXCLUSIVE),
                           .hitMiss(MISS)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
  
 $display("*********** END OF TEST %d\n",2);
*/
//************************************************************************************************************************************************************
//Test  15 in the test bench. local cache and other cache have a block in Shared state. Local cache writes to this block.
//first, create a shared block in core 0 and core 1 by doing read miss for the same block in both cores
/*  $display("*********** START OF TEST %d",15);
    //Address[`INDEX_MSB:`INDEX_LSB] += 1;
    //Create an exclusive block in core 0
    Address = 32'h54321678;
    local_operation = PrRd;
    local_cache     = 0;
    other_cache     = 1;
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(other_cache),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(INVALID),
                           .hitMiss(MISS)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
    
    #100;
    //Create an shared block in core 1 by doing a read miss for the exclusive block in core 0
    local_cache     = 1;
    other_cache     = 0;
    
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(other_cache),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(EXCLUSIVE),
                           .hitMiss(MISS)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
    #100;
    //Now do a PrWr on the Shared Block in Cache 0 that is shared with Cache 1
    local_operation = PrWr;
    local_cache     = 1;
    other_cache     = 0;
    testLocal_NonLocalCore(.local_intf(local_intf),
                           .local_cache(local_cache),
                           .other_cache(other_cache),
                           .local_operation(local_operation),
                           .Address(Address),
                           .blockStateOtherCache(SHARED),
                           .hitMiss(HIT)); 
    dispMesiStates(local_cache,Address);
    dispMesiStates(other_cache,Address);
 $display("*********** END OF TEST %d\n",15);
//*************************************************************************************************************************************************************
*/

//******************************************* TEST 16 Pseudo LRU TESTING*****************************************************************************************************
/*
$display("*********** START OF TEST %d",16);
//Fill out a cache set
 repeat(4) begin
 
     local_cache                       = 0;
     topReadMiss_inst                  = new();
     topReadMiss_inst.Address          = Address;
     topReadMiss_inst.core             = local_cache ;
     topReadMiss_inst.Max_Resp_Delay   = 10;
     topReadMiss_inst.testSimpleReadMiss(local_intf);
     dispMesiStates(local_cache,Address);
     #10;
     topReadMiss_inst.reset_DUT_inputs(local_intf); 
     #100;
     dispLRUvar(local_cache,Address);
    Address[`TAG_MSB:`TAG_LSB] += 1;
end
//Now do a read miss
$display("*********************Set is full, now doing read misses*************");
   repeat(4) begin
     topReadMiss_inst                  = new();
     topReadMiss_inst.Address          = Address;
     topReadMiss_inst.core             = local_cache ;
     topReadMiss_inst.Max_Resp_Delay   = 10;
     topReadMiss_inst.testSimpleReadMiss(local_intf);
     dispMesiStates(local_cache,Address);
     #10;
     topReadMiss_inst.reset_DUT_inputs(local_intf); 
     #100;
     dispLRUvar(local_cache,Address);
    Address[`TAG_MSB:`TAG_LSB] += 1;
  end
$display("*********** END OF TEST %d\n",16);
 */
//******************************************* END OF TEST 16 ***************************************************************************//

//******************************************* START TEST 17 Instruction Cache (IL) TESTING *****************************************************************************

/*$display("*********** START OF TEST %d\n ** IL Read Miss **",17); 
//Read Miss on IL
     Address                           = 32'hdeadbeef;
     local_cache                       = 5;  //P2_IL
     topReadMiss_inst                  = new();
     topReadMiss_inst.Address          = Address;
     topReadMiss_inst.core             = local_cache ;
     topReadMiss_inst.Max_Resp_Delay   = 10;
     topReadMiss_inst.testSimpleReadMiss(local_intf);
     //dispMesiStates(local_cache,Address);
     #10;
     topReadMiss_inst.reset_DUT_inputs(local_intf); 
     #100;
     dispLRUvar(local_cache,Address);
     //display the data stored in P1_IL
     dispCacheVarData(local_cache,Address); 
$display("*********** END OF TEST %d\n",17); 
 */
//******************************************* END OF TEST 17 Instruction Cache (IL) TESTING ****************************************************************************

//******************************************* START TEST 18 Instruction Cache (IL) TESTING *****************************************************************************
$display("*********** START OF TEST %d\n *** Read Hit Checking for Instruction Caches",18); 
//PLRU Checking in IL
Address                           = 32'hdeadbeef;
//Fill out the Cache set
temp_data                         = 32'hbaadbadb;
repeat(4) begin
     local_cache                       = 7;  //P3_IL
     topReadMiss_inst                  = new();
     topReadMiss_inst.Address          = Address;
     topReadMiss_inst.core             = local_cache ;
     topReadMiss_inst.DataWrittenByMem = temp_data ;
     topReadMiss_inst.Max_Resp_Delay   = 10;
     topReadMiss_inst.testSimpleReadMiss(local_intf);
     //dispMesiStates(local_cache,Address);
     #10;
     topReadMiss_inst.reset_DUT_inputs(local_intf); 
     #100;
     dispLRUvar(local_cache,Address);
     //display the data stored in P1_IL
     dispCacheVarData(local_cache,Address); 
     Address[`TAG_MSB:`TAG_LSB] += 1;  //move to next block
     temp_data                  += 32'h00000001;  //increment the data just so that each block has different data
end
     $display("*********** END OF TEST %d\n",18); 
//Now do a read Hit
Address                           = 32'hdeadbeef;
repeat(4) begin
     topReadHit_inst                  = new();
     topReadHit_inst.Address          = Address;
     topReadHit_inst.core             = local_cache ;
     topReadHit_inst.Max_Resp_Delay   = 10;
     topReadHit_inst.testSimpleReadHit(local_intf);
     $display("Data on Data_Bus = %x", CMC.Data_Bus[local_cache]);
     //dispMesiStates(local_cache,Address);
     #10;
     topReadHit_inst.reset_DUT_inputs(local_intf); 
     #100;
     dispLRUvar(local_cache,Address);
     //display the data stored in P1_IL
     dispCacheVarData(local_cache,Address); 
     Address[`TAG_MSB:`TAG_LSB] += 1;  //move to next block
end
//******************************************* END OF TEST 18 Instruction Cache (IL) TESTING ****************************************************************************
#100;
$finish;       
end 

always @(posedge g_intf.Mem_snoop_req) begin
     g_intf.Mem_snoop_gnt = 1;
     wait(g_intf.Mem_snoop_req == 0);
     g_intf.Mem_snoop_gnt = 0;
end

genvar i;
generate
for(i = 0; i < 7; i++) begin
   always @(posedge g_intf.Com_Bus_Req_proc[i]) begin
     g_intf.Com_Bus_Gnt_proc[i] = 1;
     wait(g_intf.Com_Bus_Req_proc[i] == 0);
     g_intf.Com_Bus_Gnt_proc[i] = 0;
   end
   if(i <= 3) begin
     always @(posedge g_intf.Com_Bus_Req_snoop[i]) begin
      #2;
      g_intf.Com_Bus_Gnt_snoop[i] = 1;
      wait(g_intf.Com_Bus_Req_snoop[i] == 0);
      g_intf.Com_Bus_Gnt_snoop[i] = 0;
     end
   end
end //for
endgenerate
endmodule



