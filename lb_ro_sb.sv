import "DPI-C" context function int unsigned addFunc(int unsigned a, int unsigned b);

`uvm_analysis_imp_decl(_in_frame)
`uvm_analysis_imp_decl(_out_frame)

class lb_ro_sb_c extends uvm_scoreboard;
  `uvm_component_utils(lb_ro_sb_c)

  uvm_analysis_imp_in_frame  #(lb_ro_frame_mon_pkt_c, lb_ro_sb_c) in_frame_imp;
  uvm_analysis_imp_out_frame #(lb_ro_frame_mon_pkt_c, lb_ro_sb_c) out_frame_imp;

  lb_ro_frame_mon_pkt_c in_frame_q[$];
  lb_ro_frame_mon_pkt_c out_frame_q[$];

  int match_cnt, mismatch_cnt;

  localparam int unsigned MAXRGB = (int'(1) << `RGB_WIDTH) - 1;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_frame_imp  = new("in_frame_imp",  this);
    out_frame_imp = new("out_frame_imp", this);
  endfunction

  // ---------------- helpers ----------------
  function automatic bit [`RGB_WIDTH-1:0] clamp_rgb(input int unsigned v);
    if (v > MAXRGB) return MAXRGB[`RGB_WIDTH-1:0];
    else            return v[`RGB_WIDTH-1:0];
  endfunction

  function automatic rgb_t apply_offset_clamp(
      input rgb_t in_rgb,
      input bit bypass,
      input bit [`RGB_WIDTH-1:0] offset
  );
    rgb_t exp;
    int unsigned sum_r, sum_g, sum_b;

    if (bypass) begin
      exp = in_rgb;
    end
    else begin
      sum_r = addFunc(in_rgb.r, offset);
      sum_g = addFunc(in_rgb.g, offset);
      sum_b = addFunc(in_rgb.b, offset);
      exp.r = clamp_rgb(sum_r);
      exp.g = clamp_rgb(sum_g);
      exp.b = clamp_rgb(sum_b);
    end
    return exp;
  endfunction

  function automatic string rgb3s(input rgb_t p);
    return $sformatf("R:%0h G:%0h B:%0h", p.r, p.g, p.b);
  endfunction

  function automatic void dump_line_rgb(
      input string tag,
      input lb_ro_mon_pkt_c inL,
      input lb_ro_mon_pkt_c outL,
      input bit bypass,
      input bit [`RGB_WIDTH-1:0] offset
  );
    rgb_t exp;

    `uvm_info(get_type_name(),
      $sformatf("[%s] line(in=%0d out=%0d) n_in=%0d n_out=%0d bypass=%0d offset=%0h",
                tag, inL.line_idx, outL.line_idx,
                inL.in_pix_q.size(), outL.out_pix_q.size(), bypass, offset),
      UVM_HIGH)

    // 있는 만큼 전부 출력
    for (int x = 0; x < inL.in_pix_q.size(); x++) begin
      exp = apply_offset_clamp(inL.in_pix_q[x], bypass, offset);

      if (x < outL.out_pix_q.size()) begin
        `uvm_info(get_type_name(),
          $sformatf("  x=%0d | IN=(%s) | EXP=(%s) | OUT=(%s)",
                    x, rgb3s(inL.in_pix_q[x]), rgb3s(exp), rgb3s(outL.out_pix_q[x])),
          UVM_HIGH)
      end
      else begin
        `uvm_info(get_type_name(),
          $sformatf("  x=%0d | IN=(%s) | EXP=(%s) | OUT=(NONE)",
                    x, rgb3s(inL.in_pix_q[x]), rgb3s(exp)),
          UVM_HIGH)
      end
    end
  endfunction

  // ---------------- write ----------------
  
  function void write_in_frame(lb_ro_frame_mon_pkt_c f);
    in_frame_q.push_back(f);
    `uvm_info(get_type_name(),
      $sformatf("[ENQ_IN_FRAME] id=%0d lines=%0d qsize=%0d bypass=%0d offset=%0h",
                f.frame_id, f.lines.size(), in_frame_q.size(), f.bypass, f.offset_val),
      UVM_HIGH)
  endfunction

  function void write_out_frame(lb_ro_frame_mon_pkt_c f);
    out_frame_q.push_back(f);
    `uvm_info(get_type_name(),
      $sformatf("[ENQ_OUT_FRAME] id=%0d lines=%0d qsize=%0d",
                f.frame_id, f.lines.size(), out_frame_q.size()),
      UVM_HIGH)
  endfunction

  // ---------------- run/compare ----------------
  task run_phase(uvm_phase phase);
    match_cnt    = 0;
    mismatch_cnt = 0;

    fork
      compare_frames();
    join_none
  endtask

  task compare_frames();
    lb_ro_frame_mon_pkt_c inF, outF;
    bit frame_ok;

    forever begin
      wait(in_frame_q.size() > 0 && out_frame_q.size() > 0);

      inF  = in_frame_q.pop_front();
      outF = out_frame_q.pop_front();

      `uvm_info(get_type_name(),
        $sformatf("DBG: POP frames | inF=%0d(out lines=%0d) outF=%0d(out lines=%0d) | bypass=%0d offset=%0h",
                  inF.frame_id, inF.lines.size(), outF.frame_id, outF.lines.size(),
                  inF.bypass, inF.offset_val),
        UVM_HIGH)

      frame_ok = 1;

      if (inF.lines.size() != outF.lines.size()) begin
        frame_ok = 0;
        mismatch_cnt++;
        `uvm_error(get_type_name(),
          $sformatf("Frame line count mismatch in=%0d out=%0d (in_frame=%0d out_frame=%0d)",
                    inF.lines.size(), outF.lines.size(), inF.frame_id, outF.frame_id))
      end
      else begin
        for (int i = 0; i < inF.lines.size(); i++) begin
          if (!compare_one_line(inF.lines[i], outF.lines[i], inF.bypass, inF.offset_val)) begin
            frame_ok = 0;
            break;
          end
        end
      end

      if (frame_ok) begin
        match_cnt++;
        `uvm_info(get_type_name(),
          $sformatf("[PASS] Frame matched (in_frame=%0d out_frame=%0d)", inF.frame_id, outF.frame_id),
          UVM_HIGH)
      end
    end
  endtask

  function automatic bit compare_one_line(
      lb_ro_mon_pkt_c inL,
      lb_ro_mon_pkt_c outL,
      bit bypass,
      bit [`RGB_WIDTH-1:0] offset
  );
    rgb_t exp;
    bit line_ok;

    line_ok = 1;

    if (inL.in_pix_q.size() != outL.out_pix_q.size()) begin
      mismatch_cnt++;
      line_ok = 0;
      `uvm_error(get_type_name(),
        $sformatf("Line size mismatch: in=%0d out=%0d (in_line=%0d out_line=%0d)",
                  inL.in_pix_q.size(), outL.out_pix_q.size(), inL.line_idx, outL.line_idx))
    end
    else begin
      for (int x = 0; x < inL.in_pix_q.size(); x++) begin
        exp = apply_offset_clamp(inL.in_pix_q[x], bypass, offset);
        if (outL.out_pix_q[x] !== exp) begin
          mismatch_cnt++;
          line_ok = 0;
          `uvm_error(get_type_name(),
            $sformatf("Mismatch line(in=%0d out=%0d) x=%0d | exp(%0h,%0h,%0h) act(%0h,%0h,%0h) | bypass=%0d offset=%0h",
                      inL.line_idx, outL.line_idx, x,
                      exp.r, exp.g, exp.b,
                      outL.out_pix_q[x].r, outL.out_pix_q[x].g, outL.out_pix_q[x].b,
                      bypass, offset))
          break;
        end
      end
    end
    dump_line_rgb(line_ok ? "LINE_PASS" : "LINE_FAIL", inL, outL, bypass, offset);

    return line_ok;
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info(get_type_name(), "##########################", UVM_LOW)
    `uvm_info(get_type_name(), "##### COMPARE RESULT #####", UVM_LOW)
    `uvm_info(get_type_name(), "##########################", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("MATCH    = %0d", match_cnt), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("MISMATCH = %0d", mismatch_cnt), UVM_LOW)
    `uvm_info(get_type_name(), "##########################", UVM_LOW)
  endfunction

endclass
