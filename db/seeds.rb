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
    
    # start fresh with target output file "rprocs.yml"
    output_name = Rails.root.join('db','fixtures','rprocs.yml')
    if File.exist?(output_name)
      File.rename(output_name,"blorty.yml")
      File.unlink(output_name)
    end

    # get a list of the files to be processed: first concatenate, then load
    path_name = Rails.root.join('db','fixtures','*.{yml,rb}')
    puts " * loading from #{path_name}..."

    Dir.glob(path_name).each do |file|
      # If a yml file then create fixtures from yml else if an rb file
      # then execute the ruby file instead

      if file =~ /.*\.yml$/
        # since the table is rprocs, the file has to be rprocs.yml
	system("cat #{file} >> #{output_name}")
        puts " * Adding yml data fixture #{file} to #{output_name}..."
      else
        puts " * Running ruby data fixture #{file}"
        load file
      end

    end
    ActiveRecord::Fixtures.create_fixtures('db/fixtures', 'rprocs')
    File.unlink(output_name)

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
