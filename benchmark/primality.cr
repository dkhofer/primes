require "benchmark"
require "big_int"
require "../src/primes.cr"

def timing_result(&block)
  Benchmark.measure { yield }.real * 1000
end

big_number = BigInt.new(10) ** 8

(1..100).each do |i|
  test = big_number + i
  if Primes.miller_rabin_prime?(test)
    puts test
    puts "Miller-Rabin: #{timing_result { puts Primes.miller_rabin_prime?(test) }}"
    puts "naive: #{timing_result { puts Primes.naive_prime?(test) }}"
  end
end
