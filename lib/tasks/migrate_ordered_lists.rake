#
# TODO: rewrite
# Some helper tasks to edit works
#

# pull in the helpers
require_dependency 'lib/tasks/task_helpers'
include TaskHelpers

namespace :libraoc do

  namespace :migrate do

    desc "Migration to ordered fields (language, keyword, related_url, sponsoring_agency)"
    task ordered_fields: :environment do |t, args|

      # disable the workflow callbacks
      TaskHelpers.disable_workflow_callbacks

      successes = 0
      errors = 0
      LibraWork.search_in_batches( {} ) do |group|
        group.each do |w|
          begin
            print "."

            work = LibraWork.find( w['id'] )

            # this will migrate the fields...
            work.language = work.language
            work.keyword = work.keyword
            work.related_url = work.related_url
            work.sponsoring_agency = work.sponsoring_agency

            work.save!

            successes += 1
          rescue => e
            errors += 1
          end
        end
      end

      puts "done"
      puts "Processed #{successes} work(s), #{errors} error(s) encountered"

    end

    desc "Refresh by re-saving each work"
    task refresh: :environment do |t, args|

      successes = 0
      errors = 0
      LibraWork.search_in_batches( {} ) do |group|
        group.each do |w|
          begin
            print "."
            work = LibraWork.find( w['id'] )
            work.save!

            successes += 1
          rescue => ex
            puts "EXCEPTION: #{ex}"
            errors += 1
          end
        end
      end

      puts "done"
      puts "Processed #{successes} work(s), #{errors} error(s) encountered"

    end

  end   # namespace migrate

end   # namespace libraoc
