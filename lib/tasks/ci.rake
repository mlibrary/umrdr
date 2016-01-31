require 'jettywrapper'

desc "Run the ci build"
task ci: ['jetty:clean', 'jetty:config'] do
  jetty_params = Jettywrapper.load_config
  Jettywrapper.wrap(jetty_params) do
    # run the tests
    Rake::Task["spec"].invoke
  end
end
