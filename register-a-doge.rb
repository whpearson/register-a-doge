require 'sinatra'
require_relative 'db'
require 'net/http'
require 'uri'
require 'openssl'

unless $0.match?(/rspec/)
  setup_db_connection
  create_database
end

# We want to call our templates template.html.erb
Tilt.register Tilt::ERBTemplate, 'html.erb'

get '/' do
  erb :index
end

get '/register' do
  erb :register, locals: {
    registration: Registration.new,
  }
end

post '/register' do
  registration = Registration.new
  registration.first_name = params[:first_name]
  registration.last_name = params[:last_name]

  unless registration.valid?
    return erb :register, locals: { registration: registration }
  end
  splunk_token = ENV.fetch('SPLUNK_TOKEN', 'error'),
  registration.save!
   `curl -k "https://hec.splunk.zero.game.gds-reliability.engineering/services/collector"   -H "Authorization: Splunk #{SPLUNK_TOKEN}" -d '{"sourcetype": "_json", "event": {"first_name": registration.first_name, "last_name":registration.last_name, "code": registration.code, "registration": registration.registration } }'` 
  erb :success, locals: { registration: registration }
end

get '/stats' do
  locals = { registrations: [
    { name: 'Today',      value: Registration.registrations_today.count },
    { name: 'This week',  value: Registration.registrations_this_week.count },
    { name: 'This month', value: Registration.registrations_this_month.count },
    { name: 'This year',  value: Registration.registrations_this_year.count },
    { name: 'All time',   value: Registration.count }
  ] }

  erb :stats, locals: locals
end

get '/500' do
  raise '500 page'
end

get '/_health' do
  '200 - this healthcheck could be better, no?'
end

error do
  erb :error
end

not_found do
  erb :'404'
end
