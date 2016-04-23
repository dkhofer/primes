require "../src/primes"

macro precompute_primes
  {{ run("./precompute_primes") }}
end

Primes.set_small_primes(precompute_primes)

def is_prime(input)
  BigInt.new(input).prime?
end

puts is_prime(ARGV[0])
