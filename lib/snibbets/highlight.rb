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
        return code if syntax.nil? || syntax.empty? || !Lexers.skylight_lexer?(syntax)

        run_command_with_input("#{executable} #{theme}--syntax #{syntax}", input: code)
      end

      def highlight_fences(code, filename, syntax)
        content = code.dup

        content.fences.each do |f|
          rx = Regexp.new(Regexp.escape(f[:code]))
          syn = Lexers.normalize_lexer(f[:lang] || syntax)
          highlighted = highlight(f[:code].gsub(/\\k</, '\k\<'), filename, syn).strip
          code.sub!(/#{rx}/, highlighted)
        end

        Snibbets.options[:all_notes] ? code.gsub(/k\\</, 'k<') : code.gsub(/k\\</, 'k<').clean_code
      end

      def highlight(code, filename, syntax, theme = nil)
        unless $stdout.isatty
          return Snibbets.options[:all_notes] && code.replace_blocks[0].notes? ? code : code.clean_code
        end

        return highlight_fences(code, filename, syntax) if code.fenced?

        theme ||= Snibbets.options[:highlight_theme] || 'monokai'
        syntax ||= Lexers.syntax_from_extension(filename)
        syntax = Lexers.normalize_lexer(syntax)

        return code if ['text'].include?(syntax)

        skylight = TTY::Which.which('skylighting')
        pygments = TTY::Which.which('pygmentize')

        if Snibbets.options[:highlighter] =~ /^s/ && !skylight.nil?
          if !Lexers.skylight_lexer?(syntax) && !pygments.nil?
            return highlight_pygments(pygments, code, syntax, 'monokai')
          else
            return highlight_skylight(skylight, code, syntax, theme)
          end
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
