# FPGA Elevator Controller

A 3-floor elevator controller implemented on an Intel/Altera DE10-Lite FPGA 
using Verilog. A finite state machine manages floor requests, drives a 
28BYJ-48 stepper motor to move the cabin, reads floor position from FC-51 
IR sensors, and displays the current floor on a 7-segment display with 
LED status indicators.

## Hardware

- **FPGA board:** DE10-Lite (Intel MAX 10), 50 MHz clock
- **Motor:** 28BYJ-48 stepper motor via ULN2003 driver (external 5V 2A supply)
- **Sensors:** 3× FC-51 IR sensors, active-low, powered from 3.3V
- **Display:** On-board 7-segment display (HEX0, active-low)
- **Inputs:** KEY1 reset (active-low), SW0/SW1 for floor selection
- **Indicators:** LEDR0–2 floor position, LEDR3–4 motor direction, LEDR5 doors

> **Power note:** Common ground is mandatory — supply GND, ULN2003 GND, 
> DE10-Lite GND, and sensor GND all share the same rail. Do **not** power the 
> sensors from 5V; the FPGA pins tolerate only 3.3V.

## Module structure

| File | Description |
|------|-------------|
| `elevator_top.v` | Top-level module wiring all components together |
| `maquina_estados_elevador.v` | Finite state machine controlling elevator logic |
| `piso_display.v` | Drives the 7-segment display to show current floor |
| `stepper_driver.v` | Generates the step sequence for the 28BYJ-48 motor |

## Floor selection (SW1 SW0)

| SW1 | SW0 | Floor |
|-----|-----|-------|
| 0 | 0 | (idle) |
| 0 | 1 | Floor 1 |
| 1 | 0 | Floor 2 |
| 1 | 1 | Floor 3 |

## Build & run

1. Open `ELEVADOR.qpf` in Intel Quartus Prime.
2. Compile the project.
3. Program the DE10-Lite via USB-Blaster.
4. Wire the stepper (via ULN2003) and IR sensors per the reference card.
5. Power on the external supply, verify no overload, then program the bitstream.

Full pin assignments and wiring are in [the hardware reference card](./reference_card.pdf).

## Author

Julian Saucedo — Mechatronics Engineering student
