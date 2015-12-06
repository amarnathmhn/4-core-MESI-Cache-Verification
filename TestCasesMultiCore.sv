//This document contains the Test Bench to verify Multi Core (4 Core) L1 MESI Cache..
//NOTE: All the signals to the DUT/Arbiter are accessed via an sv interface. When the DUT and Arbiter Designs are made available, 
//they shall be connected to the interface.

`timescale 1ps/1ps
//Include defines.sv file containing all Macros
//`include "defines.sv"
`include "interfacesMultiCore.sv"
//enum type for MESI States
typedef enum bit[1:0] {INVALID, SHARED, EXCLUSIVE, MODIFIED} mesiStateType;
typedef enum bit {PrRd,PrWr} commandType;
//Define a base class that contains repeatedly used waiting tasks and fields.
class baseTestClass;
   
  
  string status ="PASSED"; 
  
  rand reg[`ADDRESSSIZE - 1 : 0] Address;
   
   constraint c_Address { Address inside {[32'h00000000:32'hffffffff]};}

   //Delay until Cache Wrapper responds to any stimulus either from Proc or Arbiter or Memory. Measured in cycles of clk
   rand int Max_Resp_Delay;
   rand bit Shared = 0;
   rand reg [3:0] core = 0;
   constraint c_max_delay {Max_Resp_Delay inside {[6:50]};}
   int delay;
   reg [2:0] expected_lru_var;
   reg [1:0] expected_line_to_replace;
   
   
   //Task to wait and check for Com_Bus_Req_proc_0 and CPU_Stall to be asserted
   virtual task check_ComBusReqproc_CPUStall_assert(virtual interface globalInterface sintf,input [3:0] core);
      delay = 0;
      fork
        begin 
         while(delay <= Max_Resp_Delay) begin
           @(posedge sintf.clk);
           delay += 1; 
         end 
        end
        begin 
           wait(sintf.Com_Bus_Req_proc_0 && sintf.CPU_stall[core]);
        end
      join_any
      disable fork;
    //Check if Com_Bus_Req_proc_0 is asserted  
    assert(sintf.Com_Bus_Req_proc_0) $display("SUCCESS:: Com_Bus_Req_Proc and CPU_stall are asserted within timeout after PrRd/PrWr is asserted");
    else begin $display("BUG:: Com_Bus_Req_Proc or CPU_stall is not asserted after PrRd/PrWr");
      status = "FAILED";
    end
    return;
   endtask : check_ComBusReqproc_CPUStall_assert
   
   //Task to wait and check for Com_Bus_Req_snoop_0 to be asserted
   virtual task check_ComBusReqSnoop_assert(virtual interface globalInterface sintf,input [3:0] core);
      delay = 0;
      fork
        begin 
         while(delay <= Max_Resp_Delay) begin
           @(posedge sintf.clk);
           delay += 1; 
         end 
        end
        begin 
           wait(sintf.Com_Bus_Req_snoop_0);
        end
      join_any
      disable fork;
    //Check if Com_Bus_Req_ is asserted  
    assert(sintf.Com_Bus_Req_snoop_0) $display("SUCCESS:: Com_Bus_Req_snoop_0 is asserted within timeout after BusRd/BusRdX is asserted");
    else begin $display("BUG:: Com_Bus_Req_snoop_0 is not asserted after BusRd/BusRdX");
     status = "FAILED";
    end
   endtask : check_ComBusReqSnoop_assert
   
   
   //Task to wait and check for Com_Bus_Req_snoop_0 to be deasserted
   virtual task check_ComBusReqSnoop_deassert(virtual interface globalInterface sintf,input [3:0] core);
      delay = 0;
      fork
        begin 
         while(delay <= Max_Resp_Delay) begin
           @(posedge sintf.clk);
           delay += 1; 
         end 
        end
        begin 
           wait(!sintf.Com_Bus_Req_snoop_0);
        end
      join_any
      disable fork;
    //Check if Com_Bus_Req_ is asserted  
    assert(!sintf.Com_Bus_Req_snoop_0) $display("SUCCESS:: Com_Bus_Req_snoop_0 is deasserted within timeout after BusRd is asserted");
    else $warning(1,"TEST:  Checker: Com_Bus_Req_snoop_0 is not deasserted after BusRd", $time);
   endtask : check_ComBusReqSnoop_deassert
 
   //Task to wait for Com_Bus_Req_proc_0 and CPU_Stall to be deasserted
   virtual task check_ComBusReqproc_CPUStall_deaassert(virtual interface globalInterface sintf,input [3:0] core);
      delay = 0;
      fork
        begin 
         while(delay <= Max_Resp_Delay) begin
           @(posedge sintf.clk);
           delay += 1; 
         end 
        end
        begin 
           wait(!sintf.Com_Bus_Req_proc_0 && !sintf.CPU_stall[core]);
        end
      join_any
      disable fork;
      assert(!sintf.CPU_stall[core]) $display("SUCCESS:: CPU_stall De-Asserted");
      else  begin $display("BUG:: CPU_stall not deasserted");
       status = "FAILED";
      end
      assert(!sintf.Com_Bus_Req_proc_0) $display("SUCCESS:: Com_Bus_Req_proc_0 De-Asserted");
      else begin $display("BUG:: Com_Bus_Req_proc_0 not deasserted");
       status = "FAILED";
      end
   endtask : check_ComBusReqproc_CPUStall_deaassert
 
    //Task to wait for Com Bus Gnt Proc to be asserted
    virtual task check_ComBusGntproc_assert(virtual interface globalInterface sintf,input [3:0] core);
    delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
      end
      begin 
         wait(sintf.Com_Bus_Gnt_proc_0);
      end
    join_any
    disable fork;
    return;
   endtask : check_ComBusGntproc_assert
   //Task to wait for BusRd is raised.
   virtual task check_BusRd_assert(virtual interface globalInterface sintf,input [3:0] core);
    delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
      end
      begin 
         wait(sintf.BusRd);
      end
    join_any
    assert(sintf.BusRd) $display("SUCCESS:: BusRd Asserted Properly ");
    disable fork;
    return;
   endtask : check_BusRd_assert
   
  //Task to wait till address placed by cache on Address_Com bus
  virtual task check_Address_Com_load(virtual interface globalInterface sintf,input [3:0] core);
    delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
      end
      begin 
         wait(sintf.Address[core][31:2] == sintf.Address_Com[31:2]);
      end
    join_any
    disable fork;
    
    assert(sintf.Address[core][31:2] == sintf.Address_Com[31:2] &&
           sintf.Address_Com[1:0] == 0) $display("SUCCESS:: Correct Address is placed on Address_Com Bus"); 
    else $warning(1," Checker: Address is either not placed on Address_Com bus or wrong address is placed",$time);
    return;
  endtask : check_Address_Com_load

