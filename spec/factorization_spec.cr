require "spec"
require "../src/factorization"

describe "Factorization" do
  it "verifies primality of factors" do
    expect_raises { Factorization.verify_primality([[2, 3], [4, 5]]) }
  end

  it "finds product of factors" do
    Factorization.product_of_factors([[2, 3], [3, 2]], Int32).should eq 72
    empty_array = [] of Array(Int32)
    Factorization.product_of_factors(empty_array, Int32).should eq 1
  end

  it "initializes" do
    result = Factorization.new(BigInt.new(72), [[BigInt.new(2), BigInt.new(3)]])
    result.n.should eq 72
    result.factors.should eq [[2, 3]]
    result.unfactored.should eq 9
  end

  context "factorization" do
    it "works on negative numbers" do
      Factorization.factorization(-1).should eq [[-1, 1]]
      Factorization.factorization(-4).should eq [[-1, 1], [2, 2]]
    end

    it "works on positive composite numbers" do
      Factorization.factorization(4).should eq [[2, 2]]
      Factorization.factorization(1_007).should eq [[19, 1], [53, 1]]
      24.factorization.should eq [[2, 3], [3, 1]]
      7200.factorization.should eq [[2, 5], [3, 2], [5, 2]]
    end

    it "plays well with BigInts" do
      Factorization.factorization(BigInt.new(4)).should eq [[2, 2]]
      Factorization.factorization(BigInt.new(1_007)).should eq [[19, 1], [53, 1]]

      Factorization.factorization(BigInt.new(-1)).should eq [[-1, 1]]
      Factorization.factorization(BigInt.new(-4)).should eq [[-1, 1], [2, 2]]
    end

    it "does trial division correctly" do
      Factorization.trial_division(Factorization.new(1_098_413)).factors.should eq [[563, 1], [1951, 1]]
    end

    it "does Pollard Rho correctly" do
      Factorization.pollard_rho(Factorization.new(1_098_413)).factors.should eq [[563, 1], [1951, 1]]
      Factorization.pollard_rho(Factorization.new(BigInt.new(2) ** 67 - 1)).factors.should eq [[193_707_721, 1], [761_838_257_287, 1]]
    end

    it "does Pollard P-1 correctly" do
      Factorization.pollard_p_minus_one(Factorization.new(1_098_413)).factors.should eq [[563, 1], [1951, 1]]
    end
  end

end
