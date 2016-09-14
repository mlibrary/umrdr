module CurationConcerns
  class PermissionBadge
    include ActionView::Helpers::TagHelper

    def initialize(solr_document)
      @solr_document = solr_document
    end

    # Draws a span tag with styles for a bootstrap label
    def render
      content_tag(:span, link_title, title: link_title, class: "label #{dom_label_class}")
    end

    private

      def dom_label_class
        if open_access?
          'label-success'
        elsif registered?
          'label-info'
        else
          'label-danger'
        end
      end

      def link_title
        if open_access?
          'Open Access'
        elsif registered?
          I18n.translate('curation_concerns.institution_name')
        else
          'Draft'
        end
      end

      def open_access?
        @open_access = @solr_document.visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC if @open_access.nil?
        @open_access
      end

      def registered?
        @registered = @solr_document.visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED if @registered.nil?
        @registered
      end

  end
end