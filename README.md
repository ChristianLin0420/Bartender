# Bartender
2019 Digital Design Experiment final project, NTHU

## About 
* Language : Swift, Verilog
* BLE connect protocol
* Bartending machine consturction

## Software introduction

### Swift


### Verilog
A. State Transition Diagram
![image](https://github.com/ChristianLin0420/Bartender/blob/master/Screen%20Shot%202020-01-28%20at%2017.07.19.png)

B. Brief Description
This is the whole process of verilog code, first, FPGA stays at WAIT state until bluetooth_send singal turn into 1.
And then current state will turn to ADD, according to the data FPGA received, machine starts to make particular bartending.
Current state turns into SWITCH and begins adding wine or drink. When the bartending finishe, current state turns to END, and then turns back to END after 10ns.

## Hardware introduction
All Hardware setting and mechanism are all in the link : [here](https://hackmd.io/@BJLin-0420/ryrsOdxAH)

## Reference
[Report](https://github.com/ChristianLin0420/Bartender/blob/master/Team26_Final_Project_Report.pdf)
