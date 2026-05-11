import subprocess

MARCADOR = "#" #marca o fim da exprecao

with open("teste.md", "r", encoding= "utf-8") as f:
    f.next()
    f.read()
    with open("01_soma.foca", "w", encoding = "utf-8") as target:
        for linha in f:
            target.write(linha)

            if MARCADOR in linha:
                #terminei a leitura
                #rode o codigo
                resultado = subprocess.run(["make"],
                               cwd= "/home/joao/Documents/estudos/faculdade/compiladores/repo_trabalho/trabalho_compiladores",
                               capture_output = True,
                               text = True
                               )
                #tratar a saida
                print(resultado.stdout)
                print("/n")

                #movo para o inicio e apago o resto
                target.seek(0)
                target.truncate()
                