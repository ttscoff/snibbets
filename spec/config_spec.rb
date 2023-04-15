# frozen_string_literal: true

RSpec.describe Snibbets::Config do
  subject(:config) { Snibbets::Config.new }

  describe '.best_editor' do
    it 'returns editor' do
      expect(config.best_editor).not_to be nil
    end
  end

  describe '.best_menu' do
    it 'returns menu' do
      expect(config.best_menu).not_to be nil
    end
  end

  describe '.config_dir' do
    it 'returns dir path' do
      expect(config.config_dir).to eq("#{ENV['HOME']}/.config/snibbets")
    end
  end

  describe '.config_file' do
    it 'returns file path' do
      expect(config.config_file).to eq("#{ENV['HOME']}/.config/snibbets/snibbets.yml")
    end
  end
end
