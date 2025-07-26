// top_tb.sv - Testbench top that instantiates SoC
`timescale 1ns/1ps

module top_tb;

    // Clock and reset
    logic clk;
    logic rst_n;

    // ALU inputs
    logic [31:0] a;
    logic [31:0] b;
    logic [3:0]  alu_op;
    logic [31:0] result;

    // DUT instantiation
    soc_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Stimulus for now (we'll replace this with UVM later)
    initial begin
        $display("Running SoC ALU test...");

        clk   = 0;
        rst_n = 0;
        #20;
        rst_n = 1;

        a = 32'd10; b = 32'd3; alu_op = 4'b0000; #10; // ADD
        a = 32'd15; b = 32'd5; alu_op = 4'b0001; #10; // SUB
        a = 32'd2;  b = 32'd3; alu_op = 4'b0101; #10; // SLL

        $display("Result: %h", result);
        #20;
        $finish;
    end

endmodule
