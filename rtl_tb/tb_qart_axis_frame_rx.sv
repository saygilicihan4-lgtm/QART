module tb_qart_axis_frame_rx;
 logic clk=0,aresetn=0; always #1 clk=~clk;
 logic [31:0] s_axis_tdata;logic [3:0] s_axis_tkeep;logic s_axis_tvalid,s_axis_tready,s_axis_tlast;
 logic frame_valid,frame_fault;logic [31:0] magic,seq,crc_received,payload0,payload1;
 logic [7:0] version,kind;logic [15:0] flags,channel,action,amplitude,duration;
 qart_axis_frame_rx dut(.aclk(clk),.*);
 task beat(input [31:0] d,input bit last);
  @(negedge clk);s_axis_tdata=d;s_axis_tvalid=1;s_axis_tkeep=4'hf;s_axis_tlast=last;
  @(negedge clk);s_axis_tvalid=0;s_axis_tlast=0;
 endtask
 initial begin
  s_axis_tvalid=0;s_axis_tlast=0;s_axis_tkeep=4'hf;s_axis_tdata=0;
  repeat(2) @(negedge clk);aresetn=1;
  beat(32'h51484150,0); beat(32'h00000102,0); beat(32'd7,0);
  beat({16'd1,16'd3},0); beat({16'd100,16'h4000},0);
  beat(32'h11223344,0);beat(32'h55667788,0);beat(32'hdeadbeef,1);
  // frame_valid is a one-cycle pulse asserted on the final accepted beat.
  if(!frame_valid||frame_fault||magic!=32'h51484150||version!=2||kind!=1||seq!=7||
     channel!=3||action!=1||amplitude!=16'h4000||duration!=100||
     payload0!=32'h11223344||payload1!=32'h55667788||crc_received!=32'hdeadbeef) $fatal(1,"frame decode mismatch");
  beat(32'h51484150,1);
  // frame_fault, like frame_valid, is a one-cycle pulse sampled at the accepted beat.
  if(!frame_fault) $fatal(1,"early TLAST not rejected");
  $display("QART_AXIS_RX_TEST_PASS");$finish;
 end
endmodule
