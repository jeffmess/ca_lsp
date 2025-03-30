# typed: true
# 
class RubyLsp::NodeContext
  extend T::Sig
  sig { returns(Prism::Node) }
  def node
  end
end

class RubyLsp::ResponseBuilders::CollectionResponseBuilder < RubyLsp::ResponseBuilders::ResponseBuilder
  extend T::Generic
  def <<(*); end
  def push(*); end
end

module RubyLsp::Interface::Location
  def self.new(uri:, range:); end
end

module RubyLsp::Interface::Position
  def self.new(line:, character:); end
end
module RubyLsp::Interface::Range
  def self.new(start:, end:); end
end
