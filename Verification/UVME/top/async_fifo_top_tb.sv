module async_fifo_top_tb;

  import uvm_pkg::*;
  import verification_pkg::*;

  `include "uvm_macros.svh"

  // Clock and reset signals
  logic wclk;
  logic rclk;

  // Clock generation
  initial wclk = 0;
  always #5 wclk = ~wclk; // 100MHz if WCLK_SPEED=10
  initial rclk = 0;
  always #7 rclk = ~rclk; // ~71.4MHz if RCLK_SPEED=14

  // Unified interface instantiation
  async_fifo_interface fifo_if (
    .wclk(wclk),
    .rclk(rclk)
  );

  // DUT instantiation
  async_fifo_int_mem #(
    .DATA_WIDTH(32),
    .ADDRESS_WIDTH(5),
    //.DEPTH(32),
    .SOFT_RESET(0),
    .POWER_SAVE (1),
    .STICKY_ERROR(0),
    .RESET_MEM(0),
    .PIPE_WRITE(0),
    .DEBUG_ENABLE(0),
    .PIPE_READ(0),
    .SYNC_STAGE(0)
  ) dut (
    // Write side
    .wclk(wclk),
    .hw_rst_n(fifo_if.hw_rst_n),
    .wdata(fifo_if.wdata),
    .write_enable(fifo_if.write_enable),
    .afull_value(fifo_if.afull_value),
    .sw_rst(fifo_if.sw_rst),
    .mem_rst(fifo_if.mem_rst),
    .wfull(fifo_if.wfull),
    .wr_almost_ful(fifo_if.wr_almost_ful),
    .overflow(fifo_if.overflow),
    .fifo_write_count(fifo_if.fifo_write_count),
    .wr_level(fifo_if.wr_level),
    // Read side
    .rclk(rclk),
    .read_enable(fifo_if.read_enable),
    .aempty_value(fifo_if.aempty_value),
    .read_data(fifo_if.read_data),
    .rdempty(fifo_if.rdempty),
    .rd_almost_empty(fifo_if.rd_almost_empty),
    .underflow(fifo_if.underflow),
    .fifo_read_count(fifo_if.fifo_read_count),
    .rd_level(fifo_if.rd_level)
  );

  // UVM config_db setup
  initial begin
    // Set the virtual interface for UVM (use driver modport)
    uvm_config_db#(virtual async_fifo_interface)::set(null, "*", "fifo_vif", fifo_if);
  end

  // Waveform dumping
  initial begin
    $shm_open("wave.shm");
    $shm_probe("AS");
  end
  // Start UVM
  initial begin
    run_test("async_fifo_base_test");
  end

endmodule