# AES-128 com protocolo de comunicação I²C
Implementação em verilog de um encriptador e decriptador AES-128, onde a comunicação de entrada é feita através do protocolo I²C. A palavra a ser criptografada/decriptografada, a chave desta operação e o tipo de operação a ser feita (criptografia ou decriptografia) são recebidos de forma serial e então passados a um circuito de controle que sincroniza todas as operações necessárias. A saída é disponibilizada de forma paralela. O circuito foi desenvolvido de forma que cada bloco da criptografia é independente e assíncrono, facilitando o processo de escrita e teste do código. Todos os módulos desenvolvidos foram testados individualmente e em conjunto, validando sua operação.

**Input**: palavra a ser criptografada (128 bits), chave (128 bits) and operação (criptografia: 8'b0000000, decriptografia: 8'b00000001)

**Output**: cifra (paralela 128 bits) e flag done

<img width="593" height="610" alt="image" src="https://github.com/user-attachments/assets/cfc2f0fb-18e6-4bb6-b622-e836faa76021" />



**Desenvolvedores**:

Andre Luiz E. Araujo - andrediaraujo@gmail.com

Daniella Vicentini Azevedo dos Santos - daniella.vicentini@yahoo.com.br

Guilherme Henrique Duarte Mendes - gui_mendes10@hotmail.com

Janaína G. M. Oliveira - janaina.gmoliveira@gmail.com

Lucas Manoel Leite de Souza - lmanoelso@gmail.com

Maria Teresa Rocha Carvalho - mariateresarochacarvalho@gmail.com

Matheus Henrique Martins Paiva mtpaivamrhenrique@gmail.com

Sérgio Henrique Azevedo dos Santos - shasantos2005@gmail.com

**Orientador**:

Felipe Gustavo de Freitas Rocha - felipef.rocha@inatel.br
