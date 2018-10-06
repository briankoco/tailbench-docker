#!/bin/bash

#run on mad6
./autogen.sh
./configure --enable-shore6 --enable-dbgsymbols SHORE_HOME=../shore-mt/ CXXFLAGS="-I /usr/lib64/glib-2.0/include"
make -j32
