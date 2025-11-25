import sys
import os
import ply.lex as lex
import ply.yacc as yacc

P_MOD = 1234577

def ipow(base, exp):
    if exp < 0:
        exp = (P_MOD - 1 + exp) % P_MOD  
    result = 1
    b = base % P_MOD
    while exp > 0:
        if exp % 2 == 1:
            result = (result * b) % P_MOD
        b = (b * b) % P_MOD
        exp //= 2
    return result

def yyerror(msg):
    # Udaje naszą funkcję yyerror w Bisonie
    print(f"[ERROR]: {msg}\n")

# --- Lexer ---
tokens = (
    'NUMBER',
    'PLUS', 'MINUS', 'TIMES', 'DIV', 'POW',
    'LPAREN', 'RPAREN',
    'POWER_ERROR', 
)

t_PLUS   = r'\+'
t_MINUS  = r'-'
t_TIMES  = r'\*'
t_DIV    = r'/'
t_POW    = r'\^'
t_LPAREN = r'\('
t_RPAREN = r'\)'

t_ignore = ' \t'

def t_NUMBER(t):
    r'\d+'
    t.value = int(t.value)
    return t

# linie zaczynające się od # to komentarze 
def t_COMMENT(t):
    r'\#[^\n]*'
    pass

def t_newline(t):
    r'\n+'
    t.lexer.lineno += len(t.value)

def t_error(t):
    t.lexer.skip(1)

lexer = lex.lex()

# --- Precedence ---
precedence = (
    ('right', 'NEGPOV'),
    ('left',  'PLUS', 'MINUS'),
    ('right', 'UMINUS'),
    ('left',  'TIMES', 'DIV'),
    ('left',  'POW'),
)

# --- Parser ---
# Each expr node returns a tuple (val, rpn)
def p_input_line_expr(p):
    'line : expr'
    p[0] = p[1]

def p_input_error_nop(p):
    'line : '
    p[0] = None

def p_expr_number(p):
    'expr : NUMBER'
    val = p[1] % P_MOD
    p[0] = (val, str(val))

def p_expr_power_error(p):
    'expr : POWER_ERROR'
    yyerror("Invalid powers")
    # Force a parse error path
    raise SyntaxError("Invalid powers")

def p_expr_plus(p):
    'expr : expr PLUS expr'
    val = (p[1][0] + p[3][0]) % P_MOD
    rpn = f"{p[1][1]} {p[3][1]} +"
    p[0] = (val, rpn)

def p_expr_times(p):
    'expr : expr TIMES expr'
    val = (p[1][0] * p[3][0]) % P_MOD
    rpn = f"{p[1][1]} {p[3][1]} *"
    p[0] = (val, rpn)

def p_expr_group(p):
    'expr : LPAREN expr RPAREN'
    p[0] = p[2]

def p_expr_minus(p):
    'expr : expr MINUS expr'
    val = (((p[1][0] - p[3][0]) % P_MOD) + P_MOD) % P_MOD
    rpn = f"{p[1][1]} {p[3][1]} -"
    p[0] = (val, rpn)

def p_expr_pow(p):
    'expr : expr POW expr'
    val = ipow(p[1][0], p[3][0])
    rpn = f"{p[1][1]} {p[3][1]} ^"
    p[0] = (val, rpn)

def p_expr_pow_neg(p):
    'expr : expr POW MINUS expr %prec NEGPOV'
    # Compute with negative exponent
    val = ipow(p[1][0], -p[4][0])

    # Print RPN exponent transformed to the equivalent positive exponent modulo (p-1)
    # Expected behavior: 2^-2 -> "2 1234574 ^"
    (P_MOD - 1 - p[4][0]) % P_MOD
    negexp = (P_MOD - 1 - p[4][0]) % P_MOD
    rpn = f"{p[1][1]} {negexp} ^"
    p[0] = (val, rpn)

def p_expr_uminus(p):
    'expr : MINUS expr %prec UMINUS'
    val = (-p[2][0] + P_MOD) % P_MOD
    rpn = str(val)
    p[0] = (val, rpn)

def p_expr_div(p):
    'expr : expr DIV expr'
    if p[3][0] == 0:
        yyerror("Division by zero")
        raise SyntaxError("Division by zero")
    inv = ipow(p[3][0], P_MOD - 2)
    val = (p[1][0] * inv) % P_MOD
    rpn = f"{p[1][1]} {p[3][1]} /"
    p[0] = (val, rpn)

def p_error(tok):
    print("ERROR.\n")

parser = yacc.yacc(start='line')

def main():
    filename="./../ex1/exercise.txt"
    if not os.path.exists(filename):
        print(f"[ERROR] Can't open {filename}")
        return 1

    combined_line = ""

    with open(filename, "r") as fp:
        for raw_line in fp:
            line = raw_line.rstrip("\n")

            # pomiń komentarze
            if line.startswith("#"):
                print(line)
                continue

            # sprawdź czy linia kończy się na backslash
            if line.endswith("\\"):
                combined_line += line[:-1]
                continue
            else:
                combined_line += line
                print(combined_line)

            # mamy pełne wyrażenie
            if combined_line.strip():
                try:
                    result = parser.parse(combined_line, lexer=lexer)
                    if result:
                        val, rpn = result
                        print(rpn)
                        print(f"= {val}\n")
                except SyntaxError:
                    # błędy już obsłużone w p_error/yyerror
                    pass

            # wyczyść bufor
            combined_line = ""

    return 0

if __name__ == "__main__":
    main() 