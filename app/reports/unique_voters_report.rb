class UniqueVotersReport
  attr_accessor :items

  # set up the report generation, probably using the helper method
  def initialize(attr = {})
    # read in params, set attrs
  end

  # create the report when so commanded
  def generate(format,period)

    # use the provided method to get the rows on which to report
    rows = ReportsHelper.get_report_items(period)

    # do the actual processing
    accum = Hash.new()			# where we accumulate data to report

    rows.each do |row|
      k = row['voterid']
      accum[k] = 0 if accum[k].nil?
      accum[k] += 1
    end

    # send the processed data to the appropriate output routine
    if format == 'html'
        return html_output(accum)
    end
    if format == 'csv'
        return csv_output(accum)
    end

    return "Programming error in report generation"
  end

  # create the HTML version of the report and display it in the browser
  def html_output(accum)

    retval = '<table cellspacing="3" cellpadding="3">'
    retval += "\n<tr><th></th>"

    # output the column headers
    I18n.t('UniqueVotersReport.column_headers').each do |h|
      retval += "<th>#{h}</th>"
    end

    retval += "\n</tr>\n"

    bg = ''
    count = 0
    accum.sort_by {|k,v| v}.reverse.each do |k,v|
      count += 1
      if bg.blank?
        bg = 'lightgrey'
      else
        bg = ''
      end
      retval += "<tr bgcolor=\"#{bg}\"><td align=\"right\">#{count}</td><td>#{k}</td><td align=\"right\">#{v}</td></tr>\n"
    end
    retval += "</table>\n"

    # return the formatted HTML
    retval
  end

  # create the CSV version of the report and download it to the client 
  def csv_output(accum)

    # some day the user id will be added to the filename so that it really works
    fn = Rails.root.join('public','data','UniqueVotersReport.csv')

    csv = File.open(fn,"w")

    # output the column headers
    hdrs = Array.new;
    I18n.t('UniqueVotersReport.column_headers').each do |h|
      hdrs.push('"' + h + '"')
    end
    csv.puts hdrs.join(',')

    # output the corresponding data
    accum.each do |k,v|
      csv.puts "#{k},#{v}"
    end

    csv.close

    ActionController::Base.helpers.link_to "CSV","/data/UniqueVotersReport.csv"
  end
end
