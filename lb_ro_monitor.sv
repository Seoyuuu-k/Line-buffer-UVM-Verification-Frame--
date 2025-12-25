
class lb_ro_monitor_c extends uvm_monitor;
  `uvm_component_utils(lb_ro_monitor_c)

  uvm_analysis_port#(lb_ro_frame_mon_pkt_c) in_frame_port;
  uvm_analysis_port#(lb_ro_frame_mon_pkt_c) out_frame_port;

  virtual interface lb_ro_if lb_ro_vif;


  bit          prev_i_de, prev_o_de;
  bit          prev_i_vsync, prev_o_vsync;


  bit          in_active, out_active;
  int unsigned in_line_idx, out_line_idx;

  lb_ro_mon_pkt_c in_pkt;
  lb_ro_mon_pkt_c out_pkt;


  lb_ro_frame_mon_pkt_c in_frame;
  lb_ro_frame_mon_pkt_c out_frame;

  int unsigned in_frame_id, out_frame_id;


  bit stop_req;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_frame_port  = new("in_frame_port",  this);
    out_frame_port = new("out_frame_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual lb_ro_if)::get(this, "", "lb_ro_vif", lb_ro_vif))
      `uvm_fatal(get_type_name(), "lb_ro_vif not set")
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    prev_i_de    = 0; prev_o_de    = 0;
    prev_i_vsync = 0; prev_o_vsync = 0;

    in_active   = 0; out_active   = 0;
    in_line_idx = 0; out_line_idx = 0;

    in_frame_id = 0; out_frame_id = 0;

    in_frame = null; out_frame = null;
    stop_req = 0;

    fork
      // IN
      forever begin
        if (stop_req) break; // 종료 요청이면 루프 탈출
        @(posedge lb_ro_vif.i_clk iff lb_ro_vif.i_rstn);
        in_data();
        prev_i_de    = lb_ro_vif.i_de;
        prev_i_vsync = lb_ro_vif.i_vsync;
      end

      // OUT
      forever begin
        if (stop_req) break; // 종료 요청이면 루프 탈출
        @(posedge lb_ro_vif.i_clk iff lb_ro_vif.i_rstn);
        out_data();
        prev_o_de    = lb_ro_vif.o_de;
        prev_o_vsync = lb_ro_vif.o_vsync;
      end
    join_none
  endtask

  
  task in_data();
    bit de    = lb_ro_vif.i_de;
    bit vsync = lb_ro_vif.i_vsync;

 
    if (vsync && !prev_i_vsync) begin
      
      if (in_frame != null) begin
        in_frame_port.write(in_frame);
      end

      in_frame = lb_ro_frame_mon_pkt_c::type_id::create(
                   $sformatf("in_frame_%0d", in_frame_id), this);
      in_frame.frame_id   = in_frame_id++;

      in_frame.bypass     = lb_ro_vif.i_bypass;
      in_frame.offset_val = lb_ro_vif.i_offset_val;
      in_frame.hact       = lb_ro_vif.i_hact;
      in_frame.vact       = lb_ro_vif.i_vact;

      in_frame.lines.delete();
      in_line_idx = 0;
    end

  
    if (de && !prev_i_de && !in_active) begin
      in_active = 1;
      in_pkt = lb_ro_mon_pkt_c::type_id::create(
                 $sformatf("in_line_%0d", in_line_idx), this);

      in_pkt.line_idx   = in_line_idx++;
      in_pkt.in_pix_cnt = 0;
      in_pkt.in_pix_q.delete();

      in_pkt.i_bypass     = lb_ro_vif.i_bypass;
      in_pkt.i_offset_val = lb_ro_vif.i_offset_val;
    end


    if (de && in_active) begin
      rgb_t p;
      p.r = lb_ro_vif.i_r_data;
      p.g = lb_ro_vif.i_g_data;
      p.b = lb_ro_vif.i_b_data;
      in_pkt.in_pix_q.push_back(p);
      in_pkt.in_pix_cnt++;
    end


    if (!de && prev_i_de && in_active) begin
      in_active = 0;
      if (in_frame != null) begin
        in_frame.lines.push_back(in_pkt);
      end
    end


  endtask


  task out_data();
    bit de    = lb_ro_vif.o_de;
    bit vsync = lb_ro_vif.o_vsync;

    if (vsync && !prev_o_vsync) begin
      if (out_frame != null) begin
        out_frame_port.write(out_frame);
      end

      out_frame = lb_ro_frame_mon_pkt_c::type_id::create(
                    $sformatf("out_frame_%0d", out_frame_id), this);
      out_frame.frame_id = out_frame_id++;
      out_frame.lines.delete();
      out_line_idx = 0;
    end

    if (de && !prev_o_de && !out_active) begin
      out_active = 1;
      out_pkt = lb_ro_mon_pkt_c::type_id::create(
                  $sformatf("out_line_%0d", out_line_idx), this);
      out_pkt.line_idx    = out_line_idx++;
      out_pkt.out_pix_cnt = 0;
      out_pkt.out_pix_q.delete();
    end

    if (de && out_active) begin
      rgb_t p;
      p.r = lb_ro_vif.o_r_data;
      p.g = lb_ro_vif.o_g_data;
      p.b = lb_ro_vif.o_b_data;
      out_pkt.out_pix_q.push_back(p);
      out_pkt.out_pix_cnt++;
    end

    if (!de && prev_o_de && out_active) begin
      out_active = 0;
      if (out_frame != null) begin
        out_frame.lines.push_back(out_pkt);
      end
    end
  endtask


  function void finalize_open_lines();
    
    if (in_active && in_pkt != null) begin
      in_active = 0;
      if (in_frame != null) in_frame.lines.push_back(in_pkt);
    end

    if (out_active && out_pkt != null) begin
      out_active = 0;
      if (out_frame != null) out_frame.lines.push_back(out_pkt);
    end
  endfunction

  function void flush_frames_now();
    // open line 정리 후 frame write
    finalize_open_lines();

    if (in_frame != null) begin
      in_frame_port.write(in_frame);
      in_frame = null;
    end

    if (out_frame != null) begin
      out_frame_port.write(out_frame);
      out_frame = null;
    end
  endfunction


  function void phase_ready_to_end(uvm_phase phase);
    super.phase_ready_to_end(phase);

    if (phase.get_name() == "run") begin
      stop_req = 1;
      phase.raise_objection(this, "monitor final flush");
      flush_frames_now();
      phase.drop_objection(this, "monitor final flush");
    end
  endfunction

endclass
