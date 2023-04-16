# frozen_string_literal: true

RSpec.describe Snibbets::Lexers do
  subject(:lexers) { Snibbets::Lexers }

  describe '.lexers' do
    it 'builds lexer list' do
      expect(lexers.lexers).not_to be nil
    end
  end

  describe '.ext_to_lang' do
    context 'given an extension' do
      it 'turns rb to ruby' do
        expect(lexers.ext_to_lang('rb')).to eq('ruby')
      end

      it 'turns ts to typescript' do
        expect(lexers.ext_to_lang('ts')).to eq('typescript')
      end
    end
  end

  describe '.lang_to_ext' do
    context 'given a language' do
      it 'turns ruby to rb' do
        expect(lexers.lang_to_ext('ruby')).to eq('rb')
      end

      it 'turns typescript to ts' do
        expect(lexers.lang_to_ext('typescript')).to eq('ts')
      end
    end
  end

  describe '.syntax_from_extension' do
    context 'given a filename' do
      it 'turns filename.rb to ruby' do
        expect(lexers.syntax_from_extension('filename.rb.md')).to eq('ruby')
      end
    end
  end
end
