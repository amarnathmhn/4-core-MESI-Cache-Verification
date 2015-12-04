//IMPORTANT: This documents contains top module which does Simulation Based verification of DUT. The test cases used are taken from TestCases.sv file.
//Test Cases for IL are a subset of Test Cases for DL. MESI and Snoop based
//testing are only applicable for DL. So IL can be tested by following steps
//similar to that of DL

`timescale 1ps/1ps
//include Design Files
`include "cache_multi_config.v" //DUT design file 
`include "arbiter.v"
`include "TestCases.sv"
//define half clock period
`define HALF_PERIOD 100

module top_C1();


 //Global interface containing all the signals that need to be
 //driven/monitored
 globalInterface g_intf #(.cores(4))(.clk(a.clk));


 //Virtual interface for global interface
 virtual interface globalInterface local_intf;
 //Connect internal registers of DUT to interface
 assign g_intf.Cache_var            = P1_DL.cb.Cache_var;
 assign g_intf.Cache_proc_contr     = P1_DL.cb.Cache_proc_contr;
 assign g_intf.LRU_var              = P1_DL.cc.LRU_var;
 assign g_intf.LRU_replacement_proc = P1_DL.cc.LRU_replacement_proc;
 always @(g_intf.clk) begin
   g_intf.Updated_MESI_state_proc  = P1_DL.cb.Updated_MESI_state_proc; 
   g_intf.Blk_access_proc          = P1_DL.cb.Blk_access_proc;
   g_intf.Blk_access_snoop         = P1_DL.cb.Blk_access_snoop;
   g_intf.Index_snoop              = P1_DL.cb.Index_snoop;
    
 end
//The port connections are made without the knowledge of the actual design. It is supposed to change later.
cache_multi_config_1 CMC (
                        g_intf.clk,
                        g_intf.PrWr[0],
                        g_intf.PrWr[1],
                        g_intf.PrWr[2],
                        g_intf.PrWr[3],
                        g_intf.PrRd[0],
                        g_intf.PrRd[1],
                        g_intf.PrRd[2],
                        g_intf.PrRd[3],
                        g_intf.Address[0],
                        g_intf.Address[1],
                        g_intf.Address[2],
                        g_intf.Address[3],
                        g_intf.Data_Bus[0],
                        g_intf.Data_Bus[1],
                        g_intf.Data_Bus[2],
                        g_intf.Data_Bus[3],
                        g_intf.CPU_stall[0],
                        g_intf.CPU_stall[1],
                        g_intf.CPU_stall[2],
                        g_intf.CPU_stall[3],
                        g_intf.Com_Bus_Req_proc_0,
                        g_intf.Com_Bus_Gnt_proc_0,
                        g_intf.Com_Bus_Req_snoop_0,
                        g_intf.Com_Bus_Gnt_snoop_0,
                        g_intf.Address_Com,
                        g_intf.Data_Bus_Com,
                        g_intf.Data_in_Bus,
                        g_intf.Mem_wr,
                        g_intf.Mem_oprn_abort,
                        g_intf.Mem_write_done,

);
 
arbiter a (
                        g_intf.Com_Bus_Req_proc_0,
			g_intf.Com_Bus_Req_proc_1,
			g_intf.Com_Bus_Req_proc_2,
			g_intf.Com_Bus_Req_proc_3,
			g_intf.Com_Bus_Req_proc_4,
			g_intf.Com_Bus_Req_proc_5,
			g_intf.Com_Bus_Req_proc_6,
			g_intf.Com_Bus_Req_proc_7,
			g_intf.Com_Bus_Req_snoop_0,
			g_intf.Com_Bus_Req_snoop_1,
			g_intf.Com_Bus_Req_snoop_2,
			g_intf.Com_Bus_Req_snoop_3,
			g_intf.Com_Bus_Gnt_proc_0,
			g_intf.Com_Bus_Gnt_proc_1,
			g_intf.Com_Bus_Gnt_proc_2,
			g_intf.Com_Bus_Gnt_proc_3,
			g_intf.Com_Bus_Gnt_proc_4,
			g_intf.Com_Bus_Gnt_proc_5,
			g_intf.Com_Bus_Gnt_proc_6,
			g_intf.Com_Bus_Gnt_proc_7,
			g_intf.Com_Bus_Gnt_snoop_0,
			g_intf.Com_Bus_Gnt_snoop_1,
			g_intf.Com_Bus_Gnt_snoop_2,
			g_intf.Com_Bus_Gnt_snoop_3,
			g_intf.Mem_snoop_req,
			g_intf.Mem_snoop_gnt
);

//Instantiate  Top level direct testcase object. Please consider that these
//test cases consider more than 1 scenario specified in Test Plan and As
//commented in TestCases.sv file
topReadMiss                     topReadMiss_inst;
topReadHit                      topReadHit_inst;
topWriteMiss                    topWriteMiss_inst;
topWriteHit                     topWriteHit_inst;
topReadMissReplaceModified      topReadMissReplaceModified_inst;
topWriteMissModifiedReplacement topWriteMissModifiedReplacement_inst;
topBusRdSnoop                   topBusRdSnoop_inst;
topBusRdXSnoop                  topBusRdXSnoop_inst;
topSnoopInvalidate              topSnoopInvalidate_inst;
reg[31:0] temp_addr;
reg[31:0] temp_data;
reg [7:0] test_no;

initial
 begin
   #20;
//Repeat the following tests for all cores using core variable in each testcase. For example core = 0 will test the cache in core 0 while checking the behavior of all other caches in the multi core environment
$display("Core 1 testing started");
$display("************** STARTING TOP LEVEL TESTING ******************"); 
   local_intf         = g_intf;
// top read miss
   test_no            = 1;
   topReadMiss_inst   = new();
   topReadMiss_inst.randomize() with 
    {Address          == 32'hdeadbeef &&
     Shared           == 1'b0 &&  
     Max_Resp_Delay   == 10;
     core             == 0;
     };
    temp_addr          = topReadMiss_inst.Address;

   topReadMiss_inst.testSimpleReadMiss(local_intf);
   //print lRU value
   temp_data          = P1_DL.cb.Cache_var[{temp_addr[`INDEX_MSB: `INDEX_LSB],2'b00}][`CACHE_DATA_MSB: `CACHE_DATA_LSB];
   
   #10;
   topReadMiss_inst.reset_DUT_inputs(local_intf); 
   #100;
//top read hit
   test_no            += 1;
   topReadHit_inst    = new();
   topReadHit_inst.randomize() with {Address == 32'hdeadbeef &&
   Max_Resp_Delay     == 30 &&
   core               == 0 &&
   last_data_stored   == temp_data;};
   topReadHit_inst.testSimpleReadHit(local_intf);
   #100;
   topReadHit_inst.reset_DUT_inputs(local_intf); 
   #100;

$display("Testing Read Miss Scenario using topReadMiss test case when other Cache contain data in shared state");
// top read miss
   test_no            += 1;
   topReadMiss_inst   = new();
   topReadMiss_inst.randomize() with 
    {Address          == 32'h00000000 &&
     Shared           == 1'b1 &&  
     core               == 0 &&
     Max_Resp_Delay   == 10;};
    temp_addr          = topReadMiss_inst.Address;

   topReadMiss_inst.testSimpleReadMiss(local_intf);
   //print lRU value
   temp_data          = P1_DL.cb.Cache_var[{temp_addr[`INDEX_MSB: `INDEX_LSB],2'b00}][`CACHE_DATA_MSB: `CACHE_DATA_LSB];
   
   #10;
   topReadMiss_inst.reset_DUT_inputs(local_intf); 
   #100;

//top write miss
   test_no            += 1;
   topWriteMiss_inst  = new();
   topWriteMiss_inst.randomize() with
  {Address            == 32'hbabecafe &&
   Max_Resp_Delay     == 10 &&
   core               == 0 &&
   wrData             == 32'hcafecafe; };
   topWriteMiss_inst.testWriteMiss(local_intf);
   #100;
   topWriteMiss_inst.reset_DUT_inputs(local_intf); 
   #100;
//top write hit on the block previously written so that the initial MESI state is MODIFIED
   test_no            += 1;
   topWriteHit_inst   = new();
   topWriteHit_inst.randomize() with
   {Address           == 32'hbabecafe &&
    Max_Resp_Delay    == 10 &&
    core               == 0 &&
    wrData            == 32'hbaabbaab;};
   topWriteHit_inst.testSimpleWriteHit(local_intf);
   #100;
   topWriteHit_inst.reset_DUT_inputs(local_intf);
   #100;
//top write hit on the block previously read so that the initial MESI state is EXCLUSIVE(Code not fixed so should give shared instead)
   test_no            += 1;
   topWriteHit_inst   = new();
   topWriteHit_inst.randomize() with
   {Address           == 32'hdeadbeef &&
    Max_Resp_Delay    == 10 &&
    core               == 0 &&
    wrData            == 32'hbaabbaab;};
   topWriteHit_inst.testSimpleWriteHit(local_intf);
   #100;
   topWriteHit_inst.reset_DUT_inputs(local_intf);
   #100;
//top read miss with replacement of a modified block required.
   //set up the DUT for this test by forcing data in all of the blocks of a
   //set to be written
  for(reg[15:0] i = 0; i< 4; i++) begin
   $display("***Setting up DUT Environment for ReadMiss Modified replacement test tag = %d **",i);
   topWriteMiss_inst   = new();
   topWriteMiss_inst.randomize() with
  {Address            == {i,14'd1,2'b00}  &&
   Max_Resp_Delay     == 10     &&
   core               == 0 &&
   wrData             == 32'hcafecafb+i; };

   topWriteMiss_inst.testWriteMiss(local_intf);
   #10;
   topWriteMiss_inst.reset_DUT_inputs(local_intf);
   #100;
  end//for
  #10;
   topWriteMiss_inst.reset_DUT_inputs(local_intf);
  #10;
   
   $display("***DONE Setting up DUT Environment for ReadMiss Modified replacement test");
   test_no            += 1;
   topReadMissReplaceModified_inst = new();
   topReadMissReplaceModified_inst.randomize() with
   {Address[31:0]       == {16'd5,14'd1,2'b00}  && 
    Max_Resp_Delay      == 10   && 
    core               == 0 &&
    Shared              == 0; 
   };
   
   topReadMissReplaceModified_inst.testReadMissReplaceModified(local_intf);
   #100;   
   topReadMissReplaceModified_inst.reset_DUT_inputs(local_intf);
   #100;
 //top write miss with replacement required for a modified block
   test_no            += 1;
   topWriteMissModifiedReplacement_inst                = new();
   topWriteMissModifiedReplacement_inst.Address        = {16'd100,14'd1,2'b00};
   topWriteMissModifiedReplacement_inst.Max_Resp_Delay = 10;
   topWriteMissModifiedReplacement_inst.wrData         = 32'hbeadbead;
   
   topWriteMissModifiedReplacement_inst.testWriteMissReplaceModified(local_intf);
   #100;
   topWriteMissModifiedReplacement_inst.reset_DUT_inputs(local_intf);
   #100;
 //top bus read snoop
   test_no += 1;
   topBusRdSnoop_inst                = new();
   topBusRdSnoop_inst.Address        = {16'd100,14'd1,2'b00};
   topBusRdSnoop_inst.Max_Resp_Delay = 10;
   topBusRdSnoop_inst.core           = 0;
   fork
   topBusRdSnoop_inst.testBusRdSnoop(local_intf);
   begin
     #200;
     $display("Last Test Timedout.. Moving on");
   end
   join_any;
   disable fork;
   #100;
   
   topBusRdSnoop_inst.reset_DUT_inputs(local_intf);
   #100;
 //top bus read with an intent to write snoop
   test_no += 1;
   topBusRdXSnoop_inst                = new();
   topBusRdXSnoop_inst.Address        =  {16'd100,14'd1,2'b00};
   topBusRdXSnoop_inst.Max_Resp_Delay = 10;
   topBusRdXSnoop_inst.core           = 0;
   fork
     topBusRdXSnoop_inst.testBusRdXSnoop(local_intf);
     begin
      #200;
      $display("Last Test Timedout.. Moving on");
     end
   join_any;
   disable fork;
   #100;
//top Snoop Invalidate test
   topSnoopInvalidate_inst                = new();
   topSnoopInvalidate_inst.reset_DUT_inputs(local_intf);
   topSnoopInvalidate_inst.Address        = {16'd100,14'd1,2'b00};
   topSnoopInvalidate_inst.Max_Resp_Delay = 10;
   topSnoopInvalidate_inst.core           = 0;
   topSnoopInvalidate_inst.testInvalidation(local_intf);
   #100;
   $finish;       


 end 
 

 


always @(posedge g_intf.clk)

   g_intf.check_UndefinedBehavior(0);
endmodule
