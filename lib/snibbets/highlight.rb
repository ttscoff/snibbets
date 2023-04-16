module Snibbets
  module Highlight
    class << self
      def highlight_pygments(executable, code, syntax, theme)
        puts [syntax, theme]
        # syntax = syntax.nil? || syntax.empty? ? '-g' : "-l #{syntax}"
        theme = theme.nil? || theme.empty? ? '' : ",style=#{theme}"
        `echo #{Shellwords.escape(code)} | #{executable} -O full#{theme} -g` # #{theme}
      end

      def highlight_skylight(executable, code, syntax, theme)
        theme ||= 'monokai'
        theme_file = File.join(__dir__, '..', "#{theme}.theme")
        puts theme_file
        theme = if File.exist?(theme_file)
                  "-t #{theme_file} "
                else
                  ''
                end
        return code if syntax.nil? || syntax.empty?

        `echo #{Shellwords.escape(code)} | #{executable} #{theme}--syntax #{syntax}`
      end

      def highlight(code, filename, theme = nil)
        theme ||= Snibbets.options[:highlight_theme]
        syntax = Lexers.syntax_from_extension(filename)

        skylight = TTY::Which.which('skylighting')
        pygments = TTY::Which.which('pygmentize')

        if Snibbets.options[:highlighter] =~ /^s/ && skylight
          return highlight_skylight(skylight, code, syntax, theme)
        elsif Snibbets.options[:highlighter] =~ /^p/ && !pygments.empty?
          return highlight_pygments(pygments, code, syntax, theme)
        elsif !skylight.empty?
          return highlight_skylight(skylight, code, syntax, theme)
        elsif !pygments.empty?
          return highlight_pygments(pygments, code, syntax, theme)
        end

        code
      end
    end
  end
end
