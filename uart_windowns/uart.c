

#include <stdio.h>
#include <windows.h>


#define COM_PORT "COM4"  
#define BAUD_RATE CBR_9600 
#define DATA_BITS 8  
#define STOP_BITS ONESTOPBIT 
#define PARITY NOPARITY 



void configure_uart(HANDLE *hSerial) {
    *hSerial = CreateFile(
        COM_PORT, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);


    if (*hSerial == INVALID_HANDLE_VALUE) {
        printf("Erro ao abrir a porta serial.\n");
        return;
    }


    DCB dcbSerialParams = {0};
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);


    if (!GetCommState(*hSerial, &dcbSerialParams)) {
        printf("Erro ao obter estado da porta serial.\n");
        return;
    }


    // Definir os parâmetros da porta serial
    dcbSerialParams.BaudRate = BAUD_RATE;
    dcbSerialParams.ByteSize = DATA_BITS;
    dcbSerialParams.StopBits = STOP_BITS;
    dcbSerialParams.Parity = PARITY;


    if (!SetCommState(*hSerial, &dcbSerialParams)) {
        printf("Erro ao configurar a porta serial.\n");
        return;
    }


    // Configuração de tempo de leitura da porta serial
    COMMTIMEOUTS timeouts = {0};
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;


    SetCommTimeouts(*hSerial, &timeouts);
}


// Função para enviar um byte via UART
void send_data(HANDLE hSerial, unsigned char data) {
    DWORD bytesWritten;
    if (!WriteFile(hSerial, &data, sizeof(data), &bytesWritten, NULL)) {
        printf("Erro ao enviar dados.\n");
    }
}


//receber informação


// Função para ler um byte via UART
int receive_data(HANDLE hSerial, unsigned char *data) {
    DWORD bytesRead;
    if (ReadFile(hSerial, data, 1, &bytesRead, NULL) && bytesRead == 1) {
        return 1;  // Sucesso
    } else {
        return 0;  // Falha na leitura
    }
}




int main() {
    HANDLE hSerial;
    configure_uart(&hSerial);


    // Variáveis para a matriz
    int rows, cols;


    // Solicitar ao usuário o tamanho da matriz
    printf("Digite o numero de linhas da matriz (2-5): ");
    scanf("%d", &rows);
    if (rows < 2 || rows > 5) {
        printf("Numero de linhas invalido! O numero de linhas deve ser entre 2 e 5.\n");
        CloseHandle(hSerial);
        return 1;
    }


   


    // Definir a matriz com base no tamanho informado pelo usuário
    unsigned char matrix[5][5];  // Máximo de 5x5


    // Solicitar ao usuário os valores para preencher a matriz
    printf("Digite os valores da matriz (em hexadecimal):\n");
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < rows ; j++) {
            printf("Valor para posicao [%d][%d]: ", i + 1, j + 1);
            scanf("%hhx", &matrix[i][j]);  // Leitura em hexadecimal
        }
    }


    // Enviar os dados da matriz para a FPGA com uma espera de 1 segundo entre cada envio
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < rows; j++) {
            // Enviar o valor atual da matriz
            send_data(hSerial, matrix[i][j]);
            printf("Dado enviado: 0x%X\n", matrix[i][j]);


            // Pausa de 1 segundo (1000 milissegundos)
            Sleep(1000);
        }
    }


   




    printf("\nAguardando resposta da FPGA...\n");


    unsigned char result;
    int received_count = 0;


    // Suponha que a FPGA envie `rows` bytes de volta (um resultado por linha, por exemplo)
    int  um =  1;
    while (um) {
       
        if (receive_data(hSerial, &result)) {
            printf("Resposta recebida [%d]: 0x%X\n", received_count + 1, result);
            received_count++;
        } else {
            printf("Esperando dado...\n");
            Sleep(100); // Espera um pouco antes de tentar de novo
        }
    }


   
    // Fechar a porta serial
    CloseHandle(hSerial);
    return 0;
}






#include <stdio.h>
#include <windows.h>


