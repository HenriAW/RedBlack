#!/usr/bin/env bash

cd ./src
gcc \
  -O3 -march=native -mfpmath=sse -msse2 \
  -c int_to_ascii.s -o int_to_ascii.o
gcc \
  -O3 -march=native -mfpmath=sse -msse2 \
  -c linux.s -o linux.o
gcc \
  -O3 -march=native -mfpmath=sse -msse2 \
  -c next_number.s -o next_number.o
ld int_to_ascii.o linux.o next_number.o -o ../next_number

cd - > /dev/null

# Run programme with output converted to binary
#result="$(./next_number | tr -d '\0')" > /dev/null
#echo "obase=2;${result}" | bc

# perf
#perf record -g ./next_number
#perf report --call-graph

time ./next_number
