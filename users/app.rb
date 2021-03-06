class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    json User.all
  end

  get %r{/(\d+)} do |id|
    json User.find(id)
  end

  get '/health' do
    halt 204
  end
end
