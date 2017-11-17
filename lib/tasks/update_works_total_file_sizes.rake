
desc 'Update generic works to include total file size'
task :update_works => :environment do
  Umrdr::UpdateWorksTotalFileSizes.run
end

desc 'Update single generic work to include total file size'
task :update_work => :environment do
  Umrdr::UpdateWorkTotalFileSizes.run
end

module Umrdr

  class UpdateWork
    def self.run
      # TODO: pass in the work ids
      all_works = []
      all_works << ::GenericWork.find( '1n79h444s' )
      all_works << ::GenericWork.find( 'ft848q70w' )
      #all_works << ::GenericWork.find( 'mg74qm08d' )
      UpdateWorksTotalFileSizes.new( all_works ).run
    end
  end

  class UpdateWorks
    def self.run
      all_works = ::GenericWork.all
      UpdateWorksTotalFileSizes.new( all_works ).run
    end
  end

  class UpdateWorksTotalFileSizes

    def initialize( works )
      @works = works
    end

    def run
      total = 0
      nil_af_files = []
      nil_files = []
      begin
        @works.map do |w|
          if w.nil?
            puts "Skipping nil work"
          else
            subtotal = 0
            print "#{w.id} has #{w.file_set_ids.size} files..."
            STDOUT.flush
            w.file_set_ids.map do |fid|
              af = ActiveFedora::Base.find fid
              if af.nil?
                nil_af_files << fid
              else
                file = nil
                begin
                  file = af.original_file
                rescue Ldp::HttpError => e2
                  puts "#{e2.class}: #{e2.message} at #{e2.backtrace[0]}"
                rescue Exception => e
                  puts "#{e.class}: #{e.message} at #{e.backtrace[0]}"
                end
                if file.nil?
                  nil_files << af
                else
                  size = file.size
                  subtotal += size
                  total += size
                end
              end
            end
            puts "with total size: #{ActiveSupport::NumberHelper.number_to_human_size( subtotal )}\n"
            STDOUT.flush
            begin
              w.total_file_size = subtotal
              w.save( validate: false )
            rescue Ldp::HttpError => e2
              puts "#{e2.class}: #{e2.message} at #{e2.backtrace[0]}"
            rescue Exception => e
              puts "#{e.class}: #{e.message} at #{e.backtrace[0]}"
            end
          end
        end
      rescue Exception => e
        STDERR.puts "UpdateWorksTotalFileSizes #{e.class}: #{e.message} at #{e.backtrace[0]}"
      end
      puts
      puts "nil_af_files count = #{nil_af_files.size}"
      puts "nil_af_files = #{nil_af_files}"
      puts
      puts "nil_files count = #{nil_files.size}"
      #puts "nil_files = #{nil_files}"
      puts
      puts "Total: #{ActiveSupport::NumberHelper.number_to_human_size( total )}"
    end
  end

  class FindFilesWithDotNCExtension
    def self.run
      total = 0
      nil_af_files = []
      nil_files = []
      work_ids_found = []
      all_works = []
      begin
        all_works = ::GenericWork.all ; all_works.size
        all_works.map do |w|
          if w.nil?
            puts "Skipping nil work"
          else
            subtotal = 0
            puts "#{w.id} has #{w.file_set_ids.size} files"
            w.file_set_ids.map do |fid|
              af = ActiveFedora::Base.find fid
              if af.nil?
                nil_af_files << fid
              else
                file = nil
                begin
                  file = af.original_file
                rescue Exception => e
                  puts "#{e.class}: #{e.message}"
                end
                if file.nil?
                  nil_files << af
                else
                  if ( file.file_name[0] =~ /\.nc$/ )
                    puts "found file_name match for work #{w.id}"
                    unless work_ids_found.include? w.id
                      work_ids_found << w.id
                    end
                  end
                  size = file.size
                  subtotal += size
                  total += size
                end
              end
            end
            puts w.id + " subtotal: " + ActiveSupport::NumberHelper.number_to_human_size( subtotal )
          end
        end
      rescue Exception => e
        STDERR.puts "FindFilesWithDotNCExtension #{e.class}: #{e.message}"
      end
      puts
      puts "nil_af_files count = #{nil_af_files.size}"
      puts "nil_af_files = " + nil_af_files.to_s
      puts
      puts "nil_files count = " + nil_files.size.to_s
      #puts "nil_files = " + nil_files.to_s
      puts
      puts "Total: " + ActiveSupport::NumberHelper.number_to_human_size( total )
      puts
      puts "Work ids found containing .nc files: " + work_ids_found.to_s
    end
  end

end
