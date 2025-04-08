# RELATÓRIO - COPROCESSADOR PARA OPERAÇÕES MATRICIAIS EM FPGA

## Sumário

- [Introdução](#introdução)
- [Requisitos do problema](#requisitos-do-problema)
- [Recursos Utilizados](#recursos-utilizados)
  - [Quartus Prime](#quartus-prime)
  - [FPGA DE1-SoC](#fpga-de1-soc)
  - [Icarus Verilog](#icarus-verilog)
- [Desenvolvimento e Arquitetura do Sistema](#desenvolvimento-e-arquitetura-do-sistema)
  - [Unidade de Controle de Operações Matriciais](#unidade-de-controle-de-operações-matriciais)
  - [Bloco de Memória](#bloco-de-memória)
  - [ULA (Unidade Lógica e Aritmética)](#ula-unidade-lógica-e-aritmética)
- [Referências](#referências)

## Introdução
O processamento de matrizes constitui um componente essencial em uma ampla gama de aplicações computacionais, como sistemas embarcados, algoritmos de aprendizado de máquina, visão computacional, computação gráfica, simulações numéricas e controle de sistemas dinâmicos. A manipulação eficiente de estruturas matriciais exige arquiteturas capazes de realizar operações aritméticas com paralelismo e desempenho adequados.

Neste projeto, desenvolve-se um co-processador aritmético especializado em operações matriciais, implementado em linguagem de descrição de hardware Verilog HDL. O sistema é capaz de executar, de forma autônoma, operações como adição, subtração, multiplicação e cálculo de determinantes de matrizes 2x2 e 3x3, a partir de instruções armazenadas em uma memória de programa.

## Requisitos do problema

1. Descrição do hardware com a linguagem **Verilog**.
2. Utilizar os componentes disponíveis da **FPGA DE1-SoC**.
3. Realizar as seguintes operações matriciais:
   - Adição de matrizes
   - Subtração de matrizes
   - Multiplicação de matrizes
   - Multiplicação de matriz por um número inteiro
   - Determinante
   - Transposição de matrizes
   - Cálculo da matriz oposta
4. Cada elemento é representado por um número inteiro de 8 bits.
5. O coprocessador deve implementar paralelismo para otimizar a execução.

## Recursos Utilizados

### Quartus Prime
O **Quartus Prime** foi utilizado como principal ambiente de desenvolvimento para síntese, compilação e implementação do projeto em Verilog HDL. As principais funções desempenhadas pelo software no projeto foram:

- **Síntese e Análise de Recursos:** Realiza a tradução da descrição em Verilog para circuitos lógicos, permitindo avaliar a utilização de **LUTs**, **DSPs**, dentre outros recursos da FPGA.
- **Compilação e Geração de Bitstream:** Compila o projeto completo e gera o arquivo de configuração necessário para programar a FPGA.
- **Gravação na FPGA:** A gravação do projeto na placa **DE1-SoC** foi feita através da ferramenta Programmer, utilizando o cabo **USB-Blaster**.
- **Pinagem com Pin Planner:** Ferramenta utilizada para mapear os sinais de entrada e saída do projeto aos pinos físicos da FPGA, como **LEDs**, **chaves** (**switches**), **botões** (**keys**) e **displays** disponíveis na placa.

### FPGA DE1-SoC
A **DE1-SoC** é a plataforma utilizada para a implementação e testes do coprocessador. Ela combina um FPGA da Intel com diversos periféricos integrados, facilitando o desenvolvimento de sistemas embarcados e aplicações em hardware reconfigurável.

- **Dispositivo FPGA:** Cyclone® V SE 5CSEMA5F31C6N.
- **Memória embarcada:** 4.450 Kbits e 6 blocos DSP de 18x18 bits.
- **Entradas e saídas utilizadas no projeto:** 4 botões de pressão, 10 chaves deslizantes e 10 LEDs vermelhos de usuário.

Para mais informações técnicas, acesse o [Manual da Placa DE1-SoC (PDF)](https://drive.google.com/file/d/1dBaSfXi4GcrSZ0JlzRh5iixaWmq0go2j/view).

### Icarus Verilog
O Icarus Verilog foi utilizado como ferramenta de simulação funcional durante o desenvolvimento do projeto. Trata-se de um compilador open-source para a linguagem Verilog, amplamente utilizado para validar o comportamento de circuitos antes da síntese em hardware.

**Funções no projeto:**
- **Simulação dos módulos individuais:** Permitiu verificar o funcionamento correto de blocos como a ULA, adição, subtração, multiplicação por escalar e determinante antes da integração no sistema completo.
- **Depuração de lógica:** Facilitou a identificação de erros lógicos e falhas de sincronismo, permitindo testes com diferentes valores de entrada e análise dos sinais de saída.
- **Validação sem hardware:** Proporcionou uma forma rápida de testar o comportamento do coprocessador sem a necessidade imediata de programar a FPGA, acelerando o ciclo de desenvolvimento.

## Desenvolvimento e Arquitetura do Sistema

## Unidade de Controle de Operações Matriciais
*Descrever o funcionamento do módulo `coprocessador`*

## Bloco de Memória
*Descrever o funcionamento do bloco de memória `memory_block`*

## ULA (Unidade Lógica e Aritmética)

### Conceito
A Unidade Lógica e Aritmética (ULA) é um bloco funcional responsável pela execução de operações aritméticas e lógicas definidas por um código de operação (opcode). Neste projeto, a ULA foi adaptada para processar dados matriciais, operando com elementos inteiros de 8 bits. Ela atua como um circuito combinacional (com apoio sequencial para certas operações), roteando os operandos para módulos especializados conforme o opcode, e retornando o resultado correspondente.

### Estrutura

#### Módulo Principal `alu.v`
- Responsável por gerenciar todas as operações
- Seleciona as operações com base no **opcode**

|**opcode**|**Operação**|**Descrição**             |
|----------|------------|--------------------------|
|`000`     | A + B      | Soma                     |
|`001`     | A - B      | Subtração                |
|`010`     | Aᵀ         | Tranposição              |
|`011`     | -A         | Oposição                 |
|`100`     | k·A        | Mutiplicação por escalar |
|`101`     | det(A)     | Determinante da matriz   |
|`110`     | A × B      | Multiplicação de matrizes|    

## Referências
*Colocar as referências utilizadas como o manual da placa, um livro de Sistemas Digitais e um livro que ensine as operações com determinante.*
