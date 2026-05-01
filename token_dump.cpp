#define main oldmain
#include "y.tab.c"
#undef main
#include <iostream>
int main(){
    int tok;
    while((tok = yylex()) != 0){
        std::cout << tok;
        if (tok < 256 && tok > 0) std::cout << "('" << char(tok) << "')";
        if (!yylval.label.empty()) std::cout << " [" << yylval.label << "]";
        std::cout << "\n";
    }
    return 0;
}
