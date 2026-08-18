AS=ca65
AR=ar65

target = float.lib conio.lib

default: all

all: $(target)

float.lib: float.o
conio.lib: conio.o

float.o: float.s float.h
conio.o: conio.s

%.lib: %.o
	$(AR) a $@ $<

%.o: %.s
	$(AS) -l $(basename $<).lst $<
clean:
	@rm -f *.lst *.lib *.o

.PHONY: clean
.PRECIOUS: %.lib
