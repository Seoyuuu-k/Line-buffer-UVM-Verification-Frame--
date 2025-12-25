module linebuf_rgboffset_top#(
  parameter                     VER_WIDTH   = 6             ,
  parameter                     HOR_WIDTH   = 6             ,
  parameter                     RGB_WIDTH   = 10            ,
  parameter                     ADDR_WIDTH  = 6             ,
  parameter                     DATA_WIDTH  = RGB_WIDTH*3
) (
  input                         clk         ,
  input                         rstn        ,
  input                         i_bypass    ,
  input         [RGB_WIDTH-1:0] i_offset_val,
  input         [VER_WIDTH-1:0] i_vsw       ,
  input         [VER_WIDTH-1:0] i_vbp       ,
  input         [VER_WIDTH-1:0] i_vact      ,
  input         [VER_WIDTH-1:0] i_vfp       ,
  input         [HOR_WIDTH-1:0] i_hsw       ,
  input         [HOR_WIDTH-1:0] i_hbp       ,
  input         [HOR_WIDTH-1:0] i_hact      ,
  input         [HOR_WIDTH-1:0] i_hfp       ,
  input                         i_vsync     ,
  input                         i_hsync     ,
  input                         i_de        ,
  input         [RGB_WIDTH-1:0] i_r_data    ,
  input         [RGB_WIDTH-1:0] i_g_data    ,
  input         [RGB_WIDTH-1:0] i_b_data    ,
  output reg                    o_vsync     ,
  output reg                    o_hsync     ,
  output reg                    o_de        ,
  output reg    [RGB_WIDTH-1:0] o_r_data    ,
  output reg    [RGB_WIDTH-1:0] o_g_data    ,
  output reg    [RGB_WIDTH-1:0] o_b_data
);

  localparam [RGB_WIDTH-1:0] MAX_VAL = { RGB_WIDTH{1'b1} };

  // ===== Config Registers =====
  reg                   r_bypass    ;
  reg   [RGB_WIDTH-1:0] r_offset_val;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      r_bypass      <= 1'b0;
      r_offset_val  <= {RGB_WIDTH{1'b0}};
    end else begin
      r_bypass      <= i_bypass;
      r_offset_val  <= i_offset_val;
    end
  end

  // ===== Internal Signals from linebuf_ctrl =====
  wire                  w_vsync     ;
  wire                  w_hsync     ;
  wire                  w_de        ;
  wire  [RGB_WIDTH-1:0] w_r_data    ;
  wire  [RGB_WIDTH-1:0] w_g_data    ;
  wire  [RGB_WIDTH-1:0] w_b_data    ;

  // ===== Instantiation =====
  linebuf_ram_wrap #(
    .VER_WIDTH  (VER_WIDTH  ),
    .HOR_WIDTH  (HOR_WIDTH  ),
    .RGB_WIDTH  (RGB_WIDTH  ),
    .ADDR_WIDTH (ADDR_WIDTH ),
    .DATA_WIDTH (DATA_WIDTH )
  )
  ulinebuf_ram_wrap_0(
    .clk        (clk        ),
    .rstn       (rstn       ),
    .i_vsw      (i_vsw      ),
    .i_vbp      (i_vbp      ),
    .i_vact     (i_vact     ),
    .i_vfp      (i_vfp      ),
    .i_hsw      (i_hsw      ),
    .i_hbp      (i_hbp      ),
    .i_hact     (i_hact     ),
    .i_hfp      (i_hfp      ),
    .i_vsync    (i_vsync    ),
    .i_hsync    (i_hsync    ),
    .i_de       (i_de       ),
    .i_r_data   (i_r_data   ),
    .i_g_data   (i_g_data   ),
    .i_b_data   (i_b_data   ),
    .o_vsync    (w_vsync    ),
    .o_hsync    (w_hsync    ),
    .o_de       (w_de       ),
    .o_r_data   (w_r_data   ),
    .o_g_data   (w_g_data   ),
    .o_b_data   (w_b_data   )
  );

  // ===== Source selection =====
  wire [RGB_WIDTH-1:0] w_src_r          = r_bypass ? i_r_data : w_r_data ;
  wire [RGB_WIDTH-1:0] w_src_g          = r_bypass ? i_g_data : w_g_data ;
  wire [RGB_WIDTH-1:0] w_src_b          = r_bypass ? i_b_data : w_b_data ;

  wire                 w_src_vsync      = r_bypass ? i_vsync  : w_vsync  ;
  wire                 w_src_hsync      = r_bypass ? i_hsync  : w_hsync  ;
  wire                 w_src_de         = r_bypass ? i_de     : w_de     ;

  wire [RGB_WIDTH-1:0] w_eff_offset_val = r_bypass ? {RGB_WIDTH{1'b0}} : r_offset_val;

 
  // ===== Add + Clamp =====
  wire [RGB_WIDTH:0]   w_sum_r      = {1'b0, w_src_r} + {1'b0, w_eff_offset_val};
  wire [RGB_WIDTH:0]   w_sum_g      = {1'b0, w_src_g} + {1'b0, w_eff_offset_val};
  wire [RGB_WIDTH:0]   w_sum_b      = {1'b0, w_src_b} + {1'b0, w_eff_offset_val};
  
  /*
    // ===== Add + Clamp =====
  wire [RGB_WIDTH:0]   w_sum_r      = {1'b0, w_src_r} ;
  wire [RGB_WIDTH:0]   w_sum_g      = {1'b0, w_src_g} ;
  wire [RGB_WIDTH:0]   w_sum_b      = {1'b0, w_src_b} ;
  
 */

  wire [RGB_WIDTH-1:0] w_clamp_r    = !w_src_de ? {RGB_WIDTH{1'b0}} : (w_sum_r[RGB_WIDTH] ? MAX_VAL : w_sum_r[RGB_WIDTH-1:0]);
  wire [RGB_WIDTH-1:0] w_clamp_g    = !w_src_de ? {RGB_WIDTH{1'b0}} : (w_sum_g[RGB_WIDTH] ? MAX_VAL : w_sum_g[RGB_WIDTH-1:0]);
  wire [RGB_WIDTH-1:0] w_clamp_b    = !w_src_de ? {RGB_WIDTH{1'b0}} : (w_sum_b[RGB_WIDTH] ? MAX_VAL : w_sum_b[RGB_WIDTH-1:0]);


  // ===== Output Pipeline =====
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      o_vsync  <= 1'b0;
      o_hsync  <= 1'b0;
      o_de     <= 1'b0;
      o_r_data <= {RGB_WIDTH{1'b0}};
      o_g_data <= {RGB_WIDTH{1'b0}};
      o_b_data <= {RGB_WIDTH{1'b0}};
    end else begin
      o_vsync  <= w_src_vsync   ;
      o_hsync  <= w_src_hsync   ;
      o_de     <= w_src_de      ;
      o_r_data <= w_clamp_r     ;
      o_g_data <= w_clamp_g     ;
      o_b_data <= w_clamp_b     ;
    end
  end

endmodule
