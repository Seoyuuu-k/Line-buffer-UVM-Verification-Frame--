class lb_ro_env_c extends uvm_env;
  `uvm_component_utils(lb_ro_env_c)

  lb_ro_agent_c lb_ro_agent ;
  lb_ro_sb_c    lb_ro_sb    ;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), $sformatf("build_phase() starts.."), UVM_LOW)

    lb_ro_agent = lb_ro_agent_c::type_id::create("lb_ro_agent", this);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "lb_ro_agent", "is_active", UVM_ACTIVE);
    lb_ro_sb = lb_ro_sb_c::type_id::create("lb_ro_sb", this);

    `uvm_info(get_type_name(), $sformatf("build_phase() ends.."), UVM_LOW)
  endfunction

  function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  // (FRAME) monitor -> scoreboard
  lb_ro_agent.lb_ro_monitor.in_frame_port.connect(lb_ro_sb.in_frame_imp);
  lb_ro_agent.lb_ro_monitor.out_frame_port.connect(lb_ro_sb.out_frame_imp);

endfunction
endclass