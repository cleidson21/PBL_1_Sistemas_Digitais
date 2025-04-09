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

## Cooprocessor 
1- Coprocessor 
 O  cooprocessor  é responsável por coordenar operações entre blocos internos do sistema, garantindo a execução paralela e eficiente de cálculos envolvendo matrizes. Embora o sistema opere com apenas quatro operações atômicas, a máquina de estados implementada conta com um número maior de estados, o que é necessário para garantir sincronização, estabilidade e funcionamento confiável mesmo em altas frequências de clock.
A máquina de estados implementada é composta por 7 estados , organizados de forma sequencial e lógica, contemplando as fases de escrita na memória, leitura dos dados, execução da operação selecionada e gravação dos resultados  , entre cada processo desse existe um estado extra para evitar que erros ocorram com a ultilização da memória . A comunicação com a memória é feita por meio de sinais de controle, incluindo variáveis de write enable e data bus .

2. Escrita na Memória (Estado 1)
Inicialmente, é necessário carregar os valores das matrizes na memória. Esse processo começa com a pré-carga dos dados na FPGA, que são então enviados para a memória por meio do registrador data, o qual se conecta diretamente ao módulo de memória.

A variável de controle responsável pela escrita é ativada (setada em ‘1’), habilitando o modo de escrita na memória. A transmissão dos dados ocorre de forma paralela, ou seja, os valores correspondentes das duas matrizes são enviados simultaneamente para a memória, ocupando posições específicas.

Para garantir a integridade da operação, o sistema permanece em espera por alguns ciclos (estado de controle), permitindo a sincronização dos dados antes de desativar o write enable e prosseguir com a próxima etapa.

3. Leitura da Memória (Estados 3 e 4)
Nos estados seguintes, ocorre o processo inverso: a leitura dos dados armazenados. Com o sinal de write enable desativado (indicando modo de leitura), o módulo captura os dados das matrizes também de forma paralela, byte a byte.

Novamente, é introduzido um estado de controle adicional, garantindo que os valores capturados não apresentem inconsistências antes de serem enviados aos módulos responsáveis pelas operações.

4. Execução da Operação (Estados 5 e 6)
A operação a ser realizada é escolhida de forma prévia por meio de um opcode. No estado 5, os dados já extraídos da memória são processados por unidades operacionais específicas (ex: adição, subtração, multiplicação, etc.), onde todas as operações ocorrem em paralelo.

No entanto, apenas o resultado da operação correspondente ao opcode é selecionado e armazenado em um vetor de saída.

O estado 6 age como buffer de controle, aguardando o tempo necessário antes de habilitar a escrita do resultado final na memória.

5. Escrita dos Resultados na Memória
Com os resultados armazenados em um registrador de saída, o coprocessador ativa novamente o sinal de write enable, desta vez para armazenar o resultado final na memória. A escrita ocorre de forma ordenada e paralela, respeitando o posicionamento original das matrizes.

## Bloco de Memória
A RAM de 1 porta é composta pelos seguintes sinais fundamentais:
Endereço (address): especifica a posição de memória a ser acessada.

Dado de entrada (data): representa a informação a ser armazenada na memória, no caso de uma escrita.

Dado de saída (q): fornece o conteúdo da posição de memória solicitada, no caso de uma leitura.


Clock: sinal de sincronismo responsável por coordenar as operações internas.


Write Enable (wren): sinal de habilitação de escrita; quando ativo (nível lógico alto), permite que o dado na entrada seja escrito na posição de memória indicada.


O comportamento da RAM segue a lógica síncrona típica: a cada borda de subida do sinal de clock, a operação realizada depende do estado do sinal wren. Se o sinal estiver ativo, o valor presente na entrada data é armazenado na posição indicada por address. Caso contrário, a memória permanece em modo de leitura, e o valor armazenado na posição especificada é apresentado na saída q , o que em nosso sistema ocorre de modo imediato sem haver uma sincronização com o clock de armazenamento.

Aplicação em FPGA
Internamente, ao instanciar uma RAM de 1 porta que faz parte do IP Catalog no Quartus, o compilador mapeia automaticamente essa estrutura para os blocos de memória dedicados presentes na arquitetura física da FPGA. Esses blocos são otimizados para operações de leitura e escrita em alta velocidade, oferecendo acesso eficiente com baixo consumo de lógica programável.
Além disso, por meio da aba Tools > In-System Memory Content Editor, é possível visualizar e interagir com o conteúdo da memória durante a execução, o que facilita a análise e depuração do sistema.
Essas características nos impulsionaram a utilizar essa memória em detrimento de registradores comuns, que são construídos em Verilog a partir da criação de variáveis explícitas . 

Configuração Utilizada
O módulo Memory Block (RAM 1-Port) foi configurado para conter 4 words de 16 bits cada . 


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
