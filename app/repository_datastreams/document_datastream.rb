class DocumentDatastream < GenericWorkRdfDatastream
  map_predicates do |map|
    map.alternate_title(to: "title#alternate", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.bibliographic_citation({in: RDF::DC, to: 'bibliographicCitation'})

    map.contributor(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.coverage_spatial({to: "coverage#spatial", in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.coverage_temporal({to: "coverage#temporal", in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.creator(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_created(:to => "date#created", :in => RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.date_modified(to: "modified", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.date_uploaded(to: "dateSubmitted", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.description(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.genre({to: "type#genre", in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.identifier({to: "identifier#doi", in: RDF::QualifiedDC})

    map.language({in: RDF::DC}) do |index|
      index.as :searchable, :facetable
    end

    map.note({to: 'description#note', in: RDF::QualifiedDC})

    map.publisher({in: RDF::DC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.publisher_digital({to:"publisher#digital", in: RDF::QualifiedDC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.requires({in: RDF::DC})

    map.rights(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.source({in: RDF::DC})

    map.subject(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable, :facetable
    end

    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.type(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.unit(to: "subject#unit", in: RDF::QualifiedDC, class_name: 'Unit')
  end

  accepts_nested_attributes_for :unit
  class Unit
    include ActiveFedora::RdfObject
    map_predicates do |map|
      map.college({ to: 'subject#college', in: RDF::QualifiedDC }) do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end

      map.department({ to: 'subject#department', in: RDF::QualifiedDC }) do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end
    end

    def persisted?
      rdf_subject.present?
    end

    def id
      rdf_subject.to_s if persisted?
    end
  end
end
