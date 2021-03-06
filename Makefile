parser.exe : lex.yy.c parser.tab.c parser.tab.h main.c parser-data.c
	gcc -Wall lex.yy.c parser.tab.c parser-data.c main.c -o $@ -lm

lex.yy.c : scanner.l parser.tab.h
	flex --header-file=scanner.h $^

parser.tab.c parser.tab.h : parser.y
	bison --defines -g -t $^

clean :
	rm -f lex.yy.c parser.tab.[ch] parser.exe
