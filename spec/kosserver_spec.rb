require 'spec_helper'

require 'capybara_discoball'
require 'faraday'
require 'ldp_testsuite_wrapper'
require 'ldp_testsuite_wrapper/rspec'
require 'nokogiri'
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
      let(:test_suite_options) { { 'non-rdf' => true, inderect: true } }
    end
  end
end
