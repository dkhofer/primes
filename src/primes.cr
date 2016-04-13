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
      factors << convert_type([-1, 1], n)
      n = n.abs
    end

    if n == 2
      return [convert_type([2, 1], n)]
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
