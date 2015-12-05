`define BUF_WIDTH 3    // BUF_SIZE = 16 -> BUF_WIDTH = 4, no. of bits to be used in pointer
`define BUF_SIZE ( 1<<`BUF_WIDTH )
`include "fifo.v"

module arbiter (	Com_Bus_Req_proc[0],
					Com_Bus_Req_proc[1],
					Com_Bus_Req_proc[2],
					Com_Bus_Req_proc[3],
					Com_Bus_Req_proc[4],
					Com_Bus_Req_proc[5],
					Com_Bus_Req_proc[6],
					Com_Bus_Req_proc[7],
					Com_Bus_Req_snoop[0],
					Com_Bus_Req_snoop[1],
					Com_Bus_Req_snoop[2],
					Com_Bus_Req_snoop[3],
					Com_Bus_Gnt_proc_0,
					Com_Bus_Gnt_proc_1,
					Com_Bus_Gnt_proc_2,
					Com_Bus_Gnt_proc_3,
					Com_Bus_Gnt_proc_4,
					Com_Bus_Gnt_proc_5,
					Com_Bus_Gnt_proc_6,
					Com_Bus_Gnt_proc_7,
					Com_Bus_Gnt_snoop_0,
					Com_Bus_Gnt_snoop_1,
					Com_Bus_Gnt_snoop_2,
					Com_Bus_Gnt_snoop_3,
					Mem_snoop_req,
					Mem_snoop_gnt);
					
input 					Com_Bus_Req_proc[7:0];
input 					Com_Bus_Req_snoop[3:0];
//output					Com_Bus_Gnt_proc[7:0];
//output					Com_Bus_Gnt_snoop[3:0];
input 					Mem_snoop_req;
output					Mem_snoop_gnt;

output 					Com_Bus_Gnt_proc_0;
output 					Com_Bus_Gnt_proc_1;
output 					Com_Bus_Gnt_proc_2;
output 					Com_Bus_Gnt_proc_3;
output 					Com_Bus_Gnt_proc_4;
output 					Com_Bus_Gnt_proc_5;
output 					Com_Bus_Gnt_proc_6;
output 					Com_Bus_Gnt_proc_7;

output 					Com_Bus_Gnt_snoop_0;
output 					Com_Bus_Gnt_snoop_1;
output 					Com_Bus_Gnt_snoop_2;
output 					Com_Bus_Gnt_snoop_3;
/*
reg 					Com_Bus_Gnt_proc_0;
reg 					Com_Bus_Gnt_proc_1;
reg 					Com_Bus_Gnt_proc_2;
reg 					Com_Bus_Gnt_proc_3;
reg 					Com_Bus_Gnt_proc_4;
reg 					Com_Bus_Gnt_proc_5;
reg 					Com_Bus_Gnt_proc_6;
reg 					Com_Bus_Gnt_proc_7;

reg 					Com_Bus_Gnt_snoop_0;
reg 					Com_Bus_Gnt_snoop_1;
reg 					Com_Bus_Gnt_snoop_2;
reg 					Com_Bus_Gnt_snoop_3;
*/

reg 					Com_Bus_Gnt_proc [7 : 0];
reg 					Com_Bus_Gnt_snoop[3:0];
reg						Mem_snoop_gnt;

reg clk;
reg snoop_0, snoop_1, snoop_2, snoop_3;
reg snoop_give;
reg Mem_snoop_give;

always 
begin
	#1 clk = 1'b0;
	#1 clk = 1'b1;
end


assign	Com_Bus_Gnt_proc_0 = Com_Bus_Gnt_proc [0];
assign	Com_Bus_Gnt_proc_1 = Com_Bus_Gnt_proc [1];
assign	Com_Bus_Gnt_proc_2 = Com_Bus_Gnt_proc [2];
assign	Com_Bus_Gnt_proc_3 = Com_Bus_Gnt_proc [3];
assign	Com_Bus_Gnt_proc_4 = Com_Bus_Gnt_proc [4];
assign	Com_Bus_Gnt_proc_5 = Com_Bus_Gnt_proc [5];
assign	Com_Bus_Gnt_proc_6 = Com_Bus_Gnt_proc [6];
assign	Com_Bus_Gnt_proc_7 = Com_Bus_Gnt_proc [7];
    
assign	Com_Bus_Gnt_snoop_0 = Com_Bus_Gnt_snoop [0];
assign	Com_Bus_Gnt_snoop_1 = Com_Bus_Gnt_snoop [1];
assign	Com_Bus_Gnt_snoop_2 = Com_Bus_Gnt_snoop [2];
assign	Com_Bus_Gnt_snoop_3 = Com_Bus_Gnt_snoop [3];


reg 					rst;
wire  			[3:0] 	buf_out;
reg 					rd_en; 
wire 					buf_empty, buf_full; 
wire 	[`BUF_WIDTH :0] fifo_counter;

reg [1:0] state;
reg [1:0] current_proc;
reg snoop_done;

integer temp;
integer temp_snoop;

parameter IDLE 		= 2'b00;
parameter PROC_REQ 	= 2'b01;
parameter SNOOP_REQ = 2'b10;
parameter MEM_REQ 	= 2'b11;

parameter PROC1		= 4'b0001;
parameter PROC2		= 4'b0010;
parameter PROC3		= 4'b0011;
parameter PROC4		= 4'b0100;
parameter PROC5		= 4'b0101;
parameter PROC6		= 4'b0110;
parameter PROC7		= 4'b0111;
parameter PROC8		= 4'b1000;

initial
begin
	#1 rst = 1'b1;
	#2 rst = 1'b0;
end

fifo f1 (Com_Bus_Req_proc[0], Com_Bus_Req_proc[1], Com_Bus_Req_proc[2], Com_Bus_Req_proc[3],Com_Bus_Req_proc[4], Com_Bus_Req_proc[5], Com_Bus_Req_proc[6], Com_Bus_Req_proc[7], rst, buf_out, rd_en, buf_empty, buf_full, fifo_counter);

// Logic for rd_en
//always @ *
always @ (posedge clk)
begin
	if (rst)
		rd_en = 1'b0;
	else
	begin
		if ((state == IDLE) && !buf_empty)
			rd_en = 1'b1;
		else
			rd_en = 1'b0;
	end
end

always @ *
begin
	case (buf_out)
		PROC1:
			temp = 0;
		PROC2:
			temp = 1;
		PROC3:
			temp = 2;
		PROC4:
			temp = 3;
		PROC5:
			temp = 4;
		PROC6:
			temp = 5;
		PROC7:
			temp = 6;
		PROC8:
			temp = 7;
	endcase
end


//arbiter state diagram
//FSM
//always @ *
always @ (posedge clk)
begin
	if (rst)
		state = IDLE;
	else
	begin
	case (state)
		IDLE:
			if (!buf_empty || buf_out != 4'b0000)
			begin
				state = PROC_REQ;
			end
			else
				state = IDLE;
		PROC_REQ:
			if (!snoop_done && snoop_give)
				state = SNOOP_REQ;
			else if (!snoop_done && Mem_snoop_give)
				state = MEM_REQ;
			else if (Com_Bus_Req_proc [temp] == 1'b0)
			begin
				state = IDLE;
			end
			else	
				state = PROC_REQ;
		SNOOP_REQ:
			if (Com_Bus_Req_snoop[temp_snoop] == 1'b0)
			begin
				state = PROC_REQ;
				//snoop_done = 1'b1;
			end
			else
				state = SNOOP_REQ;
		MEM_REQ:
			if (Mem_snoop_req == 1'b0)
			begin
				state = PROC_REQ;
				//snoop_done = 1'b1;
			end
			else
				state = MEM_REQ;
		default:
				state = state;
	endcase
	end
end

always @ (Mem_snoop_req or posedge rst)
begin
	if (rst)
		Mem_snoop_give = 1'b0;
	else if (state == PROC_REQ && Mem_snoop_req)
		Mem_snoop_give = 1'b1;
	else	
		Mem_snoop_give	= 1'b0;
end

always @ (Com_Bus_Req_snoop[0] or posedge rst)
begin
	if (rst)
		snoop_0 = 1'b0;
	else if (state == PROC_REQ && temp!= 0 && Com_Bus_Req_snoop[0])
	begin
		snoop_0 = 1'b1;
	end
	else
		snoop_0 = 1'b0;
end
always @ (Com_Bus_Req_snoop[1]  or posedge rst)
begin
	if (rst)
		snoop_1 = 1'b0;
	else if (state == PROC_REQ && temp!= 1 && Com_Bus_Req_snoop[1])
	begin
		snoop_1 = 1'b1;
	end
	else
		snoop_1 = 1'b0;
end
always @ (Com_Bus_Req_snoop[2]  or posedge rst)
begin
	if (rst)
		snoop_2 = 1'b0;
	else if (state == PROC_REQ && temp!= 2 && Com_Bus_Req_snoop[2])
	begin
		snoop_2 = 1'b1;
	end
	else
		snoop_2 = 1'b0;
end
always @ (Com_Bus_Req_snoop[3]  or posedge rst)
begin
	if (rst)
		snoop_3 = 1'b0;
	else if (state == PROC_REQ && temp!= 3 && Com_Bus_Req_snoop[3])
	begin
		snoop_3 = 1'b1;
	end
	else
		snoop_3 = 1'b0;
end


always @ *
begin
if (state == PROC_REQ && !snoop_done)
begin
	casex ({snoop_0,snoop_1,snoop_2,snoop_3})
		4'b1xxx:
		begin
			temp_snoop = 0;
			snoop_give = 1'b1;
		end
		4'b01xx:
		begin
			temp_snoop = 1;
			snoop_give = 1'b1;
		end		
		4'b001x:
		begin
			temp_snoop = 2;
			snoop_give = 1'b1;
		end		
		4'b0001:
		begin
			temp_snoop = 3;
			snoop_give = 1'b1;
		end
		default:
		begin
			temp_snoop = 0;
			snoop_give = 1'b0;
		end
	endcase
end
end

/*
always @ (posedge Com_Bus_Req_snoop [0] or posedge Com_Bus_Req_snoop [1] or posedge Com_Bus_Req_snoop [2] or posedge Com_Bus_Req_snoop [3] or posedge Mem_snoop_req)
begin
	if (state == PROC_REQ)
	begin
		if (Com_Bus_Req_snoop [0] == 1'b1 && temp != 0)
			temp_snoop = 0;
		else if (Com_Bus_Req_snoop [1] == 1'b1 && temp != 1)
			temp_snoop = 1;
		else if (Com_Bus_Req_snoop [2] == 1'b1 && temp != 2)
			temp_snoop = 2;
		else if (Com_Bus_Req_snoop [3] == 1'b1 && temp != 3)
			temp_snoop = 3;
		else if 
	end
end
*/

//output logic
always @ *
//always @ (posedge clk)
begin
	if (rst)
	begin
		Com_Bus_Gnt_proc[0] = 1'b0;
		Com_Bus_Gnt_proc[1] = 1'b0;
		Com_Bus_Gnt_proc[2] = 1'b0;
		Com_Bus_Gnt_proc[3] = 1'b0;
		Com_Bus_Gnt_proc[4] = 1'b0;
		Com_Bus_Gnt_proc[5] = 1'b0;
		Com_Bus_Gnt_proc[6] = 1'b0;
		Com_Bus_Gnt_proc[7] = 1'b0;
		Com_Bus_Gnt_snoop[0] = 1'b0;
		Com_Bus_Gnt_snoop[1] = 1'b0;
		Com_Bus_Gnt_snoop[2] = 1'b0;
		Com_Bus_Gnt_snoop[3] = 1'b0;
		Mem_snoop_gnt	= 1'b0;
	end
	else
	case (state)
		IDLE:
		begin
			snoop_done = 1'b0;
			if (Com_Bus_Req_proc [temp] == 1'b0)
			begin
				Com_Bus_Gnt_proc [temp] = 1'b0;
			end
		end
		PROC_REQ:
		begin
			if (Com_Bus_Req_proc [temp] == 1'b1)
			begin
				Com_Bus_Gnt_proc [temp] = 1'b1;
			end
			if (Com_Bus_Req_snoop [temp_snoop] == 1'b0)
				Com_Bus_Gnt_snoop [temp_snoop] = 1'b0;
			if (Mem_snoop_req == 1'b0)
				Mem_snoop_gnt = 1'b0;
		end
		SNOOP_REQ:
		begin
			snoop_done = 1'b1;
			if (Com_Bus_Req_snoop [temp_snoop] == 1'b1)
				Com_Bus_Gnt_snoop [temp_snoop] = 1'b1;
		end
		MEM_REQ:
		begin
			snoop_done = 1'b1;
			if (Mem_snoop_req == 1'b1)
				Mem_snoop_gnt = 1'b1;	
		end
		default:
		begin
			Com_Bus_Gnt_proc [temp] 		= 1'b0;
			Com_Bus_Gnt_snoop [temp_snoop] 	= 1'b0;
			Mem_snoop_gnt 					= 1'b0;
		end
	endcase
end

endmodule