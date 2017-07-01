require 'google/cloud/speech'

if Rails.env.production? || Rails.env.staging?
  $speech = Google::Cloud::Speech.new
end
