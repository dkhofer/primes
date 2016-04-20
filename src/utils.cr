module Utils
  extend self

  # Finds greatest number less than or equal to the square root of n
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

  # Returns an integer x such that x ** k == n, or nil if there is no
  # such x.
  def self.kth_root(n, k)
    root = BigInt.new(0)
    log = ((n.to_s.split("").size * 4) / Math.log(k, 2)).to_i
    (0..log + 1).reverse_each do |i|
      layer = BigInt.new(1) << i
      if (root + layer) ** k <= n
        root += layer
      end
    end

    if root ** k == n
      n.class.new(root)
    else
      nil
    end
  end

  # Returns a pair [x, k] such that x ** k == n, or nil if there is no
  # such pair.
  def self.perfect_power(n)
    return nil if n < 4

    bits = n.to_s.split("").size * 4
    (2..bits).reverse_each do |i|
      result = kth_root(n, i)
      unless result.nil?
        return [result, i]
      end
    end

    nil
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

  # NOTE(hofer): Necessary because if we have an array of say Int64's
  # and want to add an Int32 to it, the compiler complains.  It would
  # be nice if it would instead convert the Int32 to an Int64, but I
  # can live without it for now.
  def self.convert_type(ints, n)
    ints.map { |i| typeof(n).new(i) }
  end

  def self.rand(n : BigInt)
    temp_n = n
    result = BigInt.new(0)

    while temp_n != 0
      bit = rand(2)
      if (result | bit) < n
        result |= bit
      end

      if (result << 1) < n
        result <<= 1
      end

      temp_n >>= 1
    end

    result
  end
end
