class async_fifo_sequence_item extends uvm_sequence_item;

  // Asynchronous reset signals
  rand bit hw_rst_n;
  rand bit mem_rst;
  
  // Synchronous reset signal
  rand bit sw_rst;

  // Write side signals
  rand bit [31:0] wdata;
  rand bit write_enable;
  rand bit [4:0] afull_value;
  bit wfull;
  bit wr_almost_ful;
  bit overflow;
  bit [5:0] fifo_write_count;
  bit [5:0] wr_level;

  // Read side signals
  rand bit read_enable;
  rand bit [4:0] aempty_value;
  bit rdempty;
  bit rd_almost_empty;
  bit underflow;
  bit [5:0] fifo_read_count;
  bit [5:0] rd_level;
  bit [31:0] read_data;

  // Reasonable value constraints
  constraint value_constraints {
    afull_value inside {[1:31]};
    aempty_value inside {[1:31]};
    wdata inside {[0:32'hFFFF_FFFF]};
  }

  `uvm_object_utils_begin(async_fifo_sequence_item)
    // Reset signals
    `uvm_field_int(hw_rst_n, UVM_ALL_ON)
    `uvm_field_int(mem_rst, UVM_ALL_ON)
    `uvm_field_int(sw_rst, UVM_ALL_ON)
    
    // Write signals
    `uvm_field_int(wdata, UVM_ALL_ON)
    `uvm_field_int(write_enable, UVM_ALL_ON)
    `uvm_field_int(afull_value, UVM_ALL_ON)
    `uvm_field_int(wfull, UVM_ALL_ON)
    `uvm_field_int(wr_almost_ful, UVM_ALL_ON)
    `uvm_field_int(overflow, UVM_ALL_ON)
    `uvm_field_int(fifo_write_count, UVM_ALL_ON)
    `uvm_field_int(wr_level, UVM_ALL_ON)
    
    // Read signals
    `uvm_field_int(read_enable, UVM_ALL_ON)
    `uvm_field_int(aempty_value, UVM_ALL_ON)
    `uvm_field_int(rdempty, UVM_ALL_ON)
    `uvm_field_int(rd_almost_empty, UVM_ALL_ON)
    `uvm_field_int(underflow, UVM_ALL_ON)
    `uvm_field_int(fifo_read_count, UVM_ALL_ON)
    `uvm_field_int(rd_level, UVM_ALL_ON)
    `uvm_field_int(read_data, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "async_fifo_sequence_item");
    super.new(name);
  endfunction

  function void do_copy(uvm_object rhs);
    async_fifo_sequence_item rhs_;
    if (!$cast(rhs_, rhs)) begin
      `uvm_fatal("COPY_FAIL", "Type mismatch in do_copy")
    end
    super.do_copy(rhs);
    
    // Copy reset signals
    hw_rst_n = rhs_.hw_rst_n;
    mem_rst = rhs_.mem_rst;
    sw_rst = rhs_.sw_rst;
    
    // Copy write signals
    wdata = rhs_.wdata;
    write_enable = rhs_.write_enable;
    afull_value = rhs_.afull_value;
    wfull = rhs_.wfull;
    wr_almost_ful = rhs_.wr_almost_ful;
    overflow = rhs_.overflow;
    fifo_write_count = rhs_.fifo_write_count;
    wr_level = rhs_.wr_level;
    
    // Copy read signals
    read_enable = rhs_.read_enable;
    aempty_value = rhs_.aempty_value;
    rdempty = rhs_.rdempty;
    rd_almost_empty = rhs_.rd_almost_empty;
    underflow = rhs_.underflow;
    fifo_read_count = rhs_.fifo_read_count;
    rd_level = rhs_.rd_level;
    read_data = rhs_.read_data;
  endfunction

  function string convert2string();
    return $sformatf("hw_rst_n=%0b mem_rst=%0b sw_rst=%0b wdata=0x%0h write_enable=%0b afull_value=%0d wfull=%0b wr_almost_ful=%0b overflow=%0b fifo_write_count=%0d wr_level=%0d read_enable=%0b aempty_value=%0d rdempty=%0b rd_almost_empty=%0b underflow=%0b fifo_read_count=%0d rd_level=%0d read_data=0x%0h",
      hw_rst_n, mem_rst, sw_rst,
      wdata, write_enable, afull_value,
      wfull, wr_almost_ful, overflow, fifo_write_count, wr_level,
      read_enable, aempty_value,
      rdempty, rd_almost_empty, underflow, fifo_read_count, rd_level,
      read_data
    );
  endfunction

endclass
