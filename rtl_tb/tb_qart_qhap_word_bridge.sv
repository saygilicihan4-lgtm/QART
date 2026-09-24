module tb_qart_qhap_word_bridge;
 logic clk=0,rst_n=0,clear_fault=0,host_valid=0,host_ready,host_last=0;
 logic[31:0]host_data=0,m_axis_tdata;logic[3:0]host_keep=4'hf,m_axis_tkeep;
 logic m_axis_tvalid,m_axis_tready=0,m_axis_tlast,overflow_fault;
 always #1 clk=~clk;
 qart_qhap_word_bridge dut(.*);

 task reset_bridge; begin rst_n=0;host_valid=0;m_axis_tready=0;clear_fault=0;repeat(2)@(posedge clk);rst_n=1;@(posedge clk);end endtask
 initial begin
  reset_bridge();
  // Fill elastic buffer.
  @(negedge clk);host_data=32'h11112222;host_valid=1;
  @(negedge clk);host_valid=0;repeat(2)@(posedge clk);
  if(!m_axis_tvalid)$fatal(1,"buffer not full");

  // Stable TVALID under backpressure is legal AXI behavior.
  @(negedge clk);host_data=32'haabbccdd;host_keep=4'hf;host_last=1;host_valid=1;
  repeat(4)@(posedge clk);
  if(overflow_fault)$fatal(1,"legal stable backpressure faulted");
  @(negedge clk);m_axis_tready=1;
  @(posedge clk);@(negedge clk);host_valid=0;
  if(overflow_fault)$fatal(1,"stable stalled transfer faulted");

  // Mutation while stalled is a source protocol violation.
  reset_bridge();
  @(negedge clk);host_data=32'h1;host_last=0;host_valid=1;
  @(negedge clk);host_valid=0;repeat(2)@(posedge clk);
  @(negedge clk);host_data=32'h2;host_valid=1;
  @(posedge clk);@(negedge clk);host_data=32'h3;
  @(posedge clk);#1;if(!overflow_fault)$fatal(1,"stalled payload mutation not faulted");

  // Stop the violating transaction, then explicit operator clear recovers.
  // Clearing while the source is still violating must not mask the violation.
  @(negedge clk);host_valid=0;
  @(posedge clk);
  @(negedge clk);clear_fault=1;@(posedge clk);@(negedge clk);clear_fault=0;
  @(posedge clk);#1;if(overflow_fault)$fatal(1,"clear failed after violation ceased");

  // TVALID withdrawal before handshake is a violation.
  reset_bridge();
  @(negedge clk);host_data=32'h10;host_valid=1;
  @(negedge clk);host_valid=0;repeat(2)@(posedge clk);
  @(negedge clk);host_data=32'h20;host_valid=1;
  @(posedge clk);@(negedge clk);host_valid=0;
  @(posedge clk);#1;if(!overflow_fault)$fatal(1,"TVALID withdrawal not faulted");

  // Simultaneous clear plus a continuing violation must remain faulted.
  @(negedge clk);clear_fault=1;
  @(posedge clk);#1;if(!overflow_fault)$fatal(1,"violation did not win over clear");
  $display("QART_QHAP_WORD_BRIDGE_PASS");$finish;
 end
endmodule
