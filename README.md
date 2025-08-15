# 🚀 Trabalho Prático – RISC-V (CSI509)

Repositório do Trabalho Prático 1 da disciplina **CSI509 – Organização e Arquitetura de Computadores II** (UFOP – Engenharia da Computação). O objetivo é implementar um processador RISC-V simplificado, suportando um subconjunto de instruções.

---

## 📌 Grupo: [12]
### Instruções implementadas:
- `lh`
- `sh`
- `sub`
- `or`
- `andi`
- `srl`
- `beq`

---

## 📁 Estrutura do Repositório

.
├── docs/             # Documentos de referência e relatório do projeto
│   ├── comoRodar.txt
│   ├── CSI509-Trabalho Prático.pdf
│   ├── Grupos CSI259-TPs.pdf
│   └── Relatório.pdf
├── sim/              # Arquivos de saída da compilação (gerados pelo iverilog)
├── src/              # Códigos-fonte em Verilog
│   ├── components/   # Módulos genéricos e reutilizáveis (ex: MUXes)
│   ├── control/      # Módulos da unidade de controle
│   ├── core/         # Módulos do pipeline (estágios, registradores e processador)
│   ├── execution/    # Módulos do estágio de execução (ULA, Forwarding e Hazard Detection)
│   ├── memory/       # Módulos de memória (banco de registradores, dados, instrução)
│   └── tb/           # Módulo de Testbench para a simulação
├── waves/            # Arquivos de forma de onda (gerados pela simulação)
├── LICENSE           # Licença do repositório
└── README.md         # Documentação principal do projeto
---

## 🧪 Testbench

O testbench simula o funcionamento do processador, exibindo no terminal o estado dos 32 registradores e da memória de dados após a execução. Um clock automático é usado, e os resultados são comparados com os valores esperados.

---

## 🔧 Implementação no FPGA

A ser realizado em uma data posterior.

---

## 📄 Documentação

A documentação está em formato SBC (LaTeX), contendo:

- Introdução
- Objetivos
- Metodologias
- Análise de Resultados
- Conclusão
- Referências bibliográficas

---

## 👨‍🏫 Professor
**Racyus Delano Garcia Pacífico**

---

## ✅ Autores

- [Victor Pureza Cabral - 21.2.8095]
- [Otávio Augusto Guimarães Ferreira - 21.2.8074]
