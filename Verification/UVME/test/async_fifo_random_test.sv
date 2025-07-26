class async_fifo_random_test extends async_fifo_base_test;
  `uvm_component_utils(async_fifo_random_test)

  async_fifo_base_sequence random_seq;

  function new(string name = "async_fifo_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    random_seq = async_fifo_base_sequence::type_id::create("random_seq");
    random_seq.scenario = 0; // Random scenario
    random_seq.num_transactions = 30;
    `uvm_info(get_type_name(), "Building async_fifo_random_test", UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    `uvm_info(get_type_name(), "Starting random test sequence", UVM_LOW)
    
    // Start the random sequence
    random_seq.start(m_env.m_fifo_agent.m_sequencer);
    
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this, 100ns);
  endtask

endclass 