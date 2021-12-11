VPATH = $(shell which v)

all:
	@echo "Wrong usage: `make (prod|dev|clean)`"

prod: clean
	@$(VPATH) fmt -w .
	@$(VPATH) -cc gcc -o motor -prod -cg -enable-globals .
	@./motor

dev:
	@$(VPATH) fmt -w .
	@$(VPATH) -cg -keepc -enable-globals run .

clean:
	@rm -rf motor *.log Motor


