# frozen_string_literal: true

RSpec.describe Snibbets::Config do
  subject(:config_class) { Snibbets::Config }
  subject(:config) { Snibbets::Config.new }

  describe ':DEFAULT_OPTIONS' do
    it 'defines defaults' do
      expect(config_class::DEFAULT_OPTIONS).not_to be nil
    end
  end

  describe '#initialize' do
    it 'initializes config' do
      expect(config.options).not_to be nil
    end
  end

  describe '.best_editor' do
    context 'based on existence of executables' do
      it 'returns EDITOR' do
        config.test_editor = 'EDITOR'
        expect(config.best_editor).to eq(ENV['EDITOR'])
      end

      it 'returns GIT_EDITOR' do
        config.test_editor = 'GIT_EDITOR'
        expect(config.best_editor).to eq(ENV['GIT_EDITOR'])
      end

      it 'returns path to code' do
        config.test_editor = 'code'
        expect(config.best_editor).to eq(`which code`.strip)
      end

      it 'returns path to subl' do
        config.test_editor = 'subl'
        expect(config.best_editor).to eq(`which subl`.strip)
      end

      it 'returns path to vim' do
        config.test_editor = 'vim'
        expect(config.best_editor).to eq(`which vim`.strip)
      end

      it 'returns path to nano' do
        config.test_editor = 'nano'
        expect(config.best_editor).to eq(`which nano`.strip)
      end

      it 'returns TextEdit' do
        config.test_editor = nil
        expect(config.best_editor).to eq('TextEdit')
      end
    end
  end

  describe '.best_menu' do
    context 'based on existence of executables' do
      it 'returns fzf' do
        config.test_editor = 'fzf'
        expect(config.best_menu).to eq('fzf')
      end

      it 'returns gum' do
        config.test_editor = 'gum'
        expect(config.best_menu).to eq('gum')
      end

      it 'returns console' do
        config.test_editor = nil
        expect(config.best_menu).to eq('console')
      end
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

  describe '.read_config' do
    it 'reads configuration' do
      expect(config.read_config).not_to be nil
    end

    it 'fails to read non-existant file' do
      old_config = config.config_file
      config.config_file = 'well shit'
      expect(config.read_config).to eq({})
      config.config_file = old_config
    end
  end

  describe '.write_config' do
    it 'write config file' do
      expect(config.write_config).to be true
    end
  end
end
