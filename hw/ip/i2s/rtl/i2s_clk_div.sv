// Copyright 2022 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

// Author: Tim Frey <tim.frey@epfl.ch>, EPFL, STI-SEL
// Date: 13.02.2023
// Description: I2s peripheral


module i2s_clk_div #(
    parameter DIV_VALUE_WIDTH
) (
    input logic clk_i,
    input logic rst_ni,
    input logic en_i,

    output logic clk_o,

    input logic [DIV_VALUE_WIDTH-1:0] div_i
);

  logic enabled;

  logic [DIV_VALUE_WIDTH-1:0] r_counter;
  logic [DIV_VALUE_WIDTH-1:0] div_sampled;


  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      r_counter <= 'h0;
    end else begin
      if (enabled) begin
        if (r_counter == div_sampled) r_counter <= 'h0;
        else r_counter <= r_counter + 1;
      end
    end
  end

  //Generate the internal WS signal
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      clk_o <= 1'b0;
    end else begin
      if (enabled) begin
        if (r_counter == div_sampled) clk_o <= ~clk_o;
      end else begin
        clk_o <= 1'b0;
      end
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      div_sampled <= 'h0;
      enabled <= 1'b0;
    end else begin
      if (enabled) begin
        if (r_counter == div_sampled) begin
          if (clk_o == 1'b1) begin
            if (en_i == 1'b0) begin
              enabled <= 1'b0;
            end
          end else begin
            div_sampled <= div_i;
          end
        end
      end else begin
        if (en_i) begin
          div_sampled <= div_i;
          enabled <= 1'b1;
        end
      end
    end
  end

endmodule : i2s_clk_div
