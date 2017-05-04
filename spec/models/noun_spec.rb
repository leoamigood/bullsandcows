require 'rails_helper'

describe Noun, type: :model do

  context 'given dictionaries' do
    let!(:english) { create :dictionary, :english, enabled: true }
    let!(:russian) { create :dictionary, :russian, enabled: true }
    let!(:disabled) { create :dictionary, :english, enabled: false }

    it 'get nouns in active dictionary' do
      expect(Noun.active).to match_array(russian.nouns + english.nouns)
    end

    it 'get nouns in preferred language' do
      expect(Noun.in_language('RU')).to eq(russian.nouns)
    end

    it 'get nouns with specified word length' do
      expect(Noun.by_length(7)).to all(satisfy {|word| word.noun.length == 7})
    end

    it 'get nouns with specified word length' do
      expect(Noun.by_length(7)).to all(satisfy {|word| word.noun.length == 7})
    end

    it 'get nouns with specified language' do
      expect(Noun.in_language('RU')).to all(satisfy {|word| word.dictionary.lang == 'RU'})
    end

    context 'with english dictionary complexity levels' do
      let!(:hard) { create :dictionary_level, :hard_en, dictionary_id: english.id }

      it 'get nouns with specified language and complexity' do
        expect(Noun.by_complexity('EN', 'hard').pluck(:level)).to all(be_between(10, 15))
      end
    end

    context 'with russian and english dictionaries complexity levels' do
      let!(:hard_ru) { create :dictionary_level, :hard_ru, dictionary_id: russian.id }
      let!(:hard_en) { create :dictionary_level, :hard_en, dictionary_id: english.id }

      it 'get nouns with levels according specified language and complexity' do
        expect(Noun.by_complexity('RU', 'medium').pluck(:level)).to all(be_between(3, 4))
        expect(Noun.by_complexity('EN', 'hard').pluck(:level)).to all(be_between(10, 15))
      end
    end
  end

end
