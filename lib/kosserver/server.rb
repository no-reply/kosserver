require 'kosserver'
require 'sinatra/base'
require 'rack/ldp'

module KOSServer
  class Server < Sinatra::Base
    use Rack::LDP::ContentNegotiation
    use Rack::LDP::Errors
    use Rack::ConditionalGet
    use Rack::LDP::Responses
    use Rack::LDP::Requests
    use Rack::Memento

    RDF::LDP::Memento.use_memento!

    configure { set :repository, RDF::Repository.new }

    get '/' do
      RDF::LDP::Container
        .new(RDF::URI(request.url), settings.repository)
        .create(StringIO.new, 'text/turtle') if settings.repository.empty?

      RDF::LDP::Resource.find(RDF::URI(request.url), settings.repository)
    end

    get '/*' do
      RDF::LDP::Resource.find(RDF::URI(request.url), settings.repository)
    end

    patch '/*' do
      RDF::LDP::Resource.find(RDF::URI(request.url), settings.repository)
    end

    post '/*' do
      RDF::LDP::Resource.find(RDF::URI(request.url), settings.repository)
    end

    put '/*' do
      begin
        RDF::LDP::Resource.find(RDF::URI(request.url), settings.repository)
      rescue RDF::LDP::NotFound
        RDF::LDP::Resource.interaction_model(request.env.fetch('HTTP_LINK', ''))
          .new(RDF::URI(request.url), settings.repository)
      end
    end

    options '/*' do
      RDF::LDP::Resource.find(RDF::URI(request.url), settings.repository)
    end

    head '/*' do
      RDF::LDP::Resource.find(RDF::URI(request.url), settings.repository)
    end

    delete '/*' do
      RDF::LDP::Resource.find(RDF::URI(request.url), settings.repository)
    end

    run! if app_file == $0
  end
end
