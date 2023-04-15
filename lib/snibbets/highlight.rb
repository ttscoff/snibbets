module Snibbets
  class Highlight
    def highlight_pygments(executable, code, syntax, theme)
      syntax = syntax.empty? ? '-g' : "-l #{syntax}"
      `echo #{Shellwords.escape(code)} | #{executable} #{syntax}`
    end

    def highlight_skylight(executable, code, syntax, theme)
      return code if syntax.empty?

      `echo #{Shellwords.escape(code)} | #{executable} --syntax #{syntax}`
    end

    def highlight(code, filename, theme = 'monokai')
      syntax = syntax_from_extension(filename)

      skylight = TTY::Which.which('skylighting')
      return highlight_skylight(skylight, code, syntax, theme) unless skylight.empty?

      pygments = TTY::Which.which('pygmentize')
      return highlight_pygments(pygments, code, syntax, theme) unless pygments.empty?

      code
    end
  end
end
