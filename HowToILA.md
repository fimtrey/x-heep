# Guide to use the "Xilinx Integrated Logic Analyzer" 
## About
> The Integrated Logic Analyzer (ILA) core can be used to monitor the internal signals of a design. The ILA core includes many advanced features of modern logic analyzers, including Boolean trigger equations, and edge transition triggers. Because the ILA core is synchronous to the design being monitored, all design clock constraints that are applied to your design are also applied to the components inside the ILA core.

Using the ILA makes easier to solve FPGA specific problems. Make sure your system is running in simulation before going for the ILA as the setup is a little cumbersome.

## Steps to get the ILA set up

1. Run Vivado Implementation
    Using the command given in the README
    ```
    make vivado-fpga FPGA_BOARD=pynq-z2
    ```
2. Open the Vivado project `/.../*.xfc`
3. In Synthesised Desgin press `Set up Debug`
4. Select the signals and clock domains
   1. Try to find the signals you wan't to debug. (They might not exist under the same name nor by at the expected level in the hierarchy)

   2. Select a clock domain. Vivado might chose different clocks depending on the signals. Maybe use `...`
   3. Press `generate debug cores`.
5. By saving the design you can add the command to a file (e.g. `constraints.xdc`), which will add the same ILA even if you recompile from make (step 1).
6. Regenerate the bit stream.
7. Upload the bitstream from Vivado, the Hardware Manager will directly ask you if you wan't to connect to the debug cores.
8. Reduced the jtag clock frequency to talk to the debug core. In the Hardware Target go to `...`
9. Debug with the ILA


## Troubleshoutting
If you get the following message trying to start the trigger of an ILA core
```

```

Which was solved by step 4.2 and 8. Make sure you selected a valid frequency for your clock and a valid "free running" clock source. 



## Example
An example constraints.xdc looks like
```
create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list xilinx_clk_wizard_wrapper_i/xilinx_clk_wizard_i/clk_wiz_0/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 3 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_count_bit_reg[0]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_count_bit_reg[1]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_count_bit_reg[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[0]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[1]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[2]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[3]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[4]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[5]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[6]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[7]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[8]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[9]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[10]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[11]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[12]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[13]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[14]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[15]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[16]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[17]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[18]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[19]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[20]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[21]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[22]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[23]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[24]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[25]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[26]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[27]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[28]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[29]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[30]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_shadow_reg[31]_0[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 2 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_count_bit_reg[4]_0[0]} {x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_count_bit_reg[4]_0[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_sck_out_x]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/ws]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_started]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_started_dly]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/data_rx_dc_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list x_heep_system_i/core_v_mini_mcu_i/peripheral_subsystem_i/i2s_i/i2s_core_i/i2s_rx_channel_i/r_ws_old]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list x_heep_system_i/i2s_sd_in_x_muxed]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_out_OBUF]

```
