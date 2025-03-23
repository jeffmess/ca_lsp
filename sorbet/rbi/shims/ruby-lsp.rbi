# typed: true
# 
class RubyLsp::NodeContext
  extend T::Sig
  sig { returns(Prism::Node) }
  def node
  end
end

