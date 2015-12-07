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
typedef enum bit {MISS,HIT}  hitMissType;
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
   mesiStateType mesiStates[2*`CORES]; 
   
   //Task to wait and check for Com_Bus_Req_proc_0 and CPU_Stall to be asserted
   virtual task check_ComBusReqproc_CPUStall_assert(virtual interface globalInterface sintf,input [3:0] core);
      delay = 0;
      $display("Checking check_ComBusReqproc_CPUStall_assert for core %x ",core);
      fork
        begin 
         while(delay <= Max_Resp_Delay) begin
           @(posedge sintf.clk);
           delay += 1; 
         end 
        end
        begin 
           wait(sintf.Com_Bus_Req_proc[core] && sintf.CPU_stall[core]);
        end
      join_any
      disable fork;
    //Check if Com_Bus_Req_proc_0 is asserted  
    assert(sintf.Com_Bus_Req_proc[core]) $display("SUCCESS:: Com_Bus_Req_Proc[%d] and CPU_stall are asserted within timeout after PrRd/PrWr is asserted",core);
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
           wait(sintf.Com_Bus_Req_snoop[core]);
        end
      join_any
      disable fork;
    //Check if Com_Bus_Req_ is asserted  
    assert(sintf.Com_Bus_Req_snoop[core]) $display("SUCCESS:: Com_Bus_Req_snoop[%d] is asserted within timeout after BusRd/BusRdX is asserted",core);
    else begin $display("BUG:: Com_Bus_Req_snoop[%d] is not asserted after BusRd/BusRdX",core);
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
           wait(!sintf.Com_Bus_Req_snoop[core]);
        end
      join_any
      disable fork;
    //Check if Com_Bus_Req_ is asserted  
    assert(!sintf.Com_Bus_Req_snoop[core]) $display("SUCCESS:: Com_Bus_Req_snoop[%d] is deasserted within timeout after BusRd is asserted",core);
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
           wait(!sintf.Com_Bus_Req_proc[core] && !sintf.CPU_stall[core]);
        end
      join_any
      disable fork;
      assert(!sintf.CPU_stall[core]) $display("SUCCESS:: CPU_stall De-Asserted");
      else  begin $display("BUG:: CPU_stall not deasserted");
       status = "FAILED";
      end
      assert(!sintf.Com_Bus_Req_proc[core]) $display("SUCCESS:: Com_Bus_Req_proc[%d] De-Asserted",core);
      else begin $display("BUG:: Com_Bus_Req_proc[%d] not deasserted",core);
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
         wait(sintf.Com_Bus_Gnt_proc[core]);
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
    assert(sintf.Mem_oprn_abort) $display("SUCCESS:: Mem_oprn_abort is asserted");
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
    assert(sintf.Shared) $display("SUCCESS:: Shared line is asserted");
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
    assert(sintf.Mem_wr) $display("SUCCESS:: Mem_wr is asserted");
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
    assert(sintf.Data_in_Bus) $display("SUCCESS:: Data_in_Bus is asserted");
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
     mesiStates[core] = mst;
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
 //function to check LRU value 
  virtual function check_LRU_var(virtual interface globalInterface sintf, input [2:0] expected_lru_var);
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
  endfunction: check_LRU_var
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
//display mesi states of all blocks in a given set
task dispMesiStates(virtual interface globalInterface sintf,input [3:0] core,input [31:0] Address);
   reg [2:0] line;
   mesiStateType mst;
   reg [`TAG_SIZE-1:0] tag;
   for(line = 3'b000; line <= 3'b011; line++) begin
    mst = mesiStateType'(sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
    tag = sintf.Cache_proc_contr[core][{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_TAG_MSB:`CACHE_TAG_LSB];

    $display("MESI State of block %d in Core %d with Tag %x set %x is %s",line,core,tag,Address[`INDEX_MSB:`INDEX_LSB],mst);
   end
   $display("\n");
endtask :dispMesiStates

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
     
    sintf.ClkBlk.Address[core][31:0] <= Address;
     //sintf.ClkBlk.Shared <= Shared;
     expected_lru_var = 3'bxxx; 
  endtask :drive 

  task check(virtual globalInterface sintf);
     //DataWrittenByMem =  32'hBABABABA;
     //Check for behavior
    //Com_Bus_Req_proc and CPU_stall must be made high
     check_ComBusReqproc_CPUStall_assert(sintf,core);
    //Wait until arbiter grants access
     check_ComBusGntproc_assert(sintf,core);
    //Check if the Cache raises BusRd
    check_BusRd_assert(sintf,core);
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
      
     $display("\n****** Test topReadMiss Started for core = %d for Address %x****** ",core,Address); 
     
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
      $display("\n****** Test topReadHit Started for core = %d and Address = %x****** ",core,Address); 
      
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
          repeat(Max_Resp_Delay) @sintf.clk;
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



//A master class that generates all scenarios in HAS3.0 Appendix
class topLocal_NonLocalCoreTest extends baseTestClass;

  reg [3:0] local_cache;  //local core number
  reg [3:0] other_cache;  //other core number
  reg [3:0] tmp_cache;
  reg [31:0] temp_addr;
  reg [2:0]  line;
  commandType operation;   //PrRd or PrWr
  mesiStateType blockStateOtherCache; //Block state in other cache
  mesiStateType mst; 
  hitMissType   hitMiss;
  topReadMiss   topReadMiss_inst; //class to create ReadMiss 
  topWriteMiss  topWriteMiss_inst; //class to create WriteMiss 
  topReadHit    topReadHit_inst; //class to create ReadHit
  topWriteHit   topWriteHit_inst;//class to create topWriteHit
  
 
  //This task will create the desired state of the block in other_cache
  task createOtherCacheBlockState(virtual interface globalInterface sintf);
     begin
     $display("Attemptig to create %s state for block with Address %x in Cache %d",blockStateOtherCache,Address,other_cache);
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
             if(topReadMiss_inst.mesiStates[other_cache] == blockStateOtherCache)
               $display("Successfully Created %s state for block with Address %x in Cache %d",blockStateOtherCache,Address,other_cache);
             else $display("Attempt UnSuccessful. MESI State in other Cache %d is %s",other_cache,mesiStates[other_cache]);
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
             
             if(topWriteMiss_inst.mesiStates[other_cache] == blockStateOtherCache)
               $display("Successfully Created %s state for block with Address %x in Cache %d",blockStateOtherCache,Address,other_cache);
             else $display("Attempt UnSuccessful");
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
             mesiStates[other_cache] = topReadMiss_inst.mesiStates[other_cache];
             repeat(Max_Resp_Delay) @sintf.clk;
             topReadMiss_inst.reset_DUT_inputs(sintf);  
             repeat(Max_Resp_Delay) @sintf.clk;
             sintf.Cache_proc_contr[other_cache][{temp_addr[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[other_cache]}][`CACHE_MESI_MSB: `CACHE_MESI_LSB] = 2'b01;
      
             if( sintf.Cache_proc_contr[other_cache][{temp_addr[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[other_cache]}][`CACHE_MESI_MSB: `CACHE_MESI_LSB] == blockStateOtherCache)
                   $display("Successfully Created %s state for block with Address %x in Cache %d",blockStateOtherCache,Address,other_cache);
             else $display("Attempt UnSuccessful");
             repeat(Max_Resp_Delay) @sintf.clk;
             topReadMiss_inst.reset_DUT_inputs(sintf);  
             repeat(Max_Resp_Delay) @sintf.clk;
         end
         /*for (line=2'b00; line <= 2'b11; line++) begin
                     mst = mesiStateType'(sintf.Cache_proc_contr[other_cache][{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
                     $display("mst for line %d is %s in other core %d",line,mesiStateType'(mst),other_cache);
         end
         for (line=2'b00; line <= 2'b11; line++) begin
                     mst = mesiStateType'(sintf.Cache_proc_contr[local_cache][{Address[`INDEX_MSB:`INDEX_LSB],line[1:0]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
                     $display("mst for line %d is %s in local core %d",line,mesiStateType'(mst),local_cache);
         end*/
     end
  endtask :  createOtherCacheBlockState
  //task to test PrRd/PrWr on the local cache. Attempt for a Read/Write Miss
  task testLocalCacheMiss(virtual interface globalInterface sintf);
   reg [31:0] DataWrittenByMem;
     begin
        $display("Attempting a %s on local cache %d for Address %x while this block is present in other Cache %d in %s state",operation,local_cache,Address,other_cache,blockStateOtherCache);
        if(operation == PrRd) begin
             //Do read Miss on the local core
             sintf.ClkBlk.Address[local_cache]        <= Address ;
             sintf.ClkBlk.PrRd[local_cache]           <= 1;
             sintf.ClkBlk.PrWr[local_cache]           <= 0;
             temp_addr                                 = Address;
             //Check for behavior
             //Com_Bus_Req_proc and CPU_stall must be made high
             fork
              check_ComBusReqproc_CPUStall_assert(sintf,local_cache);
             join_none
             //Wait until arbiter grants access
             fork
              check_ComBusGntproc_assert(sintf,local_cache);
             join_none
             //Check if the Cache raises BusRd
             fork
              check_BusRd_assert(sintf,local_cache);
             join_none

             if(blockStateOtherCache == INVALID) begin
             //Wait until cache places Address in Address_Com bus
             check_Address_Com_load(sintf,local_cache);
                DataWrittenByMem = 32'hbabababa;
                //Main Memory requests for Bus Access. Wait for Bus Access Grant by the arbiter
                sintf.Mem_snoop_req = 1;
                wait(sintf.Mem_snoop_gnt == 1);
                sintf.Mem_snoop_req = 0;
                //Main Memory puts data on the ClkBlk.Data_Bus_Com and raises Data_in_Bus
                sintf.ClkBlk.Data_Bus_Com <= DataWrittenByMem;
                sintf.ClkBlk.Data_in_Bus <= 1;
                //Check if MESI State is properly assigned to block corresponding to the Address given
                check_MESI_fsm(sintf,EXCLUSIVE,local_cache);
                //Check if Memory is loaded with Correct Data
                check_CacheVar_Data(sintf,DataWrittenByMem,Address,local_cache); 
                //Check if LRU Value is properly assigned
                repeat(Max_Resp_Delay) @sintf.clk;
                determine_LRU_var_exp(sintf.Blk_access_proc[local_cache],expected_lru_var);
             end
             else begin
             //Check if other_cache requests for bus access from snoop side
                //check_ComBusReqSnoop_assert(sintf,other_cache);
                //wait(sintf.Com_Bus_Gnt_snoop[other_cache]);
             //Wait until cache places Address in Address_Com bus
             check_Address_Com_load(sintf,local_cache);
             //Wait for access grant
             //Check if Mem Oprn Abrt is raised
                check_MemOprnAbrt_assert(sintf);
                if(blockStateOtherCache == SHARED) begin
                  check_Shared_assert(sintf);
                  check_DataInBus_assert(sintf);
                  //Check if MESI State is properly assigned to block corresponding to the Address given
                  check_MESI_fsm(sintf,SHARED,local_cache);
                 // @sintf.Updated_MESI_state_snoop[local_cache];
                  //check_DataBusCom_valid(sintf,topReadMiss_inst.DataWrittenByMem);
                end
                else if (blockStateOtherCache == EXCLUSIVE) begin
                  check_Shared_assert(sintf);
                  check_DataInBus_assert(sintf);
                  //check_DataBusCom_valid(sintf,topReadMiss_inst.DataWrittenByMem);
                  repeat(Max_Resp_Delay) @sintf.clk;
                  mst =  mesiStateType'(sintf.Cache_proc_contr[other_cache][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[other_cache]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
                  if(mst == SHARED) begin
                     $display("SUCCESS:: State of block with Address %x is changed to SHARED in other core %d",Address,other_cache);
                  end
                  else $display("BUG:: State of block with Address %x is changed to %s instead of SHARED in other core %d",Address,mst,other_cache); 
                  mst =  mesiStateType'(sintf.Cache_proc_contr[local_cache][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[local_cache]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
                  if(mst == SHARED) begin
                     $display("SUCCESS:: State of block with Address %x is changed to SHARED in local core %d",Address,local_cache);
                  end
                  else $display("BUG:: State of block with Address %x is changed to %s instead of SHARED in local core %d",Address,mst,local_cache); 
                end
                else if (blockStateOtherCache == MODIFIED) begin
                     
                   check_MemWr_assert(sintf);
                   fork
                      sintf.Mem_write_done = 1;
                      repeat(2) @sintf.clk;
                      sintf.Mem_write_done = 0;
                   join_none
                   check_Shared_assert(sintf);
                   check_DataInBus_assert(sintf);
                  //Check if MESI State is properly assigned to block corresponding to the Address given
                  check_MESI_fsm(sintf,SHARED,local_cache);
                  /*mst =  mesiStateType'(sintf.Cache_proc_contr[other_cache][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[other_cache]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
                  if(mst == SHARED) begin
                     $display("SUCCESS:: State of block with Address %x is changed to SHARED in other core %d",Address,other_cache);
                  end 
                  else $display("BUG:: State of block with Address %x is changed to %s instead of SHARED in other core %d",Address,mst,other_cache); 
                  
                  mst =  mesiStateType'(sintf.Cache_proc_contr[local_cache][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[local_cache]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
                  if(mst == SHARED) begin
                     $display("SUCCESS:: State of block with Address %x is changed to SHARED in local core %d",Address,local_cache);
                  end
                  else $display("BUG:: State of block with Address %x is changed to %s instead of SHARED in local core %d",Address,mst,local_cache); */
                   
                end
             end
        end
        else if (operation == PrWr) begin
             //Do a Write Miss in other_cache
             sintf.ClkBlk.Address[local_cache]        <= Address ;
             sintf.ClkBlk.PrRd[local_cache]           <= 0;
             sintf.ClkBlk.PrWr[local_cache]           <= 1;
             sintf.Data_Bus_reg[local_cache]  = 32'hdadadada;
             //wait for CPU_stall and Com_Bus_Gnt_proc to be made high
             check_ComBusReqproc_CPUStall_assert(sintf,local_cache);
             check_ComBusGntproc_assert(sintf,local_cache);
             check_BusRdX_assert(sintf,local_cache);
             check_Address_Com_load(sintf,local_cache);

             if(blockStateOtherCache == INVALID) begin
                //Lower Memory or Other Cache Loads Data on the Bus
                sintf.ClkBlk.Data_in_Bus <= 1;
                sintf.ClkBlk.Data_Bus_Com <= 32'hABACABAB;
                //Check if MESI State is properly assigned to block corresponding to the Address given
                check_MESI_fsm(sintf,MODIFIED,local_cache);
                //Check if Data is correctly written into the cache
                //check_CacheVar_Data(sintf,wrData,Address,core); 
                //check_DataBus_valid(sintf,wrData); 
                repeat(Max_Resp_Delay) @(posedge sintf.clk);
                check_ComBusReqproc_CPUStall_deaassert(sintf,local_cache);
                repeat(Max_Resp_Delay) @(posedge sintf.clk);
             end
             else if(blockStateOtherCache == SHARED) begin
               //Lower Memory or Other Cache Loads Data on the Bus
               sintf.ClkBlk.Data_in_Bus <= 1;
               sintf.ClkBlk.Data_Bus_Com <= 32'hABACABAB;
               check_Shared_assert(sintf);
               //Check if MESI State is properly assigned to block corresponding to the Address given
               check_MESI_fsm(sintf,MODIFIED,local_cache);
               mst =  mesiStateType'(sintf.Cache_proc_contr[other_cache][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[other_cache]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
                if(mst == INVALID) begin
                  $display("SUCCESS:: State of block with Address %x is changed to INVALID in other core %d",Address,other_cache);
                end
                else $display("BUG:: State of block with Address %x is changed to %s instead of INVALID in other core %d",Address,mst,other_cache); 
               mst =  mesiStateType'(sintf.Cache_proc_contr[local_cache][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[local_cache]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
                if(mst == MODIFIED) begin
                  $display("SUCCESS:: State of block with Address %x is changed to MODIFIED in local core %d",Address,local_cache);
               end
               else $display("BUG:: State of block with Address %x is changed to %s instead of MODIFIED in local core %d",Address,mst,local_cache); 
             end
             else if (blockStateOtherCache == EXCLUSIVE) begin
               //Lower Memory or Other Cache Loads Data on the Bus
               sintf.ClkBlk.Data_in_Bus <= 1;
               sintf.ClkBlk.Data_Bus_Com <= 32'hABACABAB;
               //Check if MESI State is properly assigned to block corresponding to the Address given
               check_MESI_fsm(sintf,MODIFIED,local_cache);
               /*mst =  mesiStateType'(sintf.Cache_proc_contr[other_cache][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[other_cache]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
               if(mst == INVALID) begin
                  $display("SUCCESS:: State of block with Address %x is changed to INVALID in other  core %d",Address,other_cache);
               end
               else $display("BUG:: State of block with Address %x is changed to %s instead of INVALID in other core %d",Address,mst,other_cache); 
               mst =  mesiStateType'(sintf.Cache_proc_contr[local_cache][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[local_cache]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
               if(sintf.Updated_MESI_state_proc[local_cache] == MODIFIED) begin
                  $display("SUCCESS:: State of block with Address %x is changed to MODIFIED in local core %d",Address,local_cache);
               end
               else $display("BUG:: State of block with Address %x is changed to %s instead of MODIFIED in local core %d",Address,mst,local_cache); */
             end
             else if (blockStateOtherCache == MODIFIED) begin
                check_ComBusReqSnoop_assert(sintf,other_cache);
                wait(sintf.Com_Bus_Gnt_snoop[other_cache]);
                check_MemWr_assert(sintf);
                sintf.Mem_write_done = 1;
                sintf.ClkBlk.Data_Bus_Com <= 32'hdeadcafe;
                sintf.ClkBlk.Data_in_Bus  <= 1;
               //Check if MESI State is properly assigned to block corresponding to the Address given
               check_MESI_fsm(sintf,MODIFIED,local_cache);
               mst =  mesiStateType'(sintf.Cache_proc_contr[other_cache][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[other_cache]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
               if(mst == INVALID) begin
                  $display("SUCCESS:: State of block with Address %x is changed to INVALID in other core %d",Address,other_cache);
               end 
               else $display("BUG:: State of block with Address %x is changed to %s instead of INVALID in other core %d",Address,mst,other_cache); 
               mst =  mesiStateType'(sintf.Cache_proc_contr[local_cache][{Address[`INDEX_MSB:`INDEX_LSB],sintf.Blk_access_proc[local_cache]}][`CACHE_MESI_MSB:`CACHE_MESI_LSB]);
               if(sintf.Updated_MESI_state_proc[local_cache] == MODIFIED) begin
                  $display("SUCCESS:: State of block with Address %x is changed to MODIFIED in local core %d",Address,local_cache);
               end
               else $display("BUG:: State of block with Address %x is changed to %s instead of MODIFIED in local core %d",Address,mst,local_cache); 
                
             end
             
             //topWriteMiss_inst.(sintf);
             #100;
        end
     end
  endtask :  testLocalCacheMiss
 //to verify the local cache hit process
  task testLocalCacheHit(virtual interface globalInterface sintf);
    begin
       if(operation == PrRd) begin
       end
       else if (operation == PrWr) begin
             sintf.Data_Bus_reg[local_cache]  = 32'hdadadada;
             sintf.ClkBlk.Address[local_cache]        <= Address ;
             sintf.ClkBlk.PrRd[local_cache]           <= 0;
             sintf.ClkBlk.PrWr[local_cache]           <= 1;
             //wait for CPU_stall and Com_Bus_Gnt_proc to be made high
             check_ComBusReqproc_CPUStall_assert(sintf,local_cache);
             check_ComBusGntproc_assert(sintf,local_cache);
             check_BusRdX_assert(sintf,local_cache);
             check_Address_Com_load(sintf,local_cache);
             
             if(blockStateOtherCache == SHARED) begin
                //block must be shared in local cache also
                //check if invalidate has been asserted
                check_Invalidate_assert(sintf);
                //Check if MESI State is properly assigned to block corresponding to the Address given
                check_MESI_fsm(sintf,MODIFIED,local_cache);
                //check if other core has invalidated it's data
                mst = mesiStateType'(sintf.Updated_MESI_state_snoop[other_cache]);
                if(mst == INVALID) $display("SUCCESS:: Other Cache %d invalidated the block with Address %x",other_cache,Address);
                else $display("BUG:: Other cache %d has the block status %s instead of INVALID for Address %x",other_cache,mst,Address);
             end
       end
    end
  endtask :testLocalCacheHit
  task testLocal_NonLocalCore(virtual interface globalInterface sintf);
    $display("Starting testLocal_NonLocalCore, hitMiss = %s ",hitMiss);  
    if(hitMiss == MISS) begin
         createOtherCacheBlockState(sintf);
         $display("MESI STATES BEFORE TEST");
         dispMesiStates(sintf,local_cache,Address);
         dispMesiStates(sintf,other_cache,Address);
         testLocalCacheMiss(sintf);
      end 
      else if(hitMiss == HIT) begin
         $display("WRITE HIT test on block with Address %x in local_cache %d while it is in %s state in other_cache %d",Address,local_cache,blockStateOtherCache,other_cache);
         $display("MESI STATES BEFORE TEST");
         dispMesiStates(sintf,local_cache,Address);
         dispMesiStates(sintf,other_cache,Address);
         testLocalCacheHit(sintf);
      end
  endtask : testLocal_NonLocalCore

endclass : topLocal_NonLocalCoreTest






