module Umrdr
  module FileSetBehavior
    extend ActiveSupport::Concern

    # Dirty dirty trick to ensure all have 'open' visibility.
    # Can leave all the rest of the Sufia machinery in place.
    def visibility
      'open'
    end

    def visibility=(value)
      super('open')
    end

    # Override the derivatives generation to avoid full text and non-thumbnail
    # generation.
    def create_derivatives(filename)
      case mime_type
      when *self.class.pdf_mime_types
        Hydra::Derivatives::PdfDerivatives.create(filename,
                                                  outputs: [{ label: :thumbnail, format: 'jpg',
                                                              size: '150x150',
                                                              url: derivative_url('thumbnail') }])
      when *self.class.video_mime_types
        Hydra::Derivatives::VideoDerivatives.create(filename,
                                                    outputs: [{ label: :thumbnail, format: 'jpg',
                                                                size: '150x150',
                                                                url: derivative_url('thumbnail') }])
      when *self.class.image_mime_types
        Hydra::Derivatives::ImageDerivatives.create(filename,
                                                    outputs: [{ label: :thumbnail, format: 'jpg',
                                                                size: '150x150',
                                                                url: derivative_url('thumbnail') }])
      end
    end
  end
end
