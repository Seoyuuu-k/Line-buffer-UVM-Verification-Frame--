class lb_ro_agent_c extends uvm_agent;
  `uvm_component_utils_begin(lb_ro_agent_c)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
  `uvm_component_utils_end

  lb_ro_sequencer_c lb_ro_sequencer ;
  lb_ro_driver_c    lb_ro_driver    ;
  lb_ro_monitor_c   lb_ro_monitor   ;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), $sformatf("build_phase() starts.."), UVM_LOW)

    if(!uvm_config_db#(uvm_active_passive_enum)::get(this,"","is_active",is_active))
      `uvm_error(get_full_name(), "is_active not configured");

    if (is_active == UVM_ACTIVE) begin
      `uvm_info(get_type_name(), $sformatf("is_active = UVM_ACTIVE"), UVM_LOW)
      lb_ro_sequencer = lb_ro_sequencer_c::type_id::create("lb_ro_sequencer", this);
      lb_ro_driver = lb_ro_driver_c::type_id::create("lb_ro_driver", this);
    end
    lb_ro_monitor = lb_ro_monitor_c::type_id::create("lb_ro_monitor", this);

    `uvm_info(get_type_name(), $sformatf("build_phase() ends.."), UVM_LOW)
  endfunction

  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);

    if (is_active == UVM_ACTIVE) begin
      lb_ro_driver.seq_item_port.connect(lb_ro_sequencer.seq_item_export);
    end
  endfunction

endclass
