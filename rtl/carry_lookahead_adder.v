// 8-bit carry-lookahead adder: carries computed from generate (G = A&B)
// and propagate (P = A^B) terms using expanded lookahead equations.
module carry_lookahead_adder (
    input  [7:0] A,
    input  [7:0] B,
    input        Cin,
    output [7:0] Sum,
    output       Cout
);

    wire [7:0] P, G;          // Propagate and Generate
    wire [8:0] C;             // C[0] = Cin, C[8] = Cout

    assign C[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : pg
            assign P[i] = A[i] ^ B[i];
            assign G[i] = A[i] & B[i];
        end
    endgenerate

    // Explicit carry-lookahead equations
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    assign C[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0])
                        | (P[3] & P[2] & P[1] & P[0] & C[0]);
    assign C[5] = G[4] | (P[4] & G[3]) | (P[4] & P[3] & G[2]) | (P[4] & P[3] & P[2] & G[1])
                        | (P[4] & P[3] & P[2] & P[1] & G[0]) | (P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);
    assign C[6] = G[5] | (P[5] & G[4]) | (P[5] & P[4] & G[3]) | (P[5] & P[4] & P[3] & G[2])
                        | (P[5] & P[4] & P[3] & P[2] & G[1]) | (P[5] & P[4] & P[3] & P[2] & P[1] & G[0])
                        | (P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);
    assign C[7] = G[6] | (P[6] & G[5]) | (P[6] & P[5] & G[4]) | (P[6] & P[5] & P[4] & G[3])
                        | (P[6] & P[5] & P[4] & P[3] & G[2]) | (P[6] & P[5] & P[4] & P[3] & P[2] & G[1])
                        | (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0])
                        | (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);
    assign C[8] = G[7] | (P[7] & G[6]) | (P[7] & P[6] & G[5]) | (P[7] & P[6] & P[5] & G[4]) | (P[7] & P[6] & P[5] & P[4] & G[3])
                        | (P[7] & P[6] & P[5] & P[4] & P[3] & G[2])
                        | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & G[1])
                        | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0])
                        | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);

    generate
        for (i = 0; i < 8; i = i + 1) begin : sum_bits
            assign Sum[i] = P[i] ^ C[i];
        end
    endgenerate

    assign Cout = C[8];

endmodule
