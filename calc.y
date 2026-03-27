%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void yyerror(const char *msg);
int yylex(void);

typedef struct ASTNode {
    char label[32];
    double value;           /* Store the numerical result here */
    struct ASTNode* left;
    struct ASTNode* mid;
    struct ASTNode* right;
} ASTNode;

/* Updated helper to include the 'val' result of the operation */
ASTNode* make_node(const char* label, double val, ASTNode* left, ASTNode* mid, ASTNode* right) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    strcpy(node->label, label);
    node->value = val;
    node->left = left;
    node->mid = mid;
    node->right = right;
    return node;
}

ASTNode* make_leaf(const char* label, double val) {
    return make_node(label, val, NULL, NULL, NULL);
}

void indent(int d) {
    for(int i = 0; i < d * 2; i++) printf(" ");
}

void print_tree(ASTNode* node, int depth) {
    if (!node) return;
    indent(depth);
    printf("%s\n", node->label);
    print_tree(node->left, depth + 1);
    print_tree(node->mid, depth + 1);
    print_tree(node->right, depth + 1);
}
%}

%union {
    int ival;
    double fval;
    struct ASTNode* node;
}

%token <ival> NUM
%token <fval> FNUM
%token PLUS MINUS TIMES DIVIDE CARET LPAREN RPAREN
%left PLUS MINUS
%left TIMES DIVIDE
%right CARET
%right UMINUS

%type <node> expr term factor

%%

program:
    expr { 
        printf("--- Parse Tree ---\n");
        print_tree($1, 0); 
        printf("\nOutput: %.2f\n", $1->value);
    }
    ;

expr:
    expr PLUS term { $$ = make_node("expr", $1->value + $3->value, $1, make_leaf("+", 0), $3); }
  | expr MINUS term { $$ = make_node("expr", $1->value - $3->value, $1, make_leaf("-", 0), $3); }
  | term { $$ = make_node("expr", $1->value, $1, NULL, NULL); }
    ;

term:
    term TIMES factor { $$ = make_node("term", $1->value * $3->value, $1, make_leaf("*", 0), $3); }
  | term DIVIDE factor { $$ = make_node("term", $1->value / $3->value, $1, make_leaf("/", 0), $3); }
  | factor { $$ = make_node("term", $1->value, $1, NULL, NULL); }
    ;

factor:
    NUM { 
        char buf[32]; sprintf(buf, "%d", $1);
        $$ = make_node("factor", (double)$1, make_leaf(buf, $1), NULL, NULL); 
    }
  | FNUM {
        char buf[32]; sprintf(buf, "%.2f", $1);
        $$ = make_node("factor", $1, make_leaf(buf, $1), NULL, NULL);
    }
  | factor CARET factor { 
        double res = pow($1->value, $3->value);
        $$ = make_node("factor", res, $1, make_leaf("^", 0), $3); 
    }
  | LPAREN expr RPAREN { $$ = make_node("factor", $2->value, make_leaf("(", 0), $2, make_leaf(")", 0)); }
  | MINUS factor %prec UMINUS { $$ = make_node("factor", -$2->value, make_leaf("-", 0), $2, NULL); }
    ;

%%

void yyerror(const char *msg) {
    fprintf(stderr, "Parse error: %s\n", msg);
}

int main(void) {
    return yyparse();
}