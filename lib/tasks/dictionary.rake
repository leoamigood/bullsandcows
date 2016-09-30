namespace :dictionary do

  ##
  # rake dictionary:import[RU,tmp/seed_data/dictionary.csv]
  #
  # after import is completed you might want to calculate word level for example as:
  # SQL: update nouns set level = <max level> - width_bucket(log(ipm * r), <min level>, <max level>, <total buckets>);
  task :import, [:lang, :filename] => :environment do |t, args|
    lang = args[:lang]
    filename = args[:filename]

    require 'csv'
    Noun.transaction do
      nouns = CSV.read(filename, {headers: true})
      dictionary = Dictionary.create(lang: lang, source: filename)
      Noun.import nouns.map { |row|
        attributes = Noun.column_names.reduce({}) { |h, attr| h.merge(attr => row.field(attr)) }
        Noun.new(attributes.merge(excluded: false, dictionary_id: dictionary.id))
      }

      #update nouns set level = 6 - width_bucket(log(ipm * r), 0, 5.58, 6);
    end
  end

end
