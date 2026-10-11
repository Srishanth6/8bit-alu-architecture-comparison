module alu_cla (
    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] opcode,
    output reg [7:0] Y,
    output reg       Carry,
    output reg       Zero,
    output reg       Negative,
    output reg       Overflow
);

    wire [7:0] add_sum, sub_sum;
    wire       add_cout, sub_cout;
    wire [7:0] B_inv = ~B;

    carry_lookahead_adder add_unit (
        .A(A), .B(B), .Cin(1'b0),
        .Sum(add_sum), .Cout(add_cout)
    );

    carry_lookahead_adder sub_unit (
        .A(A), .B(B_inv), .Cin(1'b1),
        .Sum(sub_sum), .Cout(sub_cout)
    );

    always @(*) begin
        // Default values for reserved opcodes and non-arithmetic ops
        Y        = 8'h00;
        Carry    = 1'b0;
        Zero     = 1'b0;
        Negative = 1'b0;
        Overflow = 1'b0;

        case (opcode)
            4'b0000: begin  // ADD
                Y        = add_sum;
                Carry    = add_cout;
                Zero     = (add_sum == 8'h00);
                Negative = add_sum[7];
                Overflow = (A[7] == B[7]) && (add_sum[7] != A[7]);
            end
            4'b0001: begin  // SUB (A - B)
                Y        = sub_sum;
                Carry    = ~sub_cout;           // Borrow = ~Cout of two's complement add
                Zero     = (sub_sum == 8'h00);
                Negative = sub_sum[7];
                Overflow = (A[7] != B[7]) && (sub_sum[7] != A[7]);
            end
            4'b0010: begin  // AND
                Y = A & B;
                Zero = (Y == 8'h00);
                Negative = Y[7];
            end
            4'b0011: begin  // OR
                Y = A | B;
                Zero = (Y == 8'h00);
                Negative = Y[7];
            end
            4'b0100: begin  // XOR
                Y = A ^ B;
                Zero = (Y == 8'h00);
                Negative = Y[7];
            end
            4'b0101: begin  // NOT A
                Y = ~A;
                Zero = (Y == 8'h00);
                Negative = Y[7];
            end
            4'b0110: begin  // Logical left shift
                Y = A << 1;
                Carry = A[7];
                Zero = (Y == 8'h00);
                Negative = Y[7];
            end
            4'b0111: begin  // Logical right shift
                Y = A >> 1;
                Carry = A[0];
                Zero = (Y == 8'h00);
                Negative = Y[7];
            end
            default: begin
                Y = 8'h00;
                Zero = 1'b1;
            end
        endcase
    end

endmodule
