# SoC Dice lab report

Moodle deadline **Friday, 11 December 2026 at 23:59**.

- `Report/` contains the FH JOANNEUM LaTeX report, waveform images and archived synthesis reports. Edit the chapter for your lab in `lab1.tex` through `lab7.tex`. `main.tex` includes them in order. Run `./Report/build.ps1` from the repository root with pdfLaTeX installed. The PDF is `Report/build/SoC-Lab-Report.pdf`. In Overleaf, use the contents of `Report/` as the project and select `main.tex` and pdfLaTeX.
- `Submission/SoC_Dice_Plain/` contains the current Vivado and Vitis source projects, based on `SoC_Dice_PlainAfterLab6Done.zip`. The project README explains how to open the Vivado project, run the testbenches, and recreate the Vitis platform.
- `Submission/SoC_Dice_Plain.zip` is the local source archive for this snapshot. Git ignores simulation databases, synthesis and implementation outputs, Vitis build products, and local ZIPs. The testbench source, waveform screenshots, and selected utilization reports are kept with the project.

The Lab 2 lint screenshot is in `Report/figures/Lab2/`. The Lab 5 lint workbook
and utilization summary are in `Report/results/`. The original Lab 2 and Lab 5
synthesis logs, Lab 5 utilization database, and Lab 5 XSA are archived locally
under `Report/results/raw/` and ignored by Git.

## What remains

1. **Complete Lab 7.** Configure AXI GPIO as dual-channel. Wire a build version to channel 1 and debounced `BTNU` and `SW[3:0]` to channel 2. Extend `app.c` to read the version, roll on a button press, update selected digits and print the result over UART Lite. The latest available archive has one GPIO channel and its `app.c` mirrors GPIO inputs to the LED controller.
2. **Run the final design with Vivado and Vitis 2025.2.** Regenerate the bitstream and export a fresh XSA. Rebind the Vitis platform to that XSA, build the application, and run it on the BASYS3. Verify single-digit and multi-digit selections and compare the UART and display results. The archived UART Lite configuration is 9600 baud, 8 data bits, and no parity. Confirm the settings on the final design.
3. **Run both module simulations and capture the figures below.** The archived Lab 2 captures document display setup and digit scanning. Refresh them from the final project and capture the LED testbench as well.
4. **Export final synthesis utilization.** In the synthesized design, report `u_seg7_top`, `u_ledcntrl_top`, and the `soc_top` instance. Use the actual hierarchy names in the synthesized design. Vivado Tcl command `report_utilization -hierarchical -hierarchical_min_primitive_count 0 -file final_utilization.rpt` includes small instances. Save the final report under `Submission/SoC_Dice_Plain/results/` so it ships with the project. Record LUTs, FFs, LUTRAM, RAMB18, and RAMB36 where available. The archived Lab 6 report covers the full board top, including its ILA. [AMD Vivado 2025.2 Tcl reference](https://docs.amd.com/r/2025.2-English/ug835-vivado-tcl-commands/report_utilization)
5. **Update and rebuild the report.** Fill the marked results and board number, then rebuild. Create a fresh project ZIP after the final project sources are committed. Upload the report PDF and the latest project ZIP to Moodle.

## Screenshots and photo

Save the final images under `Report/figures/final/` using these filenames.

| File | What to capture |
| --- | --- |
| `sev-seg-waveform.png` | Vivado simulation with APB address, write/read data, select/enable and active-low anode and segment outputs. Show the `0x1234` setup and digit scan. |
| `led-waveform.png` | Vivado simulation with `led_out`, `int_out`, AHB register writes and time cursors. Show the `0xAAAA` mask, 1 ms PWM period, 0.5 ms on-time and interrupt assertion and clear. |
| `block-design.png` | Final Vivado block design with readable MicroBlaze, memory, APB/AHB bridges, dual GPIO, UART and ILA labels. The supplied diagrams show earlier revisions. |
| `basys3-running.jpg` | A stable displayed dice value and the physical BASYS3 board number in the same photo. |
| `uart.png` | Optional serial terminal capture of the version and dice output from the same build. |

The Lab 6 archive also contains an ILA capture. It can document hardware bus activity if needed. The module simulations provide the waveform evidence requested for the report.

To regenerate the single project ZIP from the final committed tree, run this from the repository root.

```powershell
git archive --format=zip --prefix=SoC_Dice_Plain/ --output=Submission/SoC_Dice_Plain.zip HEAD:Submission/SoC_Dice_Plain
```
