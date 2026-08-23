AS=ca65
AR=ar65
CC=cl65
ASFLAGS=-l$(basename $<).lst

target = float.lib am9511.lib conio.lib

default: all

all: $(target)

am9511.lib: float.o am9511.o am9511fn.o
conio.lib: conio.o

float.o: float.s float.h
conio.o: conio.s
am9511.o: am9511.s am9511.inc
am9511fn.o: am9511fn.c am9511.h

%.lib: %.o
	$(AR) a $@ $?

%.o: %c
	$(CC) -c -t kim1 $<

clean:
	@rm -f *.lst *.lib *.o

.PHONY: clean
.PRECIOUS: %.lib
