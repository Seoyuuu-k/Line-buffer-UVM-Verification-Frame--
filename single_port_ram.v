module single_port_ram #(
  parameter                     ADDR_WIDTH = 6  ,
  parameter                     DATA_WIDTH = 30 ,
  parameter                     RAM_DEPTH  = 1 << ADDR_WIDTH
) (
  input                         clk     ,
  input                         i_cs    ,
  input                         i_we    ,
  input     [ADDR_WIDTH-1:0]    i_addr  ,
  input     [DATA_WIDTH-1:0]    i_din   ,
  output    [DATA_WIDTH-1:0]    o_dout
);

  reg       [DATA_WIDTH-1:0]    r_mem [0:RAM_DEPTH-1];

  // output : when cs=1, we=0
  assign o_dout = (i_cs && !i_we) ? r_mem[i_addr] : 'b0;

  // Memory write input
  // cs=1, we=1
  always @(posedge clk) begin
    if (i_cs && i_we) r_mem[i_addr] <= i_din;
  end

endmodule
