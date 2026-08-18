CC=cl65
CFLAGS=-c -t kim1
LIB_PATH=../lib

target = example.pap

default: all

all: $(target)

%.pap: %.bin
	srec_cat $< -binary -offset 0x200 -output $@ -MOS_Technologies

%.bin: %.o
	ld65 -L$(LIB_PATH) -o $@ -t kim1 -m $(basename $<).map $^ float.lib conio.lib kim1.lib

%.o: %.c
	$(CC) $(CFLAGS) -I$(LIB_PATH) -L$(LIB_PATH) $<

clean:
	@rm -f *.lst *.img *.com *.bin *.obj *.hex *.pap *.o *.map

.PHONY: clean
.PRECIOUS: %.pap %.s
