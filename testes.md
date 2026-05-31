#
int a;
a = 0;
if (1 < 2) {
    a = 1;
}
#
int a;
a = 0;
if (true)
    a = 1;
#
int a;
if (5 >= 3) {
    int b;
    b = 10;
    a = b;
} else {
    a = 0;
}
#
int a;
bool cond;
cond = false;
if (cond)
    a = 1;
else
    a = 2;
#
int a;
a = 0;
if (true) {
    if (2 > 1) {
        a = 10;
    }
}
#
int a;
a = 1;
if (a) {
    a = 2;
}
#
float f;
f = 2.5;
if (f) {
    int x;
    x = 1;
}
#
int a;
if true {
    a = 1;
}
#
int a;
a = 1;
else {
    a = 2;
}
#
int a;
a = 0;
while (a < 5) {
    a = a + 1;
}
#
int a;
a = 5;
while (a > 0)
    a = a - 1;
#
int a;
a = 10;
while (a) {
    a = a - 1;
}
#
int a;
a = 0;
do {
    a = a + 1;
} while (a < 5);
#
int a;
a = 5;
do
    a = a - 1;
while (a > 0);
#
int a;
a = 10;
do {
    a = a - 1;
} while (a);
#
int a;
a = 0;
do {
    a = 1;
} while (a < 5)
int i;
int soma;
soma = 0;
for (i = 0; i < 5; i = i + 1) {
    soma = soma + i;
}
# 17
int i;
for (i = 10; i > 0; i = i - 1)
    i = i * 1;
# 18
int i;
for (i = 0; i + 5; i = i + 1) {
    i = i + 0;
}
# 19
int a;
a = 0;
while (a < 10) {
    a = a + 1;
    if (a == 5) {
        break;
    }
}
# 20
int i;
int soma;
soma = 0;
for (i = 0; i < 5; i = i + 1) {
    if (i == 2) {
        continue;
    }
    soma = soma + i;
}
# 21
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
# 22
int a;
a = 1;
break;
# 23
int a;
a = 0;
if (a == 0) {
    continue;
}
# 24
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
# 25
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
# 26
float f;
f = 1.5;
switch (f) {
    case 1:
        f = 0.0;
}
# 27
int a;
a = 1;
switch (a) {
    case 'a':
        a = 0;
}
# 28
string resultado;
resultado = 'Bom' + ' dia';
out << resultado;
# 29
string resultado;
resultado = '' + 'teste';
out << resultado;
# 30
string resultado;
resultado = 'teste' + '';
out << resultado;
# 31
string parte1;
string parte2;
string resultado;
parte1 = 'Bom';
parte2 = ' dia';
resultado = parte1 + parte2;
out << resultado;
# 32
string resultado;
resultado = 'Bom' + ' dia' + ' Rafael';
out << resultado;
# 33
string resultado;
resultado = 'idade ' + 22;
# 34
bool iguais;
iguais = 'Rafael' == 'Rafael';
out << iguais;
# 35
bool iguais;
iguais = 'Rafael' == 'Pedro';
out << iguais;
# 36
bool iguais;
iguais = '' == '';
out << iguais;
# 37
bool iguais;
iguais = 'Rafael' == 'Rafa';
out << iguais;
# 38
string nome1;
string nome2;
bool iguais;
nome1 = 'Rafael';
nome2 = 'Rafael';
iguais = nome1 == nome2;
out << iguais;
# 39
bool iguais;
iguais = 'Rafael' == 'Rafael ';
out << iguais;
# 40
bool iguais;
iguais = 'abc' == 10;
out << iguais;
#
