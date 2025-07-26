class async_fifo_monitor extends uvm_monitor;
  `uvm_component_utils(async_fifo_monitor)

  uvm_analysis_port #(async_fifo_sequence_item) fifo_analysis_port;
  virtual async_fifo_interface fifo_vif;

  function new(string name = "async_fifo_monitor", uvm_component parent = null);
    super.new(name, parent);
    fifo_analysis_port = new("fifo_analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual async_fifo_interface)::get(this, "", "fifo_vif", fifo_vif)) begin
      `uvm_fatal("NOVIF", "Could not get fifo_vif from uvm_config_db")
    end
    `uvm_info(get_type_name(), "async_fifo_monitor build_phase completed, interface acquired", UVM_MEDIUM)
  endfunction

  task run_phase(uvm_phase phase);
    async_fifo_sequence_item tr;
    `uvm_info(get_type_name(), "async_fifo_monitor run_phase started", UVM_LOW)
    
    forever begin
      @(fifo_vif.monitor_cb);
      tr = async_fifo_sequence_item::type_id::create("tr", this);
      
      // Sample all signals from the interface
      // Asynchronous reset signals
      tr.hw_rst_n = fifo_vif.hw_rst_n;
      tr.mem_rst = fifo_vif.mem_rst;
      
      // Synchronous reset signal
      tr.sw_rst = fifo_vif.monitor_cb.sw_rst;
      
      // Write side signals
      tr.write_enable = fifo_vif.monitor_cb.write_enable;
      tr.wdata = fifo_vif.monitor_cb.wdata;
      tr.afull_value = fifo_vif.monitor_cb.afull_value;
      tr.wfull = fifo_vif.monitor_cb.wfull;
      tr.wr_almost_ful = fifo_vif.monitor_cb.wr_almost_ful;
      tr.overflow = fifo_vif.monitor_cb.overflow;
      tr.fifo_write_count = fifo_vif.monitor_cb.fifo_write_count;
      tr.wr_level = fifo_vif.monitor_cb.wr_level;
      
      // Read side signals
      tr.read_enable = fifo_vif.monitor_cb.read_enable;
      tr.aempty_value = fifo_vif.monitor_cb.aempty_value;
      tr.rdempty = fifo_vif.monitor_cb.rdempty;
      tr.rd_almost_empty = fifo_vif.monitor_cb.rd_almost_empty;
      tr.underflow = fifo_vif.monitor_cb.underflow;
      tr.fifo_read_count = fifo_vif.monitor_cb.fifo_read_count;
      tr.rd_level = fifo_vif.monitor_cb.rd_level;
      tr.read_data = fifo_vif.monitor_cb.read_data;
      
      // Write transaction to analysis port
      fifo_analysis_port.write(tr);
      
      `uvm_info(get_type_name(), $sformatf("async_fifo_monitor: tr = %s", tr.convert2string()), UVM_MEDIUM)
    end
  endtask

endclass
