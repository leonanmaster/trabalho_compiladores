#define YYDEBUG 1
#define main oldmain
#include "y.tab.c"
#undef main
#include <iostream>
extern int yydebug;
int main(){
    yydebug = 1;
    return yyparse();
}
