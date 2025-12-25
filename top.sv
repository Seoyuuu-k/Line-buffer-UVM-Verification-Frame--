module top;
  import uvm_pkg::*;
  import lb_ro_pkg::*;

  reg nReset;
  reg SystemClock = 0;

  always #10 SystemClock = ~SystemClock;

  initial begin
    #10 nReset = 0;
    #30 nReset = 1;
  end

  linebuf_rgboffset_top #(
    .VER_WIDTH  (`VER_WIDTH ),
    .HOR_WIDTH  (`HOR_WIDTH ),
    .RGB_WIDTH  (`RGB_WIDTH ),
    .ADDR_WIDTH (`ADDR_WIDTH),
    .DATA_WIDTH (`DATA_WIDTH)
  ) dut();

  `include "intf_insts.sv"

  initial begin
    uvm_config_db#(virtual lb_ro_if)::set(null, "uvm_test_top.tb.lb_ro_env.lb_ro_agent*", "lb_ro_vif", lb_ro_intf);
    uvm_config_db#(virtual lb_ro_if)::set(null, "uvm_test_top.tb.vseqr*", "lb_ro_vif", lb_ro_intf);

    run_test("video_test_c");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top);
  end

endmodule
