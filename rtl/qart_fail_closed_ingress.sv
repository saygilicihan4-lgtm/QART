module qart_fail_closed_ingress #(parameter integer WATCHDOG_CYCLES=16)(
 input logic clk,input logic rst_n,input logic arm,input logic clear_fault,input logic resync,
 input logic [31:0] resync_value,input logic frame_valid,input logic protocol_ok,input logic crc_ok,
 input logic [31:0] magic,input logic [7:0] version,input logic [7:0] kind,input logic [31:0] seq,
 input logic [15:0] channel,input logic [15:0] action,input logic [15:0] amplitude,input logic [15:0] duration,
 output logic permit,output logic fault,output logic safe_noop,output logic [31:0] expected_seq
);
 logic seq_ok,gate_permit,gate_fault,wd_expired,wd_noop,accept;
 qart_sequence_guard sg(.clk(clk),.rst_n(rst_n),.accept(accept),.resync(resync),.seq(seq),.resync_value(resync_value),.expected_seq(expected_seq),.seq_ok(seq_ok));
 qart_frame_guard fg(.protocol_ok(protocol_ok),.crc_ok(crc_ok),.magic(magic),.version(version),.kind(kind),.seq(seq),.expected_seq(expected_seq),.channel(channel),.action(action),.amplitude(amplitude),.duration(duration),.permit(gate_permit),.fault(gate_fault));
 assign accept=frame_valid && gate_permit && seq_ok && !wd_noop;
 qart_watchdog #(.TIMEOUT_CYCLES(WATCHDOG_CYCLES)) wd(.clk(clk),.rst_n(rst_n),.kick(accept),.arm(arm),.clear_fault(clear_fault),.expired(wd_expired),.safe_noop(wd_noop));
 assign permit=accept;
 assign fault=(frame_valid && (gate_fault || !seq_ok)) || wd_expired;
 assign safe_noop=wd_noop || fault || !permit;
endmodule
