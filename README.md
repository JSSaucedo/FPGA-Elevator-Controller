# FPGA Elevator Controller

A 3-floor elevator controller implemented on an Intel/Altera DE10-Lite FPGA 
using Verilog. The system uses a finite state machine to manage floor 
requests, drives a stepper motor to move the cabin, reads floor position 
from IR sensors, and displays the current floor on a 7-segment display.

## Hardware

- **FPGA board:** DE10-Lite (Intel MAX 10)
- **Motor:** 28BYJ-48 stepper motor
- **Driver:** ULN2003 driver board
- **Sensors:** FC-51 IR sensors (floor detection)
- **Display:** On-board 7-segment display
- **Power:** External bench power supply for the motor

## Module structure

| File | Description |
|------|-------------|
| `elevator_top.v` | Top-level module wiring all components together |
| `maquina_estados_elevador.v` | Finite state machine controlling elevator logic |
| `piso_display.v` | Drives the 7-segment display to show current floor |
| `stepper_driver.v` | Generates the step sequence for the 28BYJ-48 motor |

## How it works

The FSM tracks the current floor and target floor (`destino`), then commands 
the stepper driver to move up or down until the IR sensor confirms arrival. 
Button inputs are passed through a synchronizer chain to avoid metastability 
before being registered as floor requests.

## Build & run

1. Open `ELEVADOR.qpf` in Intel Quartus Prime.
2. Compile the project.
3. Program the DE10-Lite via the USB-Blaster (`.sof` in `output_files/`).
4. Connect the stepper motor (via ULN2003) and IR sensors to the assigned pins.

## Author

Julian Saucedo — Mechatronics Engineering student
