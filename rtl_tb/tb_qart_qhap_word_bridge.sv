module tb_qart_qhap_word_bridge;
 logic clk=0,rst_n=0;
 logic host_valid=0,host_ready,host_last=0;
 logic[31:0]host_data=0,m_axis_tdata;
 logic[3:0]host_keep=4'hf,m_axis_tkeep;
 logic m_axis_tvalid,m_axis_tready=0,m_axis_tlast,overflow_fault;

 always #1 clk=~clk;

 qart_qhap_word_bridge dut(
  .clk(clk),.rst_n(rst_n),
  .host_valid(host_valid),.host_ready(host_ready),.host_data(host_data),.host_keep(host_keep),.host_last(host_last),
  .m_axis_tdata(m_axis_tdata),.m_axis_tkeep(m_axis_tkeep),.m_axis_tvalid(m_axis_tvalid),
  .m_axis_tready(m_axis_tready),.m_axis_tlast(m_axis_tlast),.overflow_fault(overflow_fault)
 );

 initial begin
  repeat(2)@(posedge clk); rst_n=1;

  // Accept and hold one word while downstream is stalled.
  @(negedge clk);host_data=32'h11223344;host_last=0;host_valid=1;
  @(negedge clk);host_valid=0;
  repeat(2)@(posedge clk);
  if(!m_axis_tvalid || m_axis_tdata!==32'h11223344)$fatal(1,"bridge did not retain stalled word");
  if(overflow_fault)$fatal(1,"unexpected overflow");

  // Producer violates backpressure: overflow must become sticky.
  @(negedge clk);host_data=32'hdeadbeef;host_valid=1;
  @(negedge clk);host_valid=0;
  @(posedge clk);
  if(!overflow_fault)$fatal(1,"backpressure violation did not latch overflow fault");
  if(m_axis_tdata!==32'h11223344)$fatal(1,"overflow corrupted retained word");

  // Consume retained word.
  @(negedge clk);m_axis_tready=1;
  @(posedge clk);@(negedge clk);
  if(m_axis_tvalid)$fatal(1,"bridge did not drain");

  $display("QART_QHAP_WORD_BRIDGE_PASS");
  $finish;
 end
endmodule
