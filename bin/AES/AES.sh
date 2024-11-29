#!/bin/bash
gcc -O0 -g AES.c -lmcrypt -I./usr/include/ -lssl -lcrypto -lpthread -o a.out && ./a.out
javac AES.java && java AES
