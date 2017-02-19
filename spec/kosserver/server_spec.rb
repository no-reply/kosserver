require 'spec_helper'

require 'rack/test'

describe KOSServer do
  include ::Rack::Test::Methods

  let(:app) { KOSServer::Server }

  before { KOSServer::Server.repository.clear; get '/' }
  after  { KOSServer::Server.repository.clear }

  shared_context 'with scheme container' do
    let(:scheme_ctype)   { 'text/turtle' }
    let(:scheme_content) { scheme_graph.dump :ttl }
    let(:scheme_graph)   { RDF::Graph.new.insert(*scheme_statements) }
    let(:scheme_slug)    { 'myScheme' }
    let(:scheme_uri)     { RDF::URI('http://example.com/myScheme') }

    let(:scheme_statements) do
      [RDF::Statement(RDF::URI(nil),
                      RDF::Vocab::LDP.membershipResource,
                      scheme_uri),
       # RDF::Statement(RDF::URI(nil),
       #                RDF::Vocab::LDP.hasMemberRelation,
       #                RDF::Vocab::SKOS.hasTopConcept),
       RDF::Statement(RDF::URI(nil),
                      RDF::Vocab::LDP.insertedContentRelation,
                      RDF::Vocab::FOAF.primaryTopic),
       RDF::Statement(scheme_uri,
                      RDF.type,
                      RDF::Vocab::SKOS.ConceptScheme),
       RDF::Statement(scheme_uri,
                      RDF::Vocab::DC.title,
                      "My Fake Scheme")]
    end

    let(:scheme_headers) do
      {'CONTENT_TYPE' => scheme_ctype,
       'HTTP_LINK' => "#{KOSServer::KOP.SchemeContainer.to_base};rel=\"type\"",
       'HTTP_SLUG' => scheme_slug
      }
    end

    before { post '/', scheme_content, scheme_headers }
  end

  shared_context 'with top concept' do
    include_context 'with scheme container'

    let(:concept_content) { concept_graph.dump(:ttl) }
    let(:concept_ctype)   { 'text/turtle' }
    let(:concept_graph)   { RDF::Graph.new.insert(*concept_statements) }
    let(:concept_slug)     { 'my_concept' }
    let(:concept_uri)     { RDF::URI('http://example.com/my_concept') }

    let(:concept_statements) do
      [RDF::Statement(RDF::URI(nil),
                      RDF::Vocab::FOAF.primaryTopic,
                      concept_uri),
       RDF::Statement(RDF::URI(nil),
                      RDF::Vocab::LDP.membershipResource,
                      concept_uri),
       RDF::Statement(RDF::URI(nil),
                      RDF::Vocab::LDP.insertedContentRelation,
                      RDF::Vocab::FOAF.primaryTopic)]
    end

    before do
      post scheme_slug,
           concept_content,
           'CONTENT_TYPE' => concept_ctype,
           'HTTP_SLUG'    => concept_slug
    end
  end

  describe '/' do
    it 'is a container' do
      expect(last_response.headers['Link'])
        .to include "<#{RDF::Vocab::LDP.BasicContainer}>;rel=\"type\""
    end

    describe 'POSTing a Concept Scheme' do
      include_context 'with scheme container'

      let(:scheme_headers) do
        {'CONTENT_TYPE' => scheme_ctype,
         'HTTP_LINK' => "#{KOSServer::KOP.SchemeContainer.to_base};rel=\"type\""}
      end

      it 'creates a resource' do
        post '/', scheme_content, scheme_headers
        expect(last_response.status).to eq 201
      end

      it 'creates a concept scheme' do
        post '/', scheme_content, scheme_headers
        expect(last_response.headers['Link'])
          .to include KOSServer::KOP.SchemeContainer.to_base
      end
    end
  end

  describe '/{scheme_container}' do
    include_context 'with scheme container'

    it 'retrieves a scheme container' do
      get scheme_slug

      expect(last_response.headers['Link'])
        .to include KOSServer::KOP.SchemeContainer.to_base
    end

    describe 'POSTing a TopConcept' do
      include_context 'with top concept'

      it 'creates a concept container' do
        expect(last_response.headers['Link'])
          .to include KOSServer::KOP.ConceptContainer.to_base
      end

      it 'adds a top concept' do
        get scheme_slug
        
        graph = RDF::Graph.new <<
          RDF::Reader.for(content_type: last_response.headers['Content-Type'])
            .new(last_response.body)

        expect(graph)
          .to have_statement RDF::Statement(scheme_uri,
                                            RDF::Vocab::SKOS.hasTopConcept,
                                            concept_uri)
      end

      describe 'POSTing a narrower concept' do
        include_context 'with top concept'

        let(:narrower_content) { narrower_graph.dump(:ttl) }
        let(:narrower_ctype)   { 'text/turtle' }
        let(:narrower_graph)   { RDF::Graph.new.insert(*narrower_statements) }
        let(:narrower_slug)    { 'next' }
        let(:narrower_uri)     { RDF::URI('http://example.com/my_concept/next') }

        let(:narrower_statements) do
          [RDF::Statement(RDF::URI(nil),
                          RDF::Vocab::FOAF.primaryTopic,
                          narrower_uri),
           RDF::Statement(RDF::URI(nil),
                          RDF::Vocab::LDP.membershipResource,
                          narrower_uri),
           RDF::Statement(RDF::URI(nil),
                          RDF::Vocab::LDP.insertedContentRelation,
                          RDF::Vocab::FOAF.primaryTopic)]
        end

        it 'adds a narrower concept' do
          post "#{scheme_slug}/#{concept_slug}", 
               narrower_content,
               'CONTENT_TYPE' => narrower_ctype,
               'HTTP_SLUG'    => narrower_slug

          get "#{scheme_slug}/#{concept_slug}"

          graph = RDF::Graph.new <<
            RDF::Reader.for(content_type: last_response.headers['Content-Type'])
              .new(last_response.body)

          expect(graph)
            .to have_statement RDF::Statement(concept_uri,
                                              RDF::Vocab::SKOS.narrower,
                                              narrower_uri)
        end
      end
    end
  end
end
