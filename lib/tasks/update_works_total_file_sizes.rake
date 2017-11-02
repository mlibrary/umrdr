#require 'rspec/core'
#require 'rspec/core/rake_task'

desc 'Update generic works to include total file size'
task :update_works => :environment do
  Umrdr::UpdateWorksTotalFileSizes.run
end

module Umrdr
  class UpdateWorksTotalFileSizes
    def self.run
      total = 0
      nil_af_files = []
      nil_files = []
      all_works = []
      begin
        all_works = ::GenericWork.all
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
                  size = file.size
                  subtotal += size
                  total += size
                end
              end
            end
            puts w.id + " subtotal: " + ActiveSupport::NumberHelper.number_to_human_size( subtotal )
            w.total_file_size = subtotal
            w.save!
          end
        end
      rescue Exception => e
        STDERR.puts "UpdateWorksTotalFileSizes #{e.class}: #{e.message}"
      end
      puts
      puts "nil_af_files count = #{nil_af_files.size}"
      puts "nil_af_files = " + nil_af_files.to_s
      puts
      puts "nil_files count = " + nil_files.size.to_s
      #puts "nil_files = " + nil_files.to_s
      puts
      puts "Total: " + ActiveSupport::NumberHelper.number_to_human_size( total )
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
