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
