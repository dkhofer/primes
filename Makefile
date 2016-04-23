TARGET = all

all: bindir cr-factor is-prime

bindir:
	mkdir -p ./bin

cr-factor: command-line/factor.cr
	crystal build --release -o bin/cr-factor $?

is-prime: command-line/is_prime.cr
	crystal build --release -o bin/is-prime $?
