// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package i2s_reg_pkg;

  // Param list
  parameter int BytePerSampleWidth = 2;
  parameter int ClkDivSize = 16;

  // Address widths within the block
  parameter int BlockAw = 5;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {logic [15:0] q;} i2s_reg2hw_clkdividx_reg_t;

  typedef struct packed {
    struct packed {logic [1:0] q;} en;
    struct packed {logic q;} en_r;
    struct packed {logic q;} lsb_first;
    struct packed {logic q;} intr_en;
    struct packed {logic [1:0] q;} data_width;
    struct packed {logic q;} gen_clk_ws;
  } i2s_reg2hw_cfg_reg_t;

  typedef struct packed {logic [31:0] q;} i2s_reg2hw_reachcount_reg_t;

  typedef struct packed {logic q;} i2s_reg2hw_control_reg_t;

  typedef struct packed {
    struct packed {logic q;} empty;
    struct packed {logic q;} overflow;
  } i2s_reg2hw_status_reg_t;

  typedef struct packed {
    logic d;
    logic de;
  } i2s_hw2reg_control_reg_t;

  typedef struct packed {
    struct packed {
      logic d;
      logic de;
    } empty;
    struct packed {
      logic d;
      logic de;
    } overflow;
  } i2s_hw2reg_status_reg_t;

  // Register -> HW type
  typedef struct packed {
    i2s_reg2hw_clkdividx_reg_t clkdividx;  // [58:43]
    i2s_reg2hw_cfg_reg_t cfg;  // [42:35]
    i2s_reg2hw_reachcount_reg_t reachcount;  // [34:3]
    i2s_reg2hw_control_reg_t control;  // [2:2]
    i2s_reg2hw_status_reg_t status;  // [1:0]
  } i2s_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    i2s_hw2reg_control_reg_t control;  // [5:4]
    i2s_hw2reg_status_reg_t  status;   // [3:0]
  } i2s_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] I2S_CLKDIVIDX_OFFSET = 5'h0;
  parameter logic [BlockAw-1:0] I2S_CFG_OFFSET = 5'h4;
  parameter logic [BlockAw-1:0] I2S_REACHCOUNT_OFFSET = 5'h8;
  parameter logic [BlockAw-1:0] I2S_CONTROL_OFFSET = 5'hc;
  parameter logic [BlockAw-1:0] I2S_STATUS_OFFSET = 5'h10;

  // Window parameters
  parameter logic [BlockAw-1:0] I2S_RXDATA_OFFSET = 5'h14;
  parameter int unsigned I2S_RXDATA_SIZE = 'h4;

  // Register index
  typedef enum int {
    I2S_CLKDIVIDX,
    I2S_CFG,
    I2S_REACHCOUNT,
    I2S_CONTROL,
    I2S_STATUS
  } i2s_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] I2S_PERMIT[5] = '{
      4'b0011,  // index[0] I2S_CLKDIVIDX
      4'b0001,  // index[1] I2S_CFG
      4'b1111,  // index[2] I2S_REACHCOUNT
      4'b0001,  // index[3] I2S_CONTROL
      4'b0001  // index[4] I2S_STATUS
  };

endpackage

