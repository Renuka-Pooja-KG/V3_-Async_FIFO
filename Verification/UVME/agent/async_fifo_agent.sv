class async_fifo_agent extends uvm_agent;
  `uvm_component_utils(async_fifo_agent)

  // Agent components
  async_fifo_driver driver;
  async_fifo_sequencer sequencer;
  async_fifo_monitor monitor;

  // Analysis port for connecting to scoreboard/coverage
  uvm_analysis_port #(async_fifo_sequence_item) agent_analysis_port;

  function new(string name = "async_fifo_agent", uvm_component parent = null);
    super.new(name, parent);
    agent_analysis_port = new("agent_analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Create monitor (always created)
    monitor = async_fifo_monitor::type_id::create("monitor", this);
    
    // Create driver and sequencer only if agent is active
    if (get_is_active() == UVM_ACTIVE) begin
      driver = async_fifo_driver::type_id::create("driver", this);
      sequencer = async_fifo_sequencer::type_id::create("sequencer", this);
    end
    
    `uvm_info(get_type_name(), "async_fifo_agent build_phase completed", UVM_LOW)
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // Connect monitor analysis port to agent analysis port
    monitor.fifo_analysis_port.connect(agent_analysis_port);
    
    // Connect driver to sequencer only if agent is active
    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    
    `uvm_info(get_type_name(), "async_fifo_agent connect_phase completed", UVM_LOW)
  endfunction

endclass
