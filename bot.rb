require 'facebook/messenger'
require 'httparty'
require 'json'
require 'dotenv/load'
include Facebook::Messenger
# note: ENV variables should be set directly in terminal for testing on localhost

# Subcribe bot to your page
Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

API_URL = 'https://maps.googleapis.com/maps/api/geocode/json?address='

IDIOMS = {
  human_like: 'Alrighty hoe',
  not_found: 'There were no resutls. Ask me again, please',
  ask_location: 'Enter destination',
  complete: 'Done!',
  ask_coffee: 'Would you like to get some coffee?',
  what_coffee: 'What coffee would you like?',
  unknown_command: 'Sorry, I did not recognize your command',
  menu_greeting: 'What can I do for you today?',
  initial_hello: 'Welcome to coffee_bot!',
  test: 'testing'
}.freeze #means these assignments are made immutable from any method that attempts to alter it
#performs faster than normal without freeze

#COFFEE_REPLIES = [
#  {
#    content_type: 'text',
#    title: 'Americano',
#    payload: 'AMERICANO'
#  },
#  {
#    content_type: 'text',
#    title: 'Flat white',
#    payload: 'FLAT_WHITE'
#  }
#]

MENU_REPLIES = [
  {
    content_type: 'text',
    title: 'Coordinates',
    payload: 'COORDINATES' #note:worded to match the regexp in wait_for_command method
  },
  {
    content_type: 'text',
    title: 'Full address',
    payload: 'FULL_ADDRESS' #note:worded to match the regexp in wait_for_command method
  },
#  {
#    content_type: 'text',
#    title: 'Coffee?',
#    payload: 'COFFEE' #should create new regexp if want to use coffeerepliesDONE
#  },
#  {
#    content_type: 'text',
#    title: 'coffee preference',
#    payload: 'COFFEE_PREFERENCE'
#  },
  {
    content_type: 'text',
    title: 'Coffee selector',
    payload: 'COFFEE_SELECTOR'
  },
  {
    content_type: 'postback',
    title: 'Group selector',
    payload: 'GROUP_SELECTOR'
  },
  {
    content_type: 'postback',
    title: 'Change order',
    payload: 'CHANGE_ORDER'
  }
]
#check this | get started button
Facebook::Messenger::Thread.set({
  Content-Type: application/json -d {
  setting_type:call_to_actions,
  thread_state:new_thread,
  call_to_actions:[
    {
      payload:'Get started'
    }
  ]
} https://graph.facebook.com/v2.6/me/thread_settings?access_token=ENV['ACCESS_TOKEN']

# Set call to action button when user is about to address bot
# for the first time.
#initialize bot when user says something e.g 'how can i help u today?'
Facebook::Messenger::Thread.set({
  setting_type: 'call_to_actions',
  thread_state: 'new_thread',
  call_to_actions: [
    {
      payload: 'START'
    }
  ]
}, access_token: ENV['ACCESS_TOKEN'])

# Create persistent menu
#menu appear on typekeyboard consistently
#need to add methods to coffee menu options
Facebook::Messenger::Thread.set({
  setting_type: 'call_to_actions',
  thread_state: 'existing_thread',
  call_to_actions: [
    {
      type: 'postback',
      title: 'Get coordinates',
      payload: 'COORDINATES'
    },
    {
      type: 'postback',
      title: 'Get full address',
      payload: 'FULL_ADDRESS'
    },
    #{
      #type: 'postback',
      #title: 'Get Coffee?',
      #payload: 'COFFEE'
    #},
    #{
    #  type: 'postback',
    #  title: 'Coffee preference',
    #  payload: 'COFFEE_PREFERENCE'
    #},
    {
      type: 'postback',
      title: 'Coffee selector',
      payload: 'COFFEE_SELECTOR'
    },
    {
      type: 'postback',
      title: 'Group selector',
      payload: 'GROUP_SELECTOR'
    },
    {
      type: 'postback',
      title: 'Change order',
      payload: 'CHANGE_ORDER'
    }
    ]}, access_token: ENV['ACCESS_TOKEN'])

#must add methods for each of these commented menu options (redirect:logic for postbacks)
#to be able to get this running. also look at code and add coffee options

# Set greeting (for first contact)
Facebook::Messenger::Thread.set({
  setting_type: 'greeting',
  greeting: {
    text: 'Welcome to coffee_bot!'
  },
}, access_token: ENV['ACCESS_TOKEN'])

# chat buttons
# Logic for postbacks
Bot.on :postback do |postback|
  sender_id = postback.sender['id']
  case postback.payload
  when 'START' then show_replies_menu(postback.sender['id'], MENU_REPLIES)
  when 'COORDINATES'
    say(sender_id, IDIOMS[:human_like])
    say(sender_id, IDIOMS[:ask_location])
    show_coordinates(sender_id)
  when 'FULL_ADDRESS'
    say(sender_id, IDIOMS[:human_like])
    say(sender_id, IDIOMS[:ask_location])
    show_full_address(sender_id)
  when 'COFFEE'
    say(sender_id, IDIOMS[:human_like])
    say(sender_id, IDIOMS[:test])
#   coffee_bot
#  when 'AMERICANO'
#    CODE - 'okay, added to order list'
#    CODE - backend work to link data to an app run orderlist
#  when 'FLAT_WHITE'
#    CODE - 'okay, added to order list'
#    CODE - backend work to link data to an app run orderlist
  end
end

#def coffee_bot
#  Bot.on :message do |message|
#    puts "Received '#{message.inspect}' from #{message.sender}" # debug only
#    sender_id = message.sender['id']
#    case message.text
#    say(sender_id, IDIOMS[:human_like])
#    say(sender_id, IDIOMS[:ask_coffee])
#    when /yes/i, /y/i
#       say(sender_id, IDIOMS[:human_like])
#       say(sender_id, IDIOMS[:what_coffee])#, quick_replies) #so that a coffee preference menu option appears
#       #must add a facebook messenger thread set - that lists a menu of coffee
#       show_replies_coffee(message.sender['id'], COFFEE_REPLIES)#gets users ID
#       wait_for_command
#     else
#        say(sender_id, IDIOMS[:unknown_command])
#        show_replies_coffee(message.sender['id'], COFFEE_REPLIES) #can use quick_replies and say method but not sure??
#     end
#end

#def show_replies_coffee(id, quick_replies)
#  say(id, quick_replies)
#  wait_for_command
#end

#a function that does a web form to make bot send out of blue coffee?
#question according to time and days the user entered in webform page
#of webapp

#a function that adds the coffee slot menu webpage redirect to the
#consistentmenu on fb messenger app

#add paramaters needed for a coffee order to the function that asks which
#coffee eg. flat white, soy milk, regular size, no sugar etc.

#sort out how to display/calculate coffee owed




#displays set of quick replies as a menu option
def show_replies_menu(id, quick_replies)
  say(id, IDIOMS[:menu_greeting], quick_replies)
  wait_for_command
end

#start conversation loop
def wait_for_any_input
  Bot.on :message do |message|
    initial_greeting(message.sender['id'])
    show_replies_menu(message.sender['id'], MENU_REPLIES)#gets users ID
  end
end

#function to send messages directly
def say(recipient_id, text, quick_replies = nil)
  message_options = {
  recipient: { id: recipient_id },
  message: { text: text }
  }
  if quick_replies
    message_options[:message][:quick_replies] = quick_replies
  end
  Bot.deliver(message_options, access_token: ENV['ACCESS_TOKEN'])
end

def initial_greeting(id)
  say(id, IDIOMS[:initial_hello])
  wait_for_command
end

#Bot.deliver({ #send message to recipient out of the blue
#  recipient: {
#    id: '1359276920814022' #harrisons fb ID
#  },
#  message: {
#    text: 'Human, waddap'
#  }
#}, access_token: ENV['ACCESS_TOKEN'])

#logic for quick replies and text commands
def wait_for_command #method for sending messages from bot
  Bot.on :message do |message|
    puts "Received '#{message.inspect}' from #{message.sender}" # debug only
    sender_id = message.sender['id']
    case message.text
    when /coord/i, /gps/i # we use regexp to match parts of strings
      message.reply(text: IDIOMS[:human_like])
      message.reply(text: IDIOMS[:ask_location])
      show_coordinates(sender_id)
    when /full ad/i # we got the user even if he misspells address
      message.reply(text: IDIOMS[:human_like])
      message.reply(text: IDIOMS[:ask_location])
      show_full_address(sender_id)
    when /cofee/i, /coffeee/i, /cof/i
      message.reply(text: IDIOMS[:human_like])
      message.reply(text: IDIOMS[:test])
    #  coffee_bot
    #when /ameri/i, /american/i
    #      CODE - 'okay, added to order list'
      #    CODE - backend work to link data to an app run orderlist
    #when /fla/i, /whit/i
      #    CODE - 'okay, added to order list'
      #    CODE - backend work to link data to an app run orderlist
    else
      message.reply(text: IDIOMS[:unknown_command])
      show_replies_menu(sender_id, MENU_REPLIES)
    end
  end
end

#Bot.on :message do |message| #syntax for bot messaging
  #puts "Received '#{message.inspect}' from #{message.sender}" # debug purposes
  #parsed_response = get_parsed_response(API_URL, message.text) # talk to Google API
  #message.type # trick user into thinking we type something with our fingers, HA HA HA
  #coord = extract_coordinates(parsed_response) # we have a separate method for that
  #message.reply(text: "Latitude: #{coord['lat']}, Longitude: #{coord['lng']}")
  #message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
  #message.sender      # => { 'id' => '1008372609250235' }
  #message.seq         # => 73
  #message.sent_at     # => 2016-04-22 21:30:36 +0200
  #message.text        # => 'Hello, bot!'
  #message.attachments # => [ { 'type' => 'image', 'payload' => { 'url' => 'https://www.example.com/1.jpg' } } ]
  #message.reply(text: 'Hello!')
#end

#coordinates lookup
def show_coordinates(id)
  handle_api_request do |api_response|
    coord = extract_coordinates(api_response)
    text = "Latitude: #{coord['lat']} / Longitude: #{coord['lng']}"
    say(id,text)
  end
end

#full address lookup
def show_full_address(id)
  handle_api_request do |api_response|
    full_address = extract_full_address(api_response)
    say(id, full_address)
  end
end

def extract_full_address(parsed)
  parsed['results'].first['formatted_address']
end

def handle_api_request #method handles API related logic
  Bot.on :message do |message|
    #puts "Received '#{message.inspect}' from #{message.sender}" # for development only
    parsed_response = get_parsed_response(API_URL, message.text)
    message.type # let user know we're doing something
    if parsed_response
      yield(parsed_response, message)
      wait_for_any_input
    else
      message.reply(text: IDIOMS[:not_found])
      #metaprogramming voodoo to call the callee
      callee = Proc.new{caller_locations.first.label} #for access of variable from outside the block as well (proc)
      callee.call
    end
  end
end
#using API as the database to take info from other programs for your app (metaprogramming)

#talk to api
def get_parsed_response(url, query)
  # Use HTTParty gem to make a get request
  response = HTTParty.get(url + query)
  # Parse the resulting JSON so it's now a Ruby Hash
  parsed = JSON.parse(response.body)
  # Return nil if we got no results from the API.
  parsed['status'] != 'ZERO_RESULTS' ? parsed : nil
end

# Look inside the hash to find coordinates
def extract_coordinates(parsed)
  parsed['results'].first['geometry']['location']
end



#launch loop
wait_for_any_input
