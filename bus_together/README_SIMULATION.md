# Combined Bus Bridge Simulation

This directory contains a combined top-level design that connects two bus systems via UART bridge.

## Files Created

1. **`RTL_Linuka/combined_top.sv`** - Top-level module connecting both bus systems
2. **`RTL_Linuka/combined_top_tb.sv`** - Testbench for simulation
3. **`RTL_Mavishan/altsyncram.v`** - Behavioral model for Altera BRAM (for simulation)
4. **`sim_combined_fixed.do`** - QuestaSim compilation and simulation script

## Architecture

```
combined_top
├── system_top_with_bus_bridge_a (Bus A - RTL_Linuka design)
│   ├── uart_tx → connects to → demo_top_bb.m_u_rx
│   └── uart_rx ← connects from ← demo_top_bb.m_u_tx
└── demo_top_bb (Bus B - RTL_Mavishan design)
    ├── m_u_tx → connects to → system_top_with_bus_bridge_a.uart_rx
    └── m_u_rx ← connects from ← system_top_with_bus_bridge_a.uart_tx
```

## How to Run Simulation

### Method 1: Using the automated script (Recommended)
```powershell
cd bus_together
vsim -do sim_combined_fixed.do
```

### Method 2: Manual steps
```tcl
# In QuestaSim console:
do sim_combined_fixed.do
```

## Key Features

- **Separate Libraries**: Uses `work_linuka` and `work_mavishan` to avoid module name conflicts
- **UART Cross-Connection**: Two bus systems communicate via UART
- **Behavioral BRAM**: Includes simulation model for Altera `altsyncram` component
- **Comprehensive Testbench**: Tests both bus systems with read/write operations

## Testbench Scenarios

1. **Test 1**: Trigger write from Bus A (button trigger)
2. **Test 2**: Read operation from Bus B (mode=0)
3. **Test 3**: Write operation from Bus B (mode=1)
4. **Test 4**: Another trigger from Bus A

## Notes

- The simulation uses **separate work libraries** to handle module name conflicts between RTL_Linuka and RTL_Mavishan designs
- Altera-specific components (`altsyncram`) are replaced with behavioral models for simulation
- Parameter override warnings are suppressed (they're expected due to design differences)

## Troubleshooting

If you encounter compilation errors:
1. Ensure all source files are present in RTL_Linuka and RTL_Mavishan directories
2. Delete work libraries and recompile: `vdel -lib work -all; vdel -lib work_linuka -all; vdel -lib work_mavishan -all`
3. Run the script again: `vsim -do sim_combined_fixed.do`
