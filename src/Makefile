AS=ca65
LD=ld65
CFLAGS=-c -t kim1
LIB_PATH=lib

target = example.pap

default: all

all: $(target)

%.pap: %.bin
	srec_cat $< -binary -offset 0x200 -output $@ -MOS_Technologies

%.bin: %.o
	$(LD) -L$(LIB_PATH) -o $@ -C pal2.cfg -m $(basename $<).map  $^

%.o: %.s
	$(AS) -l $(basename $<).lst $<

clean:
	@rm -f *.lst *.img *.com *.bin *.obj *.hex *.pap *.o

.PHONY: clean
.PRECIOUS: %.pap
