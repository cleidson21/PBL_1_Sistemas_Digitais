# Coprocessador para Operações Matriciais em FPGA

## Sumário

- [Introdução](#introdução)
- [Requisitos do Problema](#requisitos-do-problema)
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

O processamento de matrizes é um componente essencial em diversas áreas da computação, como sistemas embarcados, aprendizado de máquina, visão computacional, computação gráfica, simulações numéricas e controle de sistemas dinâmicos. Para realizar essas operações de forma eficiente, é necessário o uso de arquiteturas especializadas que implementem operações aritméticas com alto desempenho e paralelismo.

Neste projeto, desenvolvemos um **co-processador aritmético** dedicado a operações matriciais, implementado em Verilog HDL. O sistema é capaz de executar operações como adição, subtração, multiplicação, transposição, cálculo de determinantes e oposição de matrizes de dimensões entre 2x2 e 5x5. A execução dessas operações é controlada por instruções armazenadas em uma memória de programa.

## 👥 Equipe

- **Cleidson Ramos de Carvalho**
- **Pedro Arthur**
- **Uemerson **

## Requisitos do Problema

1. Descrição do hardware utilizando a linguagem **Verilog**.
2. Utilização dos recursos da **FPGA DE1-SoC** para a implementação.
3. Implementação das seguintes operações matriciais:
   - Adição de Matrizes
   - Subtração de Matrizes
   - Multiplicação de Matrizes
   - Multiplicação de Matrizes por um Escalar
   - Cálculo de Determinante
   - Transposição de Matrizes
   - Cálculo da Matriz Oposta
4. Representação dos elementos das matrizes como números inteiros de **8 bits**.
5. O coprocessador deve implementar paralelismo para otimizar a execução das operações.

## Recursos Utilizados

### Quartus Prime

O **Quartus Prime** foi a principal ferramenta de desenvolvimento utilizada para síntese, compilação e implementação do projeto em Verilog HDL. As funções desempenhadas pelo software incluem:

- **Síntese e Análise de Recursos**: Tradução do código Verilog para circuitos lógicos, permitindo a avaliação de recursos da FPGA, como **LUTs** e **DSPs**.
- **Compilação e Geração de Bitstream**: Compilação do projeto e geração do arquivo necessário para programar a FPGA.
- **Gravação na FPGA**: Programação da FPGA utilizando a ferramenta **Programmer** e o cabo **USB-Blaster**.
- **Pinagem com Pin Planner**: Ferramenta para mapear sinais de entrada e saída do projeto aos pinos físicos da FPGA, como **LEDs**, **switches**, **botões** e **displays**.

### FPGA DE1-SoC

A **FPGA DE1-SoC** foi a plataforma utilizada para a implementação e testes do coprocessador. Essa placa combina um FPGA da Intel com diversos periféricos integrados, oferecendo uma solução robusta para sistemas embarcados e aplicações de hardware reconfigurável.

- **Dispositivo FPGA**: Cyclone® V SE 5CSEMA5F31C6N.
- **Memória Embarcada**: 4.450 Kbits e 6 blocos DSP de 18x18 bits.
- **Entradas e Saídas**: Utilização de 4 botões de pressão, 10 chaves deslizantes e 10 LEDs vermelhos de usuário.

Para mais informações técnicas, consulte o [Manual da Placa DE1-SoC (PDF)](https://drive.google.com/file/d/1dBaSfXi4GcrSZ0JlzRh5iixaWmq0go2j/view).

### Icarus Verilog

O **Icarus Verilog** foi utilizado para simulação funcional durante o desenvolvimento. Esta ferramenta open-source para a linguagem Verilog permitiu validar o comportamento do sistema antes da síntese em hardware.

**Principais funções no projeto:**

- **Simulação de Módulos Individuais**: Verificação do funcionamento correto de blocos como a ULA, adição, subtração, multiplicação por escalar e determinante antes da integração completa do sistema.
- **Depuração de Lógica**: Identificação de erros lógicos e problemas de sincronismo, facilitando a análise dos sinais de saída e testes com diferentes entradas.
- **Validação Sem Hardware**: Permitiu testar o comportamento do coprocessador sem a necessidade de programar a FPGA, acelerando o ciclo de desenvolvimento.

## Desenvolvimento e Arquitetura do Sistema

### 🧠 Coprocessor

O **Coprocessor** é o módulo central responsável por coordenar o fluxo de dados entre os blocos internos do sistema (memória, ALU e registradores), garantindo a execução sincronizada das operações matriciais. A máquina de estados finita (FSM) gerencia 7 estados distintos para controlar de maneira precisa o processo, respeitando os tempos de acesso à memória e evitando condições de corrida.

#### 🔄 Máquina de Estados Finita (FSM)

A FSM do Coprocessor controla todo o fluxo de uma operação, desde a escrita das matrizes na memória, passando pela leitura, execução da operação e até a escrita do resultado final.

##### Estados da FSM

| Estado | Nome           | Descrição |
|--------|----------------|-----------|
| 0      | **IDLE**       | Estado de repouso. Aguarda o sinal `start` para iniciar a operação. |
| 1      | **WRITE_INPUT**| Escreve os elementos das matrizes A e B na memória. |
| 2      | **WAIT_WRITE** | Espera alguns ciclos para garantir a estabilidade da escrita. |
| 3      | **READ_INPUT** | Inicia a leitura das matrizes armazenadas na memória. |
| 4      | **WAIT_READ**  | Espera para garantir que os dados lidos sejam estáveis. |
| 5      | **EXECUTE**    | Executa a operação selecionada via `op_code` (e.g., soma, multiplicação, etc). |
| 6      | **WRITE_RESULT** | Escreve o resultado final da operação de volta na memória. |

Essa organização de estados é crucial para garantir a integridade dos dados durante as operações de leitura e escrita.

#### 🧮 Operações Suportadas

As operações são selecionadas por um sinal de 3 bits, `op_code`, e executadas pela ALU. As operações disponíveis são:

- **000**: Soma de Matrizes
- **001**: Subtração de Matrizes
- **010**: Transposição
- **011**: Oposição
- **100**: Multiplicação de Matrizes
- **101**: Multiplicação por Escalar
- **110**: Cálculo de Determinante

Essas operações são realizadas apenas após o carregamento completo dos dados da memória, e o resultado é escrito de volta à memória.

#### 📏 Tamanho da Matriz

O tamanho da matriz (entre 2x2 e 5x5) é configurado através de um sinal de entrada chamado `matrix_size`. Esse valor determina:

- O número total de elementos a serem processados.
- O número de iterações nos loops de controle internos.
- A ativação de linhas e colunas na ALU.

#### 🧩 Variáveis e Controle Interno

O Coprocessor utiliza registradores e variáveis internas para gerenciar o fluxo de dados e controle. As variáveis principais são:

- `i, j`: Contadores de linha e coluna para os loops de controle.
- `state`: Estado atual da máquina de estados.
- `next_state`: Próximo estado (para FSM síncrona).
- `write_enable`: Habilita a escrita na memória.
- `read_data_A, read_data_B`: Buffers para armazenar dados lidos da memória.
- `result`: Vetor temporário para o resultado da operação.

#### ✅ Fluxo de Execução Resumido

O fluxo de execução segue os seguintes passos:

1. **Escrita**: Matrizes A e B são enviadas para a memória com `write_enable = 1`.
2. **Leitura**: Os dados são lidos da memória com `write_enable = 0`.
3. **Execução**: A ALU realiza a operação selecionada conforme o `op_code`.
4. **Resultado**: O vetor `result` é preenchido e escrito de volta na memória.
5. **Finalização**: O sinal `done` é ativado, indicando o término da operação.

---

Esse documento apresenta uma visão geral detalhada do desenvolvimento e da arquitetura do **Coprocessador** projetado para operações matriciais em FPGA.

## Bloco de Memória

A **RAM de 1 porta** é composta pelos seguintes sinais fundamentais:

- **Endereço (address)**: Especifica a posição de memória a ser acessada.
- **Dado de Entrada (data)**: Representa a informação a ser armazenada na memória, no caso de uma escrita.
- **Dado de Saída (q)**: Fornece o conteúdo da posição de memória solicitada, no caso de uma leitura.
- **Clock**: Sinal de sincronismo responsável por coordenar as operações internas.
- **Write Enable (wren)**: Habilita a escrita na memória. Quando ativo, permite que o dado na entrada seja escrito na posição indicada.

### Aplicação em FPGA

Internamente, ao instanciar uma **RAM de 1 porta** no **Quartus**, o compilador mapeia automaticamente essa estrutura para os blocos de memória dedicados presentes na arquitetura física da **FPGA**. Esses blocos são otimizados para operações de leitura e escrita em alta velocidade.

### Configuração Utilizada

O módulo **Memory Block** (RAM 1-Port) foi configurado para conter **4 palavras de 16 bits** cada.

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

- [Manual da Placa DE1-SoC (PDF)](https://drive.google.com/file/d/1dBaSfXi4GcrSZ0JlzRh5iixaWmq0go2j/view)
- [Icarus Verilog - GitHub](https://github.com/steveicarus/iverilog)
- [Quartus Prime - Documentação Oficial](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/overview.html)
