module qart_watchdog #(parameter integer TIMEOUT_CYCLES=16)(
 input logic clk,input logic rst_n,input logic kick,input logic arm,input logic clear_fault,
 output logic expired,output logic safe_noop
);
 localparam integer W=(TIMEOUT_CYCLES<=1)?1:$clog2(TIMEOUT_CYCLES+1);
 logic [W-1:0] count;
 always_ff @(posedge clk) begin
  if(!rst_n) begin count<='0; expired<=1'b0; end
  else if(clear_fault) begin count<='0; expired<=1'b0; end
  else if(!arm) count<='0;
  else if(kick) count<='0;
  else if(!expired) begin
   if(count>=TIMEOUT_CYCLES-1) begin expired<=1'b1; count<=count; end
   else count<=count+1'b1;
  end
 end
 assign safe_noop = (!rst_n) || expired;
endmodule
