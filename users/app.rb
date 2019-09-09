class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  USERS = [
    {
      id: 1,
      name: 'Bill Gates',
      email: 'bill.gates@example.com'
    },
    {
      id: 2,
      name: 'Steve Jobs',
      email: 'steve.jobs@example.com'
    }
  ]

  get '/' do
    USERS.to_json
  end

  get %r{/(\d+)} do |id|
    USERS.find { |u| u[:id] == id.to_i }.to_json
  end
end
