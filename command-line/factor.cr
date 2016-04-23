require "../src/primes"

macro precompute_primes
  {{ run("./precompute_primes") }}
end

Primes.set_small_primes(precompute_primes)

def factor(input)
  n = BigInt.new(input)
  n.factorization.map { |pair| [pair.first] * pair.last }.flatten.join(" ")
end

puts ARGV[0] + ": " + factor(ARGV[0])
