# IMPORTANT NOTE: Co-simulation Limitation

## Problem
The two bus designs (RTL_Linuka and RTL_Mavishan) have **incompatible modules with identical names**:
- `arbiter.sv` vs `arbiter.v` (different port interfaces)
- `addr_decoder.sv` vs `addr_decoder.v` (different port interfaces)  
- `uart.v` (in RTL_Linuka/uart/) vs `uart.v` (in RTL_Mavishan/) (different port names)

QuestaSim cannot properly resolve these conflicts even with separate libraries because both hierarchies are instantiated in the same simulation.

## Solution Options

### Option 1: Test Each Design Separately (Recommended for now)
Test `system_top_with_bus_bridge_a` and `demo_top_bb` in separate simulations.

### Option 2: Rename Conflicting Modules
Manually rename one set of modules (e.g., add prefix `mav_` to all RTL_Mavishan modules).

### Option 3: Use Configuration Blocks (Advanced)
Use SystemVerilog configuration blocks to explicitly bind modules to libraries.

## Current Status

The `combined_top.sv` and `combined_top_tb.sv` files are created and syntactically correct,
but cannot be simulated together due to module name conflicts.

**For successful simulation, please test each bus system independently.**
