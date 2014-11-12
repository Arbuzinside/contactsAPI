require 'net/http'
require 'net/https'
require 'uri'
require 'rexml/document'


class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]



  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.all
    if params[:search]
      #@contacts = Contact.search(params[:search])
      @contacts = @contacts.any_of({name: Regexp.new("^.*#{params[:search]}.*", Regexp::IGNORECASE)},
                                   {surname: Regexp.new("^.*#{params[:search]}.*", Regexp::IGNORECASE)},
                                   {address: Regexp.new("^.*#{params[:search]}.*", Regexp::IGNORECASE)},
                                   {email: Regexp.new("^.*#{params[:search]}.*", Regexp::IGNORECASE)},
                                   {phone: Regexp.new("^.*#{params[:search]}.*", Regexp::IGNORECASE)})
       end
  end
   # GET /contacts




  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def authenticate
    @title = "Google Authentication"

    googleauth_url = "http://127.0.0.1:3000/users/authorization/callback"
    client_id = "178637155283-a02oh0ufr9c7arkug3rj946s48mlh90p.apps.googleusercontent.com"
    google_root_url = "https://accounts.google.com/o/oauth2/auth?state=profile&redirect_uri="+googleauth_url+"&response_type=code&client_id="+client_id.to_s+"&approval_prompt=force&scope=https://www.google.com/m8/feeds/"
    redirect_to google_root_url
  end

  # GET /contacts/google
  def authorise
    begin
      @title = "Google Authetication"
      googleauth_url = "http://127.0.0.1:3000/users/authorization/callback"
      token = params[:code]
      client_id = "178637155283-a02oh0ufr9c7arkug3rj946s48mlh90p.apps.googleusercontent.com"
      client_secret = "-qIWTSBbMj-ZofgliJbNqk_1"
      uri = URI('https://accounts.google.com/o/oauth2/token')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri)

      request.set_form_data('code' => token, 'client_id' => client_id, 'client_secret' => client_secret, 'redirect_uri' => googleauth_url, 'grant_type' => 'authorization_code')
      request.content_type = 'application/x-www-form-urlencoded'
      response = http.request(request)
      response.code
      access_keys = ActiveSupport::JSON.decode(response.body)

      uri = URI.parse("https://www.google.com/m8/feeds/contacts/default/full?oauth_token="+access_keys['access_token'].to_s+"&max-results=50000&alt=json")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      contacts = ActiveSupport::JSON.decode(response.body)
      contacts['feed']['entry'].each_with_index do |contact,index|
        local_contacts = Contact.all
        name = contact['title']['$t']
        contact['gd$email'].to_a.each do |email|
          email_address = email['address']
          repeat = local_contacts.any_of({:name => name},{:email => email_address})
          length = repeat.to_a.length
          if (repeat.to_a.length == 0) #do not create it if it already exists
            Contact.create(:name => name, :email => email_address)  # for testing i m pushing it into database..
          end
        end

      end
    rescue Exception => ex
      ex.message
    end
    redirect_to contacts_path , :notice => "Your google contacts have been imported"


  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:name, :address, :surname, :email, :phone, :birthday, :notes)
    end




end
