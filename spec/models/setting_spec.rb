require 'rails_helper'

describe Setting, type: :model do

  context 'given a dictionary with levels' do
    let!(:easy) { create :dictionary_level, :easy_en }
    let!(:medium) { create :dictionary_level, :medium_en }
    let!(:hard) { create :dictionary_level, :hard_en }

    let!(:dictionary) { create :dictionary, :english, levels: [easy, medium, hard], lang: 'EN' }

    context 'with complexity in settings' do
      let!(:settings) { create :setting, language: 'EN', dictionary: dictionary, complexity: 'hard'}

      it 'get corresponding word levels' do
        expect(settings.levels).to eq([10, 11, 12, 13, 14, 15])
      end
    end

  end

end
