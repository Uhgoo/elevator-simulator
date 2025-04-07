**MARS MIPS Assembly Elevator Simulation**

The goal of this project is to mimic a real-life elevator, handling multiple requests at once, and move properly the elevator based on those requests. The system also have an emergency stops that halts the elevator until reset.

**Commands** *(All commands are inputted in the MMIO keyboard, and are followed by [Enter], to request)*:
  - Basic Floor Requests: '1', '2', '3', '4', '5', '6', '7', '8', '9'
  - Floor Calls:
      - Going Up:   '+1', '+2', '+3', '+4', '+5', '+6', '+7', '+8'
      - Going Down: '-2', '-3', '-4', '-5', '-6', '-7', '-8', '-9'
  - Emergency:
      - Call Emergency Stop: 'e' or 'E'
      - Reset Emergency: 'r' or 'R'
  - Stop Simulation: 's' or 'S'
