require "big_int"
require "./utils"

class Primes
  include Utils

  #####################
  # Primality testing #
  #####################

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

  def self.set_small_primes(primes)
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

  def self.trial_division(n : Int, lower_bound = 2)
    upper_bound = Utils.binary_search_sqrt(n)

    small_primes.each do |p|
      break if p > upper_bound
      next if p < lower_bound
      return p if n % p == 0
    end

    return n.class.new(0)
  end

  #################
  # Factorization #
  #################

  def self.pollard_rho(n : Int)
    x = BigInt.new(0)
    y = BigInt.new(0)
    product = n.class.new(1)
    polynomial = ->(x : typeof(n)) { (x * x + 1) % n }
    polynomial = ->(x : BigInt) { ((x * x) + 1) % n }
    factor = n.class.new(0)
    iterations = 0

    # NOTE(hofer): Get a positive number divisible by 100
    attempts = [10 ** 8, ((Utils.binary_search_sqrt(Utils.binary_search_sqrt(n)) / 100) + 1) * 100].min

    (1..attempts).each do |i|
      new_x = polynomial.call(x)
      new_y = polynomial.call(polynomial.call(y))
      new_product = (product * (new_y - new_x).abs) % n

      if new_product == 0 || i % 100 == 0 || i == attempts
        test_gcd = n.gcd(new_product)
        if test_gcd > 1 && test_gcd < n
          factor = n.class.new(test_gcd)
          break
        end
        product = n.class.new(1)
      else
        x = new_x
        y = new_y
        product = new_product
      end
    end

    factor
  end

  # NOTE(hofer): It appears that for this to be effective, a lot of
  # primes must be used, and I'm not going to precompute more than 1M
  # of them.
  def self.pollard_p_minus_one(n : Int)
    x = n.class.new(2)

    small_primes.each do |p|
      x = Utils.power(x, p, n)
      factor = n.gcd(x - 1)
      return factor if factor > 1 && factor < n
    end

    n.class.new(0)
  end

  def self.brute_force(n)
    current_number = n
    factors = [] of Array(typeof(n))

    divisor = small_primes.last + 1

    while current_number > 1
      max_divisor_candidate = Utils.binary_search_sqrt(current_number) + 1
      while divisor < max_divisor_candidate && current_number % divisor != 0
        divisor += 1
      end

      if divisor >= max_divisor_candidate # current_number is prime
        factors << Utils.convert_type([current_number, 1], n)
        current_number = typeof(n).new(1)
      else
        new_factors = Utils.convert_type([divisor, Utils.find_multiplicity(current_number, divisor)], n)
        factors << new_factors
        current_number = Utils.divide_out_factors(current_number, [new_factors])
      end
    end

    factors
  end

  def self.factorization(n : Int, options = ["trial_division", "pollard_rho"])
    raise "Can't factor zero!" if n == 0

    factors = [] of Array(typeof(n))

    if n < 0
      factors << Utils.convert_type([-1, 1], n)
      n = n.abs
    end

    powers = Utils.perfect_power(n)
    unless powers.nil?
      base_factors = factorization(typeof(n).new(powers.first), options)
      factors.concat(base_factors.map { |pair| [pair.first, pair.last * typeof(n).new(powers.last)] })
      return factors
    end

    if n.prime?
      factors << Utils.convert_type([n, 1], n)
      return factors
    end

    current_number = n

    # Trial division
    trial_divisor = n.class.new(1)

    while trial_divisor > 0 && !current_number.prime?
      trial_divisor = trial_division(current_number, trial_divisor)
      if trial_divisor > 0
        new_divisor_pair = Utils.convert_type([trial_divisor, Utils.find_multiplicity(current_number, trial_divisor)], n)
        factors << new_divisor_pair
        current_number = Utils.divide_out_factors(current_number, [new_divisor_pair])
      end
    end

    if current_number.prime?
      factors << Utils.convert_type([current_number, 1], n)
      return factors
    end

    if options.includes?("pollard_rho") && current_number > 1
      pollard_divisor = n.class.new(1)
      while pollard_divisor > 0 && !current_number.prime?
        pollard_divisor = pollard_rho(current_number)
        if pollard_divisor > 0
          new_divisor_pair = Utils.convert_type([pollard_divisor, Utils.find_multiplicity(current_number, pollard_divisor)], n)
          factors << new_divisor_pair
          current_number = Utils.divide_out_factors(current_number, [new_divisor_pair])
        end
      end
    end

    if options.includes?("pollard_p_minus_one") && current_number > 1
      pollard_divisor = n.class.new(1)
      while pollard_divisor > 0 && !current_number.prime?
        pollard_divisor = pollard_p_minus_one(current_number)
        if pollard_divisor > 0
          new_divisor_pair = Utils.convert_type([pollard_divisor, Utils.find_multiplicity(current_number, pollard_divisor)], n)
          factors << new_divisor_pair
          current_number = Utils.divide_out_factors(current_number, [new_divisor_pair])
        end
      end
    end

    if current_number.prime?
      factors << Utils.convert_type([current_number, 1], n)
    elsif current_number > 1
      factors.concat(brute_force(current_number).map { |pair| Utils.convert_type(pair, n) })
    end

    return factors
  end
end

struct Int
  def prime?
    Primes.prime?(self)
  end

  def factorization
    Primes.factorization(self)
  end
end
