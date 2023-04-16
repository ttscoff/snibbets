module Snibbets
  module Highlight
    class << self
      def highlight_pygments(executable, code, syntax, theme)
        puts [syntax, theme]
        # syntax = syntax.nil? || syntax.empty? ? '-g' : "-l #{syntax}"
        theme = theme.nil? || theme.empty? ? '' : ",style=#{theme}"
        `echo #{Shellwords.escape(code)} | #{executable} -O full#{theme} -g` # #{syntax}
      end

      def highlight_skylight(executable, code, syntax, theme)
        theme ||= 'monokai'
        theme_file = if theme =~ %r{^[/~].*?(\.theme)?$}
                       theme = theme.sub(/(\.theme)?$/, '.theme')
                       File.expand_path(theme)
                     else
                       theme = theme.sub(/\.theme$/, '')
                       File.join(__dir__, '..', 'themes', "#{theme}.theme")
                     end

        theme = if File.exist?(theme_file)
                  "-t #{theme_file} "
                else
                  ''
                end
        return code if syntax.nil? || syntax.empty?

        `echo #{Shellwords.escape(code)} | #{executable} #{theme}--syntax #{syntax}`
      end

      def highlight(code, filename, theme = nil)
        return code unless $stdout.isatty

        theme ||= Snibbets.options[:highlight_theme]
        syntax = Lexers.syntax_from_extension(filename)

        skylight = TTY::Which.which('skylighting')
        pygments = TTY::Which.which('pygmentize')

        if Snibbets.options[:highlighter] =~ /^s/ && !skylight.nil?
          return highlight_skylight(skylight, code, syntax, theme)
        elsif Snibbets.options[:highlighter] =~ /^p/ && !pygments.nil?
          return highlight_pygments(pygments, code, syntax, theme)
        elsif !skylight.nil?
          return highlight_skylight(skylight, code, syntax, theme)
        elsif !pygments.nil?
          return highlight_pygments(pygments, code, syntax, theme)
        end

        code
      end
    end
  end
end
