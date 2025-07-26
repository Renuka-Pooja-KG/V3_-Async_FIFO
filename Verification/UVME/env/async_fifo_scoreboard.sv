class async_fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(async_fifo_scoreboard)

  uvm_analysis_export #(async_fifo_sequence_item) fifo_export;
  uvm_tlm_analysis_fifo #(async_fifo_sequence_item) fifo_fifo;

  // Data integrity checking
  bit [31:0] expected_data_queue[$];
  int write_count = 0;
  int read_count = 0;
  int error_count = 0;

  // FIFO state tracking
  int expected_wr_level = 0;
  int expected_rd_level = 0;
  int expected_fifo_write_count = 0; // Added for checking fifo_write_count
  int expected_fifo_read_count = 0; // Added for checking fifo_read_count   
  bit expected_wfull = 0;
  bit expected_rdempty = 1;
  bit expected_wr_almost_ful = 0;
  bit expected_rdalmost_empty = 0;
  bit expected_overflow = 0;
  bit expected_underflow = 0;

  function new(string name = "async_fifo_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    fifo_export = new("fifo_export", this);
    fifo_fifo = new("fifo_fifo", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    expected_wr_level = 0;
    expected_rd_level = (1 << 5); // FIFO depth
    expected_fifo_write_count = 0; // Initialize
    expected_fifo_read_count = 0; // Initialize 
    expected_wfull = 0;
    expected_rdempty = 1;
    expected_wr_almost_ful = 0;
    expected_rdalmost_empty = 0;
    expected_overflow = 0;
    expected_underflow = 0;
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    fifo_export.connect(fifo_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    fork
      check_fifo_transactions();
      check_fifo_behavior();
    join
  endtask

  task check_fifo_transactions();
    async_fifo_sequence_item tr;
    bit [31:0] expected_data;
    
    forever begin
      fifo_fifo.get(tr);
      
      // Handle simultaneous write and read operations
      if (tr.write_enable && tr.read_enable && !tr.wfull && !tr.rdempty) begin
        `uvm_info(get_type_name(), "Simultaneous write and read: pop front, push back", UVM_MEDIUM)
        
        // Handle read operation (pop front)
        if (expected_data_queue.size() > 0) begin
          expected_data = expected_data_queue.pop_front();
          if (tr.read_data !== expected_data) begin
            `uvm_error(get_type_name(), $sformatf("Data integrity error: expected=0x%h, actual=0x%h", expected_data, tr.read_data))
            error_count++;
          end
          read_count++;
          expected_fifo_read_count++; // Increment read count
        end
        
        // Handle write operation (push back)
        expected_data_queue.push_back(tr.wdata);
        write_count++;
        expected_fifo_write_count++; // Increment write count
        
        // Update expected status flags for simultaneous operation
        expected_wfull = (expected_wr_level == (1 << 5));
        expected_rdempty = (expected_wr_level == 0);
        expected_wr_almost_ful = (expected_wr_level >= tr.afull_value);
        expected_rdalmost_empty = (expected_wr_level <= tr.aempty_value);
        expected_overflow = (expected_wr_level >= (1 << 5));
        expected_underflow = (expected_wr_level == 0);
        
      end else if (tr.write_enable && !tr.wfull) begin
        // Write-only operation
        expected_data_queue.push_back(tr.wdata);
        write_count++;
        if (expected_wr_level < (1 << 5)) begin
          expected_wr_level++;
          expected_rd_level--;
          expected_fifo_write_count++; // Increment on successful write
        end
        expected_wfull = (expected_wr_level == (1 << 5));
        expected_rdempty = (expected_wr_level == 0);
        expected_wr_almost_ful = (expected_wr_level >= tr.afull_value);
        expected_overflow = (expected_wr_level >= (1 << 5));
        `uvm_info(get_type_name(), $sformatf("Write: data=0x%h, wr_level=%d, wfull=%b", tr.wdata, expected_wr_level, expected_wfull), UVM_HIGH)
        
      end else if (tr.read_enable && !tr.rdempty) begin
        // Read-only operation
        if (expected_data_queue.size() > 0) begin
          expected_data = expected_data_queue.pop_front();
          read_count++;
          if (tr.read_data !== expected_data) begin
            `uvm_error(get_type_name(), $sformatf("Data integrity error: expected=0x%h, actual=0x%h", expected_data, tr.read_data))
            error_count++;
          end
          `uvm_info(get_type_name(), $sformatf("Read: data=0x%h (correct)", expected_data), UVM_HIGH)
          if (expected_wr_level > 0) begin
            expected_wr_level--;
            expected_rd_level++;
            expected_fifo_read_count++; // Increment on successful read
          end
          expected_wfull = (expected_wr_level == (1 << 5));
          expected_rdempty = (expected_wr_level == 0);
          expected_rdalmost_empty = (expected_wr_level <= tr.aempty_value);
          expected_underflow = (expected_wr_level == 0);
        end else begin
          `uvm_error(get_type_name(), "Read attempted but no data available")
          error_count++;
        end
      end
      
      // Check all status flags and counts for every transaction
      // Check for overflow
      if (tr.overflow != expected_overflow) begin
        `uvm_error(get_type_name(), $sformatf("Overflow mismatch: expected=%b, actual=%b", expected_overflow, tr.overflow))
        error_count++;
      end
      
      // Check for underflow
      if (tr.underflow != expected_underflow) begin
        `uvm_error(get_type_name(), $sformatf("Underflow mismatch: expected=%b, actual=%b", expected_underflow, tr.underflow))
        error_count++;
      end
      
      // Check FIFO state consistency
      if (tr.wfull != expected_wfull) begin
        `uvm_error(get_type_name(), $sformatf("FIFO full state mismatch: expected=%b, actual=%b", expected_wfull, tr.wfull))
        error_count++;
      end
      
      if (tr.rdempty != expected_rdempty) begin
        `uvm_error(get_type_name(), $sformatf("FIFO empty state mismatch: expected=%b, actual=%b", expected_rdempty, tr.rdempty))
        error_count++;
      end
      
      // Check almost full/empty flags
      if (tr.wr_almost_ful != expected_wr_almost_ful) begin
        `uvm_error(get_type_name(), $sformatf("Almost full mismatch: expected=%b, actual=%b", expected_wr_almost_ful, tr.wr_almost_ful))
        error_count++;
      end
      
      if (tr.rd_almost_empty != expected_rdalmost_empty) begin
        `uvm_error(get_type_name(), $sformatf("Almost empty mismatch: expected=%b, actual=%b", expected_rdalmost_empty, tr.rd_almost_empty))
        error_count++;
      end
      
      // Check FIFO counts
      if (tr.fifo_write_count != expected_fifo_write_count) begin
        `uvm_error(get_type_name(), $sformatf("FIFO write count mismatch: expected=%0d, actual=%0d", expected_fifo_write_count, tr.fifo_write_count))
        error_count++;
      end
      
      if (tr.fifo_read_count != expected_fifo_read_count) begin
        `uvm_error(get_type_name(), $sformatf("FIFO read count mismatch: expected=%0d, actual=%0d", expected_fifo_read_count, tr.fifo_read_count))
        error_count++;
      end
      
      // Check FIFO levels
      if (tr.wr_level != expected_wr_level) begin
        `uvm_error(get_type_name(), $sformatf("FIFO write level mismatch: expected=%0d, actual=%0d", expected_wr_level, tr.wr_level))
        error_count++;
      end
      
      if (tr.rd_level != expected_rd_level) begin
        `uvm_error(get_type_name(), $sformatf("FIFO read level mismatch: expected=%0d, actual=%0d", expected_rd_level, tr.rd_level))
        error_count++;
      end
    end
  endtask

  task check_fifo_behavior();
    forever begin
      @(posedge $time);
      if (expected_wfull && expected_rdempty) begin
        `uvm_error(get_type_name(), "Invalid FIFO state: both full and empty")
        error_count++;
      end
      if (expected_wr_level + expected_rd_level != (1 << 5)) begin
        `uvm_error(get_type_name(), $sformatf("FIFO level inconsistency: wr_level=%d, rd_level=%d", expected_wr_level, expected_rd_level))
        error_count++;
      end
    end
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Scoreboard Report:"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("  Write transactions: %d", write_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("  Read transactions: %d", read_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("  Errors detected: %d", error_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("  Remaining data in queue: %d", expected_data_queue.size()), UVM_LOW)
    if (error_count == 0) begin
      `uvm_info(get_type_name(), "Scoreboard: All checks passed!", UVM_LOW)
    end else begin
      `uvm_error(get_type_name(), $sformatf("Scoreboard: %d errors detected", error_count))
    end
  endfunction
endclass 