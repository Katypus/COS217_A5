# Dependency rules for non-file targets
all: fib
clobber: clean
	rm -f *~ \#*\#
clean:
	rm -f fib *.o

# FIB
# Dependency rules for file targets
fib: bigint.o fib.o bigintadd.o
	gcc217 -g bigint.o fib.o -o fib
bigint.o: bigint.h bigint.c bigintprivate.h
	gcc217 -g -c bigint.c
fib.o: fib.c bigint.h bigintprivate.h bigint
	gcc217 -g -c symtablelist.c
bigintadd.o: bigint.h bigintadd.c bigintprivate.h
	gcc217 -g -c bigintadd.c