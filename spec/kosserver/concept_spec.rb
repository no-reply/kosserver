require 'spec_helper'

describe KOSServer::Concept do
  let(:uri)       { RDF::URI('http://ex.org/moomin') }
  let(:container) { described_class.new(uri) }
  
  describe '.to_uri' do
    it 'has correct container class' do
      expect(described_class.to_uri).to eq KOSServer::KOP.ConceptContainer
    end
  end
end