//Task to wait till CPU_stall is de-asserted
virtual task check_CPU_stall_deassert(virtual interface globalInterface sintf,input [3:0] core);
     delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
       end
      begin 
         wait(!sintf.CPU_stall[core]);
      end
    join_any
    disable fork;
    assert(!sintf.CPU_stall[core]) $display("SUCCESS:: CPU_stall is De-asserted"); 
    else begin $display("BUG:: CPU stall not de-asserted ");
     status = "FAILED";
    end
  endtask : check_CPU_stall_deassert
  
  //Task to wait till BusRdX is asserted
 virtual task check_BusRdX_assert(virtual interface globalInterface sintf,input [3:0] core);
     delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
       end
      begin 
         wait(sintf.BusRdX);
      end
    join_any
    disable fork;
    assert(sintf.BusRdX) $display("SUCCESS:: BusRdX is asserted within timeout");
    else $display("BUG:: BusRdX  not asserted within timeout");
  endtask : check_BusRdX_assert
  
  
  //Task to wait till BusRdX is asserted
 virtual  task check_MemOprnAbrt_assert(virtual interface globalInterface sintf);
     delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
       end
      begin 
         wait(sintf.Mem_oprn_abort);
      end
    join_any
    disable fork;
    assert(sintf.Mem_oprn_abort)
    else $warning(1," Checker:  Mem_oprn_abort not asserted",$time);
  endtask : check_MemOprnAbrt_assert
 
// Check for Shared to be asserted
virtual task check_Shared_assert(virtual interface globalInterface sintf);
   delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
       end
      begin 
         wait(sintf.Shared);
      end
    join_any
    disable fork;
    assert(sintf.Shared)
    else begin $display("BUG:: Shared not asserted");
      status = "FAILED"; 
    end
endtask : check_Shared_assert

// Check for Invalidate to be asserted
virtual task check_Invalidate_assert(virtual interface globalInterface sintf);
   delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
       end
      begin 
         @(posedge sintf.Invalidate);
      end
    join_any
    disable fork;
    assert(sintf.Invalidate) $display("SUCCESS:: Invalidate asserted properly");
    else begin $display("BUG:: Invalidate not asserted");
       status = "FAILED";
    end
endtask : check_Invalidate_assert

// Check for Mem_wr to be asserted
virtual task check_MemWr_assert(virtual interface globalInterface sintf);
   delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
       end
      begin 
         wait(sintf.Mem_wr);
      end
    join_any
    disable fork;
    assert(sintf.Mem_wr)
    else $warning(1," Checker:  Invalidate not asserted",$time);
endtask : check_MemWr_assert

// Check for Data in Bus to be asserted
virtual task check_DataInBus_assert(virtual interface globalInterface sintf);
   delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
       end
      begin 
         wait(sintf.Data_in_Bus);
      end
    join_any
    disable fork;
    assert(sintf.Invalidate)
    else $warning(1," Checker:  Data in Bus not asserted",$time);
endtask : check_DataInBus_assert

