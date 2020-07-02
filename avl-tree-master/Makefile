.PHONY: default all clean distclean

CXX=c++
CXXFLAGS=-O3 -Wall -std=c++11

PROGRAMS=example

default: example
all: $(PROGRAMS)

example-base: example.cpp container.hpp avltree.hpp
	$(CXX) $(CXXFLAGS) -o $@ $<

clean:
	$(RM) *.o *~

distclean: clean
	$(RM) $(PROGRAMS)
