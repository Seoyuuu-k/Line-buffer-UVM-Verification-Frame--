lb_ro_if lb_ro_intf(.i_clk(SystemClock), .i_rstn(nReset));

assign dut.clk          = SystemClock;
assign dut.rstn         = nReset;

// control
assign dut.i_bypass     = lb_ro_intf.i_bypass;
assign dut.i_offset_val = lb_ro_intf.i_offset_val;

// timing
assign dut.i_vsw        = lb_ro_intf.i_vsw;
assign dut.i_vbp        = lb_ro_intf.i_vbp;
assign dut.i_vact       = lb_ro_intf.i_vact;
assign dut.i_vfp        = lb_ro_intf.i_vfp;
assign dut.i_hsw        = lb_ro_intf.i_hsw;
assign dut.i_hbp        = lb_ro_intf.i_hbp;
assign dut.i_hact       = lb_ro_intf.i_hact;
assign dut.i_hfp        = lb_ro_intf.i_hfp;

// video input
assign dut.i_vsync      = lb_ro_intf.i_vsync;
assign dut.i_hsync      = lb_ro_intf.i_hsync;
assign dut.i_de         = lb_ro_intf.i_de;
assign dut.i_r_data     = lb_ro_intf.i_r_data;
assign dut.i_g_data     = lb_ro_intf.i_g_data;
assign dut.i_b_data     = lb_ro_intf.i_b_data;

// video output
assign lb_ro_intf.o_vsync = dut.o_vsync;
assign lb_ro_intf.o_hsync = dut.o_hsync;
assign lb_ro_intf.o_de    = dut.o_de;
assign lb_ro_intf.o_r_data= dut.o_r_data;
assign lb_ro_intf.o_g_data= dut.o_g_data;
assign lb_ro_intf.o_b_data= dut.o_b_data;