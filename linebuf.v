module linebuf #(
  parameter                     VER_WIDTH   = 6     ,
  parameter                     HOR_WIDTH   = 6     ,
  parameter                     RGB_WIDTH   = 10    ,
  parameter                     ADDR_WIDTH  = 6     ,
  parameter                     DATA_WIDTH  = 30
) (
  input                         clk         ,
  input                         rstn        ,
  input     [ VER_WIDTH-1:0]    i_vsw       ,
  input     [ VER_WIDTH-1:0]    i_vbp       ,
  input     [ VER_WIDTH-1:0]    i_vact      ,
  input     [ VER_WIDTH-1:0]    i_vfp       ,
  input     [ HOR_WIDTH-1:0]    i_hsw       ,
  input     [ HOR_WIDTH-1:0]    i_hbp       ,
  input     [ HOR_WIDTH-1:0]    i_hact      ,
  input     [ HOR_WIDTH-1:0]    i_hfp       ,
  input                         i_vsync     ,
  input                         i_hsync     ,
  input                         i_de        ,
  input     [ RGB_WIDTH-1:0]    i_red       ,
  input     [ RGB_WIDTH-1:0]    i_green     ,
  input     [ RGB_WIDTH-1:0]    i_blue      ,
  output                        o_vsync     ,
  output                        o_hsync     ,
  output                        o_de        ,
  output                        o_cs1       ,
  output                        o_we1       ,
  output    [ADDR_WIDTH-1:0]    o_addr1     ,
  output    [DATA_WIDTH-1:0]    o_din1      ,
  output                        o_cs2       ,
  output                        o_we2       ,
  output    [ADDR_WIDTH-1:0]    o_addr2     ,
  output    [DATA_WIDTH-1:0]    o_din2      ,
  output                        o_sel
);

  wire                      w_wr_cs1    ;
  wire  [ADDR_WIDTH-1:0]    w_wr_addr1  ;
  wire                      w_wr_cs2    ;
  wire  [ADDR_WIDTH-1:0]    w_wr_addr2  ;
  wire                      w_rd_cs1    ;
  wire  [ADDR_WIDTH-1:0]    w_rd_addr1  ;
  wire                      w_rd_cs2    ;
  wire  [ADDR_WIDTH-1:0]    w_rd_addr2  ;

  input_fsm #(
    .RGB_WIDTH  (RGB_WIDTH  ),
    .ADDR_WIDTH (ADDR_WIDTH ),
    .DATA_WIDTH (DATA_WIDTH )
  )
  uInput_fsm_0 (
    .clk        (clk        ),
    .rstn       (rstn       ),
    .i_vsync    (i_vsync    ),
    .i_hsync    (i_hsync    ),
    .i_de       (i_de       ),
    .i_red      (i_red      ),
    .i_green    (i_green    ),
    .i_blue     (i_blue     ),
    .o_cs1      (w_wr_cs1   ),
    .o_we1      (o_we1      ),
    .o_addr1    (w_wr_addr1 ),
    .o_din1     (o_din1     ),
    .o_cs2      (w_wr_cs2   ),
    .o_we2      (o_we2      ),
    .o_addr2    (w_wr_addr2 ),
    .o_din2     (o_din2     )
  );

  output_fsm #(
    .VER_WIDTH  (VER_WIDTH  ),
    .HOR_WIDTH  (HOR_WIDTH  ),
    .RGB_WIDTH  (RGB_WIDTH  ),
    .ADDR_WIDTH (ADDR_WIDTH )
  )
  uOutput_fsm_0 (
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
    .o_vsync    (o_vsync    ),
    .o_hsync    (o_hsync    ),
    .o_de       (o_de       ),
    .o_cs1      (w_rd_cs1   ),
    .o_addr1    (w_rd_addr1 ),
    .o_cs2      (w_rd_cs2   ),
    .o_addr2    (w_rd_addr2 ),
    .o_sel      (o_sel      )
  );

  // ASSUMPTION: w_wr_cs1 and w_rd_cs1 are never high in the same cycle.
  assign o_cs1      = w_wr_cs1   | w_rd_cs1     ;
  assign o_cs2      = w_wr_cs2   | w_rd_cs2     ;
  assign o_addr1    = w_wr_addr1 | w_rd_addr1   ;
  assign o_addr2    = w_wr_addr2 | w_rd_addr2   ;

endmodule


