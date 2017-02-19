require 'kosserver/vocabulary'

module KOSServer
  ##
  # A ConceptScheme represents a `kop:SchemeContainer`.
  # 
  # The SchemeContainer is an `ldp:IndirectContainer` with several strict 
  # requirements at creation time:
  #
  #   - it MUST have an `ldp:membershipResource`; this resource is the 
  #       `skos:ConceptScheme` this container controls.
  #   - it MUST have an `ldp:hasMemberRelation` of `skos:hasTopConcept`; this
  #     is added by default if it is not present.
  #
  #    <> a kop:SchemeContainer ;
  #      ldp:membershipResource <myKOS> ;
  #      ldp:hasMemberRelation skos:hasTopConcept ;
  #      ldp:insertedContentRelation foaf:primaryTopic ;
  #
  #    <myKOS> a skos:ConceptScheme ;
  #      dct:title "Example KOS" .
  #
  # @see http://www.w3.org/TR/ldp/#dfn-linked-data-platform-indirect-container
  #   Definition of LDP Indirect Container
  class ConceptScheme < RDF::LDP::IndirectContainer
    ##
    # @see RDF::LDP::Container.to_uri
    def self.to_uri
      KOP.SchemeContainer
    end

    RDF::LDP::InteractionModel.register(self)

    def create(*args)
      super(*args) do |transaction|
        raise RDF::LDP::NotAcceptable if 
          transaction.query([subject_uri, MEMBERSHIP_RESOURCE_URI, :o]).empty? ||
          !transaction.query([subject_uri, RELATION_TERMS.first, :o]).empty?
        transaction.insert(default_membership_resource_statement)
        
      end
    end

    ##
    # @see RDF::LDP::Container#container_class
    def container_class
      self.class.to_uri
    end

    private

    def default_member_relation_statement
      RDF::Statement(subject_uri, 
                     RELATION_TERMS.first, 
                     RDF::Vocab::SKOS.hasTopConcept)
    end
  end
end
