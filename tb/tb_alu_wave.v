`timescale 1ns/1ps
// Short directed stimulus for waveform viewing only (not the verification testbench).
module tb_alu_wave;
  reg [7:0] A, B; reg [3:0] opcode;
  wire [7:0] Y_rca, Y_cla; wire C_r, Z_r, N_r, V_r, C_c, Z_c, N_c, V_c;
  alu_rca r(.A(A),.B(B),.opcode(opcode),.Y(Y_rca),.Carry(C_r),.Zero(Z_r),.Negative(N_r),.Overflow(V_r));
  alu_cla c(.A(A),.B(B),.opcode(opcode),.Y(Y_cla),.Carry(C_c),.Zero(Z_c),.Negative(N_c),.Overflow(V_c));
  initial begin
    $dumpfile("sim/alu_wave.vcd"); $dumpvars(0, tb_alu_wave);
    A=8'h7F; B=8'h01; opcode=4'h0; #10;   // signed overflow
    A=8'hFF; B=8'h01; opcode=4'h0; #10;   // carry out, zero
    A=8'h00; B=8'h01; opcode=4'h1; #10;   // borrow
    A=8'hF0; B=8'h3C; opcode=4'h2; #10;
    A=8'hF0; B=8'h3C; opcode=4'h3; #10;
    A=8'hF0; B=8'h3C; opcode=4'h4; #10;
    A=8'hF0; B=8'h00; opcode=4'h5; #10;
    A=8'h81; B=8'h00; opcode=4'h6; #10;
    A=8'h81; B=8'h00; opcode=4'h7; #10;
    A=8'h55; B=8'hAA; opcode=4'hA; #10;   // reserved
    $finish;
  end
endmodule
