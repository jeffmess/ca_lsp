# typed: true

class Prism::Node
  extend T::Sig

  sig { returns(String) }
  def name; end
end

class Prism::ConstantReadNode
  extend T::Sig

  sig { returns(String) }
  def full_name; end
end

class Prism::ConstantPathNode
  extend T::Sig

  sig { returns(String) }
  def full_name; end
end
