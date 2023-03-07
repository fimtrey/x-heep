// Copyright 2022 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

// Author: Tim Frey <tim.frey@epfl.ch>, EPFL, STI-SEL
// Date: 13.02.2023
// Description: I2s peripheral

// Adapted from github.com/pulp-platform/udma_i2s/blob/master/rtl/i2s_rx_channel.sv 
// by Antonio Pullini (pullinia@iis.ee.ethz.ch)

module i2s_rx_channel #(
    parameter  int unsigned SampleWidth,
    localparam int unsigned CounterWidth = $clog2(SampleWidth)
) (
    input logic clk_i,
    input logic rst_ni,
    input logic en_i,
    input logic sck_i,
    input logic ws_i,
    input logic sd_i,

    // config
    input logic cfg_lsb_first_i,
    input logic [CounterWidth-1:0] cfg_sample_width_i,

    // OUTOPUT
    output logic [SampleWidth-1:0] left_sample_o,
    output logic [SampleWidth-1:0] right_sample_o,
    output logic                   left_valid_o,
    output logic                   right_valid_o,
    input  logic                   left_read_i,
    input  logic                   right_read_i
);


  logic r_sck;
  logic s_rising_sck;

  enum logic [1:0] {
    IDLE     = 2'b00,
    RUNNING  = 2'b01,
    OVERFLOW = 2'b10,
    WORDDONE = 2'b11
  } state;

  logic r_ws_old;
  logic s_ws_edge;

  logic [SampleWidth-1:0] r_shiftreg;
  logic [CounterWidth-1:0] r_count_bit;

  assign s_ws_edge = ws_i ^ r_ws_old;
  assign s_rising_sck = ((r_sck == 1'b1) & (sck_i == 1'b0));


  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      r_sck <= 'h0;
    end else begin
      if (en_i) begin
        r_sck <= sck_i;
      end else begin
        r_sck <= 1'b0;
      end
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      r_shiftreg <= 'h0;
    end else begin
      if (state[0] == 1'b1) begin  // RUNNING or DONE
        if (cfg_lsb_first_i) begin
          r_shiftreg <= {1'b0, r_shiftreg[SampleWidth-1:1]};
          r_shiftreg[cfg_sample_width_i] <= sd_i;
        end else begin
          r_shiftreg[cfg_sample_width_i-r_count_bit] <= sd_i;  // MSB FIRST            
        end
      end
    end
  end

  // output register
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      left_sample_o  <= 'h0;
      right_sample_o <= 'h0;
      left_valid_o   <= 1'b0;
      right_valid_o  <= 1'b0;
    end else begin
      if (left_read_i) left_valid_o <= 1'b0;
      if (right_read_i) right_valid_o <= 1'b0;
      if (s_rising_sck & (state == WORDDONE)) begin
        if (r_ws_old == 1'b1) begin
          left_sample_o <= r_shiftreg;
          left_valid_o  <= 1'b1;
        end else begin
          right_sample_o <= r_shiftreg;
          right_valid_o  <= 1'b1;
        end
      end
    end
  end

  // count bit
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      r_count_bit <= 'h0;
    end else begin
      if (s_rising_sck & (state != IDLE)) begin
        if (s_ws_edge == 1'b1) begin
          r_count_bit <= 'h0;
        end else if (r_count_bit <= cfg_sample_width_i) begin
          r_count_bit <= r_count_bit + 'h1;
        end
      end
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      r_ws_old <= 'h0;
    end else begin
      if (s_rising_sck) r_ws_old <= ws_i;
    end
  end

  // fsm 
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      state <= IDLE;
    end else begin
      if (s_rising_sck) begin
        case (state)
          IDLE: begin
            if (s_ws_edge) state <= RUNNING;
          end
          RUNNING: begin
            if (s_ws_edge) state <= WORDDONE;
            else if (r_count_bit == cfg_sample_width_i) state <= OVERFLOW;
          end
          OVERFLOW: begin
            if (s_ws_edge) state <= WORDDONE;
          end
          WORDDONE: begin
            state <= RUNNING;
          end
        endcase
      end
    end
  end


endmodule : i2s_rx_channel
