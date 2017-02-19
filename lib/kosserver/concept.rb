require 'kosserver/vocabulary'

module KOSServer
  ##
  # A ConceptScheme represents a `kop:ConceptContainer`.
  class Concept < RDF::LDP::IndirectContainer
    ##
    # @see RDF::LDP::Resource.interaction_model
    def self.interaction_model(link_header)
      models = LinkHeader.parse(link_header)
        .links
        .select { |link| link['rel'].casecmp 'type' }

      return Concept if models.empty?

      super
    end

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

    private

    def default_member_relation_statement
      RDF::Statement(subject_uri,
                     RELATION_TERMS.first,
                     RDF::Vocab::SKOS.narrower)
    end
  end
end
