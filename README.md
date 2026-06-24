# 🦭 Compilador FOCA

**FOCA** (Focused Optimized Compiler Architecture) é um compilador educacional completo desenvolvido como projeto da disciplina de Compiladores. A linguagem FOCA possui uma sintaxe moderna e intuitiva, com geração de código intermediário em C/C++ compilável.

O compilador realiza **análise léxica** (Flex), **análise sintática e semântica** (Bison/Yacc) e **geração de código intermediário** em três endereços, produzindo código C++ executável.

---

> 💡 **(PRINCIPAIS EXTRAS)**
> - **`let` / Inferência de Tipo:** Declaração explícita (`let x: int`), inferência automática (`let x = 10`) ou inferência adiada/dinâmica (`let x` e depois `x = 10`).
> - **`const`:** Declaração de constantes imutáveis (`const PI = 3.14`).
> - **Subfaixa:** Validação automática de limite em runtime, ex: `let nota : 0..10`. Aborta se violado.
> - **Passagem por Nome:** Chamar funções explicitando os argumentos: `dividir(divisor = 2.0, dividendo = 10.0)`.
> - **`break all` / `continue all`:** Controle total de laços aninhados para sair ou continuar de todas as iterações de uma vez.
> - **Operações Matemáticas:** Exponenciação (`**`), Módulo (`%`) e funções embutidas (`sqrt`, `abs`, `min`, `max`).
> - **Bounds Checking:** Vetores e matrizes verificam acessos fora do limite no código gerado (C++).

---

## 📦 Instalação

É necessário as ferramentas `flex`, `bison` e `g++`.

### Ubuntu / Debian
```bash
sudo apt install build-essential flex bison
```

### Arch Linux
```bash
sudo pacman -S base-devel flex bison
```

---

## 🚀 Execução

```bash
make                                    # compila o compilador
make run FILE=exemplos/01_soma.foca     # compila e executa um exemplo .foca
make test                               # roda todos os testes automatizados
make test2                              # roda testes da etapa 2 (com Python)
make clean                              # limpa arquivos gerados
```

---

## 📖 Referência Completa da Linguagem

### Sumário de Funcionalidades

