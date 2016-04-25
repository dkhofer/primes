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
    result = Factorization.new(72, [[2, 3]])
    result.n.should eq 72
    result.factors.should eq [[2, 3]]
    result.unfactored.should eq 9
  end
end
