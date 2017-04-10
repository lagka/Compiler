%{#include<stdio.h>
#include<string.h>

int num_lines=0;
int num_chars = 0;
char buffer[2048];
char buffer2[2048];
int ps=1,pt=1;
int line=1;
int end=1;
%}

KEY "int"|"void"|"double"|"bool"|"char"|"null"|"for"|"while"|"do"|"if"|"else"|"switch"|"return"|"break"|"continue"|"const"|"true"|"false"|"struct"|"case"|"default"|"fclose"|"clearerr"|"feof"|"ferror"|"fflush"|"fgetpos"|"fopen"|"fread"|"freopen"|"FILE"|"fseek"|"fsetpos"|"long"|"ftell"|"fwrite"|"remove"|"rename"|"rewind"|"setbuff"|"setvbuff"|"tmpfile"|"tmpnam"|"fprintf"|"printf"|"sprintf"|"vfprintf"|"vprintf"|"vsprintf"|"fscanf"|"scanf"|"sscanf"|"fgetc"|"fgets"|"fputc"|"fputs"|"getc"|"getchar"|"putc"|"gets"|"putchar"|"puts"|"ungetc"|"perror"
OP "+"|"-"|"*"|"/"|"%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"
Identifier ([a-zA-Z_][A-Za-z0-9_]*)
CHAR (\'([^\'\n\\]|(\\n)|(\\t)|(\\\\))\')
DOUBLE ([0-9]+"."[0-9]*)|([0-9]*"."[0-9]+)
PUNC ":"|";"|","|"."|"("|")"|"["|"]"|"{"|"}"
INT ([1-9][0-9]*)|[0]
INTE ([0]+{INT})
NONZERO ([1-9])
ZERO ([0])
SCIENTIC ({DOUBLE}|{INT}|[0]+)[Ee][+-]?({INT}|[0+])
STRING \"[^\n"]+\"
ws [ \t]+
%x COMMENT_S
%x COMMENT_L
%x PRAGMA


%%
"/*"	{strcat(buffer,yytext);BEGIN COMMENT_S;}
"#"		{BEGIN PRAGMA;}
"//"	{BEGIN COMMENT_L;}
{KEY}	{if(pt==1){printf("#key:%s\n",yytext);}strcat(buffer,yytext);}			
{OP} 	{if(pt==1){printf("#op:%s\n",yytext);}strcat(buffer,yytext);}
{Identifier}	{if(pt==1){printf("#id:%s\n",yytext);}strcat(buffer,yytext);}
{CHAR}	{if(pt==1){printf("#char:%s\n",yytext);}strcat(buffer,yytext);}
{DOUBLE}	{if(pt==1){printf("#double:%s\n",yytext);}strcat(buffer,yytext);}
{PUNC}	{if(pt==1){printf("#punc:%s\n",yytext);}strcat(buffer,yytext);}
{INT}	{if(pt==1){printf("#integer:%s\n",yytext);}strcat(buffer,yytext);}
{SCIENTIC}	{if(pt==1){printf("#sci:%s\n",yytext);}strcat(buffer,yytext);}
{STRING}	{	strcat(buffer,yytext);
				if(pt==1){		
				strncpy(buffer2,++yytext,strlen(yytext)-2);
				printf("#string:%s\n",buffer2);
				memset(buffer2,'\0',2048);
				}
				
			}
{ws}		{strcat(buffer,yytext);}
"\n"		{	
				if(ps==1&&end==1)
				{
				printf("%d:%s\n",line,buffer);
				}
				if(end==1)line++;
				if(end==0){
					end=1;
				}
				
				memset(buffer,'\0',2048);
			}
<COMMENT_S>.		{strcat(buffer,yytext);}
<COMMENT_S>\n 		{printf("%d:%s\n",line,buffer);memset(buffer,'\0',2048);line++;}
<COMMENT_S>"*/"	{if(ps==1)printf("%d:%s*/\n",line,buffer);line++;memset(buffer,'\0',2048);end=0;BEGIN 0;}
<COMMENT_L>.		{strcat(buffer,yytext);}
<COMMENT_L>\n {BEGIN 0; if(ps==1)printf("%d://%s\n",line,buffer);line++;memset(buffer,'\0',2048);}
<PRAGMA>{ws}	{strcat(buffer2,yytext);}
<PRAGMA>.	{strcat(buffer,yytext);strcat(buffer2,yytext);}
<PRAGMA>"\n"	{
					if(strcmp(buffer,"pragmasourceon")==0){ps=1;
						printf("%d:#%s\n",line,buffer2);
						memset(buffer2,'\0',2048);
					}
					else if(strcmp(buffer,"pragmasourceoff")==0){ps=0;
						memset(buffer2,'\0',2048);
					}
					else if(strcmp(buffer,"pragmatokenon")==0){pt=1;
						printf("%d:#%s\n",line,buffer2);
						memset(buffer2,'\0',2048);
					}
					else if(strcmp(buffer,"pragmatokenoff")==0){pt=0;
						printf("%d:#%s\n",line,buffer2);
						memset(buffer2,'\0',2048);
					}
					else{
						line++;
						fprintf(stderr,"Error at line %d:%s\n",line,buffer2);
						exit(1);
					}
					memset(buffer,'\0',2048);
					line++;
					BEGIN 0;
				}
{INTE}		{fprintf(stderr,"Error at line %d:%s\n",line,yytext);exit(1);}
.  {fprintf(stderr,"Error at line %d:%s\n",line,yytext);exit(1);}
%%

int main(int argc,char * argv[]){
	++argv;
	--argc;
	if(0<argc){
		yyin=fopen(argv[0],"r");
	}else{
		yyin=stdin;
	}
	
	yylex();
	
	
	return 0;
	
}