| # | Funcionalidade | Status | Categoria |
|---|---|---|---|
| 1 | Declaração Explícita (`let x : int`) | ✅ | Obrigatório |
| 2 | Escopo Estático | ✅ | Obrigatório |
| 3 | Blocos `{ }` | ✅ | Obrigatório |
| 4 | Escopo Global (`global let`) | ✅ | Obrigatório |
| 5 | Tipos Primitivos (`int`, `float`, `bool`, `string`, `char`) | ✅ | Obrigatório |
| 6 | Inicialização de Variáveis | ✅ | Obrigatório |
| 7 | Concatenação de String (`+`) | ✅ | Obrigatório |
| 8 | Matrizes (`tipo[N]` e `tipo[N][M]`) | ✅ | Obrigatório |
| 9 | Inicialização de Matrizes | ✅ | Obrigatório |
| 10 | Expressões Aritméticas | ✅ | Obrigatório |
| 11 | Expressões Condicionais | ✅ | Obrigatório |
| 12 | Comandos de Entrada e Saída (`cin`, `cout`) | ✅ | Obrigatório |
| 13 | Comandos de Laço (`for`, `while`, `do/while`) | ✅ | Obrigatório |
| 14 | Comandos de Decisão (`if`, `if/else`, `switch`) | ✅ | Obrigatório |
| 15 | Operadores Aritméticos (`+`, `-`, `*`, `/`) | ✅ | Obrigatório |
| 16 | Operadores Relacionais (`==`, `!=`, `<`, `>`, `<=`, `>=`) | ✅ | Obrigatório |
| 17 | Operadores Lógicos (`&&`, `\|\|`, `!`) | ✅ | Obrigatório |
| 18 | Operadores Compostos (`+=`, `-=`, `*=`, `/=`) | ✅ | Obrigatório |
| 19 | Operadores Unários (`++`, `--`, `-`) | ✅ | Obrigatório |
| 20 | Conversão de Tipos (implícita e explícita) | ✅ | Obrigatório |
| 21 | Mecanismos de Controle de Laços (`break`, `continue`) | ✅ | Obrigatório |
| 22 | Detecção de Erros Semânticos | ✅ | Obrigatório |
| 23 | Subprograma — Função (`func`) | ✅ | Obrigatório |
| 24 | Subfaixa (`0..9`) | ✅ | Extra |
| 25 | Inferência de Tipos (`let x = 42`, `let x` + atribuição) | ✅ | Extra |
| 26 | Novas Operações (`**`, `%`, `sqrt`, `abs`, `min`, `max`) | ✅ | Extra |
| 27 | Controle de Laços `break all` / `continue all` | ✅ | Extra |
| 28 | Passagem de Parâmetros por Nome | ✅ | Extra |
| 29 | Constantes (`const`) | ✅ | Extra (não listado) |
| 30 | Variáveis Globais com `global let` | ✅ | Extra (não listado) |
| 31 | Shadowing de Variáveis | ✅ | Extra (não listado) |
| 32 | Funções com inferência de retorno | ✅ | Extra (não listado) |
| 33 | Verificação de bounds em vetores/matrizes | ✅ | Extra (não listado) |
| 34 | Case-insensitive keywords | ✅ | Extra (não listado) |
| 35 | Comentários de linha e bloco | ✅ | Extra (não listado) |
| 36 | Matrizes bidimensionais (Matrizes Regulares) | ✅ | Extra |
| 37 | Procedimento (funções `void`) | ✅ | Extra |

---

## ⭐ Diferenciais do Projeto

### 1. 🏷️ Sistema Duplo de Declaração (`let` + `const`)
FOCA oferece um sistema de declaração moderno inspirado em linguagens como JavaScript/Rust:
- **`let`** para variáveis mutáveis (com tipo explícito ou inferido)
- **`const`** para constantes imutáveis (com proteção semântica contra reatribuição)

```
let x = 42                // inferência: int
let y : float = 3.14      // explícito
let z                      // inferência adiada: tipo definido na 1ª atribuição
const PI = 3.14159         // constante: erro se tentar alterar
```
> **Diferencial:** a maioria dos compiladores educacionais só possui declaração explícita simples. FOCA combina três modos de declaração (`let` explícito, inferência e inferência adiada) com constantes.

---

### 2. 📏 Tipos Subfaixa com Validação em Runtime
FOCA permite definir tipos inteiros restritos a um intervalo, com verificação automática:

```
let idade : 0..150
let mes : 1..12 = 6
cin >> idade             // verifica automaticamente!
```
> **Diferencial:** implementação completa com validação em atribuição, `cin`, cast explícito e operadores compostos. Subfaixas são interoperáveis com `int`.

---

### 3. 🧮 Operações Matemáticas Avançadas
Além dos operadores padrão, FOCA inclui:
- **Exponenciação** (`**`) com precedência correta (right-associative)
- **Módulo** (`%`) para inteiros
- **Funções embutidas**: `sqrt()`, `abs()`, `min()`, `max()`

```
let r : float = 2 ** 10          // 1024.0
let resto : int = 17 % 5          // 2
let raiz : float = sqrt(144)      // 12.0
let menor : int = min(10, 20)     // 10
```

---

### 4. 🏷️ Passagem de Parâmetros por Nome
Permite chamar funções usando o **nome dos parâmetros**, independente da ordem:

```
func dividir(dividendo : float, divisor : float) : float {
    return dividendo / divisor
}

let r : float = dividir(divisor = 2.0, dividendo = 10.0)   // 5.0
```
> **Diferencial:** funcionalidade raramente implementada em compiladores educacionais. O compilador valida nomes, detecta duplicatas e proíbe mistura com argumentos posicionais.

