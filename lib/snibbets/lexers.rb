module Snibbets
  class Lexers
    attr_accessor :lexers

    def build_lexers
      IO.read('lexers_db.txt').split(/\n/).each do |line|
        key = line.match(/(?mi)^((, )?[^,]+?)+?(?=\[)/)[0]
        keys = key.split(/,/).map(&:strip)
        value = line.match(/\[(.*?)\]/)[1]
        values = value.split(/,/).map(&:strip)

        @lexers << {
          lexer: keys.shift,
          aliases: keys,
          extensions: values
        }
      end
    end

    def ext_to_lang(ext)
      matches = @lexers.select { |lex| lex[:extensions].map(&:downcase).include?(ext.downcase) }
      matches.map { |lex| lex[:lexer] }.first
    end

    def lang_to_ext(lexer)
      matches = @lexers.select { |lex| lex[:lexer] == lexer || lex[:aliases].map(&:downcase).include?(lexer.downcase) }
      matches.map { |lex| lex[:extensions].first }.first
    end

    def syntax_from_extension(filename)
      ext_to_lang(filename.split(/\./)[1])
    end
  end
end
