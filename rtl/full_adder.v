// 1-bit full adder: Sum = A ^ B ^ Cin, Cout = majority(A, B, Cin).
module full_adder (
    input  A,
    input  B,
    input  Cin,
    output Sum,
    output Cout
);

    assign Sum  = A ^ B ^ Cin;
    assign Cout = (A & B) | (A & Cin) | (B & Cin);

endmodule
