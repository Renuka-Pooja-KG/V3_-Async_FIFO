class async_fifo_sequencer extends uvm_sequencer #(async_fifo_sequence_item);
  `uvm_component_utils(async_fifo_sequencer)

  function new(string name = "async_fifo_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "async_fifo_sequencer build_phase completed", UVM_LOW)
  endfunction

endclass
