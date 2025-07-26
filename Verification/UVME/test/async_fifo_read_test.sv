class async_fifo_read_test extends async_fifo_base_test;
  `uvm_component_utils(async_fifo_read_test)

  async_fifo_base_sequence read_seq;

  function new(string name = "async_fifo_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    read_seq = async_fifo_base_sequence::type_id::create("read_seq");
    read_seq.scenario = 3; // Read-only scenario
    read_seq.num_transactions = 10;
    `uvm_info(get_type_name(), "Building async_fifo_read_test", UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    `uvm_info(get_type_name(), "Starting read test sequence", UVM_LOW)
    
    // Start the read sequence
    read_seq.start(m_env.m_fifo_agent.m_sequencer);
    
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this, 100ns);
  endtask

endclass 