---

### 5. 💥 Break All / Continue All
Controle avançado de laços aninhados que permite sair de **todos os laços** de uma vez:

```
for (let i : int = 0; i < 100; i++) {
    for (let j : int = 0; j < 100; j++) {
        if (condição) {
            break all       // sai de AMBOS os for
        }
    }
}
```
> **Diferencial:** o `break all` é uma extensão única. Implementado via pilha de labels, evita a necessidade de flags booleanas manuais para sair de laços aninhados.

---

### 6. 🛡️ Verificação de Limites em Vetores e Matrizes
Todo acesso a vetor/matriz é **verificado em tempo de execução**:

```
let v : int[5]
v[10] = 42    // ERRO: "Erro: indice fora dos limites do vetor v"

let m : int[3][3]
m[5][0] = 1   // ERRO: "Erro: indice fora dos limites da matriz m"
```
> **Diferencial:** muitas linguagens de baixo nível (como C) não fazem essa verificação. FOCA gera código de bounds checking no intermediário, semelhante a Java/Rust.

---

### 7. 🧠 Validação Semântica Abrangente
O compilador realiza mais de **30 tipos** de verificações semânticas:
- Verificação de todos os caminhos de retorno em funções
- Restrição de escopo (funções não veem variáveis locais do main)
- Proteção contra uso de variável `let x` antes da primeira atribuição
- Validação de `void` em expressões (`funcao_void() + 1` → erro)
- Validação de constantes em `cin`, `++`, `--` e operadores compostos
- Comentários de bloco não fechados detectados

---

### 8. 🔤 Keywords Case-Insensitive
Palavras-chave são case-insensitive, permitindo estilo flexível:

```
IF (x > 0) { ... }
if (x > 0) { ... }
If (x > 0) { ... }
// Todas válidas!
```

---

### 9. 📊 Matrizes Bidimensionais Completas
Suporte completo a matrizes 2D com:
- Declaração tipada: `let m : int[3][4]`
- Inicialização inline: `let m : int[2][2] = [[1, 0], [0, 1]]`
- Acesso indexado: `m[i][j]`
- Leitura/escrita: `cin >> m[i][j]`, `cout << m[i][j]`
- Verificação de dimensões na inicialização e de bounds no acesso

---

### 10. 🔧 Geração de Código Intermediário Compilável
O código intermediário gerado é **C++ válido e compilável**, incluindo:
- Runtime de I/O completo (com `read_string`, `read_int`, `read_float`, etc.)
- Validação de entrada do usuário em tempo de execução
- Gerenciamento de memória para strings (`malloc`/`free`)
- Forward declarations de funções
- Variáveis globais posicionadas corretamente

```bash
make run FILE=meu_programa.foca
# Compila FOCA → C++ → binário nativo e executa
```

---

## 🔤 Tipos de Dados Primitivos

FOCA suporta 5 tipos primitivos:

| Tipo | Descrição | Exemplo de Literal |
|---|---|---|
| `int` | Número inteiro | `42`, `0`, `-5` |
| `float` | Número de ponto flutuante | `3.14`, `.5`, `2.0` |
| `bool` | Valor lógico | `true`, `false` |
| `char` | Caractere único | `'a'`, `'Z'` |
| `string` | Cadeia de caracteres | `"hello world"` |

```
// Exemplos de uso
let idade : int = 25
let pi : float = 3.14
let ativo : bool = true
let inicial : char = 'M'
let nome : string = "FOCA"
```

---

## 📝 Declaração de Variáveis

FOCA suporta **três formas** de declaração com a palavra-chave `let`:

### Declaração Explícita (com tipo)
```
let x : int
let y : float = 3.14
let nome : string = "FOCA"
```

