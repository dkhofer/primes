require "spec"
require "../src/primes"

describe "Primes" do
  context "prime?" do
    it "returns false on numbers less than 2" do
      Primes.prime?(0).should be_false
      Primes.prime?(1).should be_false
      Primes.prime?(-1).should be_false
      Primes.prime?(-2).should be_false
      Primes.prime?(-3).should be_false
      Primes.prime?(-5).should be_false
      Primes.prime?(-6).should be_false
      Primes.prime?(-12).should be_false
    end

    it "returns false on composites" do
      Primes.prime?(4).should be_false
      # 57: the famed "Grothendieck prime".
      Primes.prime?(57).should be_false
      # 1007 == 19 * 53
      Primes.prime?(1_007).should be_false
    end

    it "returns true on primes" do
      Primes.prime?(2).should be_true
      Primes.prime?(3).should be_true
      Primes.prime?(23).should be_true
      Primes.prime?(1_009).should be_true
      Primes.prime?(1_000_003).should be_true
      Primes.prime?(1_000_005).should be_false
      Primes.prime?(193_707_721).should be_true
    end

    it "plays well with BigInts" do
      Primes.prime?(BigInt.new(2)).should be_true
      Primes.prime?(BigInt.new(2) ** 64).should be_false
    end

    it "usually works with the Fermat test" do
      # 561 is a Carmichael number.
      Primes.fermat_prime?(561).should be_false
      Primes.fermat_prime?(1_009).should be_true
    end

    it "works on the Miller-Rabin test" do
      Primes.miller_rabin_prime?(71).should be_true
      Primes.miller_rabin_prime?(561).should be_false
      Primes.miller_rabin_prime?(1_007).should be_false
      Primes.miller_rabin_prime?(1_009).should be_true
      Primes.miller_rabin_prime?(1_000_003).should be_true
      Primes.miller_rabin_prime?(1_000_005).should be_false
      Primes.miller_rabin_prime?(193_707_721).should be_true
      Primes.miller_rabin_prime?(BigInt.new("761838257287")).should be_true
      Primes.miller_rabin_prime?(BigInt.new(2) ** 67 - 1).should be_false

      naive_under_100k = (1..10 ** 5).to_a.select { |i| Primes.naive_prime?(i) }
      mr_under_100k = (1..10 ** 5).to_a.select { |i| Primes.miller_rabin_prime?(i) }

      mr_under_100k.should eq naive_under_100k
    end
  end

  context "factorization" do
    it "works on negative numbers" do
      Primes.factorization(-1).should eq [[-1, 1]]
      Primes.factorization(-4).should eq [[-1, 1], [2, 2]]
    end

    it "works on positive composite numbers" do
      Primes.factorization(4).should eq [[2, 2]]
      Primes.factorization(1_007).should eq [[19, 1], [53, 1]]
      24.factorization.should eq [[2, 3], [3, 1]]
      7200.factorization.should eq [[2, 5], [3, 2], [5, 2]]
    end

    it "plays well with BigInts" do
      Primes.factorization(BigInt.new(4)).should eq [[2, 2]]
      Primes.factorization(BigInt.new(1_007)).should eq [[19, 1], [53, 1]]

      Primes.factorization(BigInt.new(-1)).should eq [[-1, 1]]
      Primes.factorization(BigInt.new(-4)).should eq [[-1, 1], [2, 2]]
    end

    it "does trial division correctly" do
      Primes.trial_division(1_098_413).should eq 563
      Primes.trial_division(1_098_413, 564).should eq 1951
    end

    it "does Pollard Rho correctly" do
      Primes.pollard_rho(1_098_413).should eq 563
      Primes.pollard_rho(BigInt.new(2) ** 67 - 1).should eq 193_707_721
    end

    it "does Pollard P-1 correctly" do
      Primes.pollard_p_minus_one(1_098_413).should eq 563
    end
  end

  context "utility functions" do
    it "finds kth roots" do
      Primes.kth_root(81, 4).should eq 3
      Primes.kth_root(80, 4).should be_nil
      Primes.kth_root(BigInt.new(193_707_721) * BigInt.new(193_707_721), 2).should eq BigInt.new(193_707_721)
      Primes.kth_root(BigInt.new("229585692886981495482220544"), 23).should eq BigInt.new(14)
    end

    it "finds perfect powers" do
      Primes.perfect_power(81).should eq [3, 4]
      Primes.perfect_power(BigInt.new("762939453125")).should eq [5, 17]
      Primes.perfect_power(BigInt.new("229585692886981495482220544")).should eq [14, 23]
      Primes.perfect_power(BigInt.new("9847190351098450528099373752086151530631332543146139252235191014901139637782731886108754560419211788530271799786203464531596480469218430400696281710880571132292285469579555119359036917056450009027975934748461958416293375443135171439109760001")).should eq [257, 100]

      Primes.perfect_power(2).should eq nil
      Primes.perfect_power(14).should eq nil
      Primes.perfect_power(44).should eq nil
      Primes.perfect_power(BigInt.new("9191676072895965691111420287778973431718115")).should eq nil
    end

    it "computes the square root" do
      Primes.binary_search_sqrt(256).should eq 16
      Primes.binary_search_sqrt(9_999).should eq 99
    end

    it "does power + mod correctly" do
      Primes.power(BigInt.new(121_161), 500_001, 1_000_003).should eq 1
    end
  end

  context "struct Int" do
    it "includes prime? and factorization" do
      6.prime?.should be_false
      6.factorization.should eq [[2, 1], [3, 1]]

      3.prime?.should be_true
      3.factorization.should eq [[3, 1]]

      1_007.prime?.should be_false
      1_007.factorization.should eq [[19, 1], [53, 1]]

      BigInt.new(1_007).prime?.should be_false
      BigInt.new(1_007).factorization.should eq [[19, 1], [53, 1]]

      cole_prime = BigInt.new(2) ** 67 - 1
      cole_prime.prime?.should be_false
    end
  end
end
