class video_test_c extends base_test_c;
  `uvm_component_utils(video_test_c)

  function new (string name="video_test_c", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(uvm_object_wrapper)::set(this, "tb.vseqr.run_phase", "default_sequence", video::type_id::get());
  endfunction

  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);

    uvm_top.print_topology();
  endfunction

endclass


class video extends base_vseq_c;
  `uvm_object_utils(video)

  lb_ro_vseq_c    lb_ro_vseq;

  function new (string name = "video");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), $sformatf("-----------------------------"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("----- Start video_test -----"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("-----------------------------"), UVM_LOW)

    @(posedge p_sequencer.lb_ro_vif.i_rstn);
    `uvm_info(get_type_name(), $sformatf("Reset ended"), UVM_LOW)

    `uvm_do_on_with(lb_ro_vseq, p_sequencer.lb_ro_seqr,
                    {
                      data_mode         == RANDOM ; // RANDOM, FIX, INCREASE
                     //  fix_r_data        == 5        ;
                     //  fix_g_data        == 5        ;
                     //  fix_b_data        == 5        ;
                      user_bypass       == 0        ;
                      user_offset_val   == 10       ;
                      user_vsw          == 1        ;
                      user_vbp          == 1        ;
                      user_vact         == 3        ;
                      user_vfp          == 1        ;
                      user_hsw          == 1        ;
                      user_hbp          == 2        ;
                      user_hact         == 3       ;
                      user_hfp          == 2        ;
                    })

    repeat(4) @(posedge p_sequencer.lb_ro_vif.i_clk);
    `uvm_info(get_type_name(), $sformatf("-------------------------------"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("-----------TEST DONE-----------"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("-------------------------------"), UVM_LOW)
  endtask

endclass
