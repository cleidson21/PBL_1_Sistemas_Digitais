# COPROCESSADOR PARA OPERAÇÕES MATRICIAIS

## Sumário
*Fazer o sumário aqui*

## Introdução
*Fazer a introdução aqui*

## Requisitos do problema

1. Descrição do hardware com a linguagem **Verilog**.
2. Utilizar os componentes disponíveis da **FPGA DE1-SoC**.
3. Realizar as seguintes operações matriciais:
   - Adição de matrizes;
   - Subtração de matrizes;
   - Multiplicação de matrizes;
   - Multiplicação de matriz por um número inteiro;
   - Determinante;
   - Transposição de matrizes;
   - Cálculo da matriz oposta;
4. Cada elemento é representado por um número inteiro de 8 bits.
5. O coprocessador deve implementar paralelismo para otimizar a execução.

## Recursos Utilizados

### Quartus Prime
*Descrever quais foram as funções do Quartus no projeto*

### FPGA DE1-SoC
*Descrever como a placa foi utilizada no projeto e características como quantidade de chaves, LEDS e portas USB*

### Icarus Verilog
*Fazer uma breve descrição do software e dizer qual foi a utilidade dele no projeto*

## Desenvolvimento
Essa seção irá explicar o funcionamento das diferentes partes do projeto (Coprocessador, ULA, bloco de memória, etc.)

### Coprocessador
### Módulo de Memória
### ULA (Unidade Lógica e Aritmética)
A unidade lógica e aritmética é um circuito combinacional responsável por selecionar qual operação deverá ser realizada pelo coprocessador. Cada operação possui um **opcode** para sua seleção pela ULA.

|**opcode**|**Operação**|**Descrição**             |
|----------|------------|--------------------------|
|`000`     | A + B      | Soma                     |
|`001`     | A - B      | Subtração                |
|`010`     | Aᵀ         | Tranposição              |
|`011`     | -A         | Oposição                 |
|`100`     | k*A        | Mutiplicação por escalar |
|`101`     | det(A)     | Determinante da matriz   |
|`110`     | A*B        | Multiplicação de matrizes|    

## Referências
*Colocar as referências utilizadas como o manual da placa, um livro de Sistemas Digitais e um livro que ensine as operações com determinante.*