module input_fsm #(
  parameter                         RGB_WIDTH   = 10    ,
  parameter                         ADDR_WIDTH  = 6     ,
  parameter                         DATA_WIDTH  = 30
  ) (
  input                             clk         ,
  input                             rstn        ,
  input                             i_vsync     ,
  input                             i_hsync     ,
  input                             i_de        ,
  input         [ RGB_WIDTH-1:0]    i_red       ,
  input         [ RGB_WIDTH-1:0]    i_green     ,
  input         [ RGB_WIDTH-1:0]    i_blue      ,
  output reg                        o_cs1       ,
  output reg                        o_we1       ,
  output reg    [ADDR_WIDTH-1:0]    o_addr1     ,
  output reg    [DATA_WIDTH-1:0]    o_din1      ,
  output reg                        o_cs2       ,
  output reg                        o_we2       ,
  output reg    [ADDR_WIDTH-1:0]    o_addr2     ,
  output reg    [DATA_WIDTH-1:0]    o_din2
  );

  localparam                IDLE    = 0 ,
                            WRITE1  = 1 ,
                            WAIT1   = 2 ,
                            WRITE2  = 3 ,
                            WAIT2   = 4 ;

  reg   [ADDR_WIDTH-1:0]    r_addr      ;
  reg   [DATA_WIDTH-1:0]    r_din       ;
  reg   [2:0]               input_cst   ;
  reg   [2:0]               input_nst   ;


  // ***** addr_counter ******
  always @(posedge clk or negedge rstn) begin
    if (!rstn) r_addr <= {ADDR_WIDTH{1'b0}};
    else if (o_cs1 | o_cs2) r_addr <= r_addr + 1;
    else r_addr <= {ADDR_WIDTH{1'b0}};
  end

  // ***** din_reg *****
  always @(posedge clk or negedge rstn) begin
    if (!rstn) r_din <= {DATA_WIDTH{1'b0}};
    else r_din <= {i_red, i_green, i_blue};
  end

  // ***** state machine ******
  always @(posedge clk or negedge rstn) begin: state_FFs
    if (!rstn) input_cst <= IDLE;
    else input_cst <= input_nst;
  end

  always @(*) begin: state_table
    case (input_cst)
      IDLE      :   if (i_de)       input_nst = WRITE1  ;
                    else            input_nst = IDLE    ;
      WRITE1    :   if (i_vsync)    input_nst = IDLE    ;
                    else if (!i_de) input_nst = WAIT1   ;
                    else            input_nst = WRITE1  ;
      WAIT1     :   if (i_vsync)    input_nst = IDLE    ;
                    else if (i_de)  input_nst = WRITE2  ;
                    else            input_nst = WAIT1   ;
      WRITE2    :   if (i_vsync)    input_nst = IDLE    ;
                    else if (!i_de) input_nst = WAIT2   ;
                    else            input_nst = WRITE2  ;
      WAIT2     :   if (i_vsync)    input_nst = IDLE    ;
                    else if (i_de)  input_nst = WRITE1  ;
                    else            input_nst = WAIT2   ;
      default   :                   input_nst = IDLE    ;
    endcase
  end

  always @(*) begin : state_out
    o_cs1   = 1'b0;
    o_we1   = 1'b0;
    o_addr1 = {ADDR_WIDTH{1'b0}};
    o_din1  = {DATA_WIDTH{1'b0}};
    o_cs2   = 1'b0;
    o_we2   = 1'b0;
    o_addr2 = {ADDR_WIDTH{1'b0}};
    o_din2  = {DATA_WIDTH{1'b0}};
    case (input_cst)
      IDLE  :   ;
      WRITE1:   begin
                  o_cs1     = 1'b1      ;
                  o_we1     = 1'b1      ;
                  o_addr1   = r_addr    ;
                  o_din1    = r_din     ;
                end
      WAIT1 :   ;
      WRITE2:   begin
                  o_cs2     = 1'b1      ;
                  o_we2     = 1'b1      ;
                  o_addr2   = r_addr    ;
                  o_din2    = r_din     ;
                end
      WAIT2 :   ;
    endcase
  end

endmodule


module output_fsm #(
  parameter                         VER_WIDTH   = 6     ,
  parameter                         HOR_WIDTH   = 6     ,
  parameter                         RGB_WIDTH   = 10    ,
  parameter                         ADDR_WIDTH  = 6
  ) (
  input                             clk         ,
  input                             rstn        ,
  input         [ VER_WIDTH-1:0]    i_vsw       ,
  input         [ VER_WIDTH-1:0]    i_vbp       ,
  input         [ VER_WIDTH-1:0]    i_vact      ,
  input         [ VER_WIDTH-1:0]    i_vfp       ,
  input         [ HOR_WIDTH-1:0]    i_hsw       ,
  input         [ HOR_WIDTH-1:0]    i_hbp       ,
  input         [ HOR_WIDTH-1:0]    i_hact      ,
  input         [ HOR_WIDTH-1:0]    i_hfp       ,
  input                             i_vsync     ,
  input                             i_hsync     ,
  output reg                        o_vsync     ,
  output reg                        o_hsync     ,
  output reg                        o_de        ,
  output reg                        o_cs1       ,
  output reg    [ADDR_WIDTH-1:0]    o_addr1     ,
  output reg                        o_cs2       ,
  output reg    [ADDR_WIDTH-1:0]    o_addr2     ,
  output reg                        o_sel
  );

  localparam                IDLE    = 0     ,
                            DELAY   = 1     ,
                            HSW     = 2     ,
                            HBP     = 3     ,
                            NON     = 4     ,
                            READ1   = 5     ,
                            READ2   = 6     ,
                            HFP     = 7     ;

  reg                       r_hsync_dly     ;
  wire                      w_hsync_r_edge  ;
  wire                      w_hsync_f_edge  ;
  reg   [ VER_WIDTH+1:0]    r_line_cnt      ;
  reg   [ HOR_WIDTH-1:0]    r_hwidth_cnt    ;
  reg                       r_hsclr         ;
  reg   [ HOR_WIDTH-1:0]    r_hwidth        ;
  wire                      w_hrollover     ;
  reg   [ADDR_WIDTH-1:0]    r_addr          ;
  reg                       r_vact_sec      ;
  wire  [ VER_WIDTH+1:0]    w_odd           ;
  reg                       r_vsw_sec       ;
  reg   [2:0]               output_cst      ;
  reg   [2:0]               output_nst      ;

  // ***** hsync rising edge detect ******
  always @(posedge clk or negedge rstn) begin
    if (!rstn) r_hsync_dly <= 1'b0;
    else r_hsync_dly <= i_hsync;
  end

  assign w_hsync_r_edge = i_hsync & !r_hsync_dly;
  assign w_hsync_f_edge = !i_hsync & r_hsync_dly;

  // ***** line_counter ******
  always @(posedge clk or negedge rstn) begin
    if (!rstn) r_line_cnt <= {(VER_WIDTH+2){1'b0}};
    else if (i_vsync) r_line_cnt <= {(VER_WIDTH+2){1'b0}};
    else if (w_hsync_f_edge) r_line_cnt <= r_line_cnt + 1'b1;
  end

  // ***** hwidth_counter ******
  always @(posedge clk or negedge rstn) begin
    if (!rstn) r_hwidth_cnt <= {HOR_WIDTH{1'b0}};
    else if (r_hsclr || w_hrollover) r_hwidth_cnt <= {HOR_WIDTH{1'b0}};
    else r_hwidth_cnt <= r_hwidth_cnt + 1'b1;
  end

  assign w_hrollover = (r_hwidth_cnt == (r_hwidth - 1'b1));

  // ***** addr_counter ******
  always @(posedge clk or negedge rstn) begin
    if (!rstn) r_addr <= {ADDR_WIDTH{1'b0}};
    else if (o_cs1 || o_cs2) r_addr <= r_addr + 1'b1;
    else r_addr <= {ADDR_WIDTH{1'b0}};
  end

  // ***** odd ******
  assign w_odd = (r_vact_sec) ? (r_line_cnt - i_vbp - 1'b1) : {(VER_WIDTH+2){1'b0}};

  // ***** vertical active section ******
  always @(posedge clk or negedge rstn) begin
    if (!rstn) r_vact_sec <= 1'b0;
    else if (w_hsync_r_edge) begin
      if (r_line_cnt == (i_vbp + 1)) r_vact_sec <= 1'b1;
      else if ((i_vfp == 0) && (r_line_cnt == 0)) r_vact_sec <= 1'b0;
      else if (r_line_cnt == (i_vbp + i_vact + 1)) r_vact_sec <= 1'b0;
    end
  end

  // ***** vertical sync width section ******
  always @(posedge clk or negedge rstn) begin
    if (!rstn) r_vsw_sec <= 1'b0;
    else if (i_vsw == 0) begin
      if (r_line_cnt == 1) r_vsw_sec <= w_hsync_r_edge;
      else r_vsw_sec <= 1'b0;
    end
    else begin
      if (w_hsync_r_edge) begin
        if (r_line_cnt == 0) r_vsw_sec <= 1'b1;
        else if (r_line_cnt == 1) r_vsw_sec <= 1'b0;
      end
    end
  end

  // ***** state machine ******
  always @(posedge clk or negedge rstn) begin: state_FFs
    if (!rstn) output_cst <= IDLE;
    else output_cst <= output_nst;
  end

  always @(*) begin: state_table
    case (output_cst)
      IDLE      :   if (i_vsync)            output_nst = DELAY  ;
                    else                    output_nst = IDLE   ;
      DELAY     :   if (w_hsync_r_edge)     output_nst = HSW    ;
                    else                    output_nst = DELAY  ;
      HSW       :   if (w_hrollover) begin
                      if (i_hbp != 0)       output_nst = HBP    ;
                      else begin
                        if (!r_vact_sec)    output_nst = NON    ;
                        else begin
                          if (w_odd[0])     output_nst = READ1  ;
                          else              output_nst = READ2  ;
                        end
                      end
                    end
                    else                    output_nst = HSW    ;
      HBP       :   if (w_hrollover) begin
                      if (!r_vact_sec)      output_nst = NON    ;
                      else begin
                        if (w_odd[0])       output_nst = READ1  ;
                        else                output_nst = READ2  ;
                      end
                    end
                    else                    output_nst = HBP    ;
      NON       :   if (w_hrollover) begin
                      if (i_hfp != 0)       output_nst = HFP    ;
                      else                  output_nst = HSW    ;
                    end
                    else                    output_nst = NON    ;
      READ1     :   if (w_hrollover) begin
                      if (i_hfp != 0)       output_nst = HFP    ;
                      else                  output_nst = HSW    ;
                    end
                    else                    output_nst = READ1  ;
      READ2     :   if (w_hrollover) begin
                      if (i_hfp != 0)       output_nst = HFP    ;
                      else                  output_nst = HSW    ;
                    end
                    else                    output_nst = READ2  ;
      HFP       :   if (w_hrollover)        output_nst = HSW    ;
                    else                    output_nst = HFP    ;
      default   :                           output_nst = IDLE   ;
    endcase
  end

  always @(*) begin : state_out
    r_hsclr     = 1'b0;
    r_hwidth    = {HOR_WIDTH{1'b0}};
    o_cs1       = 1'b0;
    o_addr1     = {ADDR_WIDTH{1'b0}};
    o_cs2       = 1'b0;
    o_addr2     = {ADDR_WIDTH{1'b0}};
    o_sel       = 1'b0;
    o_vsync     = 1'b0;
    o_hsync     = 1'b0;
    o_de        = 1'b0;
    case (output_cst)
      IDLE  :   r_hsclr     = 1'b1      ;
      DELAY :   r_hsclr     = 1'b1      ;
      HSW   : begin
                r_hwidth    = i_hsw     ;
                o_hsync     = 1'b1      ;
                if (r_vsw_sec)  o_vsync = 1'b1  ;
                else            o_vsync = 1'b0  ;
              end
      HBP   : begin
                r_hwidth    = i_hbp     ;
                if (r_vsw_sec)  o_vsync = 1'b1  ;
                else            o_vsync = 1'b0  ;
              end
      NON   : begin
                r_hwidth    = i_hact    ;
                if (r_vsw_sec)  o_vsync = 1'b1  ;
                else            o_vsync = 1'b0  ;
              end
      READ1 : begin
                r_hwidth    = i_hact    ;
                o_cs1       = 1'b1      ;
                o_addr1     = r_addr    ;
                o_de        = 1'b1      ;
              end
      READ2 : begin
                r_hwidth    = i_hact    ;
                o_cs2       = 1'b1      ;
                o_addr2     = r_addr    ;
                o_sel       = 1'b1      ;
                o_de        = 1'b1      ;
              end
      HFP   : begin
                r_hwidth    = i_hfp     ;
                if (r_vsw_sec)  o_vsync = 1'b1  ;
                else            o_vsync = 1'b0  ;
              end
    endcase
  end

endmodule
