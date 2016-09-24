# rake dictionary:import[RU,tmp/seed_data/dictionary.ru.csv]
namespace :dictionary do
  task :import, [:lang, :filename] => :environment do |t, args|
    lang = args[:lang]
    filename = args[:filename]

    require 'csv'
    Noun.transaction do
      nouns = CSV.read(filename)
      Noun.import nouns.shift, nouns, validate: false

      Noun.order(id: :desc).limit(nouns.count).update_all(lang: lang, source: filename)
    end
  end
end
