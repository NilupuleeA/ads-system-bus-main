# Multi-Master Multi-Slave Serial System Bus Design

This repository contains the design and implementation of a scalable, priority-based serial system bus architecture. The project was developed for the **Advanced Digital Systems (EN4021)** course at the **University of Moratuwa**.

---

## 1. Overview
The design implements a multi-master, multi-slave serial system bus providing a complete framework for communication between hardware devices.

### Key Features:
* **Dual Master Interfaces:** Support for two masters capable of initiating read/write transactions.
* **Three Slave Interfaces:** Implemented using local memory blocks (BRAM).
* **Priority-Based Arbitration:** Ensures orderly bus access with Master 1 holding higher priority.
* **Split Transactions:** Supported to improve throughput by allowing the bus to be released while a slave prepares data.
* **UART Bus Bridge:** Enables cross-domain communication between separate bus systems (Bus A and Bus B).



---

## 2. System Architecture

### 2.1 Design Parameters
| Parameter | Default Value | Description |
| :--- | :--- | :--- |
| `ADDR_WIDTH` | 16 bits | Total address bus width |
| `DATA_WIDTH` | 8 bits | Data bus width |
| `SLAVE_MEM_ADDR_WIDTH` | 12 bits | Slave memory address space |
| `SLAVE_ADDR_WIDTH` | 4 bits | Slave address width |

### 2.2 Address Decoding Scheme
The system uses a 16-bit address where the top 4 bits define the Device Address and the remaining 12 bits define the Memory Address.

| Slave | Device Address | Address Range | Type |
| :--- | :--- | :--- | :--- |
| Slave 1 | `4'b0000` | 0x0000 - 0x07FF | 2KB BRAM |
| Slave 2 | `4'b0001` | 0x1000 - 0x1FFF | 4KB BRAM |
| Slave 3 | `4'b0010` | 0x2000 - 0x2FFF | 4KB BRAM |

---

## 3. Component Modules

### 3.1 Bus Arbiter
The arbiter uses a three-state finite state machine (FSM) to manage bus ownership. It implements a fixed priority where Master 1 is always served first unless it is waiting for a split transaction to resolve.



### 3.2 Master & Slave Interfaces
* **Master Interface:** Converts parallel address/data into a serial stream. It manages the `mbreq` (request) and `mbgrant` (grant) handshaking with the arbiter.
* **Slave Interface:** Converts serial bus data back to parallel for BRAM access. It manages the `ssplit` signal when it cannot immediately service a request.



### 3.3 Bus Bridge (UART)
Communication between Bus A and Bus B is handled via a UART interface operating at approximately **9600 bps**. 
* **Baud Rate Calculation:** $50 \text{ MHz} / 5208 \approx 9600 \text{ bps}$.
* **Message Frames:** 32-bit Request frames and 16-bit Response frames.

---

## 4. Timing Characteristics

Standard transaction timing (excluding arbitration wait time):

| Parameter | Value | Notes |
| :--- | :--- | :--- |
| Device Address Transfer | 4 cycles | Serial, MSB first |
| Memory Address Transfer | 12 cycles | Serial, LSB first |
| Data Transfer | 8 cycles | Serial, LSB first |
| **Total Write Transaction** | **~24 cycles** | Standard operation |
| **Total Read Transaction** | **~32 cycles** | Standard operation |

---

## 5. Resource Summary
| Component | Count / Description |
| :--- | :--- |
| Master Ports | 2 (1 local + 1 bridge) |
| Slave Ports | 3 (2 local + 1 bridge) |
| Block RAMs | 3 (32B demo + 2KB + 4KB) |
| FIFOs | 1 (8-deep, 32-bit for Bridge) |
| UART Modules | 2 (TX/RX pairs) |
| State Machines | 6+ (Arbiter, Masters, Slaves, Bridges) |

---

## 6. Project Info
* **Date:** 2025.12.09
* **Department:** Electronic & Telecommunication Engineering, University of Moratuwa
* **Team:** AMARATHUNGA D.N., PASIRA I.Ρ.Μ., RAJAPAKSHA S.S.D.Z.
