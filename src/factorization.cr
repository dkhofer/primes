class Factorization
  getter :n
  getter :factors
  getter :unfactored

  def self.factorization(n : Int, options = ["trial_division", "pollard_rho", "brute_force"])
    current_factors = Factorization.new(n)
    return current_factors.factors if current_factors.complete?

    powers = Utils.perfect_power(current_factors.unfactored)
    unless powers.nil?
      base_factors = factorization(typeof(n).new(powers.first), options)
      base_factors.each { |pair| current_factors = current_factors.with_new_factor(pair.first) }
      return current_factors.factors if current_factors.complete?
    end

    methods_by_option = {
      "trial_division" : ->trial_division(Factorization),
      "pollard_rho" : ->pollard_rho(Factorization),
      "pollard_p_minus_one" : ->pollard_p_minus_one(Factorization),
      "brute_force" : ->brute_force(Factorization),
    }

    options.each do |option|
      method = methods_by_option[option]
      current_factors = method.call(current_factors)
      return current_factors.factors if current_factors.complete?
    end

    raise "Could not fully factor #{n}. Current status: #{current_factors}.  Please file a bug report at http://github.com/dkhofer/primes/issues"
  end

  # NOTE(hofer): All methods defined below are intended to be private.
  # I need to figure out how I can have the specs call them that way,
  # though, so for now they're public.

  def initialize(n)
    raise "Can't factor zero!" if n == 0

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
    raise "Can't factor zero!" if n == 0

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

  def self.trial_division(current_factors)
    upper_bound = Utils.binary_search_sqrt(current_factors.unfactored)

    Primes.small_primes.each do |p|
      break if p > upper_bound || current_factors.complete?

      if current_factors.unfactored % p == 0
        current_factors = current_factors.with_new_factor(p)
        upper_bound = Utils.binary_search_sqrt(current_factors.unfactored)
      end
    end

    current_factors
  end

  def self.pollard_rho(current_factors)
    n = current_factors.unfactored

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
          current_factors = current_factors.with_new_factor(test_gcd)
          break if current_factors.complete?
        end
        product = n.class.new(1)
      else
        x = new_x
        y = new_y
        product = new_product
      end
    end

    current_factors
  end

  # NOTE(hofer): It appears that for this to be effective, a lot of
  # primes must be used, and I'm not going to precompute more than 1M
  # of them.
  def self.pollard_p_minus_one(current_factors)
    n = current_factors.unfactored
    x = n.class.new(2)

    Primes.small_primes.each do |p|
      x = Utils.power(x, p, n)
      factor = n.gcd(x - 1)
      if factor > 1 && factor < n
        current_factors = current_factors.with_new_factor(factor)
        break if current_factors.complete?
      end
    end

    current_factors
  end

  def self.brute_force(current_factors)
    current_number = current_factors.unfactored

    # NOTE(hofer): Only look at odd primes.
    divisor = Primes.small_primes.last + 2

    until current_factors.complete?
      max_divisor_candidate = Utils.binary_search_sqrt(current_number) + 1
      while divisor < max_divisor_candidate && current_number % divisor != 0
        divisor += 2
      end

      if divisor >= max_divisor_candidate # current_number is prime
        current_factors = current_factors.with_new_factor(current_number)
      else
        current_factors = current_factors.with_new_factor(divisor)
        current_number = current_factors.unfactored
      end
    end

    current_factors
  end
end
