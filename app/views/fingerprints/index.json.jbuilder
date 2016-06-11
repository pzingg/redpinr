json.array!(@fingerprints) do |fingerprint|
  json.extract! fingerprint, :id
  json.href fingerprint_url(fingerprint, format: :json)
end
