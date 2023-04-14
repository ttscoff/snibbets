#!/usr/bin/env ruby
# Snibbets 2.0.0

require 'optparse'
require 'readline'
require 'json'
require 'cgi'
require 'shellwords'

$search_path = File.expand_path("~/Desktop/Code/Snippets")

class String
  # Are there multiple snippets (indicated by ATX headers)
  def multiple?
    return self.scan(/^#+/).length > 1
  end

  # Is the snippet in this block fenced?
  def fenced?
    count = self.scan(/^```/).length
    return count > 1 && count.even?
  end

  def rx
    return ".*" + self.gsub(/\s+/,'.*') + ".*"
  end

  # remove outside comments, fences, and indentation
  def clean_code
    block = self

    # if it's a fenced code block, just discard the fence and everything
    # outside it
    if block.fenced?
      return block.gsub(/(?:^|.*?\n)(`{3,})(\w+)?(.*?)\n\1.*/m) {|m| $3.strip }
    end

    # assume it's indented code, discard non-indented lines and outdent
    # the rest
    indent = nil
    inblock = false
    code = []
    block.split(/\n/).each {|line|
      if line =~ /^\s*$/ && inblock
        code.push(line)
      elsif line =~ /^( {4,}|\t+)/
        inblock = true
        indent ||= Regexp.new("^#{$1}")
        code.push(line.sub(indent,''))
      else
        inblock = false
      end
    }
    code.join("\n")
  end

  # Returns an array of snippets. Single snippets are returned without a
  # title, multiple snippets get titles from header lines
  def snippets
    content = self.dup
    # If there's only one snippet, just clean it and return
    unless self.multiple?
      return [{"title" => "", "code" => content.clean_code.strip}]
    end

    # Split content by ATX headers. Everything on the line after the #
    # becomes the title, code is gleaned from text between that and the
    # next ATX header (or end)
    sections = []
    parts = content.split(/^#+/)
    parts.shift

    parts.each do |p|
      lines = p.split(/\n/)
      title = lines.shift.strip.sub(/[.:]$/, '')
      block = lines.join("\n")
      code = block.clean_code
      next unless code && !code.empty?

      sections << {
        'title' => title,
        'code' => code.strip
      }
    end
    return sections
  end
end

def gum_menu(executable, res, title)
  options = res.map { |m| m['title'] }
  puts title
  selection = `echo #{Shellwords.escape(options.join("\n"))} | #{executable} choose --limit 1`.strip
  Process.exit 1 if selection.empty?

  res.select { |m| m['title'] =~ /#{selection}/ }[0]
end

def fzf_menu(executable, res, title)
  options = res.map { |m| m['title'] }
  args = [
    "--height=#{options.count + 2}",
    %(--prompt="#{title} > "),
    '-1'
  ]
  selection = `echo #{Shellwords.escape(options.join("\n"))} | #{executable} #{args.join(' ')}`.strip
  Process.exit 1 if selection.empty?

  res.select { |m| m['title'] =~ /#{selection}/ }[0]
end

def menu(res, title = 'Select one')
  fzf = `which fzf`.strip
  return fzf_menu(fzf, res, title) unless fzf.empty?

  gum = `which gum`.strip
  return gum_menu(gum, res, title) unless gum.empty?

  console_menu(res, title)
end

# Generate a numbered menu, items passed must have a title property
def console_menu(res, title)
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
      menu(res, title)
    end
  rescue Interrupt
    system('stty', stty_save)
    exit
  end
end

# Search the snippets directory for query using find and grep
def search(query, folder, try = 0)
  # First try only search by filenames
  # Second try search with grep
  # Third try search with Spotlight name only
  # Fourth try search with Spotlight all contents
  cmd = case try
        when 0
          %(find "#{folder}" -iregex '#{query.rx}')
        when 1
          %(grep -iEl '#{query.rx}' "#{folder}/"*.md)
        when 2
          %(mdfind -onlyin "#{folder}" -name '#{query}' 2>/dev/null)
        when 3
          %(mdfind -onlyin "#{folder}" '#{query}' 2>/dev/null)
        end

  matches = `#{cmd}`.strip

  results = []

  if !matches.empty?
    lines = matches.split(/\n/)
    lines.each do |l|
      results << {
        'title' => File.basename(l, '.*'),
        'path' => l
      }
    end
    results
  else
    return [] if try > 2

    # if no results on the first try, try again searching all text
    search(query, folder, try + 1)
  end
end

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

  skylight = `which skylighting`.strip
  return highlight_skylight(skylight, code, syntax, theme) unless skylight.empty?

  pygments = `which pygmentize`.strip
  return highlight_pygments(pygments, code, syntax, theme) unless pygments.empty?

  code
end

def ext_to_lang(ext)
  case ext
  when /^(as|applescript|scpt)$/
    'applescript'
  when /^m$/
    'objective-c'
  when /^(pl|perl)$/
    'perl'
  when /^py$/
    'python'
  when /^(js|jq(uery)?|jxa)$/
    'javascript'
  when /^rb$/
    'ruby'
  when /^cc$/
    'c'
  when /^(ba|fi|z|c)?sh$/
    'bash'
  when /^pl$/
    'perl'
  else
    if %w[awk sed css sass scss less cpp php c sh swift html erb json xpath sql htaccess].include?(ext)
      ext
    else
      ''
    end
  end
end

def syntax_from_extension(filename)
  ext_to_lang(filename.split(/\./)[1])
end

options = {
    interactive: true,
    launchbar: false,
    output: 'raw',
    source: $search_path,
    highlight: false,
    all: false
  }

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options] query"

  opts.on('-q', '--quiet', 'Skip menus and display first match') do
    options[:interactive] = false
    options[:launchbar] = false
  end

  opts.on('-a', '--all', 'If a file contains multiple snippets, output all of them (no menu)') do
    options[:all] = true
  end

  opts.on('-o', '--output FORMAT', 'Output format (launchbar or raw)') do |outformat|
    valid = %w[json launchbar lb raw]
    if outformat.downcase =~ /(launchbar|lb)/
      options[:launchbar] = true
      options[:interactive] = false
    elsif valid.include?(outformat.downcase)
      options[:output] = outformat.downcase
    end
  end

  opts.on('-s', '--source FOLDER', 'Snippets folder to search') do |folder|
    options[:source] = File.expand_path(folder)
  end

  opts.on('--highlight', 'Use pygments or skylighting to syntax highlight (if installed)') do
    options[:highlight] = true
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts optparse
    Process.exit 0
  end
end

optparse.parse!

query = ''

if options[:launchbar]
  query = if $stdin.stat.size.positive?
            $stdin.read.force_encoding('utf-8')
          else
            ARGV.join(' ')
          end
elsif ARGV.length
  query = ARGV.join(' ')
end

query = CGI.unescape(query)

if query.strip.empty?
  puts 'No search query'
  puts optparse
  Process.exit 1
end

results = search(query, options[:source], 0)

if options[:launchbar]
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
else
  filepath = nil
  if results.empty?
    warn 'No results'
    Process.exit 0
  elsif results.length == 1 || !options[:interactive]
    filepath = results[0]['path']
    input = IO.read(filepath)
  else
    answer = menu(results, 'Select a file')
    filepath = answer['path']
    input = IO.read(filepath)
  end

  snippets = input.snippets

  if snippets.empty?
    warn 'No snippets found'
    Process.exit 0
  elsif snippets.length == 1 || !options[:interactive]
    if options[:output] == 'json'
      $stdout.puts snippets.to_json
    else
      snippets.each do |snip|
        code = snip['code']
        code = highlight(code, filepath) if options[:highlight]
        $stdout.puts code
      end
    end
  elsif snippets.length > 1
    if options[:all]
      if options[:output] == 'json'
        $stdout.puts snippets.to_json
      else
        snippets.each do |snippet|
          $stdout.puts snippet['title']
          $stdout.puts '------'
          $stdout.puts snippet['code']
          $stdout.puts
        end
      end
    else
      answer = menu(snippets, 'Select snippet')
      if options[:output] == 'json'
        $stdout.puts answer.to_json
      else
        code = answer['code']
        code = highlight(code, filepath) if options[:highlight]
        $stdout.puts code
      end
    end
  end
end
