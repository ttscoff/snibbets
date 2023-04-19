# frozen_string_literal: true

module Snibbets
  # String helpers
  class ::String
    def remove_spotlight_tags
      words = Shellwords.shellsplit(self)
      words.delete_if do |word|
        word =~ /^\w+:/
      end

      words.join(' ').strip
    end

    def remove_spotlight_tags!
      replace remove_spotlight_tags
    end

    def strip_empty
      split(/\n/).strip_empty.join("\n")
    end

    def remove_meta
      input = dup
      lines = input.split(/\n/)
      loop do
        line = lines[0]
        lines.shift if line =~ /^\s*[A-Z\s]+\w:\s*\S+/i || line =~ /^-{3,}\s*$/

        break
      end
      lines.join("\n")
    end

    def strip_newlines
      split(/\n/).strip_empty.join("\n")
    end

    # Are there multiple snippets (indicated by ATX headers)
    def multiple?
      gsub(/(`{3,}).*?\n\1/m, '').scan(/^#+/).length > 1
    end

    # Is the snippet in this block fenced?
    def fenced?
      count = scan(/^```/).length
      count > 1 && count.even?
    end

    def blocks
      replace_blocks[1].count
    end

    def blocks?
      blocks.positive?
    end

    def notes?
      split("\n").notes.positive?
    end

    # Return array of fenced code blocks
    def fences
      return [] unless fenced?

      rx = /(?mi)^(?<fence>`{3,})(?<lang> *\S+)? *\n(?<code>[\s\S]*?)\n\k<fence> *(?=\n|\Z)/
      matches = []
      scan(rx) { matches << Regexp.last_match }
      matches.each_with_object([]) { |m, fenced| fenced.push({ code: m['code'], lang: m['lang'] }) }
    end

    def indented?
      self =~ /^( {4,}|\t+)/
    end

    def rx
      ".*#{gsub(/\s+/, '.*')}.*"
    end

    # remove outside comments, fences, and indentation
    def clean_code
      block = dup

      # if it's a fenced code block, just discard the fence and everything
      # outside it
      if block.fenced?
        code_blocks = block.scan(/(`{3,})(\w+)?\s*\n(.*?)\n\1/m)
        code_blocks.map! { |b| b[2].strip }
        return code_blocks.join("\n\n")
      end

      # assume it's indented code, discard non-indented lines and outdent
      # the rest
      block = block.outdent if block.indented?

      block
    end

    def outdent
      lines = split(/\n/)

      incode = false
      code = []
      lines.each do |line|
        next if line =~ /^\s*$/ && !incode

        incode = true
        code.push(line)
      end

      return self unless code[0]

      indent = code[0].match(/^( {4,}|\t+)(?=\S)/)

      return self if indent.nil?

      code.map! { |line| line.sub(/(?mi)^#{indent[1]}/, '') }.join("\n")
    end

    def replace_blocks
      sans_blocks = dup
      counter = 0
      code_blocks = {}

      if Snibbets.options[:include_blockquotes]
        sans_blocks = sans_blocks.gsub(/(?mi)(^(>.*?)(\n|$))+/) do
          counter += 1
          code_blocks["block#{counter}"] = Regexp.last_match(0).gsub(/^> *(?=\S)/, '# ')
          "<block#{counter}>\n"
        end
      end

      sans_blocks = sans_blocks.gsub(/(?mi)^(`{3,})( *\S+)? *\n([\s\S]*?)\n\1 *(\n|\Z)/) do
        counter += 1
        lang = Regexp.last_match(2)
        lang = "<lang:#{lang.strip}>\n" if lang
        code_blocks["block#{counter}"] = "#{lang}#{Regexp.last_match(3)}"
        "<block#{counter}>\n"
      end

      sans_blocks = sans_blocks.gsub(/(?mi)(?<=\n\n|\A)\n?((?: {4,}|\t+)\S[\S\s]*?)(?=\n\S|\Z)/) do
        counter += 1
        code = Regexp.last_match(1).split(/\n/)

        code_blocks["block#{counter}"] = code.join("\n").outdent
        "<block#{counter}>\n"
      end

      [sans_blocks, code_blocks]
    end

    def parse_lang_marker(block)
      lang = nil
      if block =~ /<lang:(.*?)>/
        lang = Regexp.last_match(1)
        block = block.gsub(/<lang:.*?>\n+/, '').strip_empty
      end

      [lang, block]
    end

    def restore_blocks(parts, code_blocks)
      sections = []

      parts.each do |part|
        lines = part.split(/\n/).strip_empty

        notes = part.notes?

        next if lines.blocks.zero? && !notes

        title = if lines.count > 1 && lines[0] !~ /<block\d+>/ && lines[0] =~ /^ +/
                  lines.shift.strip.sub(/[.:]$/, '')
                else
                  'Default snippet'
                end

        block = lines.join("\n").gsub(/<(block\d+)>/) do
          code = code_blocks[Regexp.last_match(1)].strip_empty
          lang, code = parse_lang_marker(code)
          "\n```#{lang}\n#{code.strip}\n```"
        end

        lang, code = parse_lang_marker(block)

        next unless code && !code.empty?

        # code = code.clean_code unless notes || code.fences.count > 1

        sections << {
          'title' => title,
          'code' => code.strip_empty,
          'language' => lang
        }
      end

      sections
    end

    # Returns an array of snippets. Single snippets are returned without a
    # title, multiple snippets get titles from header lines
    def snippets
      content = dup.remove_meta
      # If there's only one snippet, just clean it and return
      # return [{ 'title' => '', 'code' => content.clean_code.strip }] unless multiple?

      # Split content by ATX headers. Everything on the line after the #
      # becomes the title, code is gleaned from text between that and the
      # next ATX header (or end)
      sans_blocks, code_blocks = content.replace_blocks

      parts = if Snibbets.options[:all_notes]
                sans_blocks.split(/^#+/)
              elsif sans_blocks =~ /<block\d+>/
                sans_blocks.split(/\n/).each_with_object([]) do |line, arr|
                  arr << line if line =~ /^#/ || line =~ /<block\d+>/
                end.join("\n").split(/^#+/)
              else
                sans_blocks.gsub(/\n{2,}/, "\n\n").split(/^#+/)
              end

      # parts.shift if parts.count > 1

      restore_blocks(parts, code_blocks)
    end
  end
end