#define COM_PORT "COM4"  // Substitua pela porta serial correta
#define BAUD_RATE CBR_9600 // Velocidade do baud rate
#define DATA_BITS 8  // 8 bits de dados
#define STOP_BITS ONESTOPBIT // 1 bit de stop
#define PARITY NOPARITY // Sem paridade


// Função para configurar a porta serial
void configure_uart(HANDLE *hSerial) {
    *hSerial = CreateFile(
        COM_PORT, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);


    if (*hSerial == INVALID_HANDLE_VALUE) {
        printf("Erro ao abrir a porta serial.\n");
        return;
    }


    DCB dcbSerialParams = {0};
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);


    if (!GetCommState(*hSerial, &dcbSerialParams)) {
        printf("Erro ao obter estado da porta serial.\n");
        return;
    }


    // Definir os parâmetros da porta serial
    dcbSerialParams.BaudRate = BAUD_RATE;
    dcbSerialParams.ByteSize = DATA_BITS;
    dcbSerialParams.StopBits = STOP_BITS;
    dcbSerialParams.Parity = PARITY;


    if (!SetCommState(*hSerial, &dcbSerialParams)) {
        printf("Erro ao configurar a porta serial.\n");
        return;
    }


    // Configuração de tempo de leitura da porta serial
    COMMTIMEOUTS timeouts = {0};
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;


    SetCommTimeouts(*hSerial, &timeouts);
}


// Função para enviar um byte via UART
void send_data(HANDLE hSerial, unsigned char data) {
    DWORD bytesWritten;
    if (!WriteFile(hSerial, &data, sizeof(data), &bytesWritten, NULL)) {
        printf("Erro ao enviar dados.\n");
    }
}


//receber informação


// Função para ler um byte via UART
int receive_data(HANDLE hSerial, unsigned char *data) {
    DWORD bytesRead;
    if (ReadFile(hSerial, data, 1, &bytesRead, NULL) && bytesRead == 1) {
        return 1;  // Sucesso
    } else {
        return 0;  // Falha na leitura
    }
}




int main() {
    HANDLE hSerial;
    configure_uart(&hSerial);


    // Variáveis para a matriz
    int rows, cols;


    // Solicitar ao usuário o tamanho da matriz
    printf("Digite o numero de linhas da matriz (2-5): ");
    scanf("%d", &rows);
    if (rows < 2 || rows > 5) {
        printf("Numero de linhas invalido! O numero de linhas deve ser entre 2 e 5.\n");
        CloseHandle(hSerial);
        return 1;
    }


   


    // Definir a matriz com base no tamanho informado pelo usuário
    unsigned char matrix[5][5];  // Máximo de 5x5


    // Solicitar ao usuário os valores para preencher a matriz
    printf("Digite os valores da matriz (em hexadecimal):\n");
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < rows ; j++) {
            printf("Valor para posicao [%d][%d]: ", i + 1, j + 1);
            scanf("%hhx", &matrix[i][j]);  // Leitura em hexadecimal
        }
    }


    // Enviar os dados da matriz para a FPGA com uma espera de 1 segundo entre cada envio
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < rows; j++) {
            // Enviar o valor atual da matriz
            send_data(hSerial, matrix[i][j]);
            printf("Dado enviado: 0x%X\n", matrix[i][j]);


            // Pausa de 1 segundo (1000 milissegundos)
            Sleep(1000);
        }
    }


   




    printf("\nAguardando resposta da FPGA...\n");


    unsigned char result;
    int received_count = 0;


    // Suponha que a FPGA envie `rows` bytes de volta (um resultado por linha, por exemplo)
    int  um =  1;
    while (um) {
       
        if (receive_data(hSerial, &result)) {
            printf("Resposta recebida [%d]: 0x%X\n", received_count + 1, result);
            received_count++;
        } else {
            printf("Esperando dado...\n");
            Sleep(100); // Espera um pouco antes de tentar de novo
        }
    }


   
    // Fechar a porta serial
    CloseHandle(hSerial);
    return 0;
}
