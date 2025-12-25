class lb_ro_base_seq_c extends uvm_sequence#(lb_ro_drv_pkt_c);
  `uvm_object_utils(lb_ro_base_seq_c)
  
    localparam int unsigned MAXRGB = (1 << `RGB_WIDTH) - 1; 

    function automatic int unsigned wrap_inc(input int unsigned v);
      return (v == MAXRGB) ? 0 : (v + 1);
    endfunction

  lb_ro_seq_item_c rnd_item;
  

  bit [`VER_WIDTH-1:0]  cfg_vsw, cfg_vbp, cfg_vact, cfg_vfp;
  bit [`HOR_WIDTH-1:0]  cfg_hsw, cfg_hbp, cfg_hact, cfg_hfp;

  function new (string name = "lb_ro_base_seq_c");
    super.new(name);
    rnd_item = new("rnd_item");
  endfunction
  

  task cache_cfg_from_item();
    cfg_vsw  = rnd_item.i_vsw;
    cfg_vbp  = rnd_item.i_vbp;
    cfg_vact = rnd_item.i_vact;
    cfg_vfp  = rnd_item.i_vfp;

    cfg_hsw  = rnd_item.i_hsw;
    cfg_hbp  = rnd_item.i_hbp;
    cfg_hact = rnd_item.i_hact;
    cfg_hfp  = rnd_item.i_hfp;
  endtask
  
    function int get_total_lines();
    return (cfg_vsw + cfg_vbp + cfg_vact + cfg_vfp);
  endfunction

  function int get_total_pixels();
    return (cfg_hsw + cfg_hbp + cfg_hact + cfg_hfp);
  endfunction
  
  
    task send_signal(
      input int x,
      input int y,
      input data_mode_e mode,
      input bit [`RGB_WIDTH-1:0] fix_r,
      input bit [`RGB_WIDTH-1:0] fix_g,
      input bit [`RGB_WIDTH-1:0] fix_b,
      inout int r_cnt,
      inout int g_cnt,
      inout int b_cnt
  );
    bit in_v_active, in_h_active;
    bit active_video;

    lb_ro_drv_pkt_c req;
    req = lb_ro_drv_pkt_c::type_id::create("req");

    start_item(req);

    // 1) Config (rnd_item 값 유지)
    req.i_bypass     = rnd_item.i_bypass;
    req.i_offset_val = rnd_item.i_offset_val;


    req.i_vsw  = cfg_vsw;  req.i_vbp  = cfg_vbp;
    req.i_vact = cfg_vact; req.i_vfp  = cfg_vfp;
    req.i_hsw  = cfg_hsw;  req.i_hbp  = cfg_hbp;
    req.i_hact = cfg_hact; req.i_hfp  = cfg_hfp;

    req.i_vsync = (y < cfg_vsw) ? 1'b1 : 1'b0;
    req.i_hsync = (x < cfg_hsw) ? 1'b1 : 1'b0;

    in_v_active  = (y >= (cfg_vsw + cfg_vbp)) 
      && (y < (cfg_vsw + cfg_vbp + cfg_vact));
    in_h_active  = (x >= (cfg_hsw + cfg_hbp)) 
      && (x < (cfg_hsw + cfg_hbp + cfg_hact));
    active_video = in_v_active && in_h_active;

    req.i_de = active_video;

    if (active_video) begin
      case (mode)
        FIX: begin
          req.i_r_data = fix_r;
          req.i_g_data = fix_g;
          req.i_b_data = fix_b;
        end

        INCREASE: begin
          req.i_r_data = r_cnt[`RGB_WIDTH-1:0];
          req.i_g_data = g_cnt[`RGB_WIDTH-1:0];
          req.i_b_data = b_cnt[`RGB_WIDTH-1:0];

          r_cnt = wrap_inc(r_cnt);
          g_cnt = wrap_inc(g_cnt);
          b_cnt = wrap_inc(b_cnt);
        end

        RANDOM: begin
            void'(req.randomize() with {
              i_r_data inside {[0:MAXRGB]};
              i_g_data inside {[0:MAXRGB]};
              i_b_data inside {[0:MAXRGB]};
            });
          end
      endcase
    end
    else begin
      req.i_r_data = '0;
      req.i_g_data = '0;
      req.i_b_data = '0;
    end

    finish_item(req);
  endtask
  
  
  task send_init(input int cycles = 1);
  lb_ro_drv_pkt_c req;

  cache_cfg_from_item();

  for (int i = 0; i < cycles; i++) begin
    req = lb_ro_drv_pkt_c::type_id::create($sformatf("init_req_%0d", i));

    start_item(req);


    req.i_bypass     = rnd_item.i_bypass;
    req.i_offset_val = rnd_item.i_offset_val;
    
    req.i_vsw  = cfg_vsw;  req.i_vbp  = cfg_vbp;
    req.i_vact = cfg_vact; req.i_vfp  = cfg_vfp;
    req.i_hsw  = cfg_hsw;  req.i_hbp  = cfg_hbp;
    req.i_hact = cfg_hact; req.i_hfp  = cfg_hfp;

    // idle cycle
    req.i_vsync = 1'b0;
    req.i_hsync = 1'b0;
    req.i_de    = 1'b0;
    req.i_r_data = '0;
    req.i_g_data = '0;
    req.i_b_data = '0;

    finish_item(req);
  end
endtask

  
  
endclass




class lb_ro_user_seq_c extends lb_ro_base_seq_c;
  `uvm_object_utils(lb_ro_user_seq_c)

  data_mode_e           data_mode;
  bit [`RGB_WIDTH-1:0]  fix_r_data, fix_g_data, fix_b_data;

  function new(string name="lb_ro_user_seq_c");
    super.new(name);
  endfunction


  task send_line(
    input int y,
    input int total_pixels,
    input data_mode_e mode,
    input bit [`RGB_WIDTH-1:0] fix_r,
    input bit [`RGB_WIDTH-1:0] fix_g,
    input bit [`RGB_WIDTH-1:0] fix_b,
    inout int r_cnt,
    inout int g_cnt,
    inout int b_cnt
  );
    for (int x = 0; x < total_pixels; x++) begin
      send_signal(x, y, mode, fix_r, fix_g, fix_b, r_cnt, g_cnt, b_cnt);
    end
  endtask

  task send_frame(
    input int frames = 1,
    input data_mode_e mode,
    input bit [`RGB_WIDTH-1:0] fix_r,
    input bit [`RGB_WIDTH-1:0] fix_g,
    input bit [`RGB_WIDTH-1:0] fix_b,
    input bit reset_cnt = 1'b1
  );
    int total_lines, total_pixels;
    int r_cnt, g_cnt, b_cnt;

    cache_cfg_from_item();
    total_lines  = get_total_lines();
    total_pixels = get_total_pixels();

    r_cnt = 0; g_cnt = 0; b_cnt = 0;

    for (int f = 0; f < frames; f++) begin
      if (reset_cnt) begin
        r_cnt = 0; g_cnt = 0; b_cnt = 0;
      end

      for (int y = 0; y < total_lines; y++) begin
        send_line(y, total_pixels, mode, fix_r, fix_g, fix_b, r_cnt, g_cnt, b_cnt);
      end
    end
  endtask


  virtual task body();
    send_init(5);

    send_frame(30, data_mode, fix_r_data, fix_g_data, fix_b_data);

    send_init(2);
  endtask
endclass
