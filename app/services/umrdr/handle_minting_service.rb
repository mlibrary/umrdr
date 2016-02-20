module Umrdr
  class HandleMintingService

    def self.mint_handle_for(work)
      do_the_thing_for work
    end

    private

    # Check that the server is reachable
    def handle_server_reachable?
      # Invoke the API and get response

    end

    def do_the_thing_for(work)
      return unless handle_server_reachable?
      new_hdl = hdl_for work
    end

    def hld_for(work, hdl_prefix=nil)
      # Do something with the work id and handle prefix

    end

  end
end
