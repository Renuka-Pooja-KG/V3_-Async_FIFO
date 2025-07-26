class async_fifo_driver extends uvm_driver #(async_fifo_sequence_item);
  `uvm_component_utils(async_fifo_driver)

  virtual async_fifo_interface fifo_vif;
  async_fifo_sequence_item tr;

  function new(string name = "async_fifo_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual async_fifo_interface)::get(this, "", "fifo_vif", fifo_vif)) begin
      `uvm_fatal("NOVIF", "Could not get fifo_vif from uvm_config_db")
    end
    tr = async_fifo_sequence_item::type_id::create("tr");
    `uvm_info(get_type_name(), "async_fifo_driver build_phase completed, interface acquired", UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "async_fifo_driver run_phase started", UVM_LOW)
    
    forever begin
      seq_item_port.get_next_item(tr);
      
      // Drive all signals from sequence item to interface
      fifo_vif.driver_cb.write_enable <= tr.write_enable;
      fifo_vif.driver_cb.wdata <= tr.wdata;
      fifo_vif.driver_cb.afull_value <= tr.afull_value;
      fifo_vif.driver_cb.read_enable <= tr.read_enable;
      fifo_vif.driver_cb.aempty_value <= tr.aempty_value;
      fifo_vif.driver_cb.sw_rst <= tr.sw_rst;
      
      // Drive asynchronous reset signals
      fifo_vif.hw_rst_n <= tr.hw_rst_n;
      fifo_vif.mem_rst <= tr.mem_rst;
      
      // Wait for clock edge
      @(fifo_vif.driver_cb);
      
      // Sample response signals
      tr.read_data = fifo_vif.driver_cb.read_data;
      tr.wfull = fifo_vif.driver_cb.wfull;
      tr.wr_almost_ful = fifo_vif.driver_cb.wr_almost_ful;
      tr.overflow = fifo_vif.driver_cb.overflow;
      tr.fifo_write_count = fifo_vif.driver_cb.fifo_write_count;
      tr.wr_level = fifo_vif.driver_cb.wr_level;
      tr.rdempty = fifo_vif.driver_cb.rdempty;
      tr.rd_almost_empty = fifo_vif.driver_cb.rd_almost_empty;
      tr.underflow = fifo_vif.driver_cb.underflow;
      tr.fifo_read_count = fifo_vif.driver_cb.fifo_read_count;
      tr.rd_level = fifo_vif.driver_cb.rd_level;
      
      `uvm_info(get_type_name(), $sformatf("async_fifo_driver: tr = %s", tr.convert2string()), UVM_LOW)
      seq_item_port.item_done();
    end
  endtask

endclass
