class Primes
  def self.prime?(n : Int)
    return false if n < 2
    return true if n == 2

    (2..Math.sqrt(n)).each { |i| return false if n % i == 0 }

    return true
  end

  def self.factorization(n : Int32)
    raise "Can't factor zero!" if n == 0

    factors = [] of Array(Int32)

    if n < 0
      factors << [-1, 1]
      n = n.abs
    end

    if n == 2
      factors << [2, 1]
      n = 1
    end

    current_number = n
    divisor = 2

    while current_number > 1
      max_divisor_candidate = Math.sqrt(current_number).to_i + 1
      while divisor < max_divisor_candidate && current_number % divisor != 0
        divisor += 1
      end

      if divisor >= max_divisor_candidate # current_number is prime
        factors << [current_number, 1]
        current_number = 1
      else
        multiplicity = 0
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
