class async_fifo_base_sequence extends uvm_sequence #(async_fifo_sequence_item);
  `uvm_object_utils(async_fifo_base_sequence)

  // Configuration parameters
  int num_transactions = 30;
  int scenario = 0; // 0: random, 1: reset, 2: write_only, 3: read_only, 4: simultaneous

  function new(string name = "async_fifo_base_sequence");
    super.new(name);
  endfunction

  // Main sequence body
  task body();
    `uvm_info(get_type_name(), $sformatf("Starting base sequence with %0d transactions, scenario=%0d", num_transactions, scenario), UVM_LOW)
    
    case (scenario)
      0: random_scenario();
      1: reset_scenario();
      2: write_only_scenario();
      3: read_only_scenario();
      4: simultaneous_scenario();
      default: random_scenario();
    endcase
    
    `uvm_info(get_type_name(), "Base sequence completed", UVM_LOW)
  endtask

  // Random scenario - mix of all operations
  task random_scenario();
    async_fifo_sequence_item tr;
    
    repeat (num_transactions) begin
      tr = async_fifo_sequence_item::type_id::create("tr");
      
      // Randomize with mixed operations
      if (!tr.randomize()) begin
        `uvm_fatal(get_type_name(), "Failed to randomize transaction")
      end
      
      start_item(tr);
      finish_item(tr);
      
      `uvm_info(get_type_name(), $sformatf("Random: %s", tr.convert2string()), UVM_HIGH)
    end
  endtask

  // Reset scenario
  task reset_scenario();
    async_fifo_sequence_item tr;
    `uvm_info(get_type_name(), "Starting reset scenario", UVM_LOW)
    
    // Apply hardware reset (active low) for 3 cycles
    repeat (3) begin
      `uvm_do_with(tr, {
        hw_rst_n == 0;      // Active low - assert reset
        mem_rst == 0;       // Active high - de-assert reset
        sw_rst == 0;
        write_enable == 0;
        read_enable == 0;
        wdata == 0;
        afull_value == 30;
        aempty_value == 2;
      })
      `uvm_info(get_type_name(), $sformatf("Hardware Reset: %s", tr.convert2string()), UVM_HIGH)
    end
    
    // De-assert hardware reset
    `uvm_do_with(tr, {
      hw_rst_n == 1;        // Active low - de-assert reset
      mem_rst == 0;         // Active high - de-assert reset
      sw_rst == 0;
      write_enable == 0;
      read_enable == 0;
      wdata == 0;
      afull_value == 16;
      aempty_value == 16;
    })
    `uvm_info(get_type_name(), $sformatf("De-assert Hardware Reset: %s", tr.convert2string()), UVM_HIGH)
    
    // Apply memory reset (active high) for 3 cycles
    repeat (3) begin
      `uvm_do_with(tr, {
        hw_rst_n == 1;      // Active low - de-assert reset
        mem_rst == 1;       // Active high - assert reset
        sw_rst == 0;
        write_enable == 0;
        read_enable == 0;
        wdata == 0;
        afull_value == 30;
        aempty_value == 2;
      })
      `uvm_info(get_type_name(), $sformatf("Memory Reset: %s", tr.convert2string()), UVM_HIGH)
    end
    
    // De-assert memory reset
    `uvm_do_with(tr, {
      hw_rst_n == 1;        // Active low - de-assert reset
      mem_rst == 0;         // Active high - de-assert reset
      sw_rst == 0;
      write_enable == 0;
      read_enable == 0;
      wdata == 0;
      afull_value == 16;
      aempty_value == 16;
    })
    `uvm_info(get_type_name(), $sformatf("De-assert Memory Reset: %s", tr.convert2string()), UVM_HIGH)
    
    // Apply software reset for 2 cycles
    repeat (2) begin
      `uvm_do_with(tr, {
        hw_rst_n == 1;      // Active low - de-assert reset
        mem_rst == 0;       // Active high - de-assert reset
        sw_rst == 1;        // Software reset asserted
        write_enable == 0;
        read_enable == 0;
        wdata == 0;
        afull_value == 30;
        aempty_value == 2;
      })
      `uvm_info(get_type_name(), $sformatf("Software Reset: %s", tr.convert2string()), UVM_HIGH)
    end
    
    // De-assert software reset and return to normal operation
    `uvm_do_with(tr, {
      hw_rst_n == 1;        // Active low - de-assert reset
      mem_rst == 0;         // Active high - de-assert reset
      sw_rst == 0;          // Software reset de-asserted
      write_enable == 0;
      read_enable == 0;
      wdata == 0;
      afull_value == 16;
      aempty_value == 16;
    })
    `uvm_info(get_type_name(), $sformatf("Normal Operation: %s", tr.convert2string()), UVM_HIGH)
  endtask

  // Write-only scenario
  task write_only_scenario();
    async_fifo_sequence_item tr;
    `uvm_info(get_type_name(), "Starting write-only scenario", UVM_LOW)
    
    // Apply hardware reset first
    repeat (3) begin
      `uvm_do_with(tr, {
        hw_rst_n == 0;      // Active low - assert reset
        mem_rst == 0;       // Active high - de-assert reset
        sw_rst == 0;
        write_enable == 0;
        read_enable == 0;
        wdata == 0;
        afull_value == 30;
        aempty_value == 2;
      })
    end
    
    // De-assert hardware reset
    `uvm_do_with(tr, {
      hw_rst_n == 1;        // Active low - de-assert reset
      mem_rst == 0;         // Active high - de-assert reset
      sw_rst == 0;
      write_enable == 0;
      read_enable == 0;
      wdata == 0;
      afull_value == 16;
      aempty_value == 16;
    })
    
    // Write data for specified number of cycles
    repeat (30) begin
      `uvm_do_with(tr, {
        hw_rst_n == 1;      // Active low - de-assert reset
        mem_rst == 0;       // Active high - de-assert reset
        sw_rst == 0;
        write_enable == 1;
        read_enable == 0;
        wdata inside {[0:32'hFFFF_FFFF]};
        afull_value inside {[1:31]};
        aempty_value == 2;
      })
      `uvm_info(get_type_name(), $sformatf("Write: %s", tr.convert2string()), UVM_HIGH)
    end
    
    // Disable write
    `uvm_do_with(tr, {
      hw_rst_n == 1;        // Active low - de-assert reset
      mem_rst == 0;         // Active high - de-assert reset
      sw_rst == 0;
      write_enable == 0;
      read_enable == 0;
      wdata == 0;
      afull_value == 16;
      aempty_value == 16;
    })
  endtask

  // Read-only scenario
  task read_only_scenario();
    async_fifo_sequence_item tr;
    `uvm_info(get_type_name(), "Starting read-only scenario", UVM_LOW)
    
    // Apply hardware reset first
    repeat (3) begin
      `uvm_do_with(tr, {
        hw_rst_n == 0;      // Active low - assert reset
        mem_rst == 0;       // Active high - de-assert reset
        sw_rst == 0;
        write_enable == 0;
        read_enable == 0;
        wdata == 0;
        afull_value == 30;
        aempty_value == 2;
      })
    end
    
    // De-assert hardware reset
    `uvm_do_with(tr, {
      hw_rst_n == 1;        // Active low - de-assert reset
      mem_rst == 0;         // Active high - de-assert reset
      sw_rst == 0;
      write_enable == 0;
      read_enable == 0;
      wdata == 0;
      afull_value == 16;
      aempty_value == 16;
    })
    
    // Read data for specified number of cycles
    repeat (10) begin
      `uvm_do_with(tr, {
        hw_rst_n == 1;      // Active low - de-assert reset
        mem_rst == 0;       // Active high - de-assert reset
        sw_rst == 0;
        write_enable == 0;
        read_enable == 1;
        wdata == 0;
        afull_value == 30;
        aempty_value inside {[1:31]};
      })
      `uvm_info(get_type_name(), $sformatf("Read: %s", tr.convert2string()), UVM_HIGH)
    end
    
    // Disable read
    `uvm_do_with(tr, {
      hw_rst_n == 1;        // Active low - de-assert reset
      mem_rst == 0;         // Active high - de-assert reset
      sw_rst == 0;
      write_enable == 0;
      read_enable == 0;
      wdata == 0;
      afull_value == 16;
      aempty_value == 16;
    })
  endtask

  // Simultaneous read and write scenario
  task simultaneous_scenario();
    async_fifo_sequence_item tr;
    `uvm_info(get_type_name(), "Starting simultaneous scenario", UVM_LOW)
    
    // Apply hardware reset first
    repeat (3) begin
      `uvm_do_with(tr, {
        hw_rst_n == 0;      // Active low - assert reset
        mem_rst == 0;       // Active high - de-assert reset
        sw_rst == 0;
        write_enable == 0;
        read_enable == 0;
        wdata == 0;
        afull_value == 30;
        aempty_value == 2;
      })
    end
    
    // De-assert hardware reset
    `uvm_do_with(tr, {
      hw_rst_n == 1;        // Active low - de-assert reset
      mem_rst == 0;         // Active high - de-assert reset
      sw_rst == 0;
      write_enable == 0;
      read_enable == 0;
      wdata == 0;
      afull_value == 16;
      aempty_value == 16;
    })
    
    // Simultaneous read and write for specified number of cycles
    repeat (10) begin
      `uvm_do_with(tr, {
        hw_rst_n == 1;      // Active low - de-assert reset
        mem_rst == 0;       // Active high - de-assert reset
        sw_rst == 0;
        write_enable == 1;
        read_enable == 1;
        wdata inside {[0:32'hFFFF_FFFF]};
        afull_value inside {[1:31]};
        aempty_value inside {[1:31]};
      })
      `uvm_info(get_type_name(), $sformatf("Simultaneous: %s", tr.convert2string()), UVM_HIGH)
    end
    
    // Disable both operations
    `uvm_do_with(tr, {
      hw_rst_n == 1;        // Active low - de-assert reset
      mem_rst == 0;         // Active high - de-assert reset
      sw_rst == 0;
      write_enable == 0;
      read_enable == 0;
      wdata == 0;
      afull_value == 16;
      aempty_value == 16;
    })
  endtask

endclass
