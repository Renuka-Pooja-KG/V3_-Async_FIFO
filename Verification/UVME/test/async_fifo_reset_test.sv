class async_fifo_reset_test extends async_fifo_base_test;
  `uvm_component_utils(async_fifo_reset_test)

  async_fifo_base_sequence reset_seq;

  function new(string name = "async_fifo_reset_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reset_seq = async_fifo_base_sequence::type_id::create("reset_seq");
    reset_seq.scenario = 1; // Reset scenario
    reset_seq.num_transactions = 30;
    `uvm_info(get_type_name(), "Building async_fifo_reset_test", UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    `uvm_info(get_type_name(), "Starting reset test sequence", UVM_LOW)
    
    // Start the reset sequence
    reset_seq.start(m_env.m_fifo_agent.m_sequencer);
    
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this, 100ns);
  endtask

endclass 