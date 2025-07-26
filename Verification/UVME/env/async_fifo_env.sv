class async_fifo_env extends uvm_env;
  `uvm_component_utils(async_fifo_env)

  async_fifo_agent      m_fifo_agent;
  async_fifo_coverage   m_fifo_coverage;
  scoreboard            m_scoreboard;

  function new(string name = "async_fifo_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_fifo_agent    = async_fifo_agent::type_id::create("m_fifo_agent", this);
    m_fifo_coverage = async_fifo_coverage::type_id::create("m_fifo_coverage", this);
    m_scoreboard    = scoreboard::type_id::create("m_scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Connect agent analysis port to coverage and scoreboard
    m_fifo_agent.agent_analysis_port.connect(m_fifo_coverage.fifo_analysis_imp);
    m_fifo_agent.agent_analysis_port.connect(m_scoreboard.fifo_export);
  endfunction

endclass 