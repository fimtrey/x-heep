// Copyright 2022 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

// Author: Tim Frey <tim.frey@epfl.ch>, EPFL, STI-SEL
// Date: 13.02.2023
// Description: Testbench for i2s_rx_channel


module i2s_rx_channel_tb #(
    parameter  int unsigned MaxWordWidth = 32,
    localparam int unsigned CounterWidth = $clog2(MaxWordWidth)
) ();
  logic rst_n = 1'b1;

  logic sck = 1'b0; 
  logic ws; 
  logic sd = 1'b1; 

  logic mic_sck;

  logic en_left = 1'b0;
  logic en_right = 1'b0;
  logic en_ws = 1'b0;

  // config
  logic [CounterWidth-1:0] word_width = 5'b11111; // must not be changed while either channel is enabled
  logic [CounterWidth-1:0] ws_gen_word_width = 5'b11111; // must not be changed while either channel is enabled

  // first data from channel? (0 = left, 1 = right) .wav uses left first
  logic start_channel = 1'b0;

  // read data out (stream interface)
  logic [MaxWordWidth-1:0] data;
  logic                    data_valid;
  logic                    data_ready;
  logic overflow;

  i2s_rx_channel #(
      .MaxWordWidth(MaxWordWidth)
  ) dut (
      .sck_i(sck),
      .rst_ni(rst_n),
      .en_left_i(en_left),
      .en_right_i(en_right),
      .ws_i(ws),
      .sd_i(sd),

      .word_width_i(cfg_word_width),
      .start_channel_i(start_channel),

      .data_o(data),
      .data_valid_o(data_valid),
      .data_ready_i(data_ready),
      .overflow_o(overflow)
  );

  

  i2s_ws_gen #(
      .MaxWordWidth(MaxWordWidth)
  ) i2s_ws_gen_i (
      .sck_i(sck),
      .rst_ni(rst_n),
      .en_i(en_ws),
      .ws_o(ws),
      .word_width_i(ws_gen_word_width)
  );


  i2s_microphone i2s_microphone_i (
      .rst_ni(rst_n),
      .i2s_sck_i(mic_sck),
      .i2s_ws_i(ws),
      .i2s_sd_o(sd)
  );

  logic connect_mic = 1'b0;

  assign mic_sck = connect_mic ? sck : 1'b0;

  // SCK generation
  logic gen_sck = 1'b0; 
  always #(5) begin
    if (gen_sck) begin
      sck <= ~sck;
    end
  end


  logic fifo_ready = 1'b0;

  assign data_ready = fifo_ready;

  always_ff @(posedge sck, negedge rst_n) begin
    if (~rst_n) begin
    end else begin
      if (data_ready & data_valid) begin
        $display("%d: Data is %08x", data, $timestamp);
      end
    end
  end

  initial begin
    rst_n = 1'b0;
    #10
    rst_n = 1'b1;

    #10
    gen_sck <= 1'b1;

    #100
    en_ws = 1'b1;
    connect_mic <= 1'b1;
    en_left = 1'b1;
    en_right = 1'b1;
    
    #(32*10*8)
    $stop;
  end


endmodule