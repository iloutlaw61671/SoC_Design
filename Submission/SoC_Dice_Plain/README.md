# BASYS3 SoC Dice project

This source snapshot comes from the Lab 6 archive and contains the Vivado hardware and standalone Vitis application. The original Lab 6 firmware configures the LED controller at 1 kHz and copies debounced GPIO inputs to the LED enable register. It is the starting point for the Lab 7 dice firmware.

## Vivado 2025.2

1. Open `Vivado/basys3_top.xpr` for part `xc7a35tcpg236-2`. Open `soc_top.bd` and generate its output products. The Vivado project retains the RTL, board constraints, block design and IP configuration files.
2. Select the simulation set for the test to run. `sim_sev_seg` starts `sev_seg_tb` with the APB master. `sim_led` starts `ledcntrl_top_tb` with the AHB-Lite master. `sim_2` retains the board-level `basys3_tb`. Run each module simulation to completion to see the register and output sequences.
3. Run synthesis and implementation and generate the bitstream. Use **File > Export > Export Hardware** with **Include bitstream** and save as `Vivado/basys3_top.xsa` for use in the next step.

## Vitis Unified IDE 2025.2

1. Open `VITIS/` as the workspace. In `basys3component` settings, use **Switch / Re-read XSA** to select the `Vivado/basys3_top.xsa` just exported. Build the platform for `microblaze_0` with the `standalone_microblaze_0` domain.
2. If the IDE cannot open the stripped platform, create a platform component named `basys3component` in a fresh workspace using the same XSA, processor and standalone domain. Use `axi_uartlite_0` for standard input and output. Import the application component or create an empty application targeting that platform and domain and copy the sources and build settings from `VITIS/app_component1/src/`.
3. Build `app_component1`, program the board and run the application. `VITIS/app_component1/src/app.c` contains `main()`.

Regenerate the XSA with embedded bitstream, BSP, simulation results and build outputs using the steps above. [AMD Vitis 2025.2 platform creation guide](https://docs.amd.com/r/2025.2-English/ug1400-vitis-embedded/Creating-a-Platform-Component-from-XSA)
