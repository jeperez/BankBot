require 'open-uri'

class Message < ActiveRecord::Base
	belongs_to :user
	@@fb_token = 'CAAW46Pf7Xo4BANlo4Unadya2BeLtUt3CO5hohlqPbn1ZCrLwbGwKQCdBQrjNFaWp0ilYlt1A4hBKebRuZA0Rai4R1wIfAsMdn3DG0jGoea2iU2frQbCcO25LQ9VEqtqMvdT07G8BbxEAXfBiOqy3NfP12t7rWp0gU7h6hRT9mPSqNfehST1fARJf2oXpBewLwMmuZBKdAZDZD'
    @@ai_token = 'e5e7bff08d9e488e80519a300cc3d9d6'
def handle_message()
	client = ApiAiRuby::Client.new(
		:client_access_token => @@ai_token,
		:subscription_key => 'YOUR_SUBSCRIPTION_KEY'
		)
	apiresponce = client.text_request text, :contexts => [self.user.state], :sessionId => self.user.fb_id, :resetContexts => self.user.clear_state
	if apiresponce[:result][:action]=='help' then
		answer_new('I will help you')
	elsif  apiresponce[:result][:action]=='nearest_ATM' then
		answer_new('phgaine mesolongi')
	elsif not self.user.pin.blank? then
		if apiresponce[:result][:action]=='smalltalk.greetings' then
			send_info
		elsif apiresponce[:result][:action]=='account_balance' then
			answer_new('Your balance is 500$')
		elsif apiresponce[:result][:action]=='last_transactions' then
			answer_new('last transactions: klp...')
		elsif apiresponce[:result][:action]=='lost_card' then
			item = apiresponce[:result][:parameters][:lost_items]
			answer_new('I will find your '+item)
		elsif apiresponce[:result][:action]=='phone_assistance' then
			answer_new('I will call you')
		elsif apiresponce[:result][:speech]!='' then
			answer_new(apiresponce[:result][:speech])
		end		

		if apiresponce[:result][:action]=='help' then
			answer_new('I will help you')
		elsif  apiresponce[:result][:action]=='nearest_ATM' then
			answer_new('phgaine mesolongi')
		end	
	else
		send_begin()
	end
	# self.user.messages.create(:text=>apiresponce[:result][:speech],:response=>true).send_message
	#puts responce[:result].inspect.gsub('"',"'")

end

def handle_sound()
	client = ApiAiRuby::Client.new(
		:client_access_token => @@ai_token,
		:subscription_key => 'YOUR_SUBSCRIPTION_KEY'
		)
	filename = self.user.fb_id+Time.now.getutc.to_s
	open(filename, 'wb') do |file|
	  file << open(text).read
	end
	# file = File.new filename
	File.delete(filename) if File.exist?(filename)
end

def answer_new(text)
	self.user.messages.create(:text=>text,:response=>true).send_message
end

def send_begin()
	conn = Faraday.new(:url => 'https://graph.facebook.com/v2.6') do |faraday|
  		faraday.request  :url_encoded             # form-encode POST params
  		faraday.response :logger                  # log requests to STDOUT
  		faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
	end

	conn.post do |req|
		req.url '/me/messages?access_token=' + @@fb_token
		req.headers['Content-Type'] = 'application/json'
		req.body = "{ \"recipient\": { \"id\" : \"#{self.user.fb_id}\" }, \"message\": { \"attachment\" : {\"type\":\"template\",\"payload\":{\"template_type\":\"button\",\"text\":\"Authenticate with NBG\",\"buttons\":[{\"type\":\"web_url\",\"title\":\"Authenticate\",\"url\":\"https://nbgbot.herokuapp.com/auth?uid=#{self.user.id}\"}]}} } }"
	end
	puts "{ \"recipient\": { \"id\" : \"#{self.user.fb_id}\" }, \"message\": { \"attachment\" : {\"type\":\"template\",\"payload\":{\"template_type\":\"button\",\"text\":\"Authenticate with NBG\",\"buttons\":[{\"type\":\"web_url\",\"title\":\"Authenticate\",\"url\":\"https://nbgbot.herokuapp.com/auth?uid=#{self.user.id}\"}]}} } }"
end

def send_info()
	conn = Faraday.new(:url => 'https://graph.facebook.com/v2.6') do |faraday|
  		faraday.request  :url_encoded             # form-encode POST params
  		faraday.response :logger                  # log requests to STDOUT
  		faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
	end

	conn.post do |req|
		req.url '/me/messages?access_token=' + @@fb_token
		req.headers['Content-Type'] = 'application/json'
		req.body = "{ \"recipient\": { \"id\" : \"#{self.user.fb_id}\" }, \"message\": { \"attachment\" : {\"type\":\"template\",\"payload\":{\"template_type\":\"button\",\"text\":\"How can i help you ? \",\"buttons\":[{\"type\":\"postback\",\"title\":\" Check account balance \",\"payload\":\" account balance \"},{\"type\":\"postback\",\"title\":\"Nearest ATM ?\",\"payload\":\"ATM ?\"},{\"type\":\"postback\",\"title\":\"Last transcations \",\"payload\":\"Last transcations \"}]}} } }"
	end
	conn.post do |req|
		req.url '/me/messages?access_token=' + @@fb_token
		req.headers['Content-Type'] = 'application/json'
		req.body = "{ \"recipient\": { \"id\" : \"#{self.user.fb_id}\" }, \"message\": { \"attachment\" : {\"type\":\"template\",\"payload\":{\"template_type\":\"button\",\"text\":\"How can i help you ? \",\"buttons\":[{\"type\":\"postback\",\"title\":\"Lost credit card \",\"payload\":\"Lost credit card \"},{\"type\":\"postback\",\"title\":\"I want some help \",\"payload\":\"I want some help \"}]}} } }"
	end
end


def send_message()
	
	conn = Faraday.new(:url => 'https://graph.facebook.com/v2.6') do |faraday|
  		faraday.request  :url_encoded             # form-encode POST params
  		faraday.response :logger                  # log requests to STDOUT
  		faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
	end

	conn.post do |req|
		req.url '/me/messages?access_token=' + @@fb_token
		req.headers['Content-Type'] = 'application/json'
		req.body = "{ \"recipient\": { \"id\" : \"#{self.user.fb_id}\" }, \"message\": { \"text\" : \"#{self.text}\" } }"
	end
end

end
