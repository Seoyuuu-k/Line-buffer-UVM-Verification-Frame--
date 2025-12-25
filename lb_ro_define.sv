
`define VER_WIDTH  6          
`define HOR_WIDTH  6          
`define RGB_WIDTH  10         
`define ADDR_WIDTH 6          
`define DATA_WIDTH `RGB_WIDTH*3

typedef enum {
  RANDOM    ,
  FIX       ,
  INCREASE
} data_mode_e;
