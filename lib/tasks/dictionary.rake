namespace :dictionary do

  ##
  # rake dictionary:import[RU,tmp/seed_data/dictionary.csv]
  # rake dictionary:import[RU,http://www.domain.com/seed_data/dictionary.csv]
  #
  # after import is completed you might want to calculate word level for example as:
  # SQL: update nouns set level = width_bucket(log(ipm * r), <min level>, <max level>, <total buckets>);
  task :import, [:lang, :uri] => :environment do |t, args|
    lang = args[:lang]
    uri = args[:uri]

    require 'csv'
    require 'open-uri'
    Noun.transaction do
      nouns = CSV.new(open(uri), :headers => :first_row)
      dictionary = Dictionary.create(lang: lang, source: uri)
      Noun.import nouns.map { |row|
        attributes = Noun.column_names.reduce({}) { |h, attr| h.merge(attr => row.field(attr)) }
        Noun.new(attributes.merge(excluded: false, dictionary_id: dictionary.id))
      }

      #update nouns set level = width_bucket(log(ipm * r), 0, 5.58, 5);
    end
  end

  ##
  # rake dictionary:levels[RU,hard,3,5]
  task :levels, [:language, :complexity, :min_level, :max_level] => :environment do |t, args|
    language = args[:language]
    complexity = args[:complexity]
    min_level, max_level = args[:min_level], args[:max_level]

    dictionary = Dictionary.find_by_lang!(language)
    DictionaryLevel.create!(dictionary_id: dictionary.id, complexity: complexity, min_level: min_level, max_level: max_level)
  end

end