//Task to wait till Single Bit is asserted! Alas Not working...Must find a new strategy to make this work. For now it shall  be here!
 virtual task check_singleBit_assert(input sbit, virtual interface
globalInterface sintf ,input [3:0] core );
     delay = 0;
    fork
      begin
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         $display("delay = %d, Max_Resp_Delay = %d, BIT = %d", delay, Max_Resp_Delay, sbit);
         delay += 1; 
       end 
       end
      begin 
         wait(sbit);
      end
    join_any
    disable fork;
    assert(sbit)
    else $warning(1," %m : Checker:  Required Bit Field not asserted",$time);
  endtask : check_singleBit_assert
  
  //Task to wait till Bus is valid..same fate as above
  virtual task check_bus_valid(input logic [31:0] BUS, virtual interface globalInterface sintf );
    delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
       end
      begin 
         wait(BUS != 32'hz);
      end
    join_any
    disable fork;
    assert(BUS != 32'hz)
    else $warning(1," %m: Checker:  The BUS contains invalid value",$time);
  endtask : check_bus_valid

 //Task to wait till DataBusCom is valid.
  virtual task check_DataBusCom_valid(virtual interface globalInterface sintf,input[31:0] data);
    delay = 0;
    fork
      begin 
       while(delay <= Max_Resp_Delay) begin
         @(posedge sintf.clk);
         delay += 1; 
       end 
       end
      begin 
         wait(sintf.ClkBlk.Data_Bus_Com == data);
      end
    join_any
    disable fork;
    assert(sintf.ClkBlk.Data_Bus_Com == data) $display("SUCCESS:: Data placed on ClkBlk.Data_Bus_Com matches input data");
    else $display("BUG:: ClkBlk.Data_Bus_Com contains incorrect data");
  endtask : check_DataBusCom_valid



  //Task to check actual and expected next MESI states
    virtual task check_MESI_fsm(virtual interface globalInterface sintf, input
mesiStateType expectedMesiState,input [3:0] core);
    mesiStateType mst;
    delay = 0;
    while(sintf.Updated_MESI_state_proc[core] != expectedMesiState)begin
       delay += 1;
       @(posedge sintf.clk);
       if(delay >= Max_Resp_Delay)
        break;
     end
     mst = mesiStateType'(sintf.Updated_MESI_state_proc[core]);
    assert(sintf.Updated_MESI_state_proc[core] == expectedMesiState) $display("SUCCESS:: Next MESI State consistent with Expected MESI State: Expected = %s, Actual = %s",expectedMesiState.name(),mst.name());
    else begin $display("BUG:: Next MESI State does not match with expected next MESI state: Expected = %s, Actual = %s",expectedMesiState.name(),mst.name());
     status = "FAILED";
    end
  endtask : check_MESI_fsm

  //Task to check if Data Bus is set with valid data
  virtual task check_DataBus_valid(virtual interface globalInterface sintf,input [31:0] data,input [3:0] core );
    delay = 0;
    while(sintf.Data_Bus[core] != data || data=== 32'hz || sintf.Data_Bus[core] === 32'hZ) begin
         delay += 1; 
         @(posedge sintf.clk);
         if(delay >= Max_Resp_Delay)
           break;
    end
    assert(sintf.Data_Bus[core] === data) $display("SUCCESS:: Correct data is placed by cache on Data_Bus to the proc: Data Bus = %x, ClkBlk.Data_Bus_Com = %x",sintf.Data_Bus[core],data);
    else begin $display("BUG:: The Data_Bus contains invalid value: Data_Bus = %x, Expected Data = %x",sintf.Data_Bus[core],data);
      status = "FAILED";
    end
  endtask : check_DataBus_valid

 //Task to check if Memory is loaded with correct data. Need to fix. Doesnot take correct data
 virtual task check_CacheVar_Data(virtual interface globalInterface sintf, input [31:0] data,input [31:0] Address,input [3:0] core);
 reg [31:0] temp_data;   
    delay = 0;
      while(sintf.Cache_var[core][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[core]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB] != data ) begin
           delay += 1;
           if(delay >= Max_Resp_Delay) begin
              $display("WARNING:: Timeout for Data to be stored in the Cache");
              break;
           end
           @(posedge sintf.clk);
      end
    temp_data = sintf.Cache_var[core][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[core]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
    assert(temp_data === data) $display("SUCCESS:: Data stored in Cache matches with Expected Data: Stored Data = %x , Expected Data = %x",temp_data,data);
    else $display("BUG:: Incorrect data is stored in the Cache: Stored Data = %x , Expected Data = %x ",$time,temp_data, data);
 endtask :  check_CacheVar_Data
  //Task to reset signals after each operation
  virtual task reset_DUT_inputs(virtual interface globalInterface dif);

        dif.Address_Com_reg 			<= 32'hZ;
	dif.ClkBlk.Data_Bus_Com 		<= 32'hZ;
	dif.ClkBlk.Data_in_Bus	 		<= 32'hZ;	
        for(int k=0; k < 8; k++) begin
	  dif.Data_Bus_reg[k]                	<= 32'hZ;
          dif.ClkBlk.PrRd[k]                         <= 0;
          dif.ClkBlk.PrWr[k]                         <= 0;
          dif.ClkBlk.Address[k]                      <= 32'hz;
        end
        //dif.BusRd_reg                           <= 1'bz;
        //dif.BusRdX_reg                          <= 1'bz;
        dif.Mem_snoop_req               = 0;
        dif.failed                              <= 1'b0;
 
  endtask : reset_DUT_inputs

 //task to determine LRU var state expected.
  virtual function determine_LRU_var_exp(input logic [1:0] line_no, ref logic [2:0] next_state);
    begin
       case(line_no)
          2'b00: next_state[2:1] = 2'b11;
          2'b01: next_state[2:1] = 2'b10;
          2'b10: begin next_state[2:2] =  1'b0; next_state[0:0] = 1'b1; end
          2'b11: begin next_state[2:2] =  1'b0; next_state[0:0] = 1'b0; end
       endcase
    end
  endfunction

 //task to determine LRU line to replace
  virtual function logic [1:0] determine_LineToBeReplaced_LRU(input logic[2:0] state);
    begin
      if(!state[2:2]) begin
          if(!state[1:1])
            return 2'b00;
          else return 2'b01; 
      end 
      else begin
          if(!state[0:0]) return 2'b10;
          else return 2'b11;
      end
    end
  endfunction : determine_LineToBeReplaced_LRU


endclass : baseTestClass 


//Test cases to verify top level functionality 
// A Simple Directed Testcase for Scenario  Read Miss with no copy available in other Caches. Verified at the top level
class topReadMiss extends baseTestClass;
   reg[31:0] DataWrittenByMem;
  //Drive DUT ports with this
  task drive(virtual globalInterface sintf);
    for(int k=0; k <= 7; k++) begin
      
         if(k != core) begin
         sintf.ClkBlk.PrRd[core] <= 0;
         sintf.ClkBlk.PrWr[core] <= 0;
         end
    
    end
    sintf.ClkBlk.PrRd[core] <= 1;
    sintf.ClkBlk.PrWr[core] <= 0;
     
    sintf.ClkBlk.Address[core] <= Address;
     //sintf.ClkBlk.Shared <= Shared;
     expected_lru_var = 3'bxxx; 
  endtask :drive 

  task check(virtual globalInterface sintf);
     var DataWrittenByMem =  32'hBABABABA;
     //Check for behavior
    //Com_Bus_Req_proc_0 and CPU_stall must be made high
     check_ComBusReqproc_CPUStall_assert(sintf,core);
    //Wait until arbiter grants access
     check_ComBusGntproc_assert(sintf,core);
     //check_ComBusGntproc_assert(sintf);
    
    //Check if the Cache raises BusRd
    check_BusRd_assert(sintf,core);
    
     //Snoop side activity
   
    //Wait until cache places Address in Address_Com bus
    check_Address_Com_load(sintf,core);
    
    //Main Memory requests for Bus Access. Wait for Bus Access Grant by the arbiter
    sintf.Mem_snoop_req = 1;
    wait(sintf.Mem_snoop_gnt == 1);
    sintf.Mem_snoop_req               = 0;
    //Main Memory puts data on the ClkBlk.Data_Bus_Com and raises Data_in_Bus
    sintf.ClkBlk.Data_Bus_Com <= DataWrittenByMem;
    sintf.ClkBlk.Data_in_Bus <= 1;
    //Check if MESI State is properly assigned to block corresponding to the Address given
    if(sintf.Shared == 1)  
      check_MESI_fsm(sintf,SHARED,core);
    else if (sintf.Shared == 0)
      check_MESI_fsm(sintf,EXCLUSIVE,core);
       
    //Check if Memory is loaded with Correct Data
    check_CacheVar_Data(sintf,DataWrittenByMem,Address,core); 
    //Check if LRU Value is properly assigned
    //wait(sintf.Blk_access_proc != 2'bZZ && 
    //     sintf.Blk_access_proc != 2'bxx)
    $display("SVDEBUG:: Block Accessed is %d",sintf.Blk_access_proc[core]);
    repeat(Max_Resp_Delay) @sintf.clk;
    determine_LRU_var_exp(sintf.Blk_access_proc[core],expected_lru_var);
    if(sintf.Blk_access_proc[core] == 0 || sintf.Blk_access_proc[core] == 1 ) begin
      assert(expected_lru_var[2:1] == sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]][2:1]) $display("SUCCESS:: Line accessed = %b, Expected LRU Var = %b, Actual LRY Var = %b ",sintf.Blk_access_proc[core],expected_lru_var,sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]]);
      else begin $display("BUG:: Expected lru var = %b, actual lru var = %b",expected_lru_var,sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]]); 
      end
    end
    else if (sintf.Blk_access_proc[core] == 2 || sintf.Blk_access_proc[core] == 3) begin
      assert({expected_lru_var[2],expected_lru_var[0]} == {sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]][2],sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]][0]}) $display("SUCCESS:: Line accessed = %b, Expected LRU Var = %b, Actual LRY Var = %b ",sintf.Blk_access_proc[core],expected_lru_var,sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]]);
      else begin $display("BUG:: Expected lru var = %b, actual lru var = %b",expected_lru_var,sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]]); 
      end
    end
    //Check if Data_Bus is valid with the data
    check_DataBus_valid(sintf,sintf.ClkBlk.Data_Bus_Com,core);
    
    //Check if CPU_stall and Com_Bus_Req_proc is de-asserted on asserting Data_in_Bus
    check_CPU_stall_deassert(sintf,core);
    check_ComBusReqproc_CPUStall_deaassert(sintf,core);
    repeat(Max_Resp_Delay) @sintf.clk;
  endtask : check
