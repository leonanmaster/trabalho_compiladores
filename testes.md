# Teste: 1
int b;
b = 10;
b += 5;
b -= 2;
b *= 3;
b /= 2;
b--;
b++;
#
# Teste: 2
int i;
int soma;
soma = 0;
for (i = 0; i < 5; i++) {
    soma = soma + i;
}
#
# Teste: 3
int i;
int soma;
soma = 0;
for (i = 5; i > 0; i--) {
    soma = soma + i;
}
#
# Teste: 4
int vet[5];
int i;

for (i = 0; i < 5; i++) {
    vet[i] = i * 10;
}

int soma;
soma = 0;
i = 0;

while (i < 5) {
    soma += vet[i];
    i++;
}
#
# Teste: 5
int mat[3][4];
int l;
int c;
int res;

l = 2;
c = 1;
mat[l][c] = 50;

res = mat[2][1] + 10;
#
# Teste: 6
int vet[3] = {10, 20, 30};
int mat[2][2] = {100, 200, 300, 400};

int somavet;
int somamat;

somavet = vet[0] + vet[2];
somamat = mat[1][0] + mat[1][1];
#