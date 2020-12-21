/*Kfir Rahamim 203426721
Hen Dahan 312585953 
Bar Piglanski 204590384*/
%option yylineno
%%
"/*"([^*]|\*+[^*/])*\*+"/"                      ;         
"function"                                      { return FUNC;}
"bool"                                          { return BOOL;}
"null"                                          { return NULL_E;}
"void"                                          { return VOID_T;}
"if"                                            { return IF;}
"else"                                          { return ELSE;}
"while"                                         { return WHILE;}
"for"                                           { return FOR;}
"do"                                            { return DO;}
"var"                                           { return VAR;}
"return"                                        { return RETURN;}
"int"                                           { return INT;}
"real"                                          { return REAL;}
"char"                                          { return CHAR;}
"int\*"                                         { return INT_P;}
"real\*"                                        { return REAL_P;}
"char\*"                                        { return CHAR_P;}
"string"                                        { return STRING_T;}
"true"                                          { return BOOL_TRUE;}
"false"                                         { return BOOL_FALSE;}
"&&"                                            { return AND;}
"||"                                            { return OR;}
"!"                                             { return NOT;}
"&"                                             { return ADDRESS;}
"|"                                             { return LENGTH;}
"+"                                             { return PLUS;}
"-"                                             { return MINUS;}
"*"                                             { return MULTIPLY;}
"/"                                             { return DIVIDE;}
"=="                                            { return EQUAL;}
"="                                             { return ASSIGN;}
"!="                                            { return NOT_EQUAL;}
">"                                             { return GT;}
"<"                                             { return LT;}
">="                                            { return GTE;}
"<="                                            { return LTE;}
[ ]                                             ;
\t                                              ;
\n                                              ;
\'.\'                                           { return CHARACTER;}
\"[^"]*\"                                       { return STRING;}
    /* Tokens */
(0|([-])?([1-9]+[0-9]*))|(0[xX][0-9A-F]+)       { return INTEGER;}
[a-zA-Z][a-zA-Z0-9_]*                           { return ID;}
[+-]?([1-9][0-9]*)?\.[0-9]+([eE][+-]?[1-9][0-9]*)?|[+-]?([1-9][0-9]*)?\.[0-9]*([eE][+-]?[1-9][0-9]*)|[+-]?[1-9][0-9]*([eE][+-]?[1-9][0-9]*)|0\.0 {return DOUBLE;}
.                                               { return yytext[0];}
%%