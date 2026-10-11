`timescale 1ns/1ps

module tb_alu_comparison;

    reg  [7:0] A, B;
    reg  [3:0] opcode;

    wire [7:0] Y_rca, Y_cla;
    wire Carry_rca, Zero_rca, Neg_rca, Ovf_rca;
    wire Carry_cla, Zero_cla, Neg_cla, Ovf_cla;

    reg  [7:0] Y_ref;
    reg Carry_ref, Zero_ref, Neg_ref, Ovf_ref;

    integer errors;
    integer tests;
    integer i;
    integer seed;

    // Ripple-carry ALU
    alu_rca dut_rca (
        .A(A),
        .B(B),
        .opcode(opcode),
        .Y(Y_rca),
        .Carry(Carry_rca),
        .Zero(Zero_rca),
        .Negative(Neg_rca),
        .Overflow(Ovf_rca)
    );

    // Carry-lookahead ALU
    alu_cla dut_cla (
        .A(A),
        .B(B),
        .opcode(opcode),
        .Y(Y_cla),
        .Carry(Carry_cla),
        .Zero(Zero_cla),
        .Negative(Neg_cla),
        .Overflow(Ovf_cla)
    );

    // Independent behavioral reference model
    task reference_model;
        input [7:0] a;
        input [7:0] b;
        input [3:0] op;

        reg [8:0] temp;
        begin
            Y_ref     = 8'h00;
            Carry_ref = 1'b0;
            Ovf_ref   = 1'b0;

            case (op)
                4'b0000: begin
                    // Addition
                    temp = {1'b0, a} + {1'b0, b};
                    Y_ref = temp[7:0];
                    Carry_ref = temp[8];
                    Ovf_ref = (a[7] == b[7]) &&
                              (Y_ref[7] != a[7]);
                end

                4'b0001: begin
                    // Subtraction: Carry represents unsigned borrow
                    temp = {1'b0, a} - {1'b0, b};
                    Y_ref = temp[7:0];
                    Carry_ref = (a < b);
                    Ovf_ref = (a[7] != b[7]) &&
                              (Y_ref[7] != a[7]);
                end

                4'b0010: Y_ref = a & b;
                4'b0011: Y_ref = a | b;
                4'b0100: Y_ref = a ^ b;
                4'b0101: Y_ref = ~a;

                4'b0110: begin
                    Y_ref = {a[6:0], 1'b0};
                    Carry_ref = a[7];
                end

                4'b0111: begin
                    Y_ref = {1'b0, a[7:1]};
                    Carry_ref = a[0];
                end

                default: begin
                    Y_ref = 8'h00;
                    Carry_ref = 1'b0;
                    Ovf_ref = 1'b0;
                end
            endcase

            Zero_ref = (Y_ref == 8'h00);
            Neg_ref  = Y_ref[7];
        end
    endtask

    // Compare both implementations with the reference
    task check;
        begin
            tests = tests + 1;
            #1;

            if ((Y_rca !== Y_ref) ||
                (Carry_rca !== Carry_ref) ||
                (Zero_rca !== Zero_ref) ||
                (Neg_rca !== Neg_ref) ||
                (Ovf_rca !== Ovf_ref) ||
                (Y_cla !== Y_ref) ||
                (Carry_cla !== Carry_ref) ||
                (Zero_cla !== Zero_ref) ||
                (Neg_cla !== Neg_ref) ||
                (Ovf_cla !== Ovf_ref) ||
                (Y_rca !== Y_cla) ||
                (Carry_rca !== Carry_cla) ||
                (Zero_rca !== Zero_cla) ||
                (Neg_rca !== Neg_cla) ||
                (Ovf_rca !== Ovf_cla)) begin

                $display("FAIL: A=%h B=%h opcode=%b", A, B, opcode);
                $display("REF: Y=%h C=%b Z=%b N=%b V=%b",
                         Y_ref, Carry_ref, Zero_ref, Neg_ref, Ovf_ref);
                $display("RCA: Y=%h C=%b Z=%b N=%b V=%b",
                         Y_rca, Carry_rca, Zero_rca, Neg_rca, Ovf_rca);
                $display("CLA: Y=%h C=%b Z=%b N=%b V=%b",
                         Y_cla, Carry_cla, Zero_cla, Neg_cla, Ovf_cla);
                errors = errors + 1;
            end
        end
    endtask

    // Apply inputs and calculate expected results
    task run_case;
        input [7:0] a;
        input [7:0] b;
        input [3:0] op;
        begin
            A = a;
            B = b;
            opcode = op;
            reference_model(a, b, op);
            check;
        end
    endtask

    initial begin
        errors = 0;
        tests  = 0;
        seed   = 42;

        A = 0;
        B = 0;
        opcode = 0;

        $display("========================================");
        $display("8-bit ALU: RCA vs CLA Verification");
        $display("Random seed: %0d", seed);
        $display("========================================");

        // 32 tests: all opcodes with two input patterns
        for (i = 0; i < 16; i = i + 1)
            run_case(8'h00, 8'h00, i);

        for (i = 0; i < 16; i = i + 1)
            run_case(8'hFF, 8'h01, i);

        // 12 directed arithmetic and shift corner cases
        run_case(8'h7F, 8'h01, 4'b0000);
        run_case(8'h80, 8'h80, 4'b0000);
        run_case(8'h00, 8'h01, 4'b0001);
        run_case(8'h80, 8'h01, 4'b0001);
        run_case(8'hFF, 8'hFF, 4'b0000);
        run_case(8'h00, 8'h00, 4'b0001);
        run_case(8'hFF, 8'h01, 4'b0000);
        run_case(8'h80, 8'h80, 4'b0000);
        run_case(8'h80, 8'h00, 4'b0110);
        run_case(8'h01, 8'h00, 4'b0111);
        run_case(8'h00, 8'h00, 4'b0110);
        run_case(8'hFF, 8'h00, 4'b0111);

        // 494 reproducible randomized tests
        for (i = 0; i < 494; i = i + 1) begin
            run_case(
                $random(seed),
                $random(seed),
                ($random(seed) & 4'hF)
            );
        end

        $display("----------------------------------------");
        $display("Tests run: %0d", tests);
        $display("Failures:  %0d", errors);

        if (errors == 0 && tests == 538) begin
            $display("ALL TESTS PASSED");
            $finish(0);
        end
        else begin
            $display("TESTBENCH FAILED");
            $finish(1);
        end
    end
endmodule
