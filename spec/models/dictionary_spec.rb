require 'rails_helper'

describe Dictionary, type: :model do

  context 'given a dictionary' do
    let!(:dictionary) { create :dictionary, lang: 'EN' }

    it 'get language of dictionary' do
      expect(dictionary.lang).to eq('english')
      expect(dictionary.english?).to eq(true)
    end
  end

end
