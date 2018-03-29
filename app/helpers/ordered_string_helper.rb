module OrderedStringHelper

  class DeserializeError < Exception
  end

  #
  # convert a serialized array to a normal array of values
  #
  def self.deserialize( str )
    if str.start_with?('[')
      begin
        arr = ActiveSupport::JSON.decode str
        if arr.kind_of?( Array )
          return arr
        end
      rescue ActiveSupport::JSON.parse_error => ignoreAndTryCsvParse
      end
    end
    # try CSV for backwards compatiblity
    arr = CSV.parse_line( str )
    if arr.kind_of?( Array )
      return arr
    end
    raise OrderedStringHelper::DeserializeError
  rescue CSV::MalformedCSVError => e
    raise OrderedStringHelper::DeserializeError
  end

  #
  # serialize a normal array of values to an array of ordered values
  #
  def self.serialize( arr )
    #str = CSV.generate_line( arr, { encoding: "UTF-8" } )
    str = ActiveSupport::JSON.encode( arr ).to_s
    return str
  end

  private

  # defaults
  TOKEN_DELIMITER = '|'.freeze

  def self.deserialize_old( arr )
    return [] if arr.blank?
    #puts "==> OrderedStringHelper::deserialize in #{OrderedStringHelper.relation_to_array( arr )}"
    res = OrderedStringHelper.to_array( arr )
    #puts "==> OrderedStringHelper::deserialize out #{res}"
    return res
  end

  def self.serialize_old( arr )
    return [] if arr.blank?
    #puts "==> OrderedStringHelper::serialize in #{arr}"
    res = []
    arr.each_with_index do |val, ix|
      res << OrderedStringHelper.encode(ix, val )
    end
    #puts "==> OrderedStringHelper::serialize out #{res}"
    return res
  end

  #
  # deserialize a serialized array of values preserving the original order
  #
  def self.to_array( arr )
    res = []
    sort( arr ).each do |val|
      res << OrderedStringHelper.get_value(val )
    end
    return res
  end

  #
  # sort an array of serialized values using the index token to determine the order
  #
  def self.sort( arr )
    # hack to force a stable sort; see https://stackoverflow.com/questions/15442298/is-sort-in-ruby-stable
    n = 0
    return arr.sort_by {|val| n += 1; [ OrderedStringHelper.get_index( val ), n ] }
  end

  #
  # encode an index and a value into a composite field
  #
  def self.encode( index, val )
    return "#{index}#{TOKEN_DELIMITER}#{val}"
  end

  #
  # extract the index attribute from the serialized value; return index '0' if the
  # field cannot be parsed correctly
  #
  def self.get_index( val )
    tokens = val.split( TOKEN_DELIMITER, 2 )
    return tokens[ 0 ].to_i if tokens.length == 2
    return 0
  end

  #
  # extract the value attribute from the serialized value; return the entire value if the
  # field cannot be parsed correctly
  #
  def self.get_value( val )
    tokens = val.split( TOKEN_DELIMITER, 2 )
    return tokens[ 1 ] if tokens.length == 2
    return val
  end

  #
  # convert an ActiveTriples::Relation to a standard array (for debugging)
  #
  def self.relation_to_array( arr )
    return arr.map { |e| e.to_s }
  end

end