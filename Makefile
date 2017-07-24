# Makefile for Nean der taler, gmake syntax
# Shouldn't be too hard to change for your platform
#
# -Marq 2001

# Platform (LINUX/IRIX)
SHELL = /bin/sh
PLATFORM = LINUX
# YES for sound, NO or whatever for no sound
SOUND = YES
# YES for a crappy old version, something else for >=3.7
OLDGLUT = NO

# General defines
CC = g++
CXXFLAGS += -O3 -flto -Wall -ffast-math -pipe $(shell pkgconf --cflags glu) -std=gnu++98 -fabi-version=2
DEF = 
GL = -lglut $(shell pkgconf --libs glu)
LDFLAGS += -lm
RM_F = rm -f

INSTALL = install
INSTALL_DIR     = $(INSTALL) -p -d -o root -g root  -m  755
INSTALL_PROGRAM = $(INSTALL) -p    -o root -g root  -m  755
INSTALL_FILE    = $(INSTALL) -p    -o root -g root  -m  644

TARGET          = neandertaler

PREFIX          = /usr
BINDIR          = $(PREFIX)/bin
SHAREDIR        = $(PREFIX)/share
TARGETSHAREDIR  = $(PREFIX)/share/neandertaler/data

export

# Linux (or XFree) specific
ifeq ($(PLATFORM),LINUX)
	X = $(shell pkgconf x11 xext xmu xi --libs)
	LIBS += -ldl
	DEF += -DBSDENV
	ifneq (,$(filter parallel=%,$(DEB_BUILD_OPTIONS)))
		NUMJOBS = $(patsubst parallel=%,%,$(filter parallel=%,$(DEB_BUILD_OPTIONS)))
		MAKEFLAGS += -j$(NUMJOBS)
	endif
endif

# If sound enabled
ifeq ($(SOUND),YES)
DEF += -DSOUND
LDFLAGS += $(shell pkgconf SDL_mixer --libs)
CXXFLAGS += $(shell pkgconf SDL_mixer --cflags)
endif

# If old GLUT version
ifeq ($(OLDGLUT),YES)
DEF += -DOLDGLUT
endif

all: $(TARGET)

$(TARGET): neandertaler_mainloop.o main.cc
	$(CC) $(CXXFLAGS) main.cc neandertaler_mainloop.o -o $(TARGET) $(DEF) $(GL) $(X) $(LDFLAGS)

neandertaler_mainloop.o: neandertaler_mainloop.cc
	$(CC) $(CXXFLAGS) -c neandertaler_mainloop.cc $(DEF)

clean: 
	-$(RM_F) $(TARGET) *.o

install: $(TARGET)
	$(INSTALL_DIR) $(DESTDIR)$(BINDIR)
	-@$(RM_F) $(DESTDIR)$(BINDIR)/$(TARGET)
	$(INSTALL_PROGRAM) $(TARGET) $(DESTDIR)$(BINDIR)
	$(INSTALL_DIR) $(DESTDIR)$(TARGETSHAREDIR)
	$(INSTALL_FILE) data/* $(DESTDIR)$(TARGETSHAREDIR)

uninstall:
	-$(RM_F) $(DESTDIR)$(BINDIR)/$(TARGET)
