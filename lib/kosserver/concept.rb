require 'kosserver/vocabulary'

module KOSServer
  ##
  # A ConceptScheme represents a `kop:ConceptContainer`.
  class Concept < RDF::LDP::IndirectContainer
    ##
    # @see RDF::LDP::Container.to_uri
    def self.to_uri
      KOP.ConceptContainer
    end

    RDF::LDP::InteractionModel.register(self)
    
    ##
    # @see RDF::LDP::Container#container_class
    def container_class
      self.class.to_uri
    end
  end
end
