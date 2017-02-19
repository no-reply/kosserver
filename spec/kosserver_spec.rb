require 'spec_helper'

require 'capybara_discoball'
require 'faraday'
require 'ldp_testsuite_wrapper'
require 'ldp_testsuite_wrapper/rspec'
require 'nokogiri'
require 'rack/test'
require 'securerandom'
require 'zip'

describe KOSServer::VERSION do
  describe '#to_a' do
    it 'gives version as array of parts' do
      expect(described_class.to_a).to contain_exactly(an_instance_of(String),
                                                      an_instance_of(String),
                                                      an_instance_of(String))
    end
  end

  describe '#to_s' do
    it 'gives version as string' do
      expect(described_class.to_s).to match /[0-9]+\.[0-9]+\.[0-9]+/
    end
  end
end

describe KOSServer do
  include ::Rack::Test::Methods

  let(:app) { KOSServer::Server }

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

  describe '/' do
    it 'is a container' do
      get '/'

      expect(last_response.headers['Link'])
        .to include "<#{RDF::Vocab::LDP.BasicContainer}>;rel=\"type\""
    end

    describe 'POSTing a Concept Scheme' do
      include_context 'with scheme container'

      let(:scheme_headers) do
        {'CONTENT_TYPE' => scheme_ctype, 
         'HTTP_LINK' => "#{KOSServer::KOP.SchemeContainer.to_base};rel=\"type\""}
      end

      it 'creates a concept scheme' do
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
      let(:concept_content) { concept_graph.dump(:ttl) }
      let(:concept_ctype)   { 'text/turtle' }
      let(:concept_graph)   { RDF::Graph.new.insert(*concept_statements) }
      let(:concept_uri)     { RDF::URI('http://example.com/my_concept') }

      let(:concept_statements) do
        [RDF::Statement(RDF::URI(nil), 
                        RDF::Vocab::FOAF.primaryTopic,
                        concept_uri)]
      end
      
      xit 'creates a concept container' do
        post scheme_slug, concept_content, 'CONTENT_TYPE' => concept_ctype

        expect(last_response.headers['Link'])
          .to include KOSServer::KOP.ConceptContainer.to_base
      end
    end
  end
end

describe 'LDP Test Suite', integration: true do
  before(:all) do
    LdpTestsuiteWrapper.default_instance_options[:version] =
      '0.2.0-SNAPSHOT'
    LdpTestsuiteWrapper.default_instance_options[:url] =
      'https://github.com/ruby-rdf/ldp-testsuite/archive/master.zip'
    LdpTestsuiteWrapper.default_instance_options[:zip_root_directory] =
      'ldp-testsuite-master'

    @server = Capybara::Discoball::Runner.new(KOSServer::Server).boot

    @skipped_tests = [
      'testContainsRdfType',
      'testTypeRdfSource',
      'testRdfTypeLdpContainer',
      'testPreferContainmentTriples',
      'testPreferMembershipTriples',
      'testPutRequiresIfMatch',
      'testRestrictUriReUseSlug'
    ]
  end

  describe 'basic containers' do
    it_behaves_like 'ldp test suite' do
      let(:server_url)         { @server }
      let(:skipped_tests)      { @skipped_tests }
      let(:test_suite_options) { { 'non-rdf' => true, basic: true } }
    end
  end

  describe 'direct containers' do
    it_behaves_like 'ldp test suite' do
      let(:server_url)         { @server }
      let(:skipped_tests)      { @skipped_tests }
      let(:test_suite_options) { { 'non-rdf' => true, direct: true } }
    end
  end

  describe 'indirect containers' do
    it_behaves_like 'ldp test suite' do
      let(:server_url)         { @server }
      let(:skipped_tests)      { @skipped_tests }
      let(:test_suite_options) { { 'non-rdf' => true, indirect: true } }
    end
  end
end
