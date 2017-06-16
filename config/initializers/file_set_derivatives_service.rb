Hyrax::FileSetDerivativesService.class_eval do

  def valid?
    begin
      supported_mime_types.include?(mime_type)
    rescue
      nil
    end
  end

end