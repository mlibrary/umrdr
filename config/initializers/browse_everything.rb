# require 'browse_everything'

module BrowseEverything
  module Driver
    class Base
      def callback
        config[:callback]
      end
    end
  end
end


