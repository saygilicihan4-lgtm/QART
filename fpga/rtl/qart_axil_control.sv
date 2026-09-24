module qart_axil_control(
 input  logic        aclk,
 input  logic        aresetn,

 input  logic [5:0]  s_axil_awaddr,
 input  logic        s_axil_awvalid,
 output logic        s_axil_awready,
 input  logic [31:0] s_axil_wdata,
 input  logic [3:0]  s_axil_wstrb,
 input  logic        s_axil_wvalid,
 output logic        s_axil_wready,
 output logic [1:0]  s_axil_bresp,
 output logic        s_axil_bvalid,
 input  logic        s_axil_bready,

 input  logic [5:0]  s_axil_araddr,
 input  logic        s_axil_arvalid,
 output logic        s_axil_arready,
 output logic [31:0] s_axil_rdata,
 output logic [1:0]  s_axil_rresp,
 output logic        s_axil_rvalid,
 input  logic        s_axil_rready,

 output logic        arm,
 output logic        clear_fault,
 output logic        resync,
 output logic [31:0] resync_value,
 input  logic [31:0] status_flags,
 input  logic [31:0] expected_seq
);
 localparam [31:0] ID      = 32'h51415254;
 localparam [31:0] VERSION = 32'h00020000;

 logic aw_hold,w_hold;
 logic [5:0] awaddr_q;
 logic [31:0] wdata_q;
 logic [3:0] wstrb_q;
 integer i;

 assign s_axil_awready = !aw_hold && !s_axil_bvalid;
 assign s_axil_wready  = !w_hold  && !s_axil_bvalid;
 assign s_axil_arready = !s_axil_rvalid;

 always_ff @(posedge aclk) begin
  if(!aresetn) begin
   aw_hold<=1'b0; w_hold<=1'b0;
   awaddr_q<=6'd0; wdata_q<=32'd0; wstrb_q<=4'd0;
   s_axil_bvalid<=1'b0; s_axil_bresp<=2'b00;
   s_axil_rvalid<=1'b0; s_axil_rdata<=32'd0; s_axil_rresp<=2'b00;
   arm<=1'b0; clear_fault<=1'b0; resync<=1'b0; resync_value<=32'd0;
  end else begin
   clear_fault<=1'b0;
   resync<=1'b0;

   if(s_axil_awvalid && s_axil_awready) begin
    aw_hold<=1'b1;
    awaddr_q<=s_axil_awaddr;
   end
   if(s_axil_wvalid && s_axil_wready) begin
    w_hold<=1'b1;
    wdata_q<=s_axil_wdata;
    wstrb_q<=s_axil_wstrb;
   end

   if(aw_hold && w_hold && !s_axil_bvalid) begin
    s_axil_bresp<=2'b00;
    case(awaddr_q)
     6'h08: begin
      if(wstrb_q[0]) begin
       arm<=wdata_q[0];
       clear_fault<=wdata_q[1];
       resync<=wdata_q[2];
      end
     end
     6'h14: begin
      for(i=0;i<4;i=i+1)
       if(wstrb_q[i]) resync_value[i*8 +: 8] <= wdata_q[i*8 +: 8];
     end
     default: s_axil_bresp<=2'b10;
    endcase
    aw_hold<=1'b0;
    w_hold<=1'b0;
    s_axil_bvalid<=1'b1;
   end else if(s_axil_bvalid && s_axil_bready) begin
    s_axil_bvalid<=1'b0;
   end

   if(s_axil_arvalid && s_axil_arready) begin
    s_axil_rresp<=2'b00;
    case(s_axil_araddr)
     6'h00: s_axil_rdata<=ID;
     6'h04: s_axil_rdata<=VERSION;
     6'h08: s_axil_rdata<={31'd0,arm};
     6'h0c: s_axil_rdata<=status_flags;
     6'h10: s_axil_rdata<=expected_seq;
     6'h14: s_axil_rdata<=resync_value;
     default: begin s_axil_rdata<=32'd0; s_axil_rresp<=2'b10; end
    endcase
    s_axil_rvalid<=1'b1;
   end else if(s_axil_rvalid && s_axil_rready) begin
    s_axil_rvalid<=1'b0;
   end
  end
 end
endmodule