### Declaração com Inferência de Tipos
O tipo é inferido automaticamente a partir do valor atribuído:
```
let x = 42          // x será do tipo int
let pi = 3.14       // pi será do tipo float
let flag = true     // flag será do tipo bool
let msg = "hello"   // msg será do tipo string
```

Também é possível declarar sem tipo e sem valor — o tipo será inferido na **primeira atribuição** (inferência adiada):
```
let x               // x existe, mas ainda não tem tipo
x = 10              // tipo inferido como int a partir daqui
```

### Constantes
Variáveis imutáveis declaradas com `const`:
```
const PI = 3.14159
const MAX : int = 100
```
> Qualquer tentativa de reatribuir uma constante gera erro semântico.

---

## 🌐 Escopo

### Escopo Estático
FOCA utiliza escopo estático (léxico). Variáveis são resolvidas pela **estrutura do código**, não pela ordem de execução.

### Blocos
Blocos `{ }` criam novos escopos. Variáveis declaradas dentro de um bloco não são visíveis fora dele:
```
let x : int = 10
{
    let x : int = 20     // shadowing: este x é diferente do de fora
    cout << x            // imprime 20
}
cout << x                // imprime 10
```

### Escopo Global
Variáveis globais são declaradas com `global let` no nível mais externo:
```
global let contador : int = 0

func incrementar() {
    contador = contador + 1
}
```
> Variáveis globais são acessíveis dentro de funções. Variáveis locais do escopo principal NÃO são.

### Shadowing
Variáveis em escopos internos podem ter o mesmo nome de variáveis em escopos externos:
```
let x : int = 100
{
    let x : int = 200
    cout << x            // 200
}
cout << x                // 100
```

---

## ➕ Operadores

### Operadores Aritméticos
| Operador | Descrição | Exemplo |
|---|---|---|
| `+` | Adição / Concatenação | `a + b`, `"hi" + "!"` |
| `-` | Subtração | `a - b` |
| `*` | Multiplicação | `a * b` |
| `/` | Divisão | `a / b` |
| `**` | Exponenciação | `2 ** 10` |
| `%` | Módulo (resto) | `10 % 3` |

### Funções Matemáticas Embutidas
| Função | Descrição | Exemplo |
|---|---|---|
| `sqrt(x)` | Raiz quadrada | `sqrt(16)` → `4.0` |
| `abs(x)` | Valor absoluto | `abs(-5)` → `5` |
| `min(a, b)` | Mínimo entre dois valores | `min(3, 7)` → `3` |
| `max(a, b)` | Máximo entre dois valores | `max(3, 7)` → `7` |

### Operadores Relacionais (resultado `bool`)
| Operador | Descrição |
|---|---|
| `==` | Igual a |
| `!=` | Diferente de |
| `<` | Menor que |
| `>` | Maior que |
| `<=` | Menor ou igual |
| `>=` | Maior ou igual |

```
let resultado : bool = 5 > 3      // true
let igual : bool = "abc" == "abc"  // true (comparação de strings!)
```

### Operadores Lógicos (resultado `bool`)
| Operador | Descrição |
|---|---|
| `&&` | E lógico |
| `\|\|` | OU lógico |
| `!` | Negação |

```
let r : bool = true && !false    // true
let s : bool = false || true     // true
```

### Operadores Compostos
```
let x : int = 10
x += 5      // x = 15
x -= 3      // x = 12
x *= 2      // x = 24
x /= 4      // x = 6
```
> O operador `+=` também funciona com strings: `s += "world"`.

### Operadores Unários
```
let i : int = 0
i++          // pós-incremento
i--          // pós-decremento
++i          // pré-incremento
--i          // pré-decremento
let neg : int = -i    // negação unária
```

---

## 🔄 Conversão de Tipos

### Conversão Implícita
Ocorre automaticamente entre `int` e `float` em expressões mistas:
```
let i : int = 10
let f : float = 3.5
let resultado : float = i + f    // i é convertido para float automaticamente
```