//   Creates the simple Read stimulus and drives it to the DUT and checks for the behavior. Take the single Top Level Cache interface as input.
   task testSimpleReadMiss(virtual globalInterface sintf);
      
     $display("\n****** Test topReadMiss Started for core = %d ****** ",core); 
     
      drive(sintf); 
      check(sintf);
    repeat(Max_Resp_Delay) @sintf.clk;
    $display("****** Test topReadMiss Done Status = %s ******\n",!sintf.failed?status:"FAILED"); 
   endtask : testSimpleReadMiss
endclass : topReadMiss

//A simple test for Scenario: Read Miss and Block is available in other Caches
class topReadMissSnoopHit extends baseTestClass;
   reg[31:0] DataWrittenByMem;
  //Drive DUT ports with this
  task drive(virtual globalInterface sintf);
    for(int k=0; k <= 7; k++) begin
      
         if(k != core) begin
         sintf.ClkBlk.PrRd[core] <= 0;
         sintf.ClkBlk.PrWr[core] <= 0;
         end
    
    end
    sintf.ClkBlk.PrRd[core] <= 1;
    sintf.ClkBlk.PrWr[core] <= 0;
     
    sintf.ClkBlk.Address[core] <= Address;
     //sintf.ClkBlk.Shared <= Shared;
     expected_lru_var = 3'bxxx; 
  endtask :drive 

   task check(virtual globalInterface sintf);
     var DataWrittenByMem =  32'hBABABABA;
     //Check for behavior
    //Com_Bus_Req_proc_0 and CPU_stall must be made high
     check_ComBusReqproc_CPUStall_assert(sintf,core);
    //Wait until arbiter grants access
     check_ComBusGntproc_assert(sintf,core);
     //check_ComBusGntproc_assert(sintf);
    
    //Check if the Cache raises BusRd
    check_BusRd_assert(sintf,core);
    
     //Snoop side activity
   
    //Wait until cache places Address in Address_Com bus
    check_Address_Com_load(sintf,core);
    //wait until lower memory or other cache places the data and asserts data_in_bus signal
    $display("Waiting for Data_in_bus");
    wait(sintf.Data_in_Bus == 1);
    //Check if MESI State is properly assigned to block corresponding to the Address given
    if(sintf.Shared == 1)  
      check_MESI_fsm(sintf,SHARED,core);
    else if (sintf.Shared == 0)      check_MESI_fsm(sintf,EXCLUSIVE,core);
       
    //Check if Memory is loaded with Correct Data
    check_CacheVar_Data(sintf,DataWrittenByMem,Address,core); 
    //Check if LRU Value is properly assigned
    //wait(sintf.Blk_access_proc != 2'bZZ && 
    //     sintf.Blk_access_proc != 2'bxx)
    $display("SVDEBUG:: Block Accessed is %d",sintf.Blk_access_proc[core]);
    repeat(Max_Resp_Delay) @sintf.clk;
    determine_LRU_var_exp(sintf.Blk_access_proc[core],expected_lru_var);
    if(sintf.Blk_access_proc[core] == 0 || sintf.Blk_access_proc[core] == 1 ) begin
      assert(expected_lru_var[2:1] == sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]][2:1]) $display("SUCCESS:: Line accessed = %b, Expected LRU Var = %b, Actual LRY Var = %b ",sintf.Blk_access_proc[core],expected_lru_var,sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]]);
      else begin $display("BUG:: Expected lru var = %b, actual lru var = %b",expected_lru_var,sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]]); 
      end
    end
    else if (sintf.Blk_access_proc[core] == 2 || sintf.Blk_access_proc[core] == 3) begin
      assert({expected_lru_var[2],expected_lru_var[0]} == {sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]][2],sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]][0]}) $display("SUCCESS:: Line accessed = %b, Expected LRU Var = %b, Actual LRY Var = %b ",sintf.Blk_access_proc[core],expected_lru_var,sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]]);
      else begin $display("BUG:: Expected lru var = %b, actual lru var = %b",expected_lru_var,sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]]); 
      end
    end
    //Check if Data_Bus is valid with the data
    check_DataBus_valid(sintf,sintf.ClkBlk.Data_Bus_Com,core);
    
    //Check if CPU_stall and Com_Bus_Req_proc is de-asserted on asserting Data_in_Bus
    check_CPU_stall_deassert(sintf,core);
    check_ComBusReqproc_CPUStall_deaassert(sintf,core);
    repeat(Max_Resp_Delay) @sintf.clk;
  endtask : check

  //   Creates the simple Read stimulus and drives it to the DUT and checks for the behavior. Take the single Top Level Cache interface as input.
   task testSimpleReadMissWithSnoopHit(virtual globalInterface sintf);
      
     $display("\n****** Test topReadMissSnoopHit Started for core = %d ****** ",core); 
     
      drive(sintf); 
      check(sintf);
    repeat(Max_Resp_Delay) @sintf.clk;
    $display("****** Test topReadMissSnoopHit Done Status = %s ******\n",!sintf.failed?status:"FAILED"); 
   endtask : testSimpleReadMissWithSnoopHit
  
endclass : topReadMissSnoopHit
// A Simple Directed Testcase for Scenario  :Read Hit. Verified at the top level
class topReadHit extends baseTestClass;
   rand reg[31:0] last_data_stored;
   task testSimpleReadHit(virtual interface globalInterface sintf);
      $display("\n****** Test topReadHit Started ****** "); 
      
      //Do a Read Hit
      sintf.ClkBlk.Address[core] <= Address;
      sintf.ClkBlk.PrRd[core]    <= 1;
      sintf.ClkBlk.PrWr[core]    <= 0;
      $display("Data to be checked against %x",last_data_stored);
      //Check if Data is placed on Data_Bus
      check_DataBus_valid(sintf,last_data_stored,core); 
      
      //Check if CPU_stall and Com_Bus_Req_proc_0 is deasserted
      check_ComBusReqproc_CPUStall_deaassert(sintf,core);
      $display("****** Test topReadHit Done Status = %s ******\n",!sintf.failed?status:"FAILED"); 
       
   endtask : testSimpleReadHit
   

