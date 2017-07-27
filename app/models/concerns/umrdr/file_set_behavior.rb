module Umrdr
  module FileSetBehavior
    extend ActiveSupport::Concern


    # Override the derivatives generation to avoid full text and non-thumbnail
    # generation.
    def create_derivatives(filename)
      case mime_type
      when *self.class.pdf_mime_types
        Hydra::Derivatives::PdfDerivatives.create(filename,
                                                  outputs: [{ label: :thumbnail, format: 'jpg',
                                                              size: '150x150',
                                                              }])
      when *self.class.video_mime_types
        Hydra::Derivatives::VideoDerivatives.create(filename,
                                                    outputs: [{ label: :thumbnail, format: 'jpg',
                                                                size: '150x150',
                                                                }])
      when *self.class.image_mime_types
        Hydra::Derivatives::ImageDerivatives.create(filename,
                                                    outputs: [{ label: :thumbnail, format: 'jpg',
                                                                size: '150x150',
                                                                 }])
      end
    end
  end
end
