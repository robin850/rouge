# -*- coding: utf-8 -*- #

module Rouge
  module Lexers
    load_lexer 'console.rb'

    class IRBLexer < ConsoleLexer
      tag 'irb'
      aliases 'pry'

      def output_lexer
        @output_lexer ||= IRBOutputLexer.new(@options)
      end

      def lang_lexer
        @lang_lexer ||= Ruby.new(@options)
      end

      def prompt_regex
        /^.*?(irb|pry).*?[>"*]/
      end
    end

    load_lexer 'ruby.rb'
    class IRBOutputLexer < Ruby
      tag 'irb_output'

      start do
        push :stdout
      end

      state :has_irb_output do
        rule %r(=>), Punctuation, :pop!
        rule /.+?(\n|$)/, Generic::Output
      end

      state :irb_error do
        rule /.+?(\n|$)/, Generic::Error
        mixin :has_irb_output
      end

      state :stdout do
        rule /\w+?(Error|Exception):.+?(\n|$)/, Generic::Error, :irb_error
        mixin :has_irb_output
      end

      prepend :root do
        rule /#</, Keyword::Type, :irb_object
      end

      state :irb_object do
        rule />/, Keyword::Type, :pop!
        mixin :root
      end
    end
  end
end