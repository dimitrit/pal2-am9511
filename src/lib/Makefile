AS=ca65
AR=ar65
CC=cl65

target = float.lib am9511.lib conio.lib

default: all

all: $(target)

am9511.lib: float.o am9511.o am9511fn.o
conio.lib: conio.o

float.o: float.s float.h
conio.o: conio.s
am9511.o: am9511.s
am9511fn.o: am9511fn.c

%.lib: %.o
	$(AR) a $@ $?

%.o: %c
	$(CC) -c -t kim1 $<

%.o: %s
	$(AS) -l $(basename $<).lst $<

clean:
	@rm -f *.lst *.lib *.o

.PHONY: clean
.PRECIOUS: %.lib
