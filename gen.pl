

open(OUTF,'>intf.txt');

my $indx = 0;
while($indx <= 7) {
   my $indx1 = $indx + 1;
   #print OUTF "g_intf.Updated_MESI_state_proc[$indx]  = P"."$indx1"."_DL.cb.Updated_MESI_state_proc; 
               #g_intf.Blk_access_proc[$indx]          = P"."$indx1"."_DL.cb.Blk_access_proc;
               #g_intf.Blk_access_snoop[$indx]         = P"."$indx1"."_DL.cb.Blk_access_snoop;
               #g_intf.Index_snoop[$indx]              = P"."$indx1"."_DL.cb.Index_snoop;\n\n";
      
   
   #print OUTF "                               assign  g_intf[$indx1].Address_Com =      g_intf[0].Address_Com,
					#      assign  g_intf[0].Data_Bus_Com	 =	g_intf[0].Data_Bus_Com,
					 #     g_intf[0].Data_in_Bus		g_intf[0].Data_in_Bus,
					#			g_intf[0].Mem_wr,
					#			g_intf[0].Mem_oprn_abort,
					#			g_intf[0].Mem_write_do
   my $p = "P"."$indx1"."_DL";
    print OUTF "assign g_intf.Cache_var[$indx]            = CMC.$p.cb.Cache_var;
 assign g_intf.Cache_proc_contr[$indx]     = CMC.$p.cb.Cache_proc_contr;
 assign g_intf.LRU_var[$indx]              = CMC.$p.cc.LRU_var;
 assign g_intf.LRU_replacement_proc[$indx] = CMC.$p.LRU_replacement_proc;\n\n";
 $indx += 1;
}