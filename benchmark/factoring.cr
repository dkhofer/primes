require "benchmark"
require "big_int"
require "../src/primes.cr"

def timing_result(&block)
  Benchmark.measure { yield }.real * 1000
end

#puts Primes::PRIMES.size
# Cole's prime
#puts timing_result { puts Primes.factorization(BigInt.new(2) ** 67 - 1, ["trial_division", "pollard_rho"]) }

#puts Primes.factorization(BigInt.new(2) ** 67 - 1, ["pollard_rho"])
puts BigInt.new(2) ** 256 + 1
puts Primes.factorization(BigInt.new(2) ** 256 + 1)
#puts Primes.factorization(BigInt.new(2) ** 512 + 1, ["pollard_rho"])
#puts Primes.factorization(BigInt.new(2) ** 1024 + 1, ["pollard_rho"])
#puts Primes.factorization(BigInt.new(2) ** 2048 + 1, ["pollard_rho"])
#puts Primes.factorization(BigInt.new(45) ** 123 + 1)
