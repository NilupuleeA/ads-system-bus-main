# Serial System Bus

This project implements a serial bus that supports 2 masters and 3 slaves. One master and one slave can be configured as a bus bridge. Slave 2 (or any other slave) can be configured to support split transactions.

## Overview

![image](https://github.com/user-attachments/assets/f2fd8790-9767-4438-a94c-400a3f5fa857)

The bus interconnect contains several parts:
- **Arbiter**: Gives priority to Master 1 over Master 2 when both masters request access at
the same time.
- **Address decoder**: Decodes the address to identify which slave to select
- **Multiplexers and decoders**: Connect required master and slave ports through the bus
based on control signals from the arbiter and address decoder

## Address Allocation

### Without Bus Bridge

![image](https://github.com/user-attachments/assets/fd640f17-f859-4092-9849-2b68da71ca15)

### With Bus Bridge

![image](https://github.com/user-attachments/assets/6e891ae5-7c08-4828-a0f8-81b18931c3f1)


