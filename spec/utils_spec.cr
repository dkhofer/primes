require "spec"
require "../src/utils"

describe "Utils" do
  it "finds kth roots" do
    Utils.kth_root(81, 4).should eq 3
    Utils.kth_root(80, 4).should be_nil
    Utils.kth_root(BigInt.new(193_707_721) * BigInt.new(193_707_721), 2).should eq BigInt.new(193_707_721)
    Utils.kth_root(BigInt.new("229585692886981495482220544"), 23).should eq BigInt.new(14)
  end

  it "finds perfect powers" do
    Utils.perfect_power(81).should eq [3, 4]
    Utils.perfect_power(BigInt.new("762939453125")).should eq [5, 17]
    Utils.perfect_power(BigInt.new("229585692886981495482220544")).should eq [14, 23]
    Utils.perfect_power(BigInt.new("9847190351098450528099373752086151530631332543146139252235191014901139637782731886108754560419211788530271799786203464531596480469218430400696281710880571132292285469579555119359036917056450009027975934748461958416293375443135171439109760001")).should eq [257, 100]

    Utils.perfect_power(2).should eq nil
    Utils.perfect_power(14).should eq nil
    Utils.perfect_power(44).should eq nil
    Utils.perfect_power(BigInt.new("9191676072895965691111420287778973431718115")).should eq nil
  end

  it "computes the square root" do
    Utils.binary_search_sqrt(256).should eq 16
    Utils.binary_search_sqrt(9_999).should eq 99
  end

  it "does power + mod correctly" do
    Utils.power(BigInt.new(121_161), 500_001, 1_000_003).should eq 1
  end

  it "computes rand correctly" do
    x = BigInt.new("123456789012345678")
    random = Utils.rand(x)
    (random >= 0).should be_true
    (random < x).should be_true
  end
end
