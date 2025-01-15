# Bartender
An automated bartending machine project combining hardware and software components, developed as a Digital Design Experiment final project at NTHU (National Tsing Hua University).

## Overview
The Bartender project is an innovative solution that combines embedded systems, mobile technology, and mechanical engineering to create an automated drink dispensing system. It features:
- Mobile app control via Bluetooth Low Energy (BLE)
- FPGA-based control system
- Automated drink mixing capabilities
- Custom hardware construction

## Technology Stack
- **Mobile App**: Swift (iOS)
- **Hardware Control**: Verilog on FPGA
- **Communication**: Bluetooth Low Energy (BLE) protocol
- **Hardware**: Custom mechanical construction

## System Architecture

### 1. Mobile Application (iOS)
The iOS application serves as the user interface for the bartending machine, allowing users to:
- Connect to the machine via BLE
- Select and customize drinks
- Control drink dispensing
- Monitor machine status

### 2. FPGA Control System
#### State Machine Implementation
The FPGA implements a finite state machine with the following states:
1. **WAIT**: Initial state, waiting for Bluetooth commands
2. **ADD**: Processing received drink recipe data
3. **SWITCH**: Activating appropriate dispensing mechanisms
4. **END**: Completing the drink preparation cycle

![State Transition Diagram](https://github.com/ChristianLin0420/Bartender/blob/master/Screen%20Shot%202020-01-28%20at%2017.07.19.png)

#### Operation Flow
1. System initializes in WAIT state
2. Upon receiving bluetooth_send signal (1), transitions to ADD state
3. Processes drink recipe data and controls dispensing mechanisms
4. Moves to SWITCH state for actual liquid dispensing
5. Completes operation in END state
6. Returns to WAIT state after 10ns

### 3. Hardware Construction
The physical construction includes:
- Custom-designed frame and mounting system
- Liquid dispensing mechanisms
- Electronic control interfaces
- BLE communication module

For detailed hardware specifications and assembly instructions, visit our [Hardware Documentation](https://hackmd.io/@BJLin-0420/ryrsOdxAH)

## Documentation
- [Full Project Report](https://github.com/ChristianLin0420/Bartender/blob/master/Team26_Final_Project_Report.pdf)
- [Hardware Documentation](https://hackmd.io/@BJLin-0420/ryrsOdxAH)

## Installation & Setup
(To be added: Instructions for setting up both software and hardware components)

## Contributing
This project was developed as part of a university course. While it's not actively maintained, feel free to fork and improve upon it.

## License
(To be specified)
