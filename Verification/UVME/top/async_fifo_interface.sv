interface async_fifo_interface (
  input logic wclk,  // Write clock
  input logic rclk   // Read clock
);

  // Asynchronous reset signals (not part of clocking blocks)
  logic hw_rst_n;
  logic mem_rst;
  
  // Synchronous reset signal
  logic sw_rst;
  
  logic [31:0] wdata;
  logic write_enable;
  logic [4:0] afull_value;
  logic wfull;
  logic wr_almost_ful;
  logic overflow;
  logic [5:0] fifo_write_count;
  logic [5:0] wr_level;

  // Read side signals
  logic [31:0] read_data;
  logic read_enable;
  logic [4:0] aempty_value;
  logic rdempty;
  logic rd_almost_empty;
  logic underflow;
  logic [5:0] fifo_read_count;
  logic [5:0] rd_level;

  // Combined driver clocking block
  // This clocking block handles both write and read operations
  // Write signals are driven on wclk, read signals are driven on rclk
  // Note: hw_rst_n and mem_rst are asynchronous and not part of clocking blocks
  clocking driver_cb @(posedge wclk or posedge rclk);
    default input #1step output #1step;
    
    // Synchronous reset signal
    output sw_rst;

    // Write domain outputs (driven on wclk)
    output wdata, write_enable, afull_value;
    
    // Read domain outputs (driven on rclk)
    output read_enable, aempty_value;
    
    // Write domain inputs (sampled on wclk)
    input wfull, wr_almost_ful, overflow, fifo_write_count, wr_level;
    
    // Read domain inputs (sampled on rclk)
    input read_data, rdempty, rd_almost_empty, underflow, fifo_read_count, rd_level;
  endclocking

  // Combined monitor clocking block
  // This clocking block monitors both write and read operations
  // All signals are sampled as inputs
  // Note: hw_rst_n and mem_rst are asynchronous and not part of clocking blocks
  clocking monitor_cb @(posedge wclk or posedge rclk);
    default input #1step output #1step;
    
    // Synchronous reset signal
    input sw_rst;

    // Write domain inputs (sampled on wclk)
    input wdata, write_enable, afull_value;
    input wfull, wr_almost_ful, overflow, fifo_write_count, wr_level;
    
    // Read domain inputs (sampled on rclk)
    input read_enable, aempty_value;
    input read_data, rdempty, rd_almost_empty, underflow, fifo_read_count, rd_level;
  endclocking

  // Modport for driver (includes asynchronous reset signals)
  modport driver_mp (
    clocking driver_cb,
    output hw_rst_n, mem_rst  // Asynchronous reset signals
  );

  // Modport for monitor (includes asynchronous reset signals)
  modport monitor_mp (
    clocking monitor_cb,
    input hw_rst_n, mem_rst   // Asynchronous reset signals
  );

endinterface
