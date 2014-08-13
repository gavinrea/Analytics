# from http://users.aber.ac.uk/cwl/ruby/db_seed.rake
namespace :db do
  desc "Load seed fixtures (from db/fixtures) into the current environment's database."
  puts "Load seed fixtures (from db/fixtures) into the current environment's database."
  task :seed => :environment do
    require 'active_record/fixtures'

    # preserve the existing active flags, if any
    flags = Hash.new()
    @rprocs = Rproc.all
    @rprocs.each do |rproc| 
      flags[rproc.module_name] = rproc.active
    end
    
    path_name = Rails.root.join('db','fixtures','*.{yml,rb}')
    puts " * loading from #{path_name}..."

    Dir.glob(path_name).each do |file|
      # If a yml file then create fixtures from yml else if an rb file
      # then execute the ruby file instead

      if file =~ /.*\.yml$/
	this_name = File.basename(file, '.*')

        # since the table is rprocs, the file has to be rprocs.yml
	if this_name == 'rprocs'
	  canonical_name = file
	else
	  canonical_name = file.gsub(/#{this_name}/,"rprocs")
	  FileUtils.cp(file,canonical_name)
	end
        puts " * Running yml data fixture #{file} (#{canonical_name})"
        ActiveRecord::Fixtures.create_fixtures('db/fixtures', 'rprocs')
	File.unlink(canonical_name)
      else
        puts " * Running ruby data fixture #{file}"
        load file
      end

    end

    # set all active flags to the appropriate value
    @rprocs = Rproc.all
    @rprocs.each do |rproc| 
      # either use the saved value or the default
      aflag_value = AppConfig.default_report_active
      if flags.has_key?(rproc.module_name)
          aflag_value = flags[rproc.module_name]
      end
      rproc.update_attribute(:active,aflag_value)
    end

  end
end
