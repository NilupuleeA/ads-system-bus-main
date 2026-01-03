# Multi-Master Multi-Slave Serial System Bus Design

[cite_start]This repository contains the design and implementation of a scalable, priority-based serial system bus architecture developed at the **University of Moratuwa**[cite: 1, 3]. [cite_start]It features a multi-master environment, split-transaction support, and a UART-based bus bridge for cross-domain communication[cite: 19, 22, 23].

---

## 1. Overview
[cite_start]The system provides a complete framework for communication between multiple hardware devices[cite: 19]:
* [cite_start]**Two Master Interfaces:** Capable of initiating read/write transactions[cite: 20].
* [cite_start]**Three Slave Interfaces:** Implemented using local BRAM blocks[cite: 21].
* [cite_start]**Priority Arbitration:** Orderly bus access with split-transaction support to maximize throughput[cite: 22].
* [cite_start]**Serial Transfer:** All data and addresses are transferred bit-serially to minimize interconnect complexity[cite: 42].



---

## 2. Bus Architecture & Parameters

### 2.1 Configurable Parameters
| Parameter | Default Value | Description |
| :--- | :--- | :--- |
| `ADDR_WIDTH` | 16 bits | [cite_start]Total address bus width [cite: 34] |
| `DATA_WIDTH` | 8 bits | [cite_start]Data bus width [cite: 34] |
| `SLAVE_MEM_ADDR_WIDTH`| 12 bits | [cite_start]Slave memory address space [cite: 34] |
| `SLAVE_ADDR_WIDTH` | 4 bits | [cite_start]Slave address width [cite: 34] |

### 2.2 Address Mapping
[cite_start]The system uses a 4-bit Device Address and a 12-bit Memory Address[cite: 46, 47].

| Slave | Device Address | Address Range | Type |
| :--- | :--- | :--- | :--- |
| Slave 1 | `4'b0000` | 0x0000 - 0x07FF | [cite_start]2KB BRAM [cite: 49] |
| Slave 2 | `4'b0001` | 0x1000 - 0x1FFF | [cite_start]4KB BRAM [cite: 49] |
| Slave 3 | `4'b0010` | 0x2000 - 0x2FFF | [cite_start]4KB BRAM [cite: 49] |

---

## 3. Key Components

### 3.1 Bus Arbiter
[cite_start]Implements a fixed-priority mechanism where **Master 1** always has higher priority over **Master 2**[cite: 51].
* [cite_start]**States:** IDLE, M1 (Master 1 granted), M2 (Master 2 granted)[cite: 58, 59, 60].
* [cite_start]**Split Support:** Tracks split transactions to resume them once the slave is ready[cite: 61].



### 3.2 Address Decoder
[cite_start]Routes serial device addresses from masters to the correct slave[cite: 89].
* [cite_start]Generates individual `mvalid` signals and `ack` handshakes[cite: 90].
* [cite_start]Restores split addresses when a transaction is ready to resume[cite: 103].

### 3.3 Bus Bridge (UART)
[cite_start]Enables communication between "Bus A" and "Bus B" domains[cite: 192, 200].
* [cite_start]**Baud Rate:** ~9600 bps (50 MHz clock with 5208 divider)[cite: 201, 205].
* [cite_start]**Request Frame:** 32-bit (Padding + Mode + Data + Addr)[cite: 211].
* [cite_start]**Response Frame:** 16-bit (Read Data + Flags)[cite: 215].

---

## 4. Timing Characteristics
[cite_start]Standard cycle counts for bus transactions (excluding arbitration latency)[cite: 319]:

| Phase | Duration | Details |
| :--- | :--- | :--- |
| Device Address | 4 cycles | [cite_start]MSB First [cite: 319] |
| Memory Address | 12 cycles | [cite_start]LSB First [cite: 319] |
| Data Transfer | 8 cycles | [cite_start]LSB First [cite: 319] |
| **Total Write** | [cite_start]**~24 cycles** | [cite: 319] |
| **Total Read** | [cite_start]**~32 cycles** | [cite: 319] |

---

## 5. Resource Summary
[cite_start]Total hardware resources utilized for the design[cite: 332]:
* [cite_start]**Block RAMs:** 3 (32B demo + 2KB + 4KB)[cite: 332].
* [cite_start]**FIFOs:** 1 (8-deep, 32-bit width for UART Bridge)[cite: 332].
* [cite_start]**UART Modules:** 2 (Asymmetric TX/RX pairs)[cite: 332].
* [cite_start]**State Machines:** 6+ (Arbiter, Masters, Slaves, Bridges)[cite: 332].

---

## 6. Project Metadata
* [cite_start]**Course:** EN4021 - Advanced Digital Systems [cite: 4]
* [cite_start]**Authors:** AMARATHUNGA D.N., PASIRA I.Ρ.Μ., RAJAPAKSHA S.S.D.Z. [cite: 9, 10, 11]
* [cite_start]**Date:** December 09, 2025 [cite: 12]
