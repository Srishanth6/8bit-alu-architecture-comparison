// 8-bit ripple-carry adder: eight full_adder stages chained carry-to-carry.
module ripple_carry_adder (
    input  [7:0] A,
    input  [7:0] B,
    input        Cin,
    output [7:0] Sum,
    output       Cout
);

    wire [7:0] carry;

    full_adder fa0 (.A(A[0]), .B(B[0]), .Cin(Cin),      .Sum(Sum[0]), .Cout(carry[0]));
    full_adder fa1 (.A(A[1]), .B(B[1]), .Cin(carry[0]), .Sum(Sum[1]), .Cout(carry[1]));
    full_adder fa2 (.A(A[2]), .B(B[2]), .Cin(carry[1]), .Sum(Sum[2]), .Cout(carry[2]));
    full_adder fa3 (.A(A[3]), .B(B[3]), .Cin(carry[2]), .Sum(Sum[3]), .Cout(carry[3]));
    full_adder fa4 (.A(A[4]), .B(B[4]), .Cin(carry[3]), .Sum(Sum[4]), .Cout(carry[4]));
    full_adder fa5 (.A(A[5]), .B(B[5]), .Cin(carry[4]), .Sum(Sum[5]), .Cout(carry[5]));
    full_adder fa6 (.A(A[6]), .B(B[6]), .Cin(carry[5]), .Sum(Sum[6]), .Cout(carry[6]));
    full_adder fa7 (.A(A[7]), .B(B[7]), .Cin(carry[6]), .Sum(Sum[7]), .Cout(carry[7]));

    assign Cout = carry[7];

endmodule