Também ocorre de `char` para `string` em atribuições compatíveis:
```
let s : string = 'a'    // char é promovido para string
```

### Conversão Explícita (Cast)
```
let f : float = 3.7
let i : int = (int) f       // i = 3 (truncamento)

let x : int = 42
let y : float = (float) x   // y = 42.0
```

---

## 📊 Vetores e Matrizes

### Vetores (Arrays Unidimensionais)
```
// Declaração sem inicialização
let v : int[5]

// Declaração com inicialização
let w : float[3] = [1.0, 2.5, 3.7]

// Acesso e atribuição
v[0] = 10
v[2] = v[0] + 5
cout << v[2]

// Leitura de entrada para vetor
cin >> v[1]
```

### Matrizes (Arrays Bidimensionais)
```
// Declaração sem inicialização
let m : int[3][4]

// Declaração com inicialização
let identidade : int[2][2] = [[1, 0], [0, 1]]

// Acesso e atribuição
m[0][0] = 42
m[1][2] = m[0][0] * 2
cout << m[1][2]

// Leitura de entrada para matriz
cin >> m[0][1]
```

> **Verificação de Limites:** FOCA verifica automaticamente em tempo de execução se os índices estão dentro dos limites do vetor/matriz. Acesso fora dos limites gera erro com mensagem indicando qual vetor/matriz violou o limite.

---

## 🔀 Concatenação de Strings

O operador `+` realiza concatenação entre strings, chars e combinações:

```
let s1 : string = "hello"
let s2 : string = " world"
let s3 : string = s1 + s2        // "hello world"

let c : char = '!'
let s4 : string = s3 + c         // "hello world!"
let s5 : string = c + s3         // "!hello world"
let s6 : string = 'a' + 'b'     // "ab"

// Concatenação com operador composto
s1 += " mundo"
s1 += '!'
```

---

## 🔁 Comandos de Laço

### While
```
let i : int = 0
while (i < 10) {
    cout << i
    i++
}
```

### Do/While
```
let i : int = 0
do {
    cout << i
    i++
} while (i < 10)
```

### For
O `for` possui escopo próprio e aceita inicialização, condição e atualização:
```
for (let i : int = 0; i < 10; i++) {
    cout << i
}
```

Todas as partes do `for` são opcionais:
```
let i : int = 0
for (; i < 5; i++) {
    cout << i
}
```

### Controle de Laços: `break` e `continue`
```
let i : int = 0
while (true) {
    i++
    if (i == 3) {
        continue      // pula para a próxima iteração
    }
    if (i == 7) {
        break          // sai do laço
    }
}
```

### 🚀 Break All / Continue All (Funcionalidade Extra)
Permite sair de **todos os laços aninhados** de uma vez:
```
for (let i : int = 0; i < 10; i++) {
    for (let j : int = 0; j < 10; j++) {
        if (i + j == 15) {
            break all     // sai de TODOS os loops de uma vez
        }
    }
}
// Execução continua aqui
```

```
for (let i : int = 0; i < 10; i++) {
    while (true) {
        continue all   // volta para o início do for mais externo
    }
}
```

---

## 🔀 Comandos de Decisão

### If / If-Else
```
let x : int = 42

if (x > 0) {
    cout << "positivo"
}

if (x > 100) {
    cout << "grande"
} else {
    cout << "pequeno"
}
```
> A condição do `if` **deve ser do tipo `bool`**. Usar um `int` ou outro tipo gera erro semântico.

### Switch / Case / Default
```
let opcao : int = 2

switch (opcao) {
    case 1:
        cout << "um"
    case 2:
        cout << "dois"
    case 3:
        cout << "tres"
    default:
        cout << "outro"
}
```

O `switch` aceita tipos `int`, `char` e `string`:
```
let nome : string = "FOCA"
switch (nome) {
    case "FOCA":
        cout << "compilador"
    case "Java":
        cout << "linguagem"
    default:
        cout << "desconhecido"
}
```

