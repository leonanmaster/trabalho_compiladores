# Teste 1: Tipos basicos, aritmetica e conversao (cast)
int a;
int b;
a = 10;
b = a + 5 * 2 ^ 2;

float f;
f = (float) b + 2.5;

char c;
c = 'x';

bool ok;
ok = true;
#

# Teste 2: Operadores logicos e relacionais
bool r1;
bool r2;
int x;
int y;

x = 10;
y = 20;

r1 = x < y and x != 5;
r2 = not (x == y) or (y >= 20);
#

# Teste 3: Operadores compostos e unarios
int cont;
cont = 0;

cont++;
cont += 10;
cont--;
cont -= 2;
cont *= 3;
cont /= 2;
#

# Teste 4: Estruturas de controle de fluxo (if, else, switch)
int valor;
valor = 2;
int res;

if (valor == 1) {
    res = 10;
} else {
    if (valor == 2) {
        res = 20;
    }
}

switch(valor) {
    case 1: { res = 100; }
    case 2: { res = 200; }
    default: { res = 0; }
}
#

# Teste 5: Estruturas de repeticao (for, while, do-while)
int i;
int soma;
soma = 0;

for (i = 0; i < 5; i++) {
    soma += i;
}

while (soma > 0) {
    soma--;
}

do {
    soma++;
} while (soma < 10);
#

# Teste 6: Controle avancado de lacos (break e continue)
int j;
int saltos;
saltos = 0;

for (j = 0; j < 10; j++) {
    if (j == 5) {
        break;
    }
    if (j == 2) {
        continue;
    }
    saltos++;
}
#

# Teste 7: Alocacao e acesso dinamico (Vetores e Matrizes)
int vetDinamico[5];
int matDinamica[3][3];
int k;

for (k = 0; k < 5; k++) {
    vetDinamico[k] = k * 2;
}

matDinamica[0][0] = vetDinamico[1];
matDinamica[2][2] = 99;
#

# Teste 8: Inicializacao em linha de vetores e matrizes
int vet[3] = {10, 20, 30};
int mat[2][2] = {1, 2, 3, 4};
int somaEstruturas;

somaEstruturas = vet[1] + mat[1][1];
#

# Teste 9: Strings e comandos de Entrada e Saida
string saudacao;
saudacao = 'Ola Mundo';

int entrada;
in >> entrada;

out << saudacao;
out << entrada;
#

# Teste 10: Declaracao e chamada de funcoes
int multiplicar(int p1, int p2) {
    return p1 * p2;
}

int principal;
principal = multiplicar(5, 4);
#