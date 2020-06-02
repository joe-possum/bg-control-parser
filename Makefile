a.exe : lex.yy.c y.tab.c main.c
	gcc -Wall lex.yy.c y.tab.c main.c

lex.yy.c : scanner.ll y.tab.h
	flex $^

y.tab.c y.tab.h : parser.y
	bison -yt --defines $^
