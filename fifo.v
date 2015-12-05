`define BUF_WIDTH 3   // BUF_SIZE = 16 -> BUF_WIDTH = 4, no. of bits to be used in pointer
`define BUF_SIZE ( 1<<`BUF_WIDTH )

module fifo(Com_Bus_req_Gnt[0], Com_Bus_req_Gnt[1], Com_Bus_req_Gnt[2], Com_Bus_req_Gnt[3], Com_Bus_req_Gnt[4], Com_Bus_req_Gnt[5], Com_Bus_req_Gnt[6], Com_Bus_req_Gnt[7], rst, buf_out, rd_en, buf_empty, buf_full, fifo_counter );

input                 rst;
input Com_Bus_req_Gnt[0:7];
//input Com_Bus_req_Gnt[1], Com_Bus_req_Gnt[2], Com_Bus_req_Gnt[3];
input rd_en;   
// reset, system clock, write enable and read enable.

output[3:0]           buf_out;                  
// port to output the data using pop.
output                buf_empty, buf_full;      
// buffer empty and full indication 
output[`BUF_WIDTH :0] fifo_counter;             
// number of data pushed in to buffer   
reg[3:0]			  buf_in;
reg[3:0]              buf_out;
reg                   buf_empty, buf_full;
reg[`BUF_WIDTH :0]    fifo_counter;
reg[`BUF_WIDTH -1:0]  rd_ptr, wr_ptr;           // pointer to read and write addresses  
reg[3:0]              buf_mem[`BUF_SIZE -1 : 0]; //  

reg 				wr_en;
reg 				  prev[0:7];

always @(fifo_counter or posedge rd_en)
begin
   buf_empty = (fifo_counter==0);
   buf_full = (fifo_counter== `BUF_SIZE);
	wr_en = 1'b0;
end

always @(posedge Com_Bus_req_Gnt[0] or posedge Com_Bus_req_Gnt[1] or posedge  Com_Bus_req_Gnt[2] or posedge  Com_Bus_req_Gnt[3] or posedge Com_Bus_req_Gnt[4] or posedge Com_Bus_req_Gnt[5] or posedge  Com_Bus_req_Gnt[6] or posedge  Com_Bus_req_Gnt[7] or posedge rst or posedge rd_en or posedge wr_en)
begin
   if( rst )
       fifo_counter <= 0;

   else if( (!buf_full && wr_en) && ( !buf_empty && rd_en ) )
       fifo_counter <= fifo_counter;

   else if( !buf_full && wr_en )
       fifo_counter <= fifo_counter + 1;

   else if( !buf_empty && rd_en )
       fifo_counter <= fifo_counter - 1;
   else
      fifo_counter <= fifo_counter;
	  

end

always @(posedge rst or posedge rd_en)
begin
   if( rst )
   begin
	buf_out <= 0;
	prev [0] = 1'b0;
	prev [1] = 1'b0;
	prev [2] = 1'b0;
	prev [3] = 1'b0;
	prev [4] = 1'b0;
	prev [5] = 1'b0;
	prev [6] = 1'b0;
	prev [7] = 1'b0;
   end
   else
   begin
      if( rd_en && !buf_empty )
         buf_out <= buf_mem[rd_ptr];
      else
         buf_out <= 4'b0000;
   end
end


always @(posedge Com_Bus_req_Gnt[0] or posedge Com_Bus_req_Gnt[1] or posedge Com_Bus_req_Gnt[2] or posedge Com_Bus_req_Gnt[3] or posedge Com_Bus_req_Gnt[4] or posedge Com_Bus_req_Gnt[5] or posedge Com_Bus_req_Gnt[6] or posedge Com_Bus_req_Gnt[7] or rst)
begin
if (rst)
begin
		wr_en = 1'b0;
		buf_in = 4'b0000;
end
else
begin

	  if (prev [0] != Com_Bus_req_Gnt[0])
	  begin
		buf_in = 4'b0001;
		wr_en = 1'b1;
	  end
	  else if (prev [1] != Com_Bus_req_Gnt[1])
	  begin
		buf_in = 4'b0010;
		wr_en = 1'b1;
	  end
	  else if (prev [2] != Com_Bus_req_Gnt[2])
	  begin
		buf_in = 4'b0011;
		wr_en = 1'b1;
	  end
	  else if (prev [3] != Com_Bus_req_Gnt[3])
	  begin
		buf_in = 4'b0100;
		wr_en = 1'b1;
	  end
	  else if (prev [4] != Com_Bus_req_Gnt[4])
	  begin
		buf_in = 4'b0101;
		wr_en = 1'b1;
	  end
	  else if (prev [5] != Com_Bus_req_Gnt[5])
	  begin
		buf_in = 4'b0110;
		wr_en = 1'b1;
	  end
	  else if (prev [6] != Com_Bus_req_Gnt[6])
	  begin
		buf_in = 4'b0111;
		wr_en = 1'b1;
	  end
	  else if (prev [7] != Com_Bus_req_Gnt[7])
	  begin
		buf_in = 4'b1000;
		wr_en = 1'b1;
	  end
	  else
	  begin
		buf_in = 4'b0000;
		wr_en = 1'b0;
	  end
end
end

always @ (Com_Bus_req_Gnt[0] or Com_Bus_req_Gnt[1] or Com_Bus_req_Gnt[2] or Com_Bus_req_Gnt[3] or Com_Bus_req_Gnt[4] or Com_Bus_req_Gnt[5] or Com_Bus_req_Gnt[6] or Com_Bus_req_Gnt[7])
begin
	#10 wr_en = 1'b0;
	prev[0] = Com_Bus_req_Gnt[0];
	prev[1] = Com_Bus_req_Gnt[1];
	prev[2] = Com_Bus_req_Gnt[2];
	prev[3] = Com_Bus_req_Gnt[3];
	prev[4] = Com_Bus_req_Gnt[4];
	prev[5] = Com_Bus_req_Gnt[5];
	prev[6] = Com_Bus_req_Gnt[6];
	prev[7] = Com_Bus_req_Gnt[7];
end

always @(posedge wr_en)
begin

   if( wr_en && !buf_full )
   begin 
	  buf_mem[ wr_ptr ] <= buf_in; 
   end
   else
      buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
end

always@(posedge Com_Bus_req_Gnt[0] or posedge Com_Bus_req_Gnt[1] or posedge  Com_Bus_req_Gnt[2] or posedge  Com_Bus_req_Gnt[3] or posedge Com_Bus_req_Gnt[4] or posedge Com_Bus_req_Gnt[5] or posedge  Com_Bus_req_Gnt[6] or posedge  Com_Bus_req_Gnt[7] or posedge rst or posedge rd_en)
begin
   if( rst )
   begin
      wr_ptr <= 0;
      rd_ptr <= 0;
   end
   else
   begin
      if( !buf_full && wr_en )    wr_ptr <= wr_ptr + 1;
          else  wr_ptr <= wr_ptr;

      if( !buf_empty && rd_en )   rd_ptr <= rd_ptr + 1;
      else rd_ptr <= rd_ptr;
   end

end
endmodule