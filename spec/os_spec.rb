# frozen_string_literal: true

RSpec.describe Snibbets::OS do
  subject(:os) { Snibbets::OS }

  describe '.copy' do
    it 'copies text' do
      text = 'copy this text'
      os.copy(text)
      expect(`pbpaste`.strip).to eq(text)
    end
  end

  describe '.paste' do
    it 'pastes text' do
      text = 'copy this text 2'
      os.copy(text)
      expect(os.paste).to eq(text)
    end
  end
end
