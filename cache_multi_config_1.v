`include "cache_wrapper_0.v"
`include "cache_wrapper_I_0.v"
`include "cache_wrapper_1.v"
`include "cache_wrapper_I_1.v"
`include "cache_wrapper_2.v"
`include "cache_wrapper_I_2.v"
`include "cache_wrapper_3.v"
`include "cache_wrapper_I_3.v"


module cache_multi_config_1 (	clk,
								PrWr              [0],
								PrRd              [0],
								Address           [0],
								Data_Bus          [0],
								CPU_stall         [0],
								Com_Bus_Req_proc  [0],
								Com_Bus_Gnt_proc  [0],
								Com_Bus_Req_snoop [0],
								Com_Bus_Gnt_snoop [0],
								PrWr              [1],
								PrRd              [1],
								Address           [1],
								Data_Bus          [1],
								CPU_stall         [1],
								Com_Bus_Req_proc  [1],
								Com_Bus_Gnt_proc  [1],
								Com_Bus_Req_snoop [1],
								Com_Bus_Gnt_snoop [1],
								PrWr              [2],
								PrRd              [2],
								Address           [2],
								Data_Bus          [2],
								CPU_stall         [2],
								Com_Bus_Req_proc  [2],
								Com_Bus_Gnt_proc  [2],
								Com_Bus_Req_snoop [2],
								Com_Bus_Gnt_snoop [2],
								PrWr              [3],
								PrRd              [3],
								Address           [3],
								Data_Bus          [3],
								CPU_stall         [3],
								Com_Bus_Req_proc  [3],
								Com_Bus_Gnt_proc  [3],
								Com_Bus_Req_snoop [3],
								Com_Bus_Gnt_snoop [3],
								Address_Com,
								Data_Bus_Com,
								Data_in_Bus,
								Mem_wr,
								Mem_oprn_abort,
								Mem_write_done,
								PrWr              [4],
								PrRd              [4],
								Address           [4],
								Data_Bus          [4],
								CPU_stall         [4],
								Com_Bus_Req_proc  [4],
								Com_Bus_Gnt_proc  [4],
								
								PrWr              [5],
								PrRd              [5],
								Address           [5],
								Data_Bus          [5],
								CPU_stall         [5],
								Com_Bus_Req_proc  [5],
								Com_Bus_Gnt_proc  [5],
								
								PrWr              [6],
								PrRd              [6],
								Address           [6],
								Data_Bus          [6],
								CPU_stall         [6],
								Com_Bus_Req_proc  [6],
								Com_Bus_Gnt_proc  [6],
								
								PrWr              [7],
								PrRd              [7],
								Address           [7],
								Data_Bus          [7],
								CPU_stall         [7],
								Com_Bus_Req_proc  [7],
								Com_Bus_Gnt_proc  [7]);



input 							clk;
input								         PrWr              [7 : 0];
input								         PrRd              [7 : 0];
input 	[`ADDRESSSIZE-1 : 0] 		Address           [7 : 0];
inout 	[`ADDRESSSIZE-1 : 0] 		Data_Bus          [7 : 0];
output								      CPU_stall         [7 : 0];
output								      Com_Bus_Req_proc  [7 : 0];

input								         Com_Bus_Gnt_proc  [7 : 0];
output								      Com_Bus_Req_snoop [3 : 0];
input								         Com_Bus_Gnt_snoop [3 : 0];

inout 	[`ADDRESSSIZE-1 : 0] 		Address_Com;
inout 	[`ADDRESSSIZE-1 : 0] 		Data_Bus_Com;
input                               Data_in_Bus;
output                              Mem_wr;
output                              Mem_oprn_abort;
input                               Mem_write_done;

wire 	[`ADDRESSSIZE-1 : 0] 	    	Address_Com;
wire 	[`ADDRESSSIZE-1 : 0] 		Data_Bus_Com;
wire                               BusRd;
wire                               BusRdX;
wire                               Invalidate;
tri                               Data_in_Bus;
wire                              Mem_wr;
wire                              Mem_oprn_abort;
wire                               Mem_write_done;

wire                                Shared_local [3 : 0];

// Needs logic to drive signal
wire								         All_Invalidation_done;

wire                              Invalidation_done [3 : 0];

assign      Shared = Shared_local[0] | Shared_local[1] | Shared_local[2] | Shared_local[3];

// A work around assumed that when one invalidation is done then all copies are invalidated
//assign All_Invalidation_done = Invalidation_done[0] & Invalidation_done[1] & Invalidation_done[2] & Invalidation_done[3];

