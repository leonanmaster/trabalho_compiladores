# Testes a Serem Realizados
char a;
a = '1';
#
char a;
a = 'a'
#
bool x;
x = false;
#
bool x;
x = 1 < 2;
#
bool x;
int t;
t = 2;
int k;
k = 3;
x = t < k;
#
bool x;
x = not not ((1+2) < 2);
#
float F;
int I;
I = 10;
F = I + 2.5;
#
int I;
float F;
I = (int) F;
#
float a;
a = 20.5;
#
int b;
b = (int) a;
#
float c;
c = b + a;
#
int b;
b = 1+2;
#
int a;
int b;
a = 10;
b = a * 2 + 3;
#
int a;
int b;
int c;
a = 8;
b = 2;
c = (a + b) * (a - b);
#
float x;
float y;
x = 2.5;
y = x / 2.0 + 1.25;
#
int i;
float f;
i = 4;
f = i + 3.75;
#
float f;
int i;
f = 9.8;
i = (int) f;
#
int i;
float f;
i = 7;
f = (float) i;
#
bool ok;
ok = true and false;
#
bool ok;
ok = true or false;
#
bool ok;
ok = not false;
#
bool ok;
int a;
int b;
a = 5;
b = 5;
ok = a == b;
#
bool ok;
int a;
int b;
a = 3;
b = 9;
ok = a <= b;
#
bool ok;
float a;
float b;
a = 4.5;
b = 2.25;
ok = a > b;
#
bool ok;
int a;
float b;
a = 3;
b = 3.0;
ok = a >= b;
#
bool ok;
int a;
int b;
int c;
a = 1;
b = 2;
c = 3;
ok = (a < b) and (b < c);
#
bool ok;
int a;
int b;
a = 1;
b = 2;
ok = not ((a + b) > 5);
#
char letra;
letra = 'z';
#
char letra;
char outra;
letra = 'x';
outra = letra;
#
int a;
a = 10 / 2;
#
float media;
int soma;
soma = 7 + 8;
media = soma / 2.0;
#
int x;
x = y + 1;
#
int x;
x = true;
#
bool ok;
ok = 1 + 2;
#
char c;
c = 65;
#
float f;
f = 'a';
#
# Teste: if simples com bloco
int a;
a = 0;
if (1 < 2) {
    a = 1;
}
#
# Teste: if simples sem chaves (comando unico)
int a;
a = 0;
if (true)
    a = 1;
#
# Teste: if/else com blocos
int a;
if (5 >= 3) {
    int b;
    b = 10;
    a = b;
} else {
    a = 0;
}
#
# Teste: if/else sem chaves (comandos unicos)
int a;
bool cond;
cond = false;
if (cond)
    a = 1;
else
    a = 2;
#
# Teste: if dentro de if (Aninhado)
int a;
a = 0;
if (true) {
    if (2 > 1) {
        a = 10;
    }
}
#
# Teste Falha: Condicao inteira no if (Erro semantico)
int a;
a = 1;
if (a) {
    a = 2;
}
#
# Teste Falha: Condicao float no if (Erro semantico)
float f;
f = 2.5;
if (f) {
    int x;
    x = 1;
}
#
# Teste Falha: Esquecer parenteses na condicao (Erro sintatico)
int a;
if true {
    a = 1;
}
#
# Teste Falha: else sem if correspondente (Erro sintatico)
int a;
a = 1;
else {
    a = 2;
}
#
# Teste: while simples com bloco
int a;
a = 0;
while (a < 5) {
    a = a + 1;
}
#
# Teste: while com comando unico (sem chaves)
int a;
a = 5;
while (a > 0)
    a = a - 1;
#
# Teste Falha: while com condicao inteira (Erro semantico)
int a;
a = 10;
while (a) {
    a = a - 1;
}
#
# Teste: do/while com bloco
int a;
a = 0;
do {
    a = a + 1;
} while (a < 5);
#
# Teste: do/while comando unico
int a;
a = 5;
do
    a = a - 1;
while (a > 0);
#
# Teste Falha: do/while com condicao inteira (Erro semantico)
int a;
a = 10;
do {
    a = a - 1;
} while (a);
#
# Teste Falha: do/while sem ponto e virgula no final (Erro sintatico)
int a;
a = 0;
do {
    a = 1;
} while (a < 5)
## Teste: for simples com bloco
int i;
int soma;
soma = 0;
for (i = 0; i < 5; i = i + 1) {
    soma = soma + i;
}
#
# Teste: for simples comando unico
int i;
for (i = 10; i > 0; i = i - 1)
    i = i * 1;
#
# Teste Falha: condicao nao booleana no for (Erro semantico)
int i;
for (i = 0; i + 5; i = i + 1) {
    i = i + 0;
}
#
# Teste: break dentro de while
int a;
a = 0;
while (a < 10) {
    a = a + 1;
    if (a == 5) {
        break;
    }
}
#
# Teste: continue dentro de for
int i;
int soma;
soma = 0;
for (i = 0; i < 5; i = i + 1) {
    if (i == 2) {
        continue;
    }
    soma = soma + i;
}
#
# Teste: break em lacos aninhados (for e while)
int i;
int j;
for (i = 0; i < 3; i = i + 1) {
    j = 0;
    while (j < 3) {
        j = j + 1;
        if (j == 2) {
            break;
        }
    }
}
#
# Teste Falha: break fora de laco
int a;
a = 1;
break;
#
# Teste Falha: continue dentro de if, mas fora de laco
int a;
a = 0;
if (a == 0) {
    continue;
}
#
# Teste: switch simples com int e break
int a;
int res;
a = 2;
switch (a) {
    case 1: {
        res = 10;
        break;
    }
    case 2: {
        res = 20;
        break;
    }
    default: {
        res = 0;
    }
}
#
# Teste: switch com char e sem chaves nos cases
char c;
int res;
c = 'x';
switch (c) {
    case 'y':
        res = 1;
        break;
    case 'x':
        res = 2;
        break;
}
#
# Teste Falha: switch com float (Erro semantico)
float f;
f = 1.5;
switch (f) {
    case 1:
        f = 0.0;
}
#
# Teste Falha: case com tipo diferente do switch (Erro semantico)
int a;
a = 1;
switch (a) {
    case 'a':
        a = 0;
}
#