require 'rails_helper'

describe Noun, type: :model do

  context 'given dictionaries' do
    let!(:active) { create :dictionary, :basic, enabled: true, lang: 'EN' }
    let!(:disabled) { create :dictionary, :basic, enabled: false, lang: 'RU' }

    it 'get nouns in active dictionary' do
      expect(Noun.active).to eq(active.nouns)
    end

    it 'get nouns in preferred language' do
      expect(Noun.in_language('RU')).to eq(disabled.nouns)
    end
  end

end
