module Umrdr
  class HandleMintingService
    attr work, hdl_prefix

    def self.mint_handle_for(work, hdl_prefix=nil)
      srvc = HandleMintingService.new work, hdl_prefix
      srvc.run
    end

    def initialize(work, prefix)
      @work = work
      @prefix = prefix
    end

    private

    def run
      return unless handle_server_reachable?
      mint_hdl
    end

    # Check that the server is reachable
    def handle_server_reachable?
      # Invoke the API and get response
      false
    end

    def mint_hdl
      # Do something with the work id and handle prefix
      1000000
    end
  end
end
