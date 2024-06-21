require 'rouge'

module Rouge
  module Lexers
    class Solidity < RegexLexer
      title "Solidity"
      desc "The Solidity smart contract language"

      tag 'solidity'
      filenames '*.sol'

      state :root do
        rule %r/\b(?:contract|library|interface|function|modifier|event|enum|struct|mapping|require|assert|revert|if|else|for|while|do|continue|break|return|emit|try|catch|throw|selfdestruct|suicide|new|this|super|msg|tx|block|abi|address|byte|bytes|string|bool|int|uint|fixed|ufixed|var|constant|immutable|anonymous|indexed|override|virtual|pure|view|payable|nonpayable|storage|memory|calldata|public|internal|external|private|constructor|fallback|receive|error|unchecked|mapping|assembly|is|as|using|true|false|abstract|pure|view|payable|constructor|returns|pragma|solidity)\b/, Keyword
        rule %r/\/\/.*/, Comment::Single
        rule %r/\/\*[\s\S]*?\*\//, Comment::Multiline
        rule %r/".*?"/, Str::Double
        rule %r/'.*?'/, Str::Single
        rule %r/[a-zA-Z_]\w*/, Name
        rule %r/\d+/, Num::Integer
        rule %r/[{}()\[\];,]/, Punctuation
        rule %r/./, Text
      end
    end
  end
end
