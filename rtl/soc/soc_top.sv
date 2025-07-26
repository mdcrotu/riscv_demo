// soc_top.v - Simple SoC wrapper with ALU instantiation
module soc_top (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alu_op,
    output logic [31:0] result
);

    // ALU instance
    alu u_alu (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result)
    );

endmodule
