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
  logic sd; 

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

      .word_width_i(word_width),
      .start_channel_i(start_channel),

      .data_o(data),
      .data_valid_o(data_valid),
      .data_ready_i(data_ready),
      .overflow_o(overflow)
  );

  

  // i2s_ws_gen #(
  //     .MaxWordWidth(MaxWordWidth)
  // ) i2s_ws_gen_i (
  //     .sck_i(sck),
  //     .rst_ni(rst_n),
  //     .en_i(en_ws),
  //     .ws_o(ws),
  //     .word_width_i(ws_gen_word_width)
  // );

  logic [31:0] test_data;

  test_mic i2s_microphone_i (
      .rst_ni(rst_n),
      .i2s_sck_i(mic_sck),
      .test_data_i(test_data),
      .i2s_ws_i(ws),
      .i2s_sd_o(sd)
  );

  logic connect_mic = 1'b0;

  assign mic_sck = connect_mic ? sck : 1'b0;

  // sck generation
  logic gen_sck = 1'b0; 
  always #(5) begin
    if (gen_sck) begin
      sck <= ~sck;
    end
  end


  logic fifo_ready = 1'b1;

  assign data_ready = fifo_ready;

  always_ff @(posedge sck, negedge rst_n) begin
    if (~rst_n) begin
    end else begin
      if (data_ready & data_valid) begin
        $display("%d: Data is %08x", $time, data);
      end
    end
  end


  task reset();
    connect_mic <= 1'b0;
    en_left = 1'b0;
    en_right = 1'b0;
    gen_sck <= 1'b0;
    rst_n = 1'b0;
    #10 rst_n = 1'b1;
    #10 gen_sck <= 1'b1;
    @(negedge sck);
    @(negedge sck);
  endtask


  initial begin

    //------------------------------------------------------------
    $display("TEST 32 bit channel !!!");
    reset();

    word_width = 5'b11111;
    connect_mic <= 1'b1;
    en_left = 1'b1;
    en_right = 1'b1;

    test_data = 32'ha6a6a6a6;
    @(negedge sck) ws = 1'b1;
    @(negedge sck);
    @(negedge sck);
    @(negedge sck) ws = 1'b0; // left channel
    repeat (32) @(negedge sck);

    ws = ~ws;
    test_data = 32'h6a6a6a6a;
    @(posedge data_valid);
    assert(data == 32'ha6a6a6a6);

    
    repeat (36) @(negedge sck);
    ws = ~ws;
    @(posedge data_valid);
    assert(data == 32'h6a6a6a6a);
    @(negedge sck);
    @(negedge sck);



    //------------------------------------------------------------
    $display("TEST 8 bit channel !!!");
    word_width = 5'b00111;
    reset();
    connect_mic <= 1'b1;
    en_left = 1'b1;
    en_right = 1'b1;

    test_data = 32'ha6a6a6a6;
    @(negedge sck) ws = 1'b1;
    @(negedge sck);
    @(negedge sck);
    @(negedge sck) ws = 1'b0; // left channel
    repeat (32) @(negedge sck);

    ws = ~ws;
    test_data = 32'h6a6a6a6a;
    @(posedge data_valid);
    assert(data == 32'ha6);

    
    repeat (36) @(negedge sck);
    ws = ~ws;
    @(posedge data_valid);
    assert(data == 32'h6a);
    @(negedge sck);
    @(negedge sck);


    //------------------------------------------------------------
    $display("TEST single channel !!!");
    reset();
    connect_mic <= 1'b1;
    en_left = 1'b0;
    en_right = 1'b1;

    test_data = 32'ha6a6a6a6;
    @(negedge sck) ws = 1'b1;
    @(negedge sck);
    @(negedge sck);
    @(negedge sck) ws = 1'b0; // left channel
    repeat (32) @(negedge sck);

    ws = ~ws;
    test_data = 32'h6a6a6a6a;
    
    // this was the left channel -> no data should be available
    @(negedge sck) assert(data_valid == 1'b0);
    @(negedge sck) assert(data_valid == 1'b0); // <<--- this one triggers if wrong channel
    @(negedge sck) assert(data_valid == 1'b0);

    repeat (32) @(negedge sck);
    ws = ~ws;
    @(posedge data_valid);
    assert(data == 32'h6a);
    @(negedge sck);
    @(negedge sck);
    connect_mic <= 1'b0;
    en_left = 1'b0;
    en_right = 1'b0;


    //------------------------------------------------------------
    $display("TEST overflow !!!");
    reset();
    connect_mic <= 1'b1;
    en_left = 1'b1;
    en_right = 1'b1;
    fifo_ready = 1'b0;
    word_width = 5'b11111;

    test_data = 32'ha6a6a6a6;
    @(negedge sck) ws = 1'b1;
    @(negedge sck);
    @(negedge sck);
    @(negedge sck) ws = 1'b0; // left channel
    repeat (32) @(negedge sck);

    ws = ~ws;
    test_data = 32'h6a6a6a6a;
    @(posedge data_valid);
    assert(data == 32'ha6a6a6a6);

    repeat (36) @(negedge sck);
    ws = ~ws;
    @(negedge sck);
    @(negedge sck);

    assert(overflow == 1'b1);
    @(negedge sck);

    en_left = 0;
    en_right = 0;
    @(negedge sck);
    @(negedge sck);
    assert(overflow == 1'b0);

    $stop;
  end


endmodule

module test_mic (
    input logic rst_ni,

    // i2s interface ports
    input logic i2s_sck_i,
    input logic i2s_ws_i,

    input logic [31:0] test_data_i,

    // output ports
    output logic i2s_sd_o
);
  logic [31:0] test_data_q;
  logic [5:0] bit_count;
  logic s_ws;
  logic r_ws;

  assign s_ws = i2s_ws_i;

  always_ff @(posedge i2s_sck_i or negedge rst_ni) begin
    if (~rst_ni) begin
      bit_count <= 0;
      r_ws <= 0;
      test_data_q <= 'h0;
    end else begin
      if (s_ws != r_ws) begin
        bit_count <= 0;
        r_ws <= s_ws;
        test_data_q <= test_data_i;
      end else begin
        bit_count <= bit_count + 1;
      end
    end
  end

  always_ff @(negedge i2s_sck_i) begin
    i2s_sd_o <= test_data_q[31-bit_count];  // MSB first
  end

endmodule

