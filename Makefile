CC=sdcc
AS8051=sdas8051
INCLUDES=../fx2lib/include
FX2LIBDIR=../fx2lib
BASENAME = fx2_usb_i2s
SOURCES=fx2_usb_i2s.c
A51_SOURCES=dscr.a51
PID=0x0
VID=0x0
CODE_LOC=--code-loc 0x0000
CODE_SIZE=--code-size 0x2000
XRAM_SIZE=--xram-size 0x2000
XRAM_LOC=--xram-loc 0x2000
BUILDDIR=build
DSCR_AREA=-Wl"-b DSCR_AREA=0x1800"
INT2JT=-Wl"-b INT2JT=0x3f00"

RELS=$(addprefix $(BUILDDIR)/, $(addsuffix .rel, $(notdir $(basename $(SOURCES) $(A51_SOURCES)))))

LINKFLAGS=$(CODE_LOC) \
	$(CODE_SIZE) \
	$(XRAM_SIZE) \
	$(XRAM_LOC) \
	$(DSCR_AREA) \
	$(INT2JT)


.PHONY: all ihx iic bix load clean clean-all

all: ihx
ihx: $(BUILDDIR)/$(BASENAME).ihx
bix: $(BUILDDIR)/$(BASENAME).bix
iic: $(BUILDDIR)/$(BASENAME).iic

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/$(BASENAME).ihx: $(BUILDDIR) $(RELS) $(FX2LIBDIR)/lib/fx2.lib $(DEPS)
	$(CC) -mmcs51 $(SDCCFLAGS) -o $@ $(RELS) fx2.lib $(LINKFLAGS) -L $(FX2LIBDIR)/lib $(LIBS)

%.rel: ../%.c
	$(CC) -mmcs51 $(SDCCFLAGS) -c -o $@ -I $(FX2LIBDIR)/include -I $(INCLUDES) $<

%.rel: ../%.a51
	$(AS8051) -plosgff $@ $<

$(BUILDDIR)/$(BASENAME).bix: $(BUILDDIR)/$(BASENAME).ihx
	objcopy -I ihex -O binary $< $@
$(BUILDDIR)/$(BASENAME).iic: $(BUILDDIR)/$(BASENAME).ihx
	$(FX2LIBDIR)/utils/ihx2iic.py -v $(VID) -p $(PID) $< $@

load: $(BUILDDIR)/$(BASENAME).bix
	fx2load -v $(VID) -p $(PID) $(BUILDDIR)/$(BASENAME).bix
clean:
	rm -f $(foreach ext, a51 asm ihx lnk lk lst map mem rel rst rest sym adb cdb bix iic, $(BUILDDIR)/*.${ext})
