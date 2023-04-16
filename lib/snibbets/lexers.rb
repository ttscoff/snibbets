# frozen_string_literal: true
require_relative 'lexers_db'

module Snibbets
  # Lexer definitions
  module Lexers
    class << self
      def lexers
        @lexers ||= build_lexers
      end

      def build_lexers
        lex = []
        LEXERS_DB.split(/\n/).each do |line|
          key = line.match(/(?mi)^((, )?[^,]+?)+?(?=\[)/)[0]
          keys = key.split(/,/).map(&:strip)
          value = line.match(/\[(.*?)\]/)[1]
          values = value.split(/,/).map(&:strip)

          lex << {
            lexer: keys.shift,
            aliases: keys,
            extensions: values
          }
        end

        lex
      end

      def ext_to_lang(ext)
        matches = lexers.select { |lex| lex[:extensions].map(&:downcase).include?(ext.downcase) }
        matches.map { |lex| lex[:lexer] }.first
      end

      def lang_to_ext(lexer)
        matches = lexers.select { |lex| lex[:lexer] == lexer || lex[:aliases].map(&:downcase).include?(lexer.downcase) }
        matches.map { |lex| lex[:extensions].first }.first
      end

      def syntax_from_extension(filename)
        exts = filename.split(/\./)[1..-2]
        ext_to_lang(exts[-1])
      end
    end
  end
end
