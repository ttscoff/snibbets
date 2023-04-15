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

    def remove_meta
      input = dup
      lines = input.split(/\n/)
      loop do
        line = lines.shift
        next if line =~ /^\s*[A-Z\s]+\w:\s*\S+/i || line =~ /^-{3,}\s*$/

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

      if indent
        code.map! { |line| line.sub(/(?mi)^#{indent[1]}/, '') }.join("\n")
      else
        self
      end
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
      sections = []
      counter = 0
      code_blocks = {}

      sans_blocks = content.gsub(/^(`{3,})(\w+)?\s*\n(.*?)\n\1/m) do
        counter += 1
        code_blocks["block#{counter}"] = Regexp.last_match(3)
        "<block#{counter}>\n"
      end

      sans_blocks = sans_blocks.gsub(/(?mi)^((?:\s{4,}|\t+)\S[\S\s]*?)(?=\n\S|\Z)/) do
        counter += 1
        code = Regexp.last_match(1).split(/\n/)

        code_blocks["block#{counter}"] = code.join("\n").outdent

        "<block#{counter}>\n"
      end

      content = []
      if sans_blocks =~ /<block\d+>/
        sans_blocks.each_line do |line|
          content << line if line =~ /^#/ || line =~ /<block\d+>/
        end

        parts = content.join("\n").split(/^#+/)
      else
        parts = sans_blocks.gsub(/\n{2,}/, "\n\n").split(/^#+/)
      end

      parts.shift if parts.count > 1

      parts.each do |part|
        lines = part.split(/\n/).strip_empty

        next if lines.blocks == 0

        title = lines.count > 1 ? lines.shift.strip.sub(/[.:]$/, '') : 'Default snippet'
        block = lines.join("\n").gsub(/<(block\d+)>/) { code_blocks[Regexp.last_match(1)] }

        code = block.clean_code

        next unless code && !code.empty?

        sections << {
          'title' => title,
          'code' => code
        }
      end

      sections
    end
  end
end