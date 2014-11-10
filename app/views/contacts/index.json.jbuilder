json.array!(@contacts) do |contact|
  json.extract! contact, :id, :name, :address, :surname, :email, :phone, :birthday, :notes
  json.url contact_url(contact, format: :json)
end
