
Umrdr::Application.config.after_initialize do
  if !Rails.env.test? && !defined?(Rails::Console) && !File.basename($0) == 'rake'
    quiet = Umrdr::Application.config.globus_restart_all_copy_jobs_quiet
    GlobusRestartAllJob.perform_later( quiet: quiet ) if Umrdr::Application.config.globus_enabled
  end
end
