module oposicao_matriz (
    input signed [199:0] matrix_A,     // Matriz A (25 elementos de 8 bits)
    output wire signed [199:0] m_oposta_A  // Matriz oposta A
);

    genvar i;
    generate
        for (i = 0; i < 25; i = i + 1) begin : inverter_elementos
            assign m_oposta_A[(i << 3) +: 8] = -matrix_A[(i << 3) +: 8];  // Inversão direta com deslocamento
        end
    endgenerate

endmodule
