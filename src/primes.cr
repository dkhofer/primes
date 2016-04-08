class Primes
  def self.prime?(n : Int)
    return false if n < 2
    return true if n == 2

    (2..Math.sqrt(n)).each { |i| return false if n % i == 0 }

    return true
  end

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
      factors << [typeof(n).new(-1), typeof(n).new(1)]
      n = n.abs
    end

    if n == 2
      factors << [n, typeof(n).new(1)]
      n = typeof(n).new(1)
    end

    current_number = n
    divisor = typeof(n).new(2)

    while current_number > 1
      max_divisor_candidate = binary_search_sqrt(current_number) + 1
      while divisor < max_divisor_candidate && current_number % divisor != 0
        divisor += typeof(n).new(1)
      end

      if divisor >= max_divisor_candidate # current_number is prime
        factors << [current_number, typeof(n).new(1)]
        current_number = typeof(n).new(1)
      else
        multiplicity = typeof(n).new(0)
        while current_number % divisor == 0
          current_number /= divisor
          multiplicity += 1
        end

        factors << [divisor, multiplicity]
      end
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
