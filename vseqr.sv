class vseqr_c extends uvm_sequencer;
  `uvm_component_utils(vseqr_c)

  virtual interface lb_ro_if lb_ro_vif;
  lb_ro_sequencer_c lb_ro_seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual lb_ro_if)::get(this, "", "lb_ro_vif", lb_ro_vif)) begin
      `uvm_fatal(get_type_name(), "Virtual Interface not set for vseqr")
    end
  endfunction
endclass