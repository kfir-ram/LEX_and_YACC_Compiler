#!/bin/bash

lex myLEX.l
yacc -v myYACC.y
cc -o comp.out y.tab.c -ll -Ly
./comp.out < myTEXT.t
