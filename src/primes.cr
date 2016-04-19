require "big_int"

class Primes
  def self.prime?(n : Int)
    # NOTE(hofer): On my laptop, 10^8 is approximately where Miller-Rabin starts
    # being faster.
    if n < 100_000_000
      naive_prime?(n)
    else
      miller_rabin_prime?(n)
    end
  end

  def self.naive_prime?(n : Int)
    return false if n < 2
    return true if n == 2

    (2..Math.sqrt(n)).each { |i| return false if n % i == 0 }

    return true
  end

  def self.power(x : Int, n : Int, m : Int)
    result = BigInt.new(1)
    square = BigInt.new(x)

    while n != 0
      result = (result * square) % m if (n & 1) == 1
      square = (square * square) % m
      n >>= 1
    end

    return m.class.new(result)
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
      a = BigInt.new(2 + rand(n - 4))
      x = power(a, t, n)

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
    power(a, n - 1, n) != n.class.new(1)
  end

  def self.compute_primes(max)
    (2..max).select { |n| n.prime? }
  end

  PRIMES = compute_primes(10 ** 6)

  # NOTE(hofer): Need this because Math.sqrt doesn't handle BigInts.
  def self.binary_search_sqrt(n)
    sqrt = typeof(n).new(0)
    log = n.to_s.split("").size * 3
    (0..log + 1).reverse_each do |i|
      layer = typeof(n).new(1) << i
      if (sqrt + layer) * (sqrt + layer) <= n
        sqrt += layer
      end
    end

    sqrt
  end

  def self.trial_division(n : Int)
    factors = PRIMES.select { |p| n % p == 0 }
    temp_n = n
    factors.map { |factor| [factor, find_multiplicity(n, factor)] }
  end

  def self.pollard_rho(n : Int)
    x = BigInt.new(0)
    y = BigInt.new(0)
    product = n.class.new(1)
    polynomial = ->(x : typeof(n)) { (x * x + 1) % n }
    polynomial = ->(x : BigInt) { ((x * x) + 1) % n }
    factor = n.class.new(0)
    iterations = 0

    # NOTE(hofer): Get a positive number divisible by 100
    attempts = [10 ** 8, ((binary_search_sqrt(binary_search_sqrt(n)) / 100) + 1) * 100].min

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

    PRIMES.each do |p|
      x = power(x, p, n)
      factor = n.gcd(x - 1)
      return factor if factor > 1 && factor < n
    end

    n.class.new(0)
  end

  def self.power(x : Int, n : Int, m : Int)
    result = x.class.new(1)
    square = x

    while n != 0
      result = (result * square) % m if (n & 1) == 1
      square = (square * square) % m
      n >>= 1
    end

    return result
  end

  def self.find_multiplicity(n, p)
    multiplicity = 0
    product = n.class.new(p)
    while n % product == 0
      product *= p
      multiplicity += 1
    end

    multiplicity
  end

  def self.divide_out_factors(n, factors)
    result = n
    factors.each do |pair|
      p = pair.first
      multiplicity = pair.last
      multiplicity.times { result /= p }
    end

    result
  end

  def self.brute_force(n)
    current_number = n
    factors = [] of Array(typeof(n))

    divisor = PRIMES.last + 1

    while current_number > 1
      max_divisor_candidate = binary_search_sqrt(current_number) + 1
      while divisor < max_divisor_candidate && current_number % divisor != 0
        divisor += 1
      end

      if divisor >= max_divisor_candidate # current_number is prime
        factors << convert_type([current_number, 1], n)
        current_number = typeof(n).new(1)
      else
        new_factors = convert_type([divisor, find_multiplicity(current_number, divisor)], n)
        factors << new_factors
        current_number = divide_out_factors(current_number, [new_factors])
      end
    end

    factors
  end

  def self.factorization(n : Int, options = ["trial_division", "pollard_rho"])
    raise "Can't factor zero!" if n == 0

    factors = [] of Array(typeof(n))

    if n < 0
      factors << convert_type([-1, 1], n)
      n = n.abs
    end

    if n.prime?
      factors << convert_type([n, 1], n)
      return factors
    end

    current_number = n

    # Trial division
    small_divisors = trial_division(current_number).map { |pair| convert_type(pair, n) }
    factors.concat(small_divisors)
    current_number = divide_out_factors(current_number, small_divisors)
    divisor = n.class.new(PRIMES.last + 1)

    if current_number.prime?
      factors << convert_type([current_number, 1], n)
      return factors
    end

    if options.includes?("pollard_rho") && current_number > 1
      pollard_divisor = n.class.new(1)
      while pollard_divisor > 0 && !current_number.prime?
        pollard_divisor = pollard_rho(current_number)
        if pollard_divisor > 0
          new_divisor_pair = convert_type([pollard_divisor, find_multiplicity(current_number, pollard_divisor)], n)
          factors << new_divisor_pair
          current_number = divide_out_factors(current_number, [new_divisor_pair])
        end
      end
    end

    if options.includes?("pollard_p_minus_one") && current_number > 1
      pollard_divisor = n.class.new(1)
      while pollard_divisor > 0 && !current_number.prime?
        pollard_divisor = pollard_p_minus_one(current_number)
        if pollard_divisor > 0
          new_divisor_pair = convert_type([pollard_divisor, find_multiplicity(current_number, pollard_divisor)], n)
          factors << new_divisor_pair
          current_number = divide_out_factors(current_number, [new_divisor_pair])
        end
      end
    end

    if current_number.prime?
      factors << convert_type([current_number, 1], n)
    elsif current_number > 1
      factors.concat(brute_force(current_number).map { |pair| convert_type(pair, n) })
    end

    return factors
  end
end

# NOTE(hofer): Necessary because if we have an array of say Int64's
# and want to add an Int32 to it, the compiler complains.  It would be
# nice if it would instead convert the Int32 to an Int64, but I can
# live without it for now.
def convert_type(ints, n)
  ints.map { |i| typeof(n).new(i) }
end

struct Int
  def prime?
    Primes.prime?(self)
  end

  def factorization
    Primes.factorization(self)
  end
end
