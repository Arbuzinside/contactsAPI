require 'json'

class Contact
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  belongs_to :user



  field :name, type: String
  field :external_id, type:String
  field :address, type: String
  field :surname, type: String
  field :email, type: String
  field :phone, type: String
  field :birthday, type: Date
  field :notes, type: String




  def self.search(params)

  end



end