endclass : topReadHit


// A Simple Directed Testcase for Scenario  Read Miss with replacement required for a Modified block. Tests until the dirty block is written back to memory.

class topReadMissReplaceModified extends baseTestClass;
     topReadMiss topReadMiss_inst; 
     rand reg [`ADDRESSSIZE - 1 : 0] Address;
     constraint c_Address { Address inside {[32'h00000000:32'hffffffff]};}
     reg[1:0]   lineToBeRepl;
     reg [15:0] TagToBeRepl;
     reg [14:0] IndexToBeRepl;
     reg [31:0] DataToBeWrittenBack;
     mesiStateType actualMesi;
     //Delay until Cache Wrapper responds to any stimulus either from Proc or Arbiter or Memory. Measured in cycles of clk
     int delay;
     task testReadMissReplaceModified(virtual interface globalInterface sintf);
      
      $display("\n****** Test topReadMissReplaceModified Started ****** "); 
      $display("Processor Read Attempt is made for Address = %x",Address);
       
      sintf.ClkBlk.Address[core] <= Address;
      sintf.ClkBlk.PrRd[core]    <= 1;
      sintf.ClkBlk.PrWr[core]    <= 0;
      //sintf.Shared  <= Shared;
      // Check for behavior
      //Com_Bus_Req_proc_0 and CPU_stall must be made high
      check_ComBusReqproc_CPUStall_assert(sintf,core);
      lineToBeRepl  =  determine_LineToBeReplaced_LRU(sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]]);
      IndexToBeRepl =  Address[`INDEX_MSB:`INDEX_LSB];
      TagToBeRepl   =  sintf.Cache_proc_contr[core][{IndexToBeRepl,lineToBeRepl}][`CACHE_TAG_MSB: `CACHE_TAG_LSB];
      //Since free block is not available, replacement of the modified block has to be carried out. Wait for bus access grant from arbiter
      wait(sintf.Com_Bus_Gnt_proc_0);
      //Wait till Address com bus is loaded with Address of the Block to be replaced
      $display("Address of the Block to be replaced = %x, Data at that location = %x",{TagToBeRepl,IndexToBeRepl,2'b00},sintf.Cache_var[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_DATA_MSB:`CACHE_DATA_LSB]); 
      delay = 0;
     fork
        begin 
         while(delay <= Max_Resp_Delay) begin
           @(posedge sintf.clk);
           delay += 1; 
         end 
        end
        begin 
           wait(sintf.Address_Com[31:2] == {sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_TAG_MSB:`CACHE_TAG_LSB],Address[`INDEX_MSB:`INDEX_LSB]});
        end
      join_any
      disable fork;
     
      
      assert(sintf.Address_Com[31:2] == {sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_TAG_MSB:`CACHE_TAG_LSB],Address[`INDEX_MSB:`INDEX_LSB]} ) $display("SUCCESS::Address_Com is loaded with correct address of the block to be replaced");
      else begin $display("BUG:: Expected Address_Com = %x, Actual Address_Com = %x",{sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_TAG_MSB:`CACHE_TAG_LSB],Address[`INDEX_MSB:`INDEX_LSB],2'b00},sintf.Address_Com[31:0]);
      status = "FAILED";
      end
      $display("SUCCESS::  Expected Address_Com = %x, Actual Address_Com = %x",{sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_TAG_MSB:`CACHE_TAG_LSB],Address[`INDEX_MSB:`INDEX_LSB],2'b00},sintf.Address_Com[31:0]);
      //Wait till Mem_wr signal is made high
      delay = 0;
      fork
        begin 
         while(delay <= Max_Resp_Delay) begin
           @(posedge sintf.clk);
           delay += 1; 
         end 
        end
        begin 
           wait(sintf.Mem_wr);
        end
      join_any
      disable fork;
      
      assert(sintf.Mem_wr) $display("SUCCESS:: Mem_wr is asserted");
      else begin $display("BUG:: Mem_wr is not asserted", $time);    
        status = "FAILED";
      end
      check_DataBusCom_valid(sintf,sintf.Cache_var[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_DATA_MSB:`CACHE_DATA_LSB]);
      //Memory asserts Memory Wr Done
      sintf.Mem_write_done = 1;
     //free block is now available. Cache will do free block operations for read miss.
     repeat(2) @(posedge sintf.clk);   
     sintf.Mem_write_done = 0;
     repeat(2) @(posedge sintf.clk);   
      
     wait(sintf.BusRd);
     sintf.Mem_snoop_req = 1;
     wait(sintf.Mem_snoop_gnt);
     @(posedge sintf.clk);
     sintf.ClkBlk.Data_Bus_Com <= 32'hdadadada;
     sintf.ClkBlk.Data_in_Bus  <= 1;
     repeat(4) @(posedge sintf.clk);
     actualMesi = mesiStateType'(sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
     if(Shared == 0) begin
         assert(sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] == EXCLUSIVE)
         else begin $display("BUG: Updated MESI State = %s Does not match with Expected state = EXCLUSIVE",actualMesi.name());
           status = "FAILED";
         end
     end
     else if (Shared == 1) begin
         assert(sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] == SHARED)
         else begin $display("BUG: Updated MESI State = %x Does not match with Expected state = SHARED",sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
          status = "FAILED";
         end
     end
      
     $display("****** Test topReadMissReplaceModified Done Status = %s ******\n",!sintf.failed?status:"FAILED"); 
     endtask : testReadMissReplaceModified

endclass : topReadMissReplaceModified


//A simple directed test for scenarios  This will verify the basic write Miss operation with free block available
class topWriteMiss extends baseTestClass;
   
    //data to be written
   rand int wrData;
   constraint c_wrData  {wrData inside {[32'h00000000:32'hffffffff]};}
   task testWriteMiss(virtual interface globalInterface sintf);
        begin
         $display("\n****** Test topWriteMiss Started ****** "); 
          sintf.ClkBlk.PrWr[core]      <= 1; 
          sintf.ClkBlk.PrRd[core]      <= 0;
          sintf.ClkBlk.Address[core]   <= Address; 
          sintf.Data_Bus_reg[core]  = wrData;
         $display("Processor Write Attempt is made for Address = %x with Data = %x",Address, wrData);
          //wait for CPU_stall and Com_Bus_Gnt_proc to be made high
          check_ComBusReqproc_CPUStall_assert(sintf,core);

          check_ComBusGntproc_assert(sintf,core);

          check_BusRdX_assert(sintf,core);

          check_Address_Com_load(sintf,core);

          //Lower Memory or Other Cache Loads Data on the Bus
          sintf.ClkBlk.Data_in_Bus <= 1;

          sintf.ClkBlk.Data_Bus_Com <= 32'hABACABAB;
           
          //Check if MESI State is properly assigned to block corresponding to the Address given
          check_MESI_fsm(sintf,MODIFIED,core);
          //Check if Data is correctly written into the cache
          check_CacheVar_Data(sintf,wrData,Address,core); 
          
          //check_DataBus_valid(sintf,wrData); 
          
          check_ComBusReqproc_CPUStall_deaassert(sintf,core);
          repeat(Max_Resp_Delay) @(posedge sintf.clk);
          $display("****** Test topWriteMiss Done Status = %s ******\n",!sintf.failed?status:"FAILED"); 
        end 
   endtask : testWriteMiss

endclass: topWriteMiss

//A simple directed test for scenarios  This will verify write Miss Operation with no free block available. Tests until block is written back into the Cache.
class topWriteMissModifiedReplacement extends baseTestClass;
   //data to be written
   rand int wrData;
   constraint c_wrData  {wrData inside {[32'h00000000:32'hffffffff]};}
   reg [1:0]  lineToBeRepl;
   reg [15:0] TagToBeRepl;
   reg [14:0] IndexToBeRepl;
   reg [31:0] DataToBeWrittenBack;
   mesiStateType actualMesi;
   task testWriteMissReplaceModified(virtual interface globalInterface sintf);
        begin
         $display("\n****** Test topWriteMissModifiedReplacement Started ****** "); 
          sintf.ClkBlk.PrWr[core]      <= 1; 
          sintf.ClkBlk.PrRd[core]      <= 0;
          sintf.ClkBlk.Address[core]   <= Address; 
          sintf.Data_Bus_reg[core]  = wrData;

    $display("Processor Write Attempt is made for Address = %x with Data = %x",Address, wrData);
          // Check for behavior
      //Com_Bus_Req_proc_0 and CPU_stall must be made high
      check_ComBusReqproc_CPUStall_assert(sintf,core);

      //Since free block is not available, replacement of the modified block has to be carried out. Wait for bus access grant from arbiter
      wait(sintf.Com_Bus_Gnt_proc_0);
            
      //Wait till Address com bus is loaded with Address of the Block to be replaced
      lineToBeRepl    =  determine_LineToBeReplaced_LRU(sintf.LRU_var[core][Address[`INDEX_MSB:`INDEX_LSB]]);
      TagToBeRepl     =  sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_TAG_MSB:`CACHE_TAG_LSB];
      IndexToBeRepl   =  Address[`INDEX_MSB:`INDEX_LSB];
      $display("MESI State of the Block To Be Replaced is %x",sintf.Cache_proc_contr[core][{IndexToBeRepl,lineToBeRepl}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
      DataToBeWrittenBack =  sintf.Cache_var[core][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[core]}][`CACHE_DATA_MSB:`CACHE_DATA_LSB];
      assert(lineToBeRepl == sintf.LRU_replacement_proc[core]) $display("SUCCESS:: LRU Replacemet Proc = %x matches with Expected Line To Be Replaced = %x",sintf.LRU_replacement_proc[core],lineToBeRepl);
      else begin $display("BUG:: LRU Replacemet Proc = %x matches with Expected Line To Be Replaced = %x",sintf.LRU_replacement_proc[core],lineToBeRepl); 
        status = "FAILED";
      end
      
      $display("Line To Be Replaced = %x, Address of the Block to be replaced = %x, Data at that location = %x",lineToBeRepl,{TagToBeRepl,IndexToBeRepl,2'b00},DataToBeWrittenBack); 
     delay = 0;
     fork
        begin 
         while(delay <= Max_Resp_Delay) begin
           @(posedge sintf.clk);
           delay += 1; 
         end 
        end
        begin 
           wait(sintf.Address_Com[31:2] === {sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_TAG_MSB:`CACHE_TAG_LSB],Address[`INDEX_MSB:`INDEX_LSB]});
        end
      join_any
      disable fork;
      assert(sintf.Address_Com[31:0] === {sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_TAG_MSB:`CACHE_TAG_LSB],Address[`INDEX_MSB:`INDEX_LSB],2'b00} ) $display("SUCCESS::Address_Com is loaded with correct address of the block to be replaced");
      else begin $display("BUG:: Expected Address_Com = %x, Actual Address_Com = %x",{sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_TAG_MSB:`CACHE_TAG_LSB],Address[`INDEX_MSB:`INDEX_LSB],2'b00},sintf.Address_Com[31:0]);
       status = "FAILED";
      end
      //Wait till Mem_wr signal is made high
      delay = 0;
      fork
        begin 
         while(delay <= Max_Resp_Delay) begin
           @(posedge sintf.clk);
           delay += 1; 
         end 
        end
        begin 
           wait(sintf.Mem_wr);
        end
      join_any
      disable fork;
      assert(sintf.Mem_wr) $display("SUCCESS:: Mem_wr is made high");
      else begin $display("BUG:Mem_wr is not made high within timeout", $time);
         status = "FAILED";
      end


      //free block is now available. Cache will do free block operations for write miss.
     repeat(2) @(posedge sintf.clk);   
     sintf.Mem_write_done = 1;
     repeat(2) @(posedge sintf.clk);   
     sintf.Mem_write_done = 0;      
     wait(sintf.BusRdX);
     sintf.Mem_snoop_req = 1;
     wait(sintf.Mem_snoop_gnt);
     sintf.Mem_snoop_req = 0;
     @(posedge sintf.clk);
     sintf.ClkBlk.Data_Bus_Com <= 32'hdddddddd;
     sintf.ClkBlk.Data_in_Bus  <= 1;
     repeat(4) @(posedge sintf.clk);
     actualMesi = mesiStateType'(sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
     if(Shared == 0) begin
         assert(sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] == MODIFIED)
         else begin $display("BUG: Updated MESI State = %s Does not match with Expected state = EXCLUSIVE",actualMesi.name());
          status = "FAILED";
         end
     end
     else if (Shared == 1) begin
         assert(sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_MESI_MSB:`CACHE_MESI_LSB] == MODIFIED)
         else begin $display("BUG: Updated MESI State = %x Does not match with Expected state = SHARED",sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],lineToBeRepl}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
          status = "FAILED";
         end
     end
     $display("\n****** Test topWriteMissModifiedReplacement Done Status = %s ******\n",!sintf.failed?status:"FAILED"); 
    end 
   endtask : testWriteMissReplaceModified
endclass : topWriteMissModifiedReplacement


// A Simple Directed Testcase for Scenario  :Write Hit. Verified at the top level
class topWriteHit extends baseTestClass;
    //the second argument is the MESI state of the block that is hit. Use the following : 0 for shared state, 1 for exclusive state, 2 for modified state
    rand reg [31:0] wrData;
    mesiStateType MESI_state;
    task testSimpleWriteHit(virtual interface globalInterface sintf);
         $display("\n****** Test topWriteHit Started for core = %d ****** ",core); 
                        //store the MESI State
                        MESI_state = mesiStateType'(sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],2'b00}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
         $display("Current MESI State of the Block is %s",MESI_state.name());
			//Do a Write
			sintf.ClkBlk.Address[core] <= Address;
			sintf.ClkBlk.PrRd[core]    <= 0;
			sintf.ClkBlk.PrWr[core]    <= 1;
			sintf.Data_Bus_reg[core]    = wrData;
                        
            if(MESI_state == SHARED) begin
               check_Invalidate_assert(sintf);
            end
            			
                //Check if Data is written into the Cache
               check_CacheVar_Data(sintf,wrData,Address,core);
               //Check if MESI_state is properly updated
               if(MESI_state == SHARED)
                 check_MESI_fsm(sintf,MODIFIED,core);
               else if(MESI_state == MODIFIED)
                 check_MESI_fsm(sintf,MODIFIED,core);
               else if(MESI_state == EXCLUSIVE)
                 check_MESI_fsm(sintf, MODIFIED,core);
                 
		//Check if CPU_stall and Com_Bus_Req_proc_0 is deasserted
		check_ComBusReqproc_CPUStall_deaassert(sintf,core);
          $display("****** Test topWriteHit Done Status = %s ******\n",!sintf.failed?status:"FAILED"); 
      
       
    endtask : testSimpleWriteHit
   

endclass : topWriteHit

//Simple Directed test to verify scenario  in which DUT Cache snoops a BusRd  while it contains
//the addressed block in shared/Modified/Exclusive state
class topBusRdSnoop extends baseTestClass;
    //use MESI_state as follows: 0 for Shared, 1 for Exclusive, 2 for Modified.
    mesiStateType MESI_state;
    reg[31:0] temp_data;
	task testBusRdSnoop(virtual interface globalInterface sintf);
	 begin
        $display("******Test topBusRdSnoop Started*********");
        $display("Bus Read  Attempt is made for Address = %x",Address);
         
	 //Other Cache raises Bus Rd signal
         sintf.Address_Com_reg = Address;
	 sintf.ClkBlk.PrRd[core]      <= 0;
         sintf.ClkBlk.PrWr[core]      <= 0;
         sintf.BusRd_reg = 1;
         
         
         repeat(2) @(posedge sintf.clk); 
	 //Check if DUT Cache Requests for Snoop Access
	 check_ComBusReqSnoop_assert(sintf,core);
	 //Calculate current MESI state of the Address Block requested.
         MESI_state = mesiStateType'(sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_snoop[core]}][`CACHE_MESI_MSB: `CACHE_MESI_LSB]);
         $display("MESI State of the Block to Be accessed = %x",MESI_state);
         temp_data  = sintf.Cache_var[core][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_snoop[core]}][`CACHE_DATA_MSB: `CACHE_DATA_LSB];
	 //if data is already in bus, then check if Bus Snoop request is deasserted
	 if(sintf.Data_in_Bus) begin
	   check_ComBusReqSnoop_deassert(sintf,core);
	 end else begin
	       
	     //wait for grant
             //try by asserting gnt snoop ourselves :)
	     wait(sintf.Com_Bus_Gnt_snoop_0);
	 	//The Cache should raise mem operation abort
	 	check_MemOprnAbrt_assert(sintf);
	 	//block is in shared state
	 	if(MESI_state == SHARED) begin
	 	  //Check if shared signal is made high
	 	  check_Shared_assert(sintf);
	 	  //Check if Data bus com is loaded with data
	 	  check_DataBusCom_valid(sintf,temp_data);//change this
	 	  //Check if Data in Bus is made high
	 	  check_DataInBus_assert(sintf);
	 	  //Check if com bus req snoop is deasserted
	 	  check_ComBusReqSnoop_deassert(sintf,core);
	 	end
	 	else if(MESI_state == EXCLUSIVE) begin //in Exclusive state
                  //Check if shared signal is made high
	 	  check_Shared_assert(sintf);
	 	  //Check if Data bus com is loaded with data
	 	  check_DataBusCom_valid(sintf,temp_data);
	 	  //Check if Data in Bus is made high
	 	  check_DataInBus_assert(sintf);
	 	  //Check if com bus req snoop is deasserted
	 	  check_ComBusReqSnoop_deassert(sintf,core);
	 	end 
	 	else if(MESI_state == MODIFIED) begin //in Modified state
	 	  //Check if Data bus com is loaded with data
	 	  check_DataBusCom_valid(sintf,temp_data);
	 	  //Check if mem wr signal is asserted
	 	  check_MemWr_assert(sintf);
	 	  //Raise Mem Wr Done
	 	  sintf.Mem_write_done = 1;
	 	  //Check if shared signal is made high
	 	  check_Shared_assert(sintf);
	 	  //Check if Data in Bus made high
	 	  check_DataInBus_assert(sintf);
	 	  //Check if com bus req snoop is deasserted
	 	  check_ComBusReqSnoop_deassert(sintf,core);
	 	end					
	  end					
          $display("****** Test topBusRdSnoop Done Status = %s ******\n",!sintf.failed?status:"FAILED"); 
	 end
	endtask
endclass : topBusRdSnoop

//Simple Directed test to verify scenario  in which DUT Cache snoops a BusRdX  while it contains
//the addressed block in shared/Modified/Exclusive state
class topBusRdXSnoop extends baseTestClass;
          
        mesiStateType MESI_state;
        reg[31:0] temp_data;
	task testBusRdXSnoop(virtual interface globalInterface sintf );
	 begin
        $display("\n******Test topBusRdXSnoop Started*********\n");
        $display("Bus ReadX  Attempt is made for Address = %x",Address);
	  //Other Cache raises Bus Rd signal
         sintf.Address_Com_reg = Address;
	 sintf.ClkBlk.PrRd[core]      <= 0;
         sintf.ClkBlk.PrWr[core]      <= 0;
         sintf.BusRd_reg = 1;
         
         
         repeat(2) @(posedge sintf.clk); 
	 //Check if DUT Cache Requests for Snoop Access
	 check_ComBusReqSnoop_assert(sintf,core);
	 //Calculate current MESI state of the Address Block requested.
         MESI_state = mesiStateType'(sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_snoop[core]}][`CACHE_MESI_MSB: `CACHE_MESI_LSB]);
         $display("MESI State of the Block to Be accessed = %x",MESI_state);
         temp_data  = sintf.Cache_var[core][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_snoop[core]}][`CACHE_DATA_MSB: `CACHE_DATA_LSB]; 
	  //if data is already in bus, then check if Bus Snoop request is deasserted
	  if(sintf.Data_in_Bus) begin
	  	check_ComBusReqSnoop_deassert(sintf,core);
	  end else begin
	        
	   //wait for grant
	   wait(sintf.Com_Bus_Gnt_snoop_0);
	   //The Cache should raise mem operation abort
	   check_MemOprnAbrt_assert(sintf);
	   //block is in shared state
	   if(MESI_state == 0) begin
	   	//Check if shared signal is made high
	   	check_Shared_assert(sintf);
	   	
	   end
	   else if(MESI_state == 1) begin //in Exclusive state
	   	//Nothing done at top level. Only internal states are changed.
	   	
	   end 
	   else if(MESI_state == 2) begin //in Modified state
	   	//Check if Common Bus Access is requested
	   	check_ComBusReqSnoop_assert(sintf,core);
	   	//wait for access grant
	   	wait(sintf.Com_Bus_Gnt_snoop_0);
	   	//check if data bus com has valid data
	   	check_DataBusCom_valid(sintf,32'bz);
	   	//check if mem wr is asserted
	   	check_MemWr_assert(sintf);
	   	//raise the memory write done
	   	sintf.Mem_write_done = 1;
	   	//check if com bus req snoop is deasserted
	   	check_ComBusReqSnoop_deassert(sintf,core);
	   	
	   end
	  		
	  end										
          $display("\n****** Test topBusRdXSnoop Done Status = %s ******\n",!sintf.failed?status:"FAILED"); 
	 end
	endtask
endclass : topBusRdXSnoop
//A master class that generates all scenarios in HAS3.0 Appendix
class topLocal_NonLocalCoreTest extends baseTestClass;

  reg [3:0] local_cache;  //local core number
  reg [3:0] other_cache;  //other core number
  reg [3:0] tmp_cache;
  reg [31:0] temp_addr;
  commandType operation;   //PrRd or PrWr
  mesiStateType blockStateOtherCache; //Block state in other cache
  topReadMiss   topReadMiss_inst; //class to create ReadMiss 
  topWriteMiss  topWriteMiss_inst; //class to create WriteMiss 
  topReadHit    topReadHit_inst; //class to create ReadHit
  topWriteHit   topWriteHit_inst;//class to create topWriteHit
  
 
  //This task will create the desired state of the block in other_cache
  task createOtherCacheBlockState(virtual interface globalInterface sintf);
     begin
     $display("Attemptig to create %s state for block with Address %x in Cache %",blockStateOtherCache,Address,other_cache);
         if(blockStateOtherCache == INVALID) begin
             //Do nothing. :)
         end
         else if (blockStateOtherCache == EXCLUSIVE) begin
          //Do a Read Miss in other_cache
             topReadMiss_inst                  = new();  
             topReadMiss_inst.Address          = Address ;
             topReadMiss_inst.Max_Resp_Delay   = Max_Resp_Delay;
             topReadMiss_inst.core             = other_cache;
             temp_addr                         = topReadMiss_inst.Address;
             topReadMiss_inst.testSimpleReadMiss(sintf);
             repeat(Max_Resp_Delay) @sintf.clk;
             topReadMiss_inst.reset_DUT_inputs(sintf);  
             repeat(Max_Resp_Delay) @sintf.clk;
         end
         else if (blockStateOtherCache == MODIFIED) begin
           //Do a Write Miss in other_cache
             topWriteMiss_inst  = new();           
             topWriteMiss_inst.Address         = Address;
             topWriteMiss_inst.Max_Resp_Delay  = Max_Resp_Delay;
             topWriteMiss_inst.core            = other_cache;
             topWriteMiss_inst.wrData          = 32'hbabababa; 
             topWriteMiss_inst.testWriteMiss(sintf);
             #100;
             topWriteMiss_inst.reset_DUT_inputs(sintf); 
             #100;
         end
         else if (blockStateOtherCache == SHARED) begin
             //Do read Miss on the other core
             topReadMiss_inst                  = new();  
             topReadMiss_inst.Address          = Address ;
             topReadMiss_inst.Max_Resp_Delay   = Max_Resp_Delay;
             topReadMiss_inst.core             = other_cache;
             temp_addr                         = topReadMiss_inst.Address;
             topReadMiss_inst.testSimpleReadMiss(sintf);
             repeat(Max_Resp_Delay) @sintf.clk;
             topReadMiss_inst.reset_DUT_inputs(sintf);  
             repeat(Max_Resp_Delay) @sintf.clk;
             //Do read Miss on some core other than the other_core and local_core
             tmp_cache  = 3 - (other_cache + local_cache);
             if (tmp_cache == 3) tmp_cache = 1;
             //Do read Miss on tmp_cache
             topReadMiss_inst                  = new();  
             topReadMiss_inst.Address          = Address ;
             topReadMiss_inst.Max_Resp_Delay   = Max_Resp_Delay;
             topReadMiss_inst.core             = tmp_cache;
             temp_addr                         = topReadMiss_inst.Address;
             topReadMiss_inst.testSimpleReadMiss(sintf);
             repeat(Max_Resp_Delay) @sintf.clk;
             topReadMiss_inst.reset_DUT_inputs(sintf);  
             repeat(Max_Resp_Delay) @sintf.clk;
         end
          
     end
  endtask :  createOtherCacheBlockState
  task testLocal_NonLocalCore(virtual interface globalInterface sintf);
     begin
       createOtherCacheBlockState(sintf);
     end
  endtask : testLocal_NonLocalCore

endclass : topLocal_NonLocalCoreTest






