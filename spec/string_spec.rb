# frozen_string_literal: true

RSpec.describe Snibbets do
  string1 = <<~EOSTRING1
    This is a note

          this is indented code

    * on the other hand
    * this is a list
      * with indentation

          This, however, is indented code

    And here's a little note

    > This is a block quote note

        So is this
  EOSTRING1

  string2 = <<~EOSTRING2
    tags: tag1, tag2

    # Snippet 1

        def hello
          puts 'hello'
        end

    # Snippet 2

    ```ruby
    This is a code block
    ```
  EOSTRING2

  string3 = <<~EOSTRING3
    This note has no code blocks

    It's just some text

    nothing else
  EOSTRING3

  describe '.replace_blocks' do
    it 'detects 3 indented blocks and block quote' do
      Snibbets.options[:include_blockquotes] = true
      _, blocks = string1.replace_blocks
      expect(string1.blocks).to eq(4)
    end
  end

  describe '.snippets' do
    it 'detects 2 snippets' do
      sections = string2.snippets
      expect(sections.count).to eq(2)
    end
  end

  describe '.blocks' do
    it 'detects 3 blocks' do
      Snibbets.options[:include_blockquotes] = false
      expect(string1.blocks).to eq(3)
    end

    it 'detects 2 blocks' do
      expect(string2.blocks).to eq(2)
    end

    it 'detects no blocks' do
      expect(string3.blocks).to eq(0)
    end
  end

  describe '.multiple?' do
    it 'detects multiple snippets' do
      expect(string2.multiple?).to be true
    end
  end

  describe '.rx' do
    it 'converts to a regular expression' do
      expect('test string'.rx).to eq('.*test.*string.*')
    end
  end

  describe '.clean_code' do
    it 'cleans code' do
      code = <<~EOCODE
        ```ruby
        def hello
          puts 'hello'
        end
        ```
      EOCODE
      expect(code.clean_code).to eq(%(def hello
  puts 'hello'
end))
    end
  end

  describe '.outdent' do
    it 'outdents properly' do
      indented = '    This text
      is indented
        a few spaces'
      to_match = 'This text
  is indented
    a few spaces'
      expect(indented.outdent).to eq(to_match)
      expect('this is not indented').to eq('this is not indented')
    end
  end

  describe '.strip_newlines' do
    it 'removes empty lines' do
      str = <<~EOSTR


      This has newlines


      EOSTR
      expect(str.strip_newlines).to eq('This has newlines')
    end
  end

  describe '.remove_spotlight_tags' do
    it 'removes all name:value pairs' do
      str = %(tag:test filename:.md tag:"multi word" text)
      expect(str.remove_spotlight_tags).to eq('text')
    end
  end

  describe '.remove_spotlight_tags!' do
    it 'removes all name:value pairs' do
      str = %(tag:test filename:.md tag:"multi word" text)
      str = str.dup
      str.remove_spotlight_tags!
      expect(str).to eq('text')
    end
  end
end
