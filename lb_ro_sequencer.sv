class lb_ro_sequencer_c extends uvm_sequencer#(lb_ro_drv_pkt_c);
  `uvm_component_utils(lb_ro_sequencer_c)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
