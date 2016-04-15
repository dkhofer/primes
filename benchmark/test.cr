require "big_int"
require "../src/primes.cr"

# Cole's prime
#puts Primes.factorization(BigInt.new(2) ** 67 - 1)

puts Primes.pollard_rho(BigInt.new(2) ** 67 - 1)
puts Primes.pollard_rho(BigInt.new(2) ** 256 + 1)
