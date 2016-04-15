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

      (s - 1).times do
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

  PRIMES = (2..10 ** 6).select { |n| n.prime? }

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

  def self.factorization(n : Int)
    raise "Can't factor zero!" if n == 0

    factors = [] of Array(typeof(n))

    if n < 0
      factors << convert_type([-1, 1], n)
      n = n.abs
    end

    if n.prime?
      factors << convert_type([n, 1], n)
      n = n.class.new(1)
    end

    current_number = n
    divisor = n.class.new(2)

    while current_number > 1
      max_divisor_candidate = binary_search_sqrt(current_number) + 1
      while divisor < max_divisor_candidate && current_number % divisor != 0
        divisor += 1
      end

      if divisor >= max_divisor_candidate # current_number is prime
        factors << convert_type([current_number, 1], n)
        current_number = typeof(n).new(1)
      else
        multiplicity = 0
        while current_number % divisor == 0
          current_number /= divisor
          multiplicity += 1
        end

        factors << convert_type([divisor, multiplicity], n)
      end
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
