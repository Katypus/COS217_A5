CFLAGS = -D NDEBUG -O -g

# Dependency rules for non-file targets
all: fib fibs
clobber: clean
	rm -f *~ \#*\#
clean:
	rm -f fib *.o
	rm -f fibs *.o

# FIB
# Dependency rules for file targets
fibs: fib.o bigint.o bigintaddopt.s
	gcc217 $(CFLAGS) fib.c bigint.c bigintaddopt.s -o fibs
fib: bigint.o fib.o bigintadd.o
	gcc217 bigint.o fib.o bigintadd.o -o fib
bigint.o: bigint.h bigint.c bigintprivate.h
	gcc217 $(CFLAGS) -c bigint.c
fib.o: fib.c bigint.h bigintprivate.h
	gcc217 $(CFLAGS) -c fib.c
bigintadd.o: bigint.h bigintadd.c bigintprivate.h
	gcc217 $(CFLAGS) -c bigintadd.c
