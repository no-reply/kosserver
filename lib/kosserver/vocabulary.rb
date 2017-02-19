require 'rdf'

module KOSServer
  class KOP < RDF::StrictVocabulary('http://ko.ischool.uw.edu/ns/ko-platform#')

    # Container Classes
    term :SchemeContainer,
         label:      "Scheme Container".freeze,
         subClassOf: ["ldp:IndirectContainer".freeze],
         type:       "rdfs:Class".freeze

    term :ConceptContainer,
         label:      "Concept Container".freeze,
         subClassOf: ["ldp:IndirectContainer".freeze],
         type:       "rdfs:Class".freeze
  end
end

