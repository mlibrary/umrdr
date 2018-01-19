
module Umrdr

  class TaskPacifier

    def initialize( out: $stdout, count_nl: 100 )
      @out = out
      @count = 0
      @count_nl = count_nl
    end

    def pacify( x = '.' )
      x = x.to_s
      @count = @count + x.length
      @out.print x
      if @count > @count_nl
        nl
      end
      @out.flush
    end

    def pacify_bracket( x, bracket_open: '(', bracket_close: ')' )
      x = x.to_s
      x = "#{bracket_open}#{x}#{bracket_close}" if x.length > 1
      pacify x
    end

    def nl
      @out.print "\n"
      @out.flush
      @count = 0
    end

  end

end
