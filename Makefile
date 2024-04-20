CFLAGS = -D NDEBUG -O -g

# Dependency rules for non-file targets
all: fib
clobber: clean
	rm -f *~ \#*\#
clean:
	rm -f fib *.o


# FIB
# Dependency rules for file targets
fib: bigint.o fib.o flatbigintadd.o
	gcc217 -pg bigint.o fib.o flatbigintadd.o -o fib
bigint.o: bigint.h bigint.c bigintprivate.h
	gcc217 $(CFLAGS) -c bigint.c
fib.o: fib.c bigint.h bigintprivate.h
	gcc217 $(CFLAGS) -c fib.c
bigintadd.o: bigint.h flatbigintadd.c bigintprivate.h
	gcc217 $(CFLAGS) -c flatbigintadd.c
