class base_test_c extends uvm_test;
  `uvm_component_utils(base_test_c)

  tb_c tb;

  function new(string name = "base_test_c", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    tb = tb_c::type_id::create("tb", this);
  endfunction

endclass
