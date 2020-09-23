
ifeq ($(OS),Windows_NT)
	DLL_EXT := .dll
else
	DLL_EXT := .so
endif

CC 		= gcc
CFLAGS 	= -fPIC -O3 -I./src
RM		= rm -f

default:	gnuplot_i.o

shared:	libgnuplot_i$(DLL_EXT)

libgnuplot_i$(DLL_EXT):	gnuplot_i.o
	$(CC) $(CFLAGS) -shared -o libgnuplot_i$(DLL_EXT) src/gnuplot_i.c

gnuplot_i.o:	src/gnuplot_i.c src/gnuplot_i.h
	$(CC) $(CFLAGS) -c -o gnuplot_i.o src/gnuplot_i.c

tests:	test/anim test/example test/sinepng

test/anim:	test/anim.c gnuplot_i.o
	$(CC) $(CFLAGS) -o test/anim test/anim.c gnuplot_i.o

test/example:	test/example.c gnuplot_i.o
	$(CC) $(CFLAGS) -o test/example test/example.c gnuplot_i.o

test/sinepng:	test/sinepng.c gnuplot_i.o
	$(CC) $(CFLAGS) -o test/sinepng test/sinepng.c gnuplot_i.o

clean:
	$(RM) libgnuplot_i$(DLL_EXT) gnuplot_i.o test/anim test/example test/sinepng

