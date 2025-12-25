class lb_ro_driver_c extends uvm_driver#(lb_ro_drv_pkt_c);
  `uvm_component_utils(lb_ro_driver_c)

  virtual lb_ro_if lb_ro_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual lb_ro_if)::get(this, "", "lb_ro_vif", lb_ro_vif)) begin
      `uvm_fatal(get_type_name(), "Virtual Interface not set for Driver")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    @(negedge lb_ro_vif.i_rstn);
    reset_signals();
    forever begin
      @(posedge lb_ro_vif.i_rstn);
      while (lb_ro_vif.i_rstn) begin
        drive_signals();
      end
      reset_signals();
    end
  endtask

  virtual task reset_signals();
    lb_ro_vif.i_bypass <= 0;
    lb_ro_vif.i_offset_val <= 0;
    lb_ro_vif.i_vsync <= 0;
    lb_ro_vif.i_hsync <= 0;
    lb_ro_vif.i_de <= 0;
    lb_ro_vif.i_r_data <= 0;
    lb_ro_vif.i_g_data <= 0;
    lb_ro_vif.i_b_data <= 0;
  endtask

  virtual task drive_signals();
    seq_item_port.get_next_item(req);
    @(posedge lb_ro_vif.i_clk);

    lb_ro_vif.i_bypass     <= req.i_bypass;
    lb_ro_vif.i_offset_val <= req.i_offset_val;
    lb_ro_vif.i_vsw  <= req.i_vsw;  lb_ro_vif.i_vbp  <= req.i_vbp;
    lb_ro_vif.i_vact <= req.i_vact; lb_ro_vif.i_vfp  <= req.i_vfp;
    lb_ro_vif.i_hsw  <= req.i_hsw;  lb_ro_vif.i_hbp  <= req.i_hbp;
    lb_ro_vif.i_hact <= req.i_hact; lb_ro_vif.i_hfp  <= req.i_hfp;

    lb_ro_vif.i_vsync  <= req.i_vsync;
    lb_ro_vif.i_hsync  <= req.i_hsync;
    lb_ro_vif.i_de     <= req.i_de;
    lb_ro_vif.i_r_data <= req.i_r_data;
    lb_ro_vif.i_g_data <= req.i_g_data;
    lb_ro_vif.i_b_data <= req.i_b_data;
    
    seq_item_port.item_done();
  endtask
endclass