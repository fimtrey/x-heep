// Copyright 2022 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

// Author: Tim Frey <tim.frey@epfl.ch>, EPFL, STI-SEL
// Date: 13.02.2023
// Description: I2s peripheral

module i2s_core #(
    parameter SampleWidth,
    parameter ClkDivSize
) (
    input logic clk_i,
    input logic rst_ni,
    input logic en_i,


    // IO interface
    output logic i2s_sck_o,
    output logic i2s_sck_oe_o,
    input  logic i2s_sck_i,
    output logic i2s_ws_o,
    output logic i2s_ws_oe_o,
    input  logic i2s_ws_i,
    output logic i2s_sd_o,
    output logic i2s_sd_oe_o,
    input  logic i2s_sd_i,

    // config
    input logic                           cfg_lsb_first_i,
    input logic [         ClkDivSize-1:0] cfg_clock_div_i,
    input logic                           cfg_clk_ws_en_i,
    input logic [$clog2(SampleWidth)-1:0] cfg_sample_width_i,

    // FIFO
    output logic [SampleWidth-1:0] fifo_rx_data_o,
    output logic                   fifo_rx_data_valid_o,
    input  logic                   fifo_rx_data_ready_i,
    output logic                   fifo_rx_err_o
);


  logic ws;
  assign ws = i2s_ws_oe_o ? i2s_ws_o : i2s_ws_i;


  i2s_ws_gen #(
      .SampleWidth(SampleWidth)
  ) i2s_ws_gen_i (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .en_i(en_i & cfg_clk_ws_en_i),
      .sck_i(sck),
      .ws_o(i2s_ws_o),
      .ws_oe_o(i2s_ws_oe_o),
      .cfg_sample_width_i(cfg_sample_width_i)
  );

  logic sck;
  assign i2s_sck_oe_o = en_i & cfg_clk_ws_en_i & clk_div_running;

  tc_clk_mux2 i_clk_bypass_mux (
      .clk0_i   (i2s_sck_i),
      .clk1_i   (i2s_sck_o),
      .clk_sel_i(i2s_sck_oe_o),
      .clk_o    (sck)
  );

  logic div_valid;
  logic div_ready;
  logic [ClkDivSize-1:0] div;

  // This is a workaround
  // Such that it starts with the demanded div value.
  logic clk_div_running;
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      clk_div_running <= 1'b0;
    end else begin
      if (div_ready) begin
        clk_div_running <= 1'b1;
      end
    end
  end

  assign div = cfg_clock_div_i;
  assign div_valid = 1'b1;



  clk_int_div #(
      .DIV_VALUE_WIDTH(ClkDivSize),
      .DEFAULT_DIV_VALUE(2)  // HAS TO BE BIGGER THAN ONE TO GET THE START RIGHT
  ) i2s_clk_gen_i (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .en_i(en_i & cfg_clk_ws_en_i),
      .test_mode_en_i(1'b0),
      .clk_o(i2s_sck_o),
      .div_i(div),
      .div_valid_i(div_valid),
      .div_ready_o(div_ready)
  );

  assign i2s_sd_oe_o = 1'b0;
  assign i2s_sd_o    = 1'b0;

  logic [SampleWidth-1:0] left_sample;
  logic left_sample_valid;
  logic left_sample_read;
  logic [SampleWidth-1:0] right_sample;
  logic right_sample_valid;
  logic right_sample_read;

  i2s_rx_channel #(
      .SampleWidth(SampleWidth)
  ) i2s_rx_channel_i (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .en_i(en_i),
      .sck_i(sck),
      .ws_i(ws),
      .sd_i(i2s_sd_i),
      .cfg_lsb_first_i(cfg_lsb_first_i),
      .cfg_sample_width_i(cfg_sample_width_i),
      .left_sample_o(left_sample),
      .right_sample_o(right_sample),
      .left_valid_o(left_sample_valid),
      .right_valid_o(right_sample_valid),
      .left_read_i(left_sample_read),
      .right_read_i(right_sample_read)
  );

  logic sample_ws;

  assign fifo_rx_err_o = 1'b0;

  always_comb begin
    if (sample_ws == 1'b0) begin
      fifo_rx_data_valid_o = left_sample_valid;
      fifo_rx_data_o = left_sample;
    end else begin
      fifo_rx_data_valid_o = right_sample_valid;
      fifo_rx_data_o = right_sample;
    end
  end

  always_comb begin
    left_sample_read  = 1'b0;
    right_sample_read = 1'b0;
    if (fifo_rx_data_valid_o & fifo_rx_data_ready_i) begin
      if (sample_ws == 1'b0) left_sample_read = 1'b1;
      else right_sample_read = 1'b1;
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      sample_ws <= 1'b0;
    end else begin
      if (fifo_rx_data_valid_o & fifo_rx_data_ready_i) begin
        sample_ws <= ~sample_ws;
      end
    end
  end


endmodule : i2s_core
