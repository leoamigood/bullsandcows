require 'google/cloud/speech'

class GoogleCloudService
  class << self
    def recognize(content, language)
      audio = buildAudio(content, language)
      results = audio.recognize(max_alternatives: 1, profanity_filter: nil)

      results.first.try(:transcript)
    end

    private

    def buildAudio(content, language)
      audio = Google::Cloud::Speech::Audio.new
      audio.instance_variable_set :@speech, $speech
      audio.language = language
      audio.encoding = :ogg_opus
      audio.sample_rate = 16000
      audio.grpc.content = content
      audio
    end
  end
end
