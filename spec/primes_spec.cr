require "big_int"
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
    end

    it "plays well with BigInts" do
      Primes.prime?(BigInt.new(2)).should be_true
      Primes.prime?(BigInt.new(2) ** 64).should be_false
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
    end
  end
end
