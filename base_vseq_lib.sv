class base_vseq_c extends uvm_sequence;
  `uvm_object_utils(base_vseq_c)
  `uvm_declare_p_sequencer(vseqr_c)

  function new(string name="base_vseq_c");
    super.new(name);
  endfunction

  virtual task pre_body();
    super.pre_body();
    if (starting_phase != null) begin
      `uvm_info(get_type_name(), $sformatf("Raise objection"), UVM_LOW)
      starting_phase.raise_objection(this, get_type_name()); // raise an objection
    end
  endtask

  virtual task post_body();
    super.post_body();
    if (starting_phase != null) begin
      `uvm_info(get_type_name(), $sformatf("Drop objection"), UVM_LOW)
      starting_phase.drop_objection(this, get_type_name()); // drop an objection
    end
  endtask

endclass
