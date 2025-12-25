class lb_ro_vseq_c extends uvm_sequence;
  `uvm_object_utils(lb_ro_vseq_c)

  lb_ro_user_seq_c  lb_ro_user_seq  ;

  rand data_mode_e              data_mode       ; // RANDOM, FIX, INCREASE
  rand bit  [`RGB_WIDTH-1:0]    fix_r_data      ; // active only in data_mode = 1
  rand bit  [`RGB_WIDTH-1:0]    fix_g_data      ;
  rand bit  [`RGB_WIDTH-1:0]    fix_b_data      ;
  rand bit                      user_bypass     ;
  rand bit  [`RGB_WIDTH-1:0]    user_offset_val ;
  rand bit  [`VER_WIDTH-1:0]    user_vsw        ;
  rand bit  [`VER_WIDTH-1:0]    user_vbp        ;
  rand bit  [`VER_WIDTH-1:0]    user_vact       ;
  rand bit  [`VER_WIDTH-1:0]    user_vfp        ;
  rand bit  [`HOR_WIDTH-1:0]    user_hsw        ;
  rand bit  [`HOR_WIDTH-1:0]    user_hbp        ;
  rand bit  [`HOR_WIDTH-1:0]    user_hact       ;
  rand bit  [`HOR_WIDTH-1:0]    user_hfp        ;

  constraint lb_ro_mode_set_default {
    soft data_mode          == 0;
    soft fix_r_data         == 0;
    soft fix_g_data         == 0;
    soft fix_b_data         == 0;
    soft user_bypass        == 0;
    soft user_offset_val    == 0;
    soft user_vsw           == 0;
    soft user_vbp           == 0;
    soft user_vact          == 0;
    soft user_vfp           == 0;
    soft user_hsw           == 0;
    soft user_hbp           == 0;
    soft user_hact          == 0;
    soft user_hfp           == 0;
  }

  function new(string name = "lb_ro_vseq_c");
    super.new(name);
    lb_ro_user_seq = lb_ro_user_seq_c::type_id::create("lb_ro_user_seq");
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), $psprintf("lb_ro_vseq_c starts.."), UVM_LOW)

    lb_ro_user_seq.data_mode                = data_mode         ;
    lb_ro_user_seq.fix_r_data               = fix_r_data        ;
    lb_ro_user_seq.fix_g_data               = fix_g_data        ;
    lb_ro_user_seq.fix_b_data               = fix_b_data        ;
    lb_ro_user_seq.rnd_item.i_bypass        = user_bypass       ;
    lb_ro_user_seq.rnd_item.i_offset_val    = user_offset_val   ;
    lb_ro_user_seq.rnd_item.i_vsw           = user_vsw          ;
    lb_ro_user_seq.rnd_item.i_vbp           = user_vbp          ;
    lb_ro_user_seq.rnd_item.i_vact          = user_vact         ;
    lb_ro_user_seq.rnd_item.i_vfp           = user_vfp          ;
    lb_ro_user_seq.rnd_item.i_hsw           = user_hsw          ;
    lb_ro_user_seq.rnd_item.i_hbp           = user_hbp          ;
    lb_ro_user_seq.rnd_item.i_hact          = user_hact         ;
    lb_ro_user_seq.rnd_item.i_hfp           = user_hfp          ;
    `uvm_send(lb_ro_user_seq)
  endtask

endclass: lb_ro_vseq_c