> **Regras do switch:**
> - Cada `case` gera um `break` implícito (sem fall-through)
> - Tipos do `case` devem ser compatíveis com a expressão do `switch`
> - Máximo de **um** `default` por `switch`

---

## 📥📤 Entrada e Saída

### Entrada (`cin`)
```
let x : int
cin >> x

let nome : string
cin >> nome

let v : int[3]
cin >> v[0]

let m : float[2][2]
cin >> m[0][1]
```
> O `cin` lê valores tipados com validação. Entrada inválida (ex: texto onde espera-se `int`) gera erro em tempo de execução.

### Saída (`cout`)
```
let x : int = 42
cout << x
cout << "Hello World"
cout << 3 + 4
cout << x > 0           // imprime resultado de expressão bool
```

---

## 🧮 Subfaixa (Funcionalidade Extra)

FOCA suporta **tipos subfaixa**, que restringem um inteiro a um intervalo fixo:

```
let nota : 0..10 = 8          // nota só pode ser entre 0 e 10
let mes : 1..12 = 6           // mês entre 1 e 12
let dia : 1..31               // dia entre 1 e 31

cin >> nota                    // validação automática no cin
nota = 11                     // ERRO em tempo de execução!
```

> A verificação é feita em **tempo de execução**: se o valor atribuído estiver fora da faixa `[min..max]`, o programa aborta com mensagem de erro. Subfaixas são compatíveis com `int` em operações e atribuições.

Uso em cast:
```
let x : int = 5
let y : 0..10 = (0..10) x     // cast explícito para subfaixa
```

---

## 🔧 Funções

### Declaração e Definição
Funções são declaradas com a palavra-chave `func`:

```
func somar(a : int, b : int) : int {
    return a + b
}
```

### Função sem Retorno (Procedimento)
Se a função não tem `return`, ela é automaticamente do tipo `void`:
```
func imprimir(msg : string) {
    cout << msg
}
```

### Função com Tipo de Retorno Inferido
Se o tipo de retorno não for declarado, ele é inferido pelo primeiro `return`:
```
func dobro(x : int) {
    return x * 2         // tipo de retorno inferido como int
}
```

### Chamada de Funções
```
let resultado : int = somar(3, 4)
imprimir("Hello!")
```

### 🚀 Passagem de Parâmetros por Nome (Funcionalidade Extra)
Argumentos podem ser passados **por nome**, em qualquer ordem:
```
func criar_ponto(x : int, y : int) : int {
    return x + y
}

// Chamada por posição (tradicional)
let p1 : int = criar_ponto(10, 20)

// Chamada por nome (ordem livre)
let p2 : int = criar_ponto(y = 20, x = 10)
```

> **Restrição:** não é permitido misturar argumentos por posição e por nome na mesma chamada.

### Funções com Strings como Parâmetro
```
func cumprimentar(nome : string) {
    let msg : string = "Olá, " + nome + "!"
    cout << msg
}

cumprimentar("FOCA")
```

### Validação de Funções
O compilador verifica automaticamente:
- ✅ Número correto de argumentos
- ✅ Tipos dos argumentos compatíveis
- ✅ Todos os caminhos retornam valor (se a função tem retorno)
- ✅ Funções devem ser declaradas antes de serem chamadas
- ✅ Funções só podem ser declaradas no escopo global
- ✅ Não é possível declarar uma função dentro de outra

---

## 💬 Comentários

FOCA suporta dois tipos de comentários:

```
// Comentário de linha

/* Comentário
   de bloco
   multi-linha */
```

> Comentários de bloco não fechados geram erro de compilação.

---

## 🛡️ Detecção de Erros

FOCA detecta uma ampla variedade de erros semânticos com mensagens claras indicando a **linha do erro**:

