interface lb_ro_if (
  input                             i_clk       ,
  input                             i_rstn
);
  logic                             i_bypass    ;
  logic         [`RGB_WIDTH-1:0]    i_offset_val;
  logic         [`VER_WIDTH-1:0]    i_vsw       ;
  logic         [`VER_WIDTH-1:0]    i_vbp       ;
  logic         [`VER_WIDTH-1:0]    i_vact      ;
  logic         [`VER_WIDTH-1:0]    i_vfp       ;
  logic         [`HOR_WIDTH-1:0]    i_hsw       ;
  logic         [`HOR_WIDTH-1:0]    i_hbp       ;
  logic         [`HOR_WIDTH-1:0]    i_hact      ;
  logic         [`HOR_WIDTH-1:0]    i_hfp       ;
  logic                             i_vsync     ;
  logic                             i_hsync     ;
  logic                             i_de        ;
  logic         [`RGB_WIDTH-1:0]    i_r_data    ;
  logic         [`RGB_WIDTH-1:0]    i_g_data    ;
  logic         [`RGB_WIDTH-1:0]    i_b_data    ;
  logic                             o_vsync     ;
  logic                             o_hsync     ;
  logic                             o_de        ;
  logic         [`RGB_WIDTH-1:0]    o_r_data    ;
  logic         [`RGB_WIDTH-1:0]    o_g_data    ;
  logic         [`RGB_WIDTH-1:0]    o_b_data    ;
endinterface
