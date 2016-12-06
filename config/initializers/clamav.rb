ClamAV.instance.loaddb if defined? ClamAV
ClamAV.instance.setstring(CL_ENGINE_TMPDIR, File.join(Rails.root, 'tmp', 'derivatives'))
