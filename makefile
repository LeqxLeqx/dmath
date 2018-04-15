#!/bin/bash

SOURCE_DIR=src
BIN_DIR=bin
FILE_NAMES=$(notdir $(wildcard $(SOURCE_DIR)/dmath/*.d))
OBJECT_FILES=$(addprefix $(BIN_DIR)/,$(FILE_NAMES:.d=.o))
DFLAGS=-g -fPIC
DCC=gdc
CC=gcc

OUTPUT=$(BIN_DIR)/libdmath.so

all : bin $(OBJECT_FILES)
	$(CC) $(OBJECT_FILES) $(DFLAGS) -shared -o $(OUTPUT)

bin/%.o : $(SOURCE_DIR)/dmath/%.d $(BIN_DIR)
	$(DCC) $(DFLAGS) $< -o $@ -c -I $(SOURCE_DIR)

$(BIN_DIR) :
	mkdir $(BIN_DIR)

clean :
	rm -rf $(BIN_DIR) 


