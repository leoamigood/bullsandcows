module FactoryGirlSupport
  module RandomSupport
    def generate_random_int(size = 0.size)
      Random.rand(2 ** (size * 4) / 2 - 1)
    end
  end
end

FactoryGirl::SyntaxRunner.send(:include, FactoryGirlSupport::RandomSupport)
