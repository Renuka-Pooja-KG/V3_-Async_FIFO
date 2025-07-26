class async_fifo_base_test extends uvm_test;
  `uvm_component_utils(async_fifo_base_test)

  async_fifo_env m_env;

  function new(string name = "async_fifo_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = async_fifo_env::type_id::create("m_env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    `uvm_info(get_type_name(), "Base test run_phase - sequences should be applied in derived tests", UVM_LOW)
    
    // Wait for some time to allow derived tests to start their sequences
    // #100ns;
    
    phase.drop_objection(this);
  endtask

  // function void report_phase(uvm_phase phase);
  //   super.report_phase(phase);
  //   int error_count = uvm_report_server::get_server().get_severity_count(UVM_ERROR);
  //   int fatal_count = uvm_report_server::get_server().get_severity_count(UVM_FATAL);
  //   string test_name = get_type_name();
    
  //   $display("=====================================================");
  //   if (!error_count && !fatal_count) begin
  //     $display("[%s] STATUS : PASSED", test_name);
  //   end else begin
  //     $display("[%s] STATUS : FAILED", test_name);
  //     $display("ERRORS:%d, FATAL:%d", error_count, fatal_count);
  //   end
  //   $display("=====================================================");
  // endfunction

endclass 