| Categoria | Exemplos de Erros Detectados |
|---|---|
| **Declaração** | Variável não declarada, redeclaração no mesmo escopo |
| **Tipos** | Atribuição incompatível, operação entre tipos inválidos |
| **Escopo** | Uso de variável fora do escopo, acesso a variável local do main dentro de função |
| **Controle** | `break`/`continue` fora de laço, condição não-bool em `if`/`while`/`for` |
| **Switch** | Tipo de `case` incompatível, múltiplos `default`, `switch` com tipo não suportado |
| **Funções** | Número incorreto de argumentos, tipo de retorno inconsistente, caminhos sem `return` |
| **Vetores** | Índice fora dos limites (runtime), uso de vetor sem índice, tamanho ≤ 0 |
| **Matrizes** | Dimensões incompatíveis na inicialização, índices inválidos |
| **Constantes** | Tentativa de modificar uma constante |
| **Subfaixa** | Valor fora da faixa permitida (runtime) |
| **Sintaxe** | Caractere não reconhecido, comentário de bloco não fechado |

### Exemplo de Mensagem de Erro
```
Erro na linha 5: Variavel x nao foi declarada anteriormente
Erro na linha 8: A condição do 'if' deve ser do tipo bool
Erro na linha 12: nao eh possivel alterar a constante PI
Erro na linha 15: Erro: valor fora da subfaixa [0..10]
```

---

## 🧪 Exemplo Completo

Abaixo um programa FOCA que demonstra múltiplas funcionalidades:

```
// ==========================================
//  Programa exemplo: Calculadora com Funções
// ==========================================

global let operacoes : int = 0

/* Função que calcula a potência usando o operador ** */
func potencia(base : float, exp : float) : float {
    operacoes++
    return base ** exp
}

/* Procedimento que imprime um separador */
func separador() {
    cout << "----"
}

// Programa principal

let pi : float = 3.14159
const E : float = 2.71828

// Vetores e matrizes
let notas : float[3] = [8.5, 9.0, 7.5]
let identidade : int[2][2] = [[1, 0], [0, 1]]

// Laço for com vetor
let soma : float = 0.0
for (let i : int = 0; i < 3; i++) {
    soma += notas[i]
}

let media : float = soma / 3.0
cout << media

// Switch com strings
let tipo : string = "quadrado"
switch (tipo) {
    case "circulo":
        let area : float = pi * potencia(5.0, 2.0)
        cout << area
    case "quadrado":
        let area : float = potencia(5.0, 2.0)
        cout << area
    default:
        cout << "forma desconhecida"
}

// Subfaixa
let nota_final : 0..10 = (int) media

// While com break
let i : int = 0
while (true) {
    if (i > 100) {
        break
    }
    i++
}

// Inferência de tipos
let resultado = potencia(2.0, 10.0)
cout << resultado

// Passagem por nome
let r : float = potencia(exp = 3.0, base = 2.0)
cout << r

separador()
cout << operacoes
```

## 📁 Estrutura do Projeto

```
compilador/
├── lexico.l          # Analisador léxico (Flex)
├── sintatico.y       # Analisador sintático + semântico + geração de código (Bison)
├── Makefile           # Build system
├── exemplos/          # Programas de teste (.foca) e saídas esperadas (.expected)
│   ├── 01_soma.foca
│   ├── etapa2_*.foca
│   └── etapa2_err_*.foca    # Testes de detecção de erros
├── testar_etapa2.py   # Script de testes automatizados
└── README.md          # Este arquivo
```

---

## 🎓 Referências

- Materiais da disciplina: http://filipe.braida.com.br/pages/courses/compiladores/
- Vídeos de apoio:
  1. [Flex](https://youtu.be/c9WLbVZ5T3w)
  2. [Bison](https://youtu.be/ATW-mq0ahaA)
  3. [Código Intermediário](https://youtu.be/xLqb5RqXANQ)
  4. [Construção do Código](https://youtu.be/FmR3p1-tzoc)
