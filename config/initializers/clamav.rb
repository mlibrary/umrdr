if defined? ClamAV
  ClamAV.instance.loaddb
  ClamAV.instance.setstring(ClamAV::CL_ENGINE_TMPDIR, File.join(Rails.root, 'tmp/derivatives'))
end
