CC=./wrapmsvc.exe
CXX=g++
CFLAGS= /MT -g /Fdcsubst.pdb
CXXFLAGS=-s -Os
EXCECUTABLES=wrapmsvc.exe csubst.exe

.PHONY: all

all: $(EXCECUTABLES)

clean:
	rm -f *~ *.obj *.pdb *.ilk

distclean: clean
	rm -f $(EXCECUTABLES)

%.exe: %.c
	$(CC) $(CFLAGS) -o $@ $<

%.exe: %.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<
