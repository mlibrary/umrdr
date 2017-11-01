
Umrdr::Application.config.after_initialize do
  if !Rails.env.test?
    GlobusRestartAllJob.perform_later if Umrdr::Application.config.globus_enabled
  end
end
