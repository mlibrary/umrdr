module CurationConcerns
  class FileSetsController < ApplicationController
    include CurationConcerns::FileSetsControllerBehavior
    include Sufia::Controller
    include Sufia::FileSetsControllerBehavior

   def create
     if params[:selected_files].present?
       create_from_browse_everything(params)
     else
       super
     end
   end 

   def create_from_upload(params)
      # check error condition No files
      return render_json_response(response_type: :bad_request, options: { message: 'Error! No file to save' }) unless params.key?(:file_set) && params.fetch(:file_set).key?(:files)

      file = params[:file_set][:files].detect { |f| f.respond_to?(:original_filename) }
      if !file
        render_json_response(response_type: :bad_request, options: { message: 'Error! No file for upload', description: 'unknown file' })
      elsif empty_file?(file)
        render_json_response(response_type: :unprocessable_entity, options: { errors: { files: "#{file.original_filename} has no content! (Zero length file)" }, description: t('curation_concerns.api.unprocessable_entity.empty_file') })
      elsif too_large_file?(file)
        render_json_response(response_type: :unprocessable_entity, options: { errors: { files: "#{file.original_filename} is larger than #{Sufia.config.max_file_size_str}" }, description: t('curation_concerns.api.unprocessable_entity.too_large_file') })
      else
        process_file(file)
      end
    rescue RSolr::Error::Http => error
      logger.error "FileSetController::create rescued #{error.class}\n\t#{error}\n #{error.backtrace.join("\n")}\n\n"
      render_json_response(response_type: :internal_error, options: { message: 'Error occurred while creating a FileSet.' })
    ensure
      # remove the tempfile (only if it is a temp file)
      file.tempfile.delete if file.respond_to?(:tempfile)
    end

    def too_large_file?(file)
      (file.respond_to?(:tempfile) && file.tempfile.size > Rails.configuration.max_file_size) || (file.respond_to?(:size) && file.size > Rails.configuration.max_file_size)
    end

protected

    def show_presenter
     Umrdr::FileSetPresenter
    end

  end
end
