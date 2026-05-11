# Tutorial do script de testes

Este projeto usa o arquivo `teste.py` para rodar varios programas escritos em FOCA e comparar as saidas geradas pelo `make`.

O fluxo principal e:

1. Escrever os casos de teste em `testes.md`.
2. Gerar um gabarito com as saidas esperadas.
3. Rodar a comparacao depois de alterar o compilador.

## Formato do `testes.md`

O arquivo `testes.md` guarda todos os casos de teste.

A primeira linha e apenas um titulo e e ignorada pelo script. Cada teste deve terminar com uma linha contendo somente `#`.

Exemplo:

```txt
# Testes a Serem Realizados
int a;
a = 1 + 2;
#
float f;
f = 2.5;
#
bool ok;
ok = 1 < 2;
#
```

Cada bloco entre dois marcadores `#` sera copiado para `exemplos/01_soma.foca`. Depois disso, o script executa `make`.

## Comandos disponiveis

Todos os comandos devem ser executados na raiz do projeto:

```sh
python3 teste.py -m store
```

Esse comando roda o `make` para cada teste de `testes.md` e salva as saidas em `saidas.txt`.

Use quando quiser guardar uma copia das saidas atuais, sem necessariamente tratar como gabarito oficial.

```sh
python3 teste.py -m gerar_gabarito
```

Esse comando roda o `make` para cada teste de `testes.md` e salva as saidas em `gabarito.txt`.

Use quando as saidas atuais estiverem corretas e voce quiser transforma-las no gabarito dos testes.

```sh
python3 teste.py -m compare
```

Esse comando roda novamente o `make` para cada teste de `testes.md` e compara a saida atual com o conteudo de `gabarito.txt`.

Se a saida for igual ao gabarito, ele imprime:

```txt
Teste N: correto
```

Se a saida for diferente, ele imprime:

```txt
Teste N: diferenca encontrada
Saida atual:
...
Saida esperada:
...
```

No final da comparacao, o script imprime um resumo.

Se todos os testes funcionarem, aparece:

```txt
Resumo: todos os N testes funcionaram.
```

Se algum teste falhar, aparece:

```txt
Resumo: alguns testes falharam.
Testes com problema: 2, 5, 9
```

## Arquivos usados pelo script

`testes.md`: entradas dos testes.

`exemplos/01_soma.foca`: arquivo temporario usado como entrada do `make`. O script sobrescreve esse arquivo a cada teste.

`saidas.txt`: arquivo gerado pelo modo `store`.

`gabarito.txt`: arquivo gerado pelo modo `gerar_gabarito` e usado pelo modo `compare`.

## Fluxo recomendado

Depois de escrever ou alterar os testes em `testes.md`, gere o gabarito:

```sh
python3 teste.py -m gerar_gabarito
```

Depois de alterar o compilador, rode:

```sh
python3 teste.py -m compare
```

Se todos os testes estiverem corretos, a saida sera uma lista parecida com:

```txt
Teste 1: correto
Teste 2: correto
Teste 3: correto

Resumo: todos os 3 testes funcionaram.
```

## Observacoes importantes

O modo `gerar_gabarito` sobrescreve `gabarito.txt`.

O modo `store` sobrescreve `saidas.txt`.

O modo `compare` depende de `gabarito.txt`. Se esse arquivo nao existir, primeiro rode:

```sh
python3 teste.py -m gerar_gabarito
```

Como o script chama `make`, qualquer erro do compilador tambem aparece na saida capturada. Isso e util para testar tanto casos validos quanto casos que devem gerar erro.
