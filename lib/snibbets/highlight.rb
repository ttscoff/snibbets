module Snibbets
  module Highlight
    class << self
      def run_command_with_input(*cmd, input: nil, fallback: nil)
        stdout, _stderr, status = Open3.capture3(*cmd, stdin_data: input)
        if status.success?
          stdout
        elsif fallback.nil?
          input
        else
          run_command_with_input(fallback, input: input, fallback: nil)
        end
      end

      def highlight_pygments(executable, code, syntax, theme)
        syntax = syntax.nil? || syntax.empty? ? '-g' : "-l #{syntax}"
        theme = theme.nil? || theme.empty? ? '' : ",style=#{theme}"
        command = "#{executable} -O full#{theme} #{syntax}"
        fallback = "#{executable} -O full#{theme} -g"
        run_command_with_input(command, input: code, fallback: fallback)
      end

      def highlight_skylight(executable, code, syntax, theme)
        theme ||= 'nord'
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

        run_command_with_input("#{executable} #{theme}--syntax #{syntax}", input: code)
        # `echo #{Shellwords.escape(code)} | #{executable} #{theme}--syntax #{syntax}`
      end

      def highlight(code, filename, syntax, theme = nil)
        return code unless $stdout.isatty

        theme ||= Snibbets.options[:highlight_theme] || 'monokai'
        syntax ||= Lexers.syntax_from_extension(filename)

        return code if ['text'].include?(syntax)

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
