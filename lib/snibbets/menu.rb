# frozen_string_literal: true

module Snibbets
  # Menu functions
  module Menu
    class << self
      def find_query_in_options(filename, res, query)
        options = res.map { |m| "#{filename} #{m['title']}" }
        words = query.split(/ +/)
        words.delete_if { |word| options.none? { |o| o =~ /#{word}/i } }
        words.map(&:downcase).join(' ')
      end

      def remove_items_without_query(filename, res, query)
        q = find_query_in_options(filename, res, query).split(/ /)
        res.delete_if do |opt|
          q.none? do |word|
            "#{filename} #{opt['title']}" =~ /#{word}/i
          end
        end
        res
      end

      def gum_menu(executable, res, title, query, filename)
        unless query.nil? || query.empty?
          res = remove_items_without_query(filename, res, query)
          return res[0] if res.count == 1
        end

        if res.count.zero?
          warn 'No matches found'
          Process.exit 1
        end

        options = res.map { |m| m['title'] }

        puts title
        args = [
          "--height=#{options.count}"
        ]
        selection = `echo #{Shellwords.escape(options.join("\n"))} | #{executable} filter #{args.join(' ')}`.strip
        Process.exit 1 if selection.empty?

        res.select { |m| m['title'] =~ /#{Regexp.escape(selection)}/ }[0]
      end

      def fzf_menu(executable, res, title, query, filename)
        orig_options = res.dup
        unless query.nil? || query.empty?
          res = remove_items_without_query(filename, res, query)
          return res[0] if res.count == 1
        end

        res = orig_options if res.count.zero?

        options = res.map { |m| "#{filename}: #{m['title']}" }
        q = query.nil? ? '' : find_query_in_options(filename, res, query)
        args = [
          "--height=#{options.count + 2}",
          %(--prompt="#{title} > "),
          '-1',
          %(--header="#{filename}"),
          # '--header-first',
          '--reverse',
          '--no-info',
          %(--query="#{q}"),
          '--tac'
        ]
        selection = `echo #{Shellwords.escape(options.join("\n"))} | #{executable} #{args.join(' ')}`.strip
        Process.exit 1 if selection.empty?

        result = res.select { |m| m['title'] == selection.sub(/^.*?: /, '') }

        result[0]
      end

      # Generate a numbered menu, items passed must have a title property
      def console_menu(res, title, filename, query: nil)
        unless query.nil? || query.empty?
          res = remove_items_without_query(filename, res, query)
          return res[0] if res.count == 1
        end

        if res.count.zero?
          warn 'No matches found'
          Process.exit 1
        end

        stty_save = `stty -g`.chomp

        trap('INT') do
          system('stty', stty_save)
          Process.exit 1
        end

        # Generate a numbered menu, items passed must have a title property('INT') { system('stty', stty_save); exit }
        counter = 1
        $stderr.puts
        res.each do |m|
          $stderr.printf("%<counter>2d) %<title>s\n", counter: counter, title: m['title'])
          counter += 1
        end
        $stderr.puts

        begin
          $stderr.printf(title.sub(/:?$/, ': '), res.length)
          while (line = Readline.readline('', true))
            unless line =~ /^[0-9]/
              system('stty', stty_save) # Restore
              exit
            end
            line = line.to_i
            return res[line - 1] if line.positive? && line <= res.length

            warn 'Out of range'
            console_menu(res, title)
          end
        rescue Interrupt
          system('stty', stty_save)
          exit
        end
      end

      def menu(res, filename: nil, title: 'Select one', query: nil)
        menu_opt = Snibbets.options[:menus]
        query&.remove_spotlight_tags!

        fzf = TTY::Which.which('fzf')
        gum = TTY::Which.which('gum')

        case menu_opt
        when /fzf/
          return fzf_menu(fzf, res, title, query, filename) unless fzf.empty?
        when /gum/
          return gum_menu(gum, res, title, query, filename) unless gum.empty?
        when /console/
          return console_menu(res, title, filename, query: query)
        end

        return fzf_menu(fzf, res, title, query, filename) unless fzf.empty?

        return gum_menu(gum, res, title, query, filename) unless gum.empty?

        console_menu(res, title, filename, query: query)
      end
    end
  end
end
