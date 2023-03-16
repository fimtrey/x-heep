// Copyright 2022 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

// Author: Tim Frey <tim.frey@epfl.ch>, EPFL, STI-SEL
// Date: 07.02.2023
// Description: I2s peripheral

module i2s #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,
    parameter int unsigned FIFO_DEPTH = 4
) (
    input logic clk_i,
    input logic rst_ni,

    // Register interface
    input  reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o,

    // I2s interface
    output logic i2s_sck_o,
    output logic i2s_sck_oe_o,
    input  logic i2s_sck_i,
    output logic i2s_ws_o,
    output logic i2s_ws_oe_o,
    input  logic i2s_ws_i,
    output logic i2s_sd_o,
    output logic i2s_sd_oe_o,
    input  logic i2s_sd_i,

    // Interrupt
    output logic intr_i2s_event_o,

    // DMA signal
    output logic i2s_rx_valid_o
);

  import i2s_reg_pkg::*;
  localparam SampleWidth = (1 << BytePerSampleWidth) * 8;
  localparam CounterWidth = BytePerSampleWidth + 3;

  // Interface signals
  i2s_reg2hw_t reg2hw;
  i2s_hw2reg_t hw2reg;

  // RX Window Interface signals
  reg_req_t    rx_win_h2d;
  reg_rsp_t    rx_win_d2h;


  logic rx_fifo_ready;
  logic [SampleWidth-1:0] rx_fifo_data_in;
  logic rx_fifo_data_in_valid;

  logic [SampleWidth-1:0] rx_fifo_data_out;
  logic rx_fifo_data_out_valid;
  logic rx_fifo_data_out_ready;

  logic rx_fifo_err;

  logic [CounterWidth-1:0] sample_width;
  assign sample_width = {reg2hw.bytepersample.q, 3'h7};

  // FIFO -> RX WINDOW
  assign rx_win_d2h.ready = rx_win_h2d.valid && rx_win_h2d.addr[BlockAw-1:0] == i2s_reg_pkg::I2S_RXDATA_OFFSET && !rx_win_h2d.write;
  assign rx_win_d2h.rdata = rx_fifo_data_out;
  assign rx_win_d2h.error = !rx_fifo_data_out_valid;

  assign rx_fifo_data_out_ready = rx_win_d2h.ready;

  assign i2s_rx_valid_o = rx_fifo_data_out_valid;

  logic rx_fifo_full;
  logic rx_fifo_empty;
  assign rx_fifo_data_out_valid = ~rx_fifo_empty;
  assign rx_fifo_ready = ~rx_fifo_full;

  // RX FIFO
  fifo_v3 #(
      .DATA_WIDTH(SampleWidth),
      .DEPTH(FIFO_DEPTH)
  ) rx_fifo_i (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .empty_o(rx_fifo_empty),
      .full_o(rx_fifo_full),
      .data_i(rx_fifo_data_in),
      .push_i(rx_fifo_data_in_valid),
      .data_o(rx_fifo_data_out),
      .pop_i(rx_fifo_data_out_ready),
      .flush_i(1'b0),
      .testmode_i(1'b0),
      .usage_o()
  );


  // STATUS 
  // assign hw2reg.status.fill_level.d = rx_fifo_usage;
  // assign hw2reg.status.fill_level.de = 1'b1;
  // assign hw2reg.status.full.d = rx_fifo_full;
  // assign hw2reg.status.full.de = 1'b1;
  assign hw2reg.status.empty.d = !rx_fifo_data_out_valid;
  assign hw2reg.status.empty.de = 1'b1;

  assign hw2reg.status.overflow.de = rx_fifo_err | reg2hw.control.q;
  assign hw2reg.status.overflow.d = rx_fifo_err & !reg2hw.control.q;


  // reset control bits immediatelly 
  // assign hw2reg.control.clear_fifo.de = reg2hw.control.clear_fifo.q;
  // assign hw2reg.control.clear_fifo.d = 1'b0;

  assign hw2reg.control.de = reg2hw.control.q;
  assign hw2reg.control.d = 1'b0;



  // Register logic
  i2s_reg_top #(
      .reg_req_t(reg_req_t),
      .reg_rsp_t(reg_rsp_t)
  ) i2s_reg_top_i (
      .clk_i,
      .rst_ni,
      .reg_req_i,
      .reg_rsp_o,
      .reg_req_win_o(rx_win_h2d),  // host to device
      .reg_rsp_win_i(rx_win_d2h),  // device to host
      .reg2hw,
      .hw2reg,
      .devmode_i(1'b1)
  );



  // Core logic
  i2s_core #(
      .SampleWidth(SampleWidth),
      .ClkDivSize (ClkDivSize)
  ) i2s_core_i (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .en_i  (reg2hw.cfg.en),

      .i2s_sck_o   (i2s_sck_o),
      .i2s_sck_oe_o(i2s_sck_oe_o),
      .i2s_sck_i   (i2s_sck_i),
      .i2s_ws_o    (i2s_ws_o),
      .i2s_ws_oe_o (i2s_ws_oe_o),
      .i2s_ws_i    (i2s_ws_i),
      .i2s_sd_o    (i2s_sd_o),
      .i2s_sd_oe_o (i2s_sd_oe_o),
      .i2s_sd_i    (i2s_sd_i),

      .cfg_clk_ws_en_i(reg2hw.cfg.gen_clk_ws.q),
      .cfg_lsb_first_i(reg2hw.cfg.lsb_first.q),
      .cfg_clock_div_i(reg2hw.clkdividx.q),
      .cfg_sample_width_i(sample_width),

      .fifo_rx_data_o(rx_fifo_data_in),
      .fifo_rx_data_valid_o(rx_fifo_data_in_valid),
      .fifo_rx_data_ready_i(rx_fifo_ready),
      .fifo_rx_err_o(rx_fifo_err)
  );

  logic event_i2s_event;
  // prim_intr_hw #(
  //     .Width(1)
  // ) intr_hw_i2s_event (
  //     .clk_i,
  //     .rst_ni,
  //     .event_intr_i          (event_i2s_event),
  //     .reg2hw_intr_enable_q_i(reg2hw.intr_enable.q),
  //     .reg2hw_intr_test_q_i  (reg2hw.intr_test.q),
  //     .reg2hw_intr_test_qe_i (reg2hw.intr_test.qe),
  //     .reg2hw_intr_state_q_i (reg2hw.intr_state.q),
  //     .hw2reg_intr_state_de_o(hw2reg.intr_state.de),
  //     .hw2reg_intr_state_d_o (hw2reg.intr_state.d),
  //     .intr_o                (intr_i2s_event_o)
  // );

  assign intr_i2s_event_o = event_i2s_event & reg2hw.intr_enable.q;
  assign hw2reg.intr_state.de = intr_i2s_event_o;
  assign hw2reg.intr_state.d = intr_i2s_event_o;



  // interrupt reach count event
  // count fifo outputs to be on clk_i
  logic [31:0] intr_reach_counter;
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      intr_reach_counter <= 32'h0;
    end else begin
      if (intr_reach_counter == reg2hw.reachcount.q) begin
        if (reg2hw.cfg.en & rx_fifo_data_out_ready & rx_fifo_data_out_valid) begin
          intr_reach_counter <= 32'h1;
        end else begin
          intr_reach_counter <= 32'h0;
        end
      end else if (reg2hw.cfg.en & rx_fifo_data_out_ready & rx_fifo_data_out_valid) begin
        intr_reach_counter <= intr_reach_counter + 32'h1;
      end
    end
  end

  assign event_i2s_event = intr_reach_counter == reg2hw.reachcount.q & reg2hw.reachcount.q != 32'h0;


endmodule : i2s