assign      All_Invalidation_done = ((!Shared_local[0] & !Invalidation_done[0]) | Invalidation_done[0]) & ((!Shared_local[1] & !Invalidation_done[1]) |   Invalidation_done[1]) & ((!Shared_local[2] & !Invalidation_done[2]) |   Invalidation_done[2]) & ((!Shared_local[3] & !Invalidation_done[3]) |   Invalidation_done[3]);

cache_wrapper_0     P1_DL (   clk,
                              PrWr[0],
                              PrRd[0],
                              Address[0],
                              Data_Bus[0],
                              CPU_stall[0],
                              Com_Bus_Req_proc[0],
                              Com_Bus_Gnt_proc[0],
                              Com_Bus_Req_snoop[0],
                              Com_Bus_Gnt_snoop[0],
                              Address_Com,
                              Data_Bus_Com,
                              BusRd,
                              BusRdX,
                              Invalidate,
                              Data_in_Bus,
                              Mem_wr,
                              Mem_oprn_abort,
                              Mem_write_done,
                              Invalidation_done[0],
                              All_Invalidation_done,
                              Shared_local[0],
                              Shared
);
cache_wrapper_I_0   P1_IL (	clk,
                              PrRd[4],
                              Address[4],
                              Data_Bus[4],
                              CPU_stall[4],
                              Com_Bus_Req_proc[4],
                              Com_Bus_Gnt_proc[4],
                              Address_Com,
                              Data_Bus_Com,
                              Data_in_Bus
                           );

cache_wrapper_1     P2_DL (   clk,
                              PrWr[1],
                              PrRd[1],
                              Address[1],
                              Data_Bus[1],
                              CPU_stall[1],
                              Com_Bus_Req_proc[1],
                              Com_Bus_Gnt_proc[1],
                              Com_Bus_Req_snoop[1],
                              Com_Bus_Gnt_snoop[1],
                              Address_Com,
                              Data_Bus_Com,
                              BusRd,
                              BusRdX,
                              Invalidate,
                              Data_in_Bus,
                              Mem_wr,
                              Mem_oprn_abort,
                              Mem_write_done,
                              Invalidation_done[1],
                              All_Invalidation_done,
                              Shared_local[1],
                              Shared
);
cache_wrapper_I_1   P2_IL (clk,
                              PrRd[5],
                              Address[5],
                              Data_Bus[5],
                              CPU_stall[5],
                              Com_Bus_Req_proc[5],
                              Com_Bus_Gnt_proc[5],
                              Address_Com,
                              Data_Bus_Com,
                              Data_in_Bus
                           );

cache_wrapper_2     P3_DL (   clk,
                              PrWr[2],
                              PrRd[2],
                              Address[2],
                              Data_Bus[2],
                              CPU_stall[2],
                              Com_Bus_Req_proc[2],
                              Com_Bus_Gnt_proc[2],
                              Com_Bus_Req_snoop[2],
                              Com_Bus_Gnt_snoop[2],
                              Address_Com,
                              Data_Bus_Com,
                              BusRd,
                              BusRdX,
                              Invalidate,
                              Data_in_Bus,
                              Mem_wr,
                              Mem_oprn_abort,
                              Mem_write_done,
                              Invalidation_done[2],
                              All_Invalidation_done,
                              Shared_local[2],
                              Shared
);
cache_wrapper_I_2   P3_IL (   clk,
                              PrRd[7],
                              Address[7],
                              Data_Bus[7],
                              CPU_stall[7],
                              Com_Bus_Req_proc[7],
                              Com_Bus_Gnt_proc[7],
                              Address_Com,
                              Data_Bus_Com,
                              Data_in_Bus
                           );

cache_wrapper_3     P4_DL (   clk,
                              PrWr[3],
                              PrRd[3],
                              Address[3],
                              Data_Bus[3],
                              CPU_stall[3],
                              Com_Bus_Req_proc[3],
                              Com_Bus_Gnt_proc[3],
                              Com_Bus_Req_snoop[3],
                              Com_Bus_Gnt_snoop[3],
                              Address_Com,
                              Data_Bus_Com,
                              BusRd,
                              BusRdX,
                              Invalidate,
                              Data_in_Bus,
                              Mem_wr,
                              Mem_oprn_abort,
                              Mem_write_done,
                              Invalidation_done[3],
                              All_Invalidation_done,
                              Shared_local[3],
                              Shared
);
cache_wrapper_I_3   P4_IL (   clk,
                              PrRd[6],
                              Address[6],
                              Data_Bus[6],
                              CPU_stall[6],
                              Com_Bus_Req_proc[6],
                              Com_Bus_Gnt_proc[6],
                              Address_Com,
                              Data_Bus_Com,
                              Data_in_Bus
                           );

endmodule
