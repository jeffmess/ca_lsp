# typed: false

module RubyLsp
  module CloudLsp
    module Logger
      def log(msg)
        STDERR.puts "[Cloud LSP] #{msg}"
      end
    end
  end
end
 
