class VoterDatesReport
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
    lodate = nil			# lowest date
    hidate = nil			# highest date

    rows.each do |row|
      d = row['date'].to_time.strftime("%F %T")

      lodate = d if lodate.nil?
      lodate = d if d < lodate

      hidate = d if hidate.nil?
      hidate = d if d > hidate
    end

    # send the processed data to the appropriate output routine
    if format == 'html'
        return html_output(lodate,hidate)
    end
    if format == 'csv'
        return csv_output(lodate,hidate)
    end

    return "Programming error in report generation"
  end

  # create the HTML version of the report and display it in the browser
  def html_output(lodate,hidate)

    retval = '<table cellspacing="3" cellpadding="3">'
    retval += "\n<tr>"

    # output the column headers
    I18n.t('VoterDatesReport.column_headers').each do |h|
      retval += "<th>#{h}</th>"
    end

    retval += "\n</tr>\n"

    retval += "<tr><td>#{lodate}</td><td>#{hidate}</td></tr>\n"
    retval += "</table>\n"

    # return the formatted HTML
    retval
  end

  # create the CSV version of the report and download it to the client 
  def csv_output(lodate,hidate)

    # some day the user id will be added to the filename so that it really works
    fn = Rails.root.join('public','data','VoterDatesReport.csv')

    csv = File.open(fn,"w")

    # output the column headers
    hdrs = Array.new;
    I18n.t('VoterDatesReport.column_headers').each do |h|
      hdrs.push('"' + h + '"')
    end
    csv.puts hdrs.join(',')

    # output the corresponding data
    csv.puts "#{lodate},#{hidate}"

    csv.close

    ActionController::Base.helpers.link_to "CSV","/data/VoterDatesReport.csv"
  end
end
