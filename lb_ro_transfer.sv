
typedef struct packed {
  bit [`RGB_WIDTH-1:0] r;
  bit [`RGB_WIDTH-1:0] g;
  bit [`RGB_WIDTH-1:0] b;
} rgb_t;



class lb_ro_drv_pkt_c extends uvm_sequence_item;

  // control
  bit                   i_bypass;
  bit [`RGB_WIDTH-1:0]  i_offset_val;

  // timing params
  bit [`VER_WIDTH-1:0]  i_vsw,  i_vbp,  i_vact, i_vfp;
  bit [`HOR_WIDTH-1:0]  i_hsw,  i_hbp,  i_hact, i_hfp;

  // video timing
  bit                   i_vsync;
  bit                   i_hsync;
  bit                   i_de;

  // video pixel
  rand bit [`RGB_WIDTH-1:0]  i_r_data;
  rand bit [`RGB_WIDTH-1:0]  i_g_data;
  rand bit [`RGB_WIDTH-1:0]  i_b_data;

  `uvm_object_utils_begin(lb_ro_drv_pkt_c)
    `uvm_field_int(i_bypass     , UVM_DEFAULT)
    `uvm_field_int(i_offset_val , UVM_DEFAULT)

    `uvm_field_int(i_vsw        , UVM_DEFAULT)
    `uvm_field_int(i_vbp        , UVM_DEFAULT)
    `uvm_field_int(i_vact       , UVM_DEFAULT)
    `uvm_field_int(i_vfp        , UVM_DEFAULT)
    `uvm_field_int(i_hsw        , UVM_DEFAULT)
    `uvm_field_int(i_hbp        , UVM_DEFAULT)
    `uvm_field_int(i_hact       , UVM_DEFAULT)
    `uvm_field_int(i_hfp        , UVM_DEFAULT)

    `uvm_field_int(i_vsync      , UVM_DEFAULT)
    `uvm_field_int(i_hsync      , UVM_DEFAULT)
    `uvm_field_int(i_de         , UVM_DEFAULT)

    `uvm_field_int(i_r_data     , UVM_DEFAULT)
    `uvm_field_int(i_g_data     , UVM_DEFAULT)
    `uvm_field_int(i_b_data     , UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name="lb_ro_drv_pkt_c");
    super.new(name);
  endfunction

endclass




class lb_ro_mon_pkt_c extends uvm_sequence_item;


  bit                   i_bypass;
  bit [`RGB_WIDTH-1:0]  i_offset_val;

  bit [`VER_WIDTH-1:0]  i_vsw,  i_vbp,  i_vact, i_vfp;
  bit [`HOR_WIDTH-1:0]  i_hsw,  i_hbp,  i_hact, i_hfp;

  bit                   i_vsync;
  bit                   i_hsync;
  bit                   i_de;

  bit [`RGB_WIDTH-1:0]  i_r_data;
  bit [`RGB_WIDTH-1:0]  i_g_data;
  bit [`RGB_WIDTH-1:0]  i_b_data;

  bit                   o_vsync;
  bit                   o_hsync;
  bit                   o_de;

  // pixel data (PKT_PIXEL)
  bit [`RGB_WIDTH-1:0]  o_r_data;
  bit [`RGB_WIDTH-1:0]  o_g_data;
  bit [`RGB_WIDTH-1:0]  o_b_data;

  // -----------------
  // LINE (PKT_LINE)
  // -----------------
  int unsigned          line_idx;
  int unsigned          in_pix_cnt;
  int unsigned          out_pix_cnt;

  rgb_t                 in_pix_q[$];
  rgb_t                 out_pix_q[$];

  `uvm_object_utils_begin(lb_ro_mon_pkt_c)

    `uvm_field_int(i_bypass     , UVM_DEFAULT)
    `uvm_field_int(i_offset_val , UVM_DEFAULT)

    `uvm_field_int(i_vsw        , UVM_DEFAULT)
    `uvm_field_int(i_vbp        , UVM_DEFAULT)
    `uvm_field_int(i_vact       , UVM_DEFAULT)
    `uvm_field_int(i_vfp        , UVM_DEFAULT)

    `uvm_field_int(i_hsw        , UVM_DEFAULT)
    `uvm_field_int(i_hbp        , UVM_DEFAULT)
    `uvm_field_int(i_hact       , UVM_DEFAULT)
    `uvm_field_int(i_hfp        , UVM_DEFAULT)

    `uvm_field_int(i_vsync      , UVM_DEFAULT)
    `uvm_field_int(i_hsync      , UVM_DEFAULT)
    `uvm_field_int(i_de         , UVM_DEFAULT)

    `uvm_field_int(i_r_data     , UVM_DEFAULT)
    `uvm_field_int(i_g_data     , UVM_DEFAULT)
    `uvm_field_int(i_b_data     , UVM_DEFAULT)

    `uvm_field_int(o_vsync      , UVM_DEFAULT)
    `uvm_field_int(o_hsync      , UVM_DEFAULT)
    `uvm_field_int(o_de         , UVM_DEFAULT)

    `uvm_field_int(o_r_data     , UVM_DEFAULT)
    `uvm_field_int(o_g_data     , UVM_DEFAULT)
    `uvm_field_int(o_b_data     , UVM_DEFAULT)

    `uvm_field_int(line_idx     , UVM_DEFAULT)
    `uvm_field_int(in_pix_cnt   , UVM_DEFAULT)
    `uvm_field_int(out_pix_cnt  , UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name="lb_ro_mon_pkt_c");
    super.new(name);
    line_idx    = 0;
    in_pix_cnt  = 0;
    out_pix_cnt = 0;
  endfunction

endclass



class lb_ro_frame_mon_pkt_c extends uvm_object;
  `uvm_object_utils(lb_ro_frame_mon_pkt_c)

  int frame_id;

  bit                   bypass;
  bit [`RGB_WIDTH-1:0]  offset_val;

  lb_ro_mon_pkt_c lines[$];
  int vact;
  int hact;

  function new(string name="lb_ro_frame_mon_pkt_c");
    super.new(name);
  endfunction
endclass