require 'spec_helper'

describe KOSServer::ConceptScheme do
  let(:uri)       { RDF::URI('http://ex.org/moomin') }
  let(:container) { described_class.new(uri) }

  it 'is registered' do
    expect(RDF::LDP::InteractionModel.for(described_class.to_uri))
      .to be described_class
  end
  
  describe '.to_uri' do
    it 'has correct container class' do
      expect(described_class.to_uri).to eq KOSServer::KOP.SchemeContainer
    end
  end
  
  describe '#create' do
    let(:content) { StringIO.new(graph.dump(:ntriples)) }
    let(:kos_uri) { uri / '#kos' }

    let(:graph) do
      RDF::Graph.new <<
        RDF::Statement(RDF::URI(uri), 
                       described_class::MEMBERSHIP_RESOURCE_URI,
                       kos_uri)
    end

    it 'has a membership resource' do
      container.create(content, 'application/n-triples')

      expect(container.membership_constant_uri).to eq kos_uri
    end

    it 'inserts a hasMemberRelation' do
      container.create(content, 'application/n-triples')

      expect(container.graph)
        .to have_statement RDF::Statement(uri, 
                                          RDF::Vocab::LDP.hasMemberRelation,
                                          RDF::Vocab::SKOS.hasTopConcept)
    end

    it 'rejects non skos:TopConcept relations' do
      graph.insert(RDF::Statement(uri,
                                  RDF::Vocab::LDP.hasMemberRelation,
                                  RDF::URI('http://example.com/fake')))

      expect { container.create(content, 'application/n-triples') }
        .to raise_error RDF::LDP::NotAcceptable
    end

    it 'has a default insertedContentRelation' do
      container.create(content, 'application/n-triples')

      expect(container.inserted_content_relation)
        .to eq RDF::Vocab::LDP.MemberSubject
    end

    context 'when no membership resource is present' do
      let(:content) { StringIO.new }

      it 'raises NotAcceptable' do
        expect { container.create(content, 'application/n-triples') }
          .to raise_error RDF::LDP::NotAcceptable
      end
    end
  end
end
