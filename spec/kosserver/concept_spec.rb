require 'spec_helper'

describe KOSServer::Concept do
  let(:uri)       { RDF::URI('http://ex.org/moomin') }
  let(:container) { described_class.new(uri) }

  let(:content)      { StringIO.new(graph.dump(:ntriples)) }
  let(:resource_uri) { uri / '#concept' }

  let(:graph) { RDF::Graph.new }

  # TODO: Resolve IndirectContainer specs
  it_behaves_like 'an RDFSource' do
    subject { described_class.new(uri) }
  end
  
  describe '.to_uri' do
    it 'has correct container class' do
      expect(described_class.to_uri).to eq KOSServer::KOP.ConceptContainer
    end
  end
end
