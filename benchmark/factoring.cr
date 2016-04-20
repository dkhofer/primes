require "benchmark"
require "big_int"
require "../src/primes.cr"

def timing_result(&block)
  Benchmark.measure { yield }.real * 1000
end

# Cole's prime
#puts Primes.factorization(BigInt.new(2) ** 67 - 1)

#puts Primes.factorization(BigInt.new(2) ** 256 + 1)
#puts Primes.factorization(BigInt.new(2) ** 512 + 1)
#puts Primes.factorization(BigInt.new(2) ** 1024 + 1)
#puts Primes.factorization(BigInt.new(2) ** 2048 + 1)
#puts Primes.factorization(BigInt.new(45) ** 123 + 1)

def test_consecutive_numbers
  bignum = BigInt.new(10) ** 40

  (0..100).each do |i|
    puts "--------------"
    puts bignum + i
    puts timing_result { puts (bignum + i).factorization }
  end
end

#test_consecutive_numbers

puts timing_result { puts BigInt.new("4337660497517294136548543824823958162240217381129360928310680501108409907018669308499646759037523055135280941119260282849228049804714190153625379797864095848934371457888221175272238345887255405924195885293637904870978723158667796633496801").factorization }
