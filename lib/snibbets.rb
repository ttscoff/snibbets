# frozen_string_literal: true

require 'optparse'
require 'readline'
require 'json'
require 'cgi'
require 'shellwords'
require 'yaml'
require 'fileutils'
require 'tty-which'
require 'open3'
require_relative 'snibbets/version'
require_relative 'snibbets/config'
require_relative 'snibbets/which'
require_relative 'snibbets/string'
require_relative 'snibbets/hash'
require_relative 'snibbets/array'
require_relative 'snibbets/menu'
require_relative 'snibbets/os'
require_relative 'snibbets/highlight'
require_relative 'snibbets/lexers'

# Top level module
module Snibbets
  class << self
    def config
      @config ||= Config.new
    end

    def options
      @options = config.options
    end

    def arguments
      @arguments = config.arguments
    end
  end
end

module Snibbets
  class << self
    def change_query(query)
      @query = query
    end

    # Search the snippets directory for query using find and grep
    def search(try: 0)
      folder = File.expand_path(Snibbets.options[:source])
      # start by doing a spotlight search, if that fails, start trying:
      # First try only search by filenames
      # Second try search with grep
      ext = Snibbets.options[:extension] || 'md'
      cmd = case try
            when 1
              %(find "#{folder}" -iregex '^#{Regexp.escape(folder)}/#{@query.rx}' -name '*.#{ext}')
            when 2
              rg = TTY::Which.which('rg')
              ag = TTY::Which.which('ag')
              ack = TTY::Which.which('ack')
              grep = TTY::Which.which('grep')
              if Snibbets.options[:name_only]
                nil
              elsif !rg.empty?
                %(#{rg} -li --color=never --glob='*.#{ext}' '#{@query.rx}' "#{folder}")
              elsif !ag.empty?
                %(#{ag} -li --nocolor -G '.*.#{ext}' '#{@query.rx}' "#{folder}")
              elsif !ack.empty?
                %(#{ack} -li --nocolor --markdown '#{@query.rx}' "#{folder}")
              elsif !grep.empty?
                %(#{grep} -iEl '#{@query.rx}' "#{folder}"/**/*.#{ext})
              else
                nil
              end
            else
              mdfind = TTY::Which.which('mdfind')
              if mdfind.empty?
                nil
              else
                name_only = Snibbets.options[:name_only] ? '-name ' : ''
                %(mdfind -onlyin #{folder} #{name_only}'#{@query} filename:.#{ext}' 2>/dev/null)
              end
            end

      if try == 2 && cmd.nil?
        puts "No search method available on this system. Please install ripgrep, silver surfer, ack, or grep."
        Process.exit 1
      end

      res = cmd.nil? ? '' : `#{cmd}`.strip

      matches = []

      unless res.empty?
        lines = res.split(/\n/)
        lines.each do |l|
          matches << {
            'title' => File.basename(l, '.*'),
            'path' => l
          }
        end

        matches.sort_by! { |a| a['title'] }.uniq!

        return matches unless matches.empty?
      end

      return matches if try == 2

      # if no results on the first try, try again searching all text
      search(try: try + 1) if matches.empty?
    end

    def open_snippet_in_editor(filepath)
      editor = Snibbets.options[:editor] || Snibbets::Config.best_editor

      os = RbConfig::CONFIG['target_os']

      if editor.nil?
        OS.open(filepath)
      else
        if os =~ /darwin.*/i
          if editor =~ /^TextEdit/
            `open -a TextEdit "#{filepath}"`
          elsif TTY::Which.bundle_id?(editor)
            `open -b "#{editor}" "#{filepath}"`
          elsif TTY::Which.app?(editor)
            `open -a "#{editor}" "#{filepath}"`
          elsif TTY::Which.exist?(editor)
            editor = TTY::Which.which(editor)
            system %(#{editor} "#{filepath}") if editor
          else
            puts "No editor configured, or editor is missing"
            Process.exit 1
          end
        elsif TTY::Which.exist?(editor)
          editor = TTY::Which.which(editor)
          system %(#{editor} "#{filepath}") if editor
        else
          puts "No editor configured, or editor is missing"
          Process.exit 1
        end
      end
    end

    def new_snippet_from_clipboard
      trap('SIGINT') do
        Howzit.console.info "\nCancelled"
        exit!
      end

      pb = OS.paste.outdent

      printf 'What does this snippet do? '
      input = $stdin.gets.chomp
      title = input unless input.empty?

      printf 'What language(s) does it use (separate with spaces, full names or file extensions will work)? '
      input = $stdin.gets.chomp
      langs = input.split(/ +/).map(&:strip) unless input.empty?
      exts = langs.map { |lang| Lexers.lang_to_ext(lang) }.delete_if(&:nil?)
      tags = langs.map { |lang| Lexers.ext_to_lang(lang) }.concat(langs).delete_if(&:nil?).sort.uniq

      exts = langs if exts.empty?

      filename = "#{title}.#{exts.join('.')}.#{Snibbets.options[:extension]}"

      File.open(File.join(File.expand_path(Snibbets.options[:source]), filename), 'w') do |f|
        f.puts "tags: #{tags.join(', ')}

    ```
    #{pb}
    ```"
      end

      puts "New snippet written to #{filename}."
    end

    def handle_launchbar(results)
      output = []

      if results.empty?
        out = {
          'title' => 'No matching snippets found'
        }.to_json
        puts out
        Process.exit
      end

      results.each do |result|
        input = IO.read(result['path'])
        snippets = input.snippets
        next if snippets.empty?

        children = []

        if snippets.length == 1
          output << {
            'title' => result['title'],
            'path' => result['path'],
            'action' => 'copyIt',
            'actionArgument' => snippets[0]['code'],
            'label' => 'Copy'
          }
          next
        end

        snippets.each { |s|
          children << {
            'title' => s['title'],
            'path' => result['path'],
            'action' => 'copyIt',
            'actionArgument' => s['code'],
            'label' => 'Copy'
          }
        }

        output << {
          'title' => result['title'],
          'path' => result['path'],
          'children' => children
        }
      end

      puts output.to_json
    end

    def handle_results(results)
      if Snibbets.options[:launchbar]
        handle_launchbar(results)
      else
        filepath = nil
        if results.empty?
          warn 'No results'
          Process.exit 0
        elsif results.length == 1 || !Snibbets.options[:interactive]
          filepath = results[0]['path']
          input = IO.read(filepath)
        else
          answer = Snibbets::Menu.menu(results, title: 'Select a file')
          filepath = answer['path']
          input = IO.read(filepath)
        end

        if Snibbets.arguments[:edit_snippet]
          open_snippet_in_editor(filepath)
          Process.exit 0
        end

        snippets = input.snippets

        if snippets.empty?
          warn 'No snippets found'
          Process.exit 0
        elsif snippets.length == 1 || !Snibbets.options[:interactive]
          if Snibbets.options[:output] == 'json'
            print(snippets.to_json, filepath)
          else
            snippets.each do |snip|
              header = File.basename(filepath, '.md')
              warn header
              warn '-' * header.length
              code = snip['code']
              lang = snip['language']
              print(code, filepath, lang)
            end
          end
        elsif snippets.length > 1
          if Snibbets.options[:all]
            if Snibbets.options[:output] == 'json'
              print(snippets.to_json, filepath)
            else

              snippets.each do |snippet|
                lang = snippet['language']
                warn "### #{snippet['title']} ###"
                # warn "# #{'-' * snippet['title'].length}"
                print(snippet['code'], filepath, lang)
                puts
              end
            end
          else
            snippets.push({ 'title' => 'All snippets', 'code' => '' })

            answer = Menu.menu(snippets, filename: File.basename(filepath, '.md'), title: 'Select snippet', query: @query)

            if answer['title'] == 'All snippets'
              snippets.delete_if { |s| s['title'] == 'All snippets' }
              if Snibbets.options[:output] == 'json'
                print(snippets.to_json, filepath)
              else
                header = File.basename(filepath, '.md')
                warn header
                warn '=' * header.length

                snippets.each do |snippet|
                  lang = snippet['language']
                  warn "### #{snippet['title']} ###"
                  # warn "# #{'-' * snippet['title'].length}"
                  print(snippet['code'], filepath, lang)
                  puts
                end

              end
            elsif Snibbets.options[:output] == 'json'
              print(answer.to_json, filepath)
            else
              header = "#{File.basename(filepath, '.md')}: #{answer['title']}"
              warn header
              warn '-' * header.length
              code = answer['code']
              lang = answer['language']
              print(code, filepath, lang)
            end
          end
        end
      end
    end

    def print(output, filepath, syntax = nil)
      if Snibbets.options[:highlight] && Snibbets.options[:output] == 'raw'
        $stdout.puts(Highlight.highlight(output, filepath, syntax))
      else
        $stdout.puts(output)
      end
      if Snibbets.options[:copy]
        OS.copy(output)
        $stderr.puts "Copied to clipboard"
      end
    end
  end
end
