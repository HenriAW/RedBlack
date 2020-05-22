#! /bin/bash

cd ./src
as int_to_ascii.s -o int_to_ascii.o
as linux.s -o linux.o
as red_black.s -o red_black.o
ld int_to_ascii.o linux.o red_black.o -o ../red_black
