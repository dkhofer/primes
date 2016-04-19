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
puts Primes.factorization(BigInt.new(2) ** 256 + 1, ["pollard_rho"])

#puts Primes.pollard_rho(BigInt.new(2) ** 67 - 1)
#puts Primes.pollard_rho(BigInt.new(2) ** 256 + 1)
