# frozen_string_literal: true

RSpec.describe TTY::Which do
  subject(:which) { TTY::Which }

  describe '.app_bundle' do
    it 'detects an existing app bundle' do
      expect(which.app_bundle('CodeRunner.app')).to eq('CodeRunner')
    end

    it 'fails on incorrect name' do
      expect(which.app_bundle('Blarney.app')).to be false
    end
  end

  describe '.bundle_id?' do
    it 'detects a bundle id' do
      expect(which.bundle_id?('com.brettterpstra.marked2')).to be true
    end

    it 'discards a bad bundle id' do
      expect(which.bundle_id?('com.brettterpstra')).to be false
    end
  end

  describe '.app?' do
    it 'turns detects an existing app' do
      expect(which.app?('/Applications/Sublime Text.app')).to eq('/Applications/Sublime Text.app')
    end

    it 'finds an app based on name' do
      expect(which.app?('Sublime Text.app')).to eq('Sublime Text')
    end

    it 'returns false on nonexistant app' do
      expect(which.app?('Blarney.app')).to be false
    end
  end
end
