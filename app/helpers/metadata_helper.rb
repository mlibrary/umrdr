module MetadataHelper

  @@FIELD_SEP = '; '.freeze

  def self.report_collection( curration_concern, out: nil, depth:  '==' )
    # TODO
    title = title( curration_concern, field_sep:'' );
    out.puts "#{depth} Collection: #{title} #{depth}"
    report_item( out, "ID: ", curration_concern.id )
    report_item( out, "Title: ", curration_concern.title, one_line: true )
    report_item( out, "Total items: ", curration_concern.member_objects.count )
    report_item( out, "Total size: ", human_readable_size( curration_concern.bytes ) )
    report_item( out, "Creator: ", curration_concern.creator )
    report_item( out, "Keyword: ", curration_concern.keyword, one_line: false, item_prefix: "\t" )
    report_item( out, "Discipline: ", curration_concern.subject, one_line: false, item_prefix: "\t" )
    report_item( out, "Language: ", curration_concern.language )
    report_item( out, "Visibility: ", curration_concern.visibility )
    if 0 < curration_concern.member_objects.count
      curration_concern.member_objects.each do |generic_work|
        out.puts
        report_generic_work( generic_work, out: out, depth: "=#{depth}" )
      end
    end
  end

  def self.report_file_set( curration_concern, out: nil, depth:  '==' )
    out.puts "#{depth} File Set: #{curration_concern.label} #{depth}"
    report_item( out, "ID: ", curration_concern.id )
    report_item( out, "File name: ", curration_concern.label )
    report_item( out, "Date uploaded: ", curration_concern.date_uploaded )
    report_item( out, "Date modified: ", curration_concern.date_uploaded )
    report_item( out, "Total file size: ", human_readable_size( curration_concern.file_size[0] ) )
    report_item( out, "Checksum: ", curration_concern.original_checksum )
    report_item( out, "Mimetype: ", curration_concern.mime_type )
  end

  def self.report_generic_work( curration_concern, out: nil, depth: '==' )
    title = title( curration_concern, field_sep:'' );
    out.puts "#{depth} Generic Work: #{title} #{depth}"
    report_item( out, "ID: ", curration_concern.id )
    report_item( out, "Title: ", curration_concern.title, one_line: true )
    report_item( out, "Methodology: ", curration_concern.methodology )
    report_item( out, "Description: ", curration_concern.description, one_line: false, item_prefix: "\t" )
    report_item( out, "Creator: ", curration_concern.creator )
    report_item( out, "Depositor: ", curration_concern.depositor )
    report_item( out, "Contact: ", curration_concern.authoremail )
    report_item( out, "Discipline: ", curration_concern.subject, one_line: false, item_prefix: "\t" )
    report_item( out, "Funded by: ", curration_concern.fundedby )
    report_item( out, "ORSP Grant Number: ", curration_concern.grantnumber )
    report_item( out, "Keyword: ", curration_concern.keyword, one_line: false, item_prefix: "\t" )
    report_item( out, "Date coverage: ", curration_concern.date_coverage )
    report_item( out, "Citation to related material: ", curration_concern.isReferencedBy )
    report_item( out, "Language: ", curration_concern.language )
    report_item( out, "Total file count: ", curration_concern.file_set_ids.count )
    report_item( out, "Total file size: ", human_readable_size( curration_concern.total_file_size ) )
    report_item( out, "DOI: ", curration_concern.doi, optional: true )
    report_item( out, "Visibility: ", curration_concern.visibility )
    report_item( out, "Rights: ", curration_concern.rights )
    report_item( out, "Admin set id: ", curration_concern.admin_set_id )
    report_item( out, "Tombstone: ", curration_concern.tombstone, optional: true )
    if 0 < curration_concern.file_sets.count
      curration_concern.file_sets.each do |file_set|
        out.puts
        report_file_set( file_set, out: out, depth: "=#{depth}" )
      end
    end
  end

  def self.human_readable_size( value )
    value = value.to_i
    return ActiveSupport::NumberHelper::NumberToHumanSizeConverter.convert( value, precision: 3 )
  end

  def self.report_item( out,
                        label,
                        value,
                        item_prefix: '',
                        item_postfix: '',
                        item_seperator: @@FIELD_SEP,
                        one_line: nil,
                        optional: false
                      )
    multi_item = value.respond_to?( :count ) && value.respond_to?( :each )
    if optional
      return if value.nil?
      return if value.to_s.empty?
      return if multi_item && 0 == value.count
    end
    if one_line.nil?
      one_line = true
      if multi_item
        if 1 < value.count
          one_line = false
        end
      end
    end
    if one_line
      if value.respond_to?( :join )
        out.puts( "#{label}#{item_prefix}#{value.join( "#{item_prefix}#{item_seperator}#{item_postfix}" )}#{item_postfix}" )
      elsif multi_item
        out.print( "#{label}" )
        count = 0
        value.each do |item|
          count += 1
          out.print( "#{item_prefix}#{item}#{item_postfix}" )
          out.print( "#{item_seperator}" ) unless value.count == count
        end
        out.puts
      else
        out.puts( "#{label}#{item_prefix}#{value}#{item_postfix}" )
      end
    else
      out.puts( "#{label}" )
      if multi_item
        value.each { |item| out.puts( "#{item_prefix}#{item}#{item_postfix}" ) }
      else
        out.puts( "#{item_prefix}#{value}#{item_postfix}" )
      end
    end
  end

  def self.title( curration_concern, field_sep: @@FIELD_SEP )
    curration_concern.title.join( field_sep )
  end

end