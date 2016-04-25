class Factorization
  getter :n
  getter :factors
  getter :unfactored

  def initialize(n, factors)
    @n = n
    self.class.verify_primality(factors)
    @factors = factors
    product = self.class.product_of_factors(factors, n.class)
    unless n % product == 0
      raise "Error: product of factors #{factors} does not evenly divide #{n}."
    end
    @unfactored = n / product
  end

  def self.verify_primality(factors)
    composites = factors.select { |pair| !(pair.first.prime? || pair.first == -1) }
    unless composites.empty?
      raise "Error: Some factors provided are not prime: #{composites}"
    end
  end

  def self.product_of_factors(factors, n_class)
    factors.reduce(n_class.new(1)) { |product, pair| pair.last.times { product *= pair.first }; product }
  end
end
