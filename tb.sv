class tb_c extends uvm_env;
  `uvm_component_utils(tb_c)
  
  vseqr_c      vseqr;
  lb_ro_env_c  lb_ro_env; // [수정] adder_env -> lb_ro_env
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_full_name(), $sformatf("build_phase() starts.."), UVM_LOW)
    
    vseqr     = vseqr_c::type_id::create("vseqr", this);
    lb_ro_env = lb_ro_env_c::type_id::create("lb_ro_env", this); // [수정] 생성
    
    `uvm_info(get_full_name(), $sformatf("build_phase() ends.."), UVM_LOW)
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), $sformatf("connect_phase() starts.."), UVM_LOW)
    
    // Virtual Sequencer 연결
    vseqr.lb_ro_seqr = lb_ro_env.lb_ro_agent.lb_ro_sequencer;
    
    `uvm_info(get_type_name(), $sformatf("connect_phase() ends.."), UVM_LOW)
  endfunction
  
endclass