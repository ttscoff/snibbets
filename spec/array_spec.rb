# frozen_string_literal: true

RSpec.describe ::Array do
  subject(:test_array) { ['', '', 'not empty', '', '', ''] }

  describe '.blocks' do
    it 'counts blocks' do
      expect(['title', '<block1>', '<block2>'].blocks).to eq(2)
    end
  end

  describe '.strip_empty' do
    it 'removes 4 lines' do
      expect(test_array.strip_empty.count).to eq(1)
    end
  end

  describe '.strip_empty!' do
    it 'strips empty elements destructively' do
      arr = test_array.dup
      arr.strip_empty!
      expect(arr.count).to eq(1)
    end
  end

  describe '.remove_leading_empty_elements' do
    it 'removes first two elements' do
      expect(test_array.remove_leading_empty_elements.count).to eq(4)
    end
  end

  describe '.remove_leading_empty_elements' do
    it 'removes last two elements' do
      expect(test_array.remove_trailing_empty_elements.count).to eq(3)
    end
  end
end
