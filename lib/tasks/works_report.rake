# frozen_string_literal: true

# ported from deepblue

namespace :deepblue do

  # bundle exec rake deepblue:works_report
  desc 'Write report of all works'
  task :works_report, %i[ options ] => :environment do |_task, args|
    args.with_defaults( options: '{}' )
    options = args[:options]
    task = Umrdr::WorksReport.new( options: options )
    task.run
  end

end

module Umrdr

  require 'tasks/curation_concern_report_task'
  require 'stringio'

  class WorksReport < CurationConcernReportTask

    # Produce a report containing:
    # * # of datasets
    # * Total size of the datasets in GB
    # * # of unique depositors
    # * # of repeat depositors
    # * Top 10 file formats (csv, nc, txt, pdf, etc)
    # * Discipline of dataset
    # * Names of depositors
    #

    def initialize( options: {} )
      super( options: options )
    end

    def run
      initialize_report_values
      report
    end

    protected

      def report
        out_report << "Report started: " << Time.new.to_s << "\n"
        prefix = "#{Time.now.strftime('%Y%m%d')}_works_report"
        @works_file = Pathname.new( '.' ).join "#{prefix}_works.csv"
        @file_sets_file = Pathname.new( '.' ).join "#{prefix}_file_sets.csv"
        @out_works = open( works_file, 'w' )
        @out_file_sets = open( file_sets_file, 'w' )
        print_work_line( out_works, header: true )
        print_file_set_line( out_file_sets, header: true )

        report_works

        print "\n"
        print "#{works_file}\n"
        print "#{file_sets_file}\n"

        out_report << "Report finished: " << Time.new.to_s << "\n"
        out_report << "Total works: #{total_works}" << "\n"
        out_report << "Total file_sets: #{total_file_sets}" << "\n"
        out_report << "Total works size: #{human_readable(total_works_size)}\n"
        out_report << "Unique authors: #{authors.size}\n"
        count = 0
        authors.each_pair { |_key, value| count += 1 if value > 1 }
        out_report << "Repeat authors: #{count}\n"
        out_report << "Unique depositors: #{depositors.size}\n"
        count = 0
        depositors.each_pair { |_key, value| count += 1 if value > 1 }
        out_report << "Repeat depositors: #{count}\n"
        top = top_ten( authors )
        top_ten_print( out_report, "\nTop ten authors:", top )
        top = top_ten( depositors )
        top_ten_print( out_report, "\nTop ten depositors:", top )
        top = top_ten( extensions )
        top_ten_print( out_report, "\nTop ten extensions:", top )
        @out_report_file = Pathname.new( '.' ).join "#{prefix}.txt"
        open( @out_report_file, 'w' ) { |out| out << out_report.string }
        print "\n"
        print "\n"
        print out_report.string
        print "\n"
        STDOUT.flush
      ensure
        unless out_works.nil?
          out_works.flush
          out_works.close
        end
        unless out_file_sets.nil?
          out_file_sets.flush
          out_file_sets.close
        end
      end

  end

end
