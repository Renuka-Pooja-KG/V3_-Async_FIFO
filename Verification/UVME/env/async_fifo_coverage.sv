class async_fifo_coverage extends uvm_subscriber #(async_fifo_sequence_item);
  `uvm_component_utils(async_fifo_coverage)
  
  async_fifo_sequence_item cov_item;
 
  // Coverage group for reset signals
  covergroup reset_cg();
    option.per_instance = 1;
    option.name = "reset_cg";
    option.comment = "Reset signals coverage group";

    hw_rst_n_cp: coverpoint cov_item.hw_rst_n {
      bins zero = {0};
      bins one = {1};
    }

    mem_rst_cp: coverpoint cov_item.mem_rst {
      bins zero = {0};
      bins one = {1};
    }

    sw_rst_cp: coverpoint cov_item.sw_rst {
      bins zero = {0};
      bins one = {1};
    }

    // Cross coverage for reset combinations
    reset_combinations: cross hw_rst_n_cp, mem_rst_cp, sw_rst_cp;
  endgroup: reset_cg

  // Coverage group for write operations
  covergroup write_cg();
    option.per_instance = 1;
    option.name = "write_cg";
    option.comment = "Write operations coverage group";

    write_enable_cp: coverpoint cov_item.write_enable {
      bins zero = {0};
      bins one = {1};
    }

    wdata_cp: coverpoint cov_item.wdata {
      option.auto_bin_max = 32;
    }

    afull_value_cp: coverpoint cov_item.afull_value {
      bins low = {[1:10]};
      bins med = {[11:20]};
      bins high = {[21:31]};
    }

    wfull_cp: coverpoint cov_item.wfull {
      bins zero = {0};
      bins one = {1};
    }

    wr_almost_ful_cp: coverpoint cov_item.wr_almost_ful {
      bins zero = {0};
      bins one = {1};
    }

    overflow_cp: coverpoint cov_item.overflow {
      bins zero = {0};
      bins one = {1};
    }

    fifo_write_count_cp: coverpoint cov_item.fifo_write_count {
      bins zero = {0};
      bins low = {[1:10]};
      bins med = {[11:20]};
      bins high = {[21:31]};
      bins full = {32};
    }

    wr_level_cp: coverpoint cov_item.wr_level {
      bins empty = {0};
      bins low = {[1:10]};
      bins med = {[11:20]};
      bins high = {[21:31]};
      bins full = {32};
    }

    // Cross coverage for write operations
    write_enable_wdata: cross write_enable_cp, wdata_cp {
      ignore_bins write_enable_zero_wdata = binsof(write_enable_cp.zero) && binsof(wdata_cp);
    }

    write_enable_afull: cross write_enable_cp, afull_value_cp;
    write_enable_wfull: cross write_enable_cp, wfull_cp;
  endgroup: write_cg

  // Coverage group for read operations
  covergroup read_cg();
    option.per_instance = 1;
    option.name = "read_cg";
    option.comment = "Read operations coverage group";

    read_enable_cp: coverpoint cov_item.read_enable {
      bins zero = {0};
      bins one = {1};
    }

    read_data_cp: coverpoint cov_item.read_data {
      option.auto_bin_max = 32;
    }

    aempty_value_cp: coverpoint cov_item.aempty_value {
      bins low = {[1:10]};
      bins med = {[11:20]};
      bins high = {[21:31]};
    }

    rdempty_cp: coverpoint cov_item.rdempty {
      bins zero = {0};
      bins one = {1};
    }

    rd_almost_empty_cp: coverpoint cov_item.rd_almost_empty {
      bins zero = {0};
      bins one = {1};
    }

    underflow_cp: coverpoint cov_item.underflow {
      bins zero = {0};
      bins one = {1};
    }

    fifo_read_count_cp: coverpoint cov_item.fifo_read_count {
      bins zero = {0};
      bins low = {[1:10]};
      bins med = {[11:20]};
      bins high = {[21:31]};
      bins full = {32};
    }

    rd_level_cp: coverpoint cov_item.rd_level {
      bins empty = {0};
      bins low = {[1:10]};
      bins med = {[11:20]};
      bins high = {[21:31]};
      bins full = {32};
    }

    // Cross coverage for read operations
    read_enable_read_data: cross read_enable_cp, read_data_cp {
      ignore_bins read_enable_zero_read_data = binsof(read_enable_cp.zero) && binsof(read_data_cp);
    }

    read_enable_aempty: cross read_enable_cp, aempty_value_cp;
    read_enable_rdempty: cross read_enable_cp, rdempty_cp;
  endgroup: read_cg

/*
  // Coverage group for simultaneous operations
  covergroup simultaneous_cg();
    option.per_instance = 1;
    option.name = "simultaneous_cg";
    option.comment = "Simultaneous read/write operations coverage group";

    // Cross coverage between write and read signals
    write_read_enable: cross cov_item.write_enable, cov_item.read_enable {
      bins write_only = binsof(cov_item.write_enable) intersect {1} && binsof(cov_item.read_enable) intersect {0};
      bins read_only = binsof(cov_item.write_enable) intersect {0} && binsof(cov_item.read_enable) intersect {1};
      bins simultaneous = binsof(cov_item.write_enable) intersect {1} && binsof(cov_item.read_enable) intersect {1};
      bins idle = binsof(cov_item.write_enable) intersect {0} && binsof(cov_item.read_enable) intersect {0};
    }

    // FIFO state during simultaneous operations
    fifo_state_simultaneous: cross cov_item.wfull, cov_item.rdempty {
      bins empty = binsof(cov_item.wfull) intersect {0} && binsof(cov_item.rdempty) intersect {1};
      bins full = binsof(cov_item.wfull) intersect {1} && binsof(cov_item.rdempty) intersect {0};
      bins normal = binsof(cov_item.wfull) intersect {0} && binsof(cov_item.rdempty) intersect {0};
      bins invalid = binsof(cov_item.wfull) intersect {1} && binsof(cov_item.rdempty) intersect {1};
    }
  endgroup: simultaneous_cg

*/
  int count = 0;
  uvm_analysis_imp #(async_fifo_sequence_item, async_fifo_coverage) fifo_analysis_imp;

  function new(string name = "async_fifo_coverage", uvm_component parent = null);
    super.new(name, parent);
    reset_cg = new();
    write_cg = new();
    read_cg = new();
    //simultaneous_cg = new();
    fifo_analysis_imp = new("fifo_analysis_imp", this);
  endfunction

  function void write(async_fifo_sequence_item t);
    cov_item = new();
    cov_item.copy(t);
    
    // Sample all coverage groups
    reset_cg.sample();
    write_cg.sample();
    read_cg.sample();
    //simultaneous_cg.sample();
    
    count++;
  endfunction

  virtual function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    `uvm_info(get_type_name(), $sformatf("async_fifo_coverage: count = %d", count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("async_fifo_coverage: reset_cg = %s", reset_cg.get_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("async_fifo_coverage: write_cg = %s", write_cg.get_coverage()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("async_fifo_coverage: read_cg = %s", read_cg.get_coverage()), UVM_LOW)
    //`uvm_info(get_type_name(), $sformatf("async_fifo_coverage: simultaneous_cg = %s", simultaneous_cg.get_coverage()), UVM_LOW)
  endfunction

endclass
