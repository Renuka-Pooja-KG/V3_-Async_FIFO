package verification_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

// Include all the files in the package
//`include "./../UVME/top/interface/wr_interface.sv"
//`include "./../UVME/top/interface/rd_interface.sv"

`include "./../UVME/sequence/async_fifo_sequence_item.sv"

`include "./../UVME/agent/async_fifo_driver.sv"
`include "./../UVME/agent/async_fifo_monitor.sv"
`include "./../UVME/agent/async_fifo_sequencer.sv"

`include "./../UVME/agent/async_fifo_agent.sv"

`include "./../UVME/env/async_fifo_coverage.sv"
`include "./../UVME/env/async_fifo_scoreboard.sv"

`include "./../UVME/env/async_fifo_env.sv"

`include "./../UVME/sequence/async_fifo_base_sequence.sv"

endpackage