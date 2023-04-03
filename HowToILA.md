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
