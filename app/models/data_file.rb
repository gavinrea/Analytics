class DataFile < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :datafile, :presence => true

  def self.save(upload)
    if (upload.nil?)
      'no file to upload'
    else

      
    end
    Dir.mkdir(directory)
    File.chmod(0700,directory)
  end

      # get the file name
      name =  upload['datafile'].original_filename

      # create the file path
      path = File.join(directory, name)

      # write the file
      File.open(path, "wb") { |f| f.write(upload['datafile'].read) }

      # return the local file name
      path
    end
  end
end
