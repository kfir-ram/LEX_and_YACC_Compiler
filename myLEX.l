 //this file was made by:
 //Kfir Rahamim 203426721
 //Hen Dahan 
 //Bar

%%
"function"	{return FUNCTION;}
"void"		{return VOID;}
"if"		{return IF;}
"else"		{return ELSE;}
"int"		{return INT;}
"char"		{return CHAR;}			
"real"		{return REAL;}
"string"	{return STRING;}
"bool"		{return BOOL;}
"="			{return EQUAL;}
"+"			{return PLUS;}
"-"			{return MINUS;}
"*"			{return MULTIPLY;}
"/"			{return DIVIDED;}
"=="		{return EQUALIVATION;}
"!="		{return NOTEQUAL;}
"++"		{return PLUSONE;}
"--"		{return MINUSONE;}
"!"			{return NOT;}
"&&"		{return AND;}
"||"		{return OR;}
"return"	{return RETURN;}
"true"		{return TRUE;}
"false"		{return FALSE;}
"null"		{return NULL;}
"{"			{return LCB;}
"}"			{return RCB;}
"("			{return LP;}
")"			{return RP;}
","			{return COMMA;}
[0-9]+		{yylval=atoi(yytext);return NUM;}
[a-z]+		{return ID;}



[ \t\n]			;//ignores tab and spaces.
.				return yytext[0];
%%