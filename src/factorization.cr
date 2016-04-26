class Factorization
  getter :n
  getter :factors
  getter :unfactored

  def initialize(n)
    @n = BigInt.new(n)

    factors = [] of Array(typeof(@n))
    if @n < 0
      factors << Utils.convert_type([-1, 1], @n)
    end

    if @n.prime?
      factors << Utils.convert_type([@n, 1], @n)
    end

    @factors = factors

    @unfactored = @n / self.class.product_of_factors(factors, @n.class)
  end

  def initialize(n : BigInt, factors : Array(Array(BigInt)))
    @n = n
    self.class.verify_primality(factors)
    @factors = factors
    product = self.class.product_of_factors(factors, n.class)
    unless BigInt.new(n) % product == 0
      raise "Error: You've found a bug.  The factors we've found so far (#{factors}) don't actually produce #{n} when multiplied together.  Please report this issue!"
    end

    quotient = BigInt.new(n) / product
    if quotient.prime?
      @factors << Utils.convert_type([quotient, BigInt.new(1)], n)
      @unfactored = BigInt.new(1)
    else
      @unfactored = n / product
    end
  end

  def self.verify_primality(factors)
    composites = factors.select { |pair| !(pair.first.prime? || pair.first == -1) }
    unless composites.empty?
      raise "Error: You've found a bug.  At least one of the factors we found (#{factors}) was not prime (#{composites}).  Please report this issue!"
    end
  end

  def self.product_of_factors(factors, n_class)
    factors.reduce(n_class.new(1)) { |product, pair| pair.last.times { product *= pair.first }; product }
  end

  def with_new_factor(factor)
    raise "New factor (#{factor}) not prime!" unless factor.prime? || factor == -1
    if factor == -1
      multiplicity = 1
    else
      multiplicity = Utils.find_multiplicity(@n, factor)
    end
    Factorization.new(@n, @factors << Utils.convert_type([factor, multiplicity], @n))
  end

  def complete?
    @unfactored == 1
  end
end
