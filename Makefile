CFLAGS = -D NDEBUG -O

# Dependency rules for non-file targets
all: fib fibs
clobber: clean
	rm -f *~ \#*\#
clean:
	rm -f fib *.o


# FIB
# Dependency rules for file targets
fibs: fib.o bigint.o bigintadd.s
	gcc217 $(CFLAGS) fib.c bigint.c bigintadd.s -o fibs
fib: bigint.o fib.o flatbigintadd.o
	gcc217 -pg bigint.o fib.o flatbigintadd.o -o fib
bigint.o: bigint.h bigint.c bigintprivate.h
	gcc217 $(CFLAGS) -c bigint.c
fib.o: fib.c bigint.h bigintprivate.h
	gcc217 $(CFLAGS) -c fib.c
flatbigintadd.o: bigint.h flatbigintadd.c bigintprivate.h
	gcc217 $(CFLAGS) -c flatbigintadd.c

