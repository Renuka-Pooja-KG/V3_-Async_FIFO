class async_fifo_simultaneous_test extends async_fifo_base_test;
  `uvm_component_utils(async_fifo_simultaneous_test)

  async_fifo_base_sequence simultaneous_seq;

  function new(string name = "async_fifo_simultaneous_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    simultaneous_seq = async_fifo_base_sequence::type_id::create("simultaneous_seq");
    simultaneous_seq.scenario = 4; // Simultaneous scenario
    simultaneous_seq.num_transactions = 10;
    `uvm_info(get_type_name(), "Building async_fifo_simultaneous_test", UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    `uvm_info(get_type_name(), "Starting simultaneous test sequence", UVM_LOW)
    
    // Start the simultaneous sequence
    simultaneous_seq.start(m_env.m_fifo_agent.m_sequencer);
    
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this, 100ns);
  endtask

endclass 