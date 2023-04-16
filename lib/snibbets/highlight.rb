module Snibbets
  module Highlight
    class << self
      def highlight_pygments(executable, code, syntax, theme)
        syntax = syntax.empty? ? '-g' : "-l #{syntax}"
        `echo #{Shellwords.escape(code)} | #{executable} -O full,style=#{theme} #{syntax}`
      end

      def highlight_skylight(executable, code, syntax, theme)
        return code if syntax.empty?

        `echo #{Shellwords.escape(code)} | #{executable} -t lib/breeze-dark.theme --syntax #{syntax}`
      end

      def highlight(code, filename, theme = 'monokai')
        syntax = Lexers.syntax_from_extension(filename)

        skylight = TTY::Which.which('skylighting')
        pygments = TTY::Which.which('pygmentize')

        if Snibbets.options[:highlighter] =~ /^s/ && skylight
          return highlight_skylight(skylight, code, syntax, theme)
        elsif Snibbets.options[:highlighter] =~ /^p/ && !pygments.empty?
          return highlight_pygments(pygments, code, syntax, theme)
        else
          if !skylight.empty?
            return highlight_skylight(skylight, code, syntax, theme)
          elsif !pygments.empty?
            return highlight_pygments(pygments, code, syntax, theme)
          end
        end

        code
      end
    end
  end
end
