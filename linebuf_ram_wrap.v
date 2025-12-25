module linebuf_ram_wrap#(
  parameter                     VER_WIDTH   = 6             ,
  parameter                     HOR_WIDTH   = 6             ,
  parameter                     RGB_WIDTH   = 10            ,
  parameter                     ADDR_WIDTH  = 6             ,
  parameter                     DATA_WIDTH  = RGB_WIDTH*3
) (
  input                         clk         ,
  input                         rstn        ,
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
  output                        o_vsync     ,
  output                        o_hsync     ,
  output                        o_de        ,
  output        [RGB_WIDTH-1:0] o_r_data    ,
  output        [RGB_WIDTH-1:0] o_g_data    ,
  output        [RGB_WIDTH-1:0] o_b_data
);

  wire                      w_cs1   ;
  wire                      w_we1   ;
  wire  [ADDR_WIDTH-1:0]    w_addr1 ;
  wire  [DATA_WIDTH-1:0]    w_din1  ;
  wire  [DATA_WIDTH-1:0]    w_dout1 ;
  wire                      w_cs2   ;
  wire                      w_we2   ;
  wire  [ADDR_WIDTH-1:0]    w_addr2 ;
  wire  [DATA_WIDTH-1:0]    w_din2  ;
  wire  [DATA_WIDTH-1:0]    w_dout2 ;
  wire                      w_sel   ;

  linebuf #(
    .VER_WIDTH  (VER_WIDTH  ),
    .HOR_WIDTH  (HOR_WIDTH  ),
    .RGB_WIDTH  (RGB_WIDTH  ),
    .ADDR_WIDTH (ADDR_WIDTH ),
    .DATA_WIDTH (DATA_WIDTH )
  )
  ulinebuf_0 (
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
    .i_red      (i_r_data   ),
    .i_green    (i_g_data   ),
    .i_blue     (i_b_data   ),
    .o_vsync    (o_vsync    ),
    .o_hsync    (o_hsync    ),
    .o_de       (o_de       ),
    .o_cs1      (w_cs1      ),
    .o_we1      (w_we1      ),
    .o_addr1    (w_addr1    ),
    .o_din1     (w_din1     ),
    .o_cs2      (w_cs2      ),
    .o_we2      (w_we2      ),
    .o_addr2    (w_addr2    ),
    .o_din2     (w_din2     ),
    .o_sel      (w_sel      )
  );

  single_port_ram #(
    .ADDR_WIDTH (ADDR_WIDTH ),
    .DATA_WIDTH (DATA_WIDTH )
  )
  sram1 (
    .clk        (clk        ),
    .i_cs       (w_cs1      ),
    .i_we       (w_we1      ),
    .i_addr     (w_addr1    ),
    .i_din      (w_din1     ),
    .o_dout     (w_dout1    )
  );

  single_port_ram #(
    .ADDR_WIDTH (ADDR_WIDTH ),
    .DATA_WIDTH (DATA_WIDTH )
  )
  sram2 (
    .clk        (clk        ),
    .i_cs       (w_cs2      ),
    .i_we       (w_we2      ),
    .i_addr     (w_addr2    ),
    .i_din      (w_din2     ),
    .o_dout     (w_dout2    )
  );

  assign {o_r_data, o_g_data, o_b_data} = (w_sel) ? w_dout2 : w_dout1;

endmodule