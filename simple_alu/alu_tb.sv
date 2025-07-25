// alu_tb.v - ALU Testbench
`timescale 1ns/1ps

module alu_tb;

    logic [31:0] a, b;
    logic [3:0]  alu_op;
    logic [31:0] result;

    alu dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result)
    );

    task run_test(input [3:0] op, input [31:0] op_a, input [31:0] op_b);
        begin
            alu_op = op;
            a = op_a;
            b = op_b;
            #1;
            $display("OP=%b A=%h B=%h RESULT=%h", alu_op, a, b, result);
        end
    endtask

    initial begin
        $display("Starting ALU tests...");
        run_test(4'b0000, 32'd10, 32'd5);   // ADD
        run_test(4'b0001, 32'd10, 32'd5);   // SUB
        run_test(4'b0010, 32'hFF00FF00, 32'h0F0F0F0F); // AND
        run_test(4'b0011, 32'hFF00FF00, 32'h0F0F0F0F); // OR
        run_test(4'b0100, 32'hFF00FF00, 32'h0F0F0F0F); // XOR
        run_test(4'b0101, 32'd1, 32'd3);    // SLL
        run_test(4'b0110, 32'd16, 32'd2);   // SRL
        run_test(4'b0111, -32'd16, 32'd2);  // SRA
        run_test(4'b1000, 32'd1, 32'd2);    // SLTU
        run_test(4'b1001, -32'd1, 32'd1);   // SLT
        $display("Done.");
        $finish;
    end

endmodule
