import subprocess
import argparse

MARCADOR = "#" #marca o fim da exprecao
ARQUIVO_TESTES = "testes.md"
ARQUIVO_SAIDAS = "saidas.txt"
ARQUIVO_ENTRADA_MAKE = "exemplos/01_soma.foca"
DIR_PROJETO = "/home/joao/Documents/estudos/faculdade/compiladores/repo_trabalho/trabalho_compiladores"
SEPARADOR_SAIDA = "===== TESTE {numero} ====="


def ler_testes():
    testes = []
    teste_atual = []

    with open(ARQUIVO_TESTES, "r", encoding="utf-8") as arquivo:
        next(arquivo)

        for linha in arquivo:
            if linha.strip() == MARCADOR:
                if teste_atual:
                    testes.append("".join(teste_atual))
                    teste_atual = []
            else:
                teste_atual.append(linha)

    return testes


def gravar_teste(teste):
    with open(ARQUIVO_ENTRADA_MAKE, "w", encoding="utf-8") as target:
        target.write(teste)


def executar_make(teste):
    gravar_teste(teste)
    resultado = subprocess.run(
        ["make"],
        cwd=DIR_PROJETO,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )
    return resultado.stdout


def dividir_saidas(conteudo):
    saidas = []
    saida_atual = []

    for linha in conteudo.splitlines(keepends=True):
        if linha.startswith("===== TESTE "):
            if saida_atual:
                saidas.append("".join(saida_atual))
                saida_atual = []
        else:
            saida_atual.append(linha)

    if saida_atual:
        saidas.append("".join(saida_atual))

    return saidas


def normalizar(texto):
    return texto.strip()


def gerar_arquivo():
    testes = ler_testes()

    with open(ARQUIVO_SAIDAS, "w", encoding="utf-8") as escrita:
        for numero, teste in enumerate(testes, start=1):
            saida = executar_make(teste)
            escrita.write(SEPARADOR_SAIDA.format(numero=numero))
            escrita.write("\n")
            escrita.write(saida)
            escrita.write("\n")

            print(SEPARADOR_SAIDA.format(numero=numero))
            print(saida)
                    
def compare():
    testes = ler_testes()

    with open(ARQUIVO_SAIDAS, "r", encoding="utf-8") as saidas:
        saidas_esperadas = dividir_saidas(saidas.read())

    for numero, teste in enumerate(testes, start=1):
        saida_atual = executar_make(teste)

        if numero > len(saidas_esperadas):
            print(f"Teste {numero}: saida esperada nao encontrada em {ARQUIVO_SAIDAS}")
            continue

        saida_esperada = saidas_esperadas[numero - 1]

        if normalizar(saida_atual) != normalizar(saida_esperada):
            print(f"Teste {numero}: diferenca encontrada")
            print("Saida atual:")
            print(saida_atual)
            print("Saida esperada:")
            print(saida_esperada)
        else:
            print(f"Teste {numero}: correto")

    if len(saidas_esperadas) > len(testes):
        print(f"{len(saidas_esperadas) - len(testes)} saida(s) esperada(s) sobrando em {ARQUIVO_SAIDAS}")

def main():
     parser = argparse.ArgumentParser()

     parser.add_argument("-m", choices=["store","compare"])
     args = parser.parse_args()

     if args.m == "store":
          gerar_arquivo()
     elif args.m == "compare":
        compare()
     else: print("python -m store ou python -m compare")
if __name__ == "__main__":
    main()
