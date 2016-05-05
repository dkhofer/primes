require "big_int"
require "./factorization"
require "./utils"

class Primes
  include Utils

  # -----------------
  # Primality testing
  # -----------------

  def self.prime?(n : Int)
    # NOTE(hofer): On my laptop, 10^8 is approximately where Miller-Rabin starts
    # being faster.
    if n < 100_000_000
      naive_prime?(n)
    else
      miller_rabin_prime?(n)
    end
  end

  def self.compute_primes(max)
    (2..max).select { |n| n.prime? }
  end

  def self.small_primes
    @@small_primes ||= compute_primes(10 ** 6)
  end

  def self.set_small_primes(primes : Array(Int32))
    @@small_primes = primes
  end

  def self.naive_prime?(n : Int)
    return false if n < 2
    return true if n == 2

    if typeof(n) == BigInt
      # NOTE(hofer): My hand-rolled square root method is much slower
      # than the built-in one.
      (2..(Utils.binary_search_sqrt(n) + 1)).each { |i| return false if n % i == 0 }
    else
      (2..Math.sqrt(n) + 1).each { |i| return false if n % i == 0 }
    end

    return true
  end

  def self.miller_rabin_prime?(n : Int)
    return naive_prime?(n) if n < 100

    n = BigInt.new(n)

    samples = 0
    temp_n = n

    while temp_n != 0
      samples += 1
      temp_n >>= 1
    end

    samples = [20, samples].max

    t = n - 1
    s = 0

    while t & 1 == 0
      t >>= 1
      s += 1
    end

    samples.times do
      if typeof(n) == BigInt
        a = Utils.rand(n - 4) + 2
      else
        a = BigInt.new(2 + rand(n - 4))
      end
      x = Utils.power(a, t, n)

      next if x == 1 || x == n - 1

      s.times do
        x = (x * x) % n
        return false if x == 1
        break if x == n - 1
      end

      return false if x != n - 1
    end

    return true
  end

  def self.fermat_prime?(n : Int)
    counter = n

    while counter != 0
      if fermat_composite?((2..n - 2).to_a.sample, n)
        return false
      end
      counter >>= 1
    end

    return true
  end

  def self.fermat_composite?(a : Int, n : Int)
    Utils.power(a, n - 1, n) != n.class.new(1)
  end
end

struct Int
  def prime?
    Primes.prime?(self)
  end

  def factorization
    Factorization.factorization(self)
  end
end
