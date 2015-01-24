class VoterActionsReport
  attr_accessor :items

  # set up the report generation, probably using the helper method
  def initialize(attr = {})
    # read in params, set attrs
  end

  # create the report when so commanded
  def generate(format, period)

    # use the provided method to get the rows on which to report
    # this gets voters within the specified period
    votersInPeriod = ReportsHelper.get_report_items(period)

    # Rails.logger.debug "votersInPeriod: #{votersInPeriod.inspect}"

    # do the actual processing where we accumulate data to report
    # let's create these hashes to already include the categories so we don't have to make them on the fly
    accumVtrActions = {"other" => {"other" => 0}}
    accumVtrForms = {"other" => {"other" => 0}}
    accumArray = [accumVtrActions, accumVtrForms]; #where we will put all the different accums
    #can we DRY this up?

    #Here is where to insert new logic!
    votersInPeriod.each do |vtr|



      # FORMS
      if vtr.form.nil? #no form exists? put it in other
        accumVtrForms["other"]["other"] += 1
      else 
         accumVtrForms[vtr.form] = {"other" => 0} if !accumVtrForms.has_key?(vtr.form) #if we have no category, make a new one

        if vtr.formNote.nil? #if no formNote exists, put in other
           accumVtrForms[vtr.Form]["other"] = 0 if accumVtrForms[vtr.form]["other"].nil?

          accumVtrForms[vtr.form]["other"] += 1

        elsif !accumVtrForms[vtr.form].has_key?(vtr.formNote) #we don't have the category, make a new one
          accumVtrForms[vtr.form] = {vtr.formNote => 1}
        else #we have the category
          accumVtrForms[vtr.form][vtr.formNote] += 1
        end
      end

    Rails.logger.debug accumVtrForms.inspect
      # ACTIONS

      if vtr.action.nil? 
        accumVtractions["other"]["other"] += 1
      else 
        accumVtrActions[vtr.action]= {"other" => 0} if !accumVtrActions.has_key?(vtr.action) 
        if vtr.notes.nil?
          # belowstatement is nil
          Rails.logger.debug accumVtrActions.inspect
          Rails.logger.debug vtr.action.inspect
          Rails.logger.debug accumVtrActions[vtr.action]["other"].inspect
          accumVtrActions[vtr.action]["other"] = 0 if accumVtrActions[vtr.action]["other"].nil?
          accumVtrActions[vtr.action]["other"] += 1 
# one of the above things being added is nil :(
        elsif !accumVtrActions[vtr.action].has_key?(vtr.notes) 
          # Rails.logger.debug " #{accumVtrActions[vtr.action]}"
          # Rails.logger.debug "is #{vtr.action} #{vtr.notes} nil?: #{accumVtrActions[vtr.action][vtr.notes]}"
          accumVtrActions[vtr.action] = {vtr.notes => 1}
          
        else 
          accumVtrActions[vtr.action][vtr.notes] += 1
        end
      end

    end

    # Rails.logger.debug "accumVtrActions #{accumVtrActions.inspect}"
    # Rails.logger.debug "accumVtrForms #{accumVtrForms.inspect}"
    # Rails.logger.debug "accumArray #{accumArray.inspect}"

    # send the processed data to the appropriate output routine
    if format == 'html'
      return html_output(accumVtrForms, accumVtrActions)
    end
    if format == 'csv'
      return csv_output(accumVtrForms, accumVtrActions)
    end

    return "Programming error in report generation"
  end


  # create the HTML version of the report and display it in the browser
  # let's modify this so that it can take multiple hashes (one for action, one for form, etc.)
  def html_output(*accums)
    #actually, should be a combo of different functions
    retval = ''#HTML string to return
    # place in 2 headers for each accum starting at the first
    headerStartIndex = 0
    headerLength = 2 #currently Action, numActions, %total

    accums.each do |accum| 

      retval += makeNestedHtmlTable(accum, headerStartIndex, headerLength, true) + "<br>\n"
      headerStartIndex +=2
    end
    # return the formatted HTML
    retval
  end

  def makeNestedHtmlTable(accum, headerStartIndex, numHeaders, displayPercentages)

    # set basic table spacing and padding
    retval = '<table cellspacing="3" cellpadding="3">'
    # linefeed, tr = row, th = header cell (in this case, the first one which is empty)
    retval += "\n<tr><th></th>" #no header for the index collumn
    # output the column headers
    # I18n is internationaliztion gem for translation
    # .t looks up the translation, in this case for column_headers(comes from locales/reports/voter_actions.yml)
    # then iterates through
    
    I18n.t('VoterActionsReport.column_headers').slice(headerStartIndex, numHeaders).each do |header|
      # adds in the table headers
      retval += "<th>#{header}</th>"
    end



  retval +="<th>Percentage</th>" if displayPercentages

    # end tag for the table row
    retval += "\n</tr>\n"
    # background
    bg = ''
    count = 0

    # get total to calc overall percentages
    total = 0
    if displayPercentages 
      accum.each_value do |subaccum| 
        subaccum.each_value {|v| total += v}
      end
    end

    # Rails.logger.debug "accu: #{accum.inspect}"

    accum.each do |k,v|
      count += 1
      # will alternate between blank and lightgrey
      bg.blank? ? bg = 'lightgrey' : bg = ''

      #count is the index in table, k is the row key
      retval +="<tr bgcolor=\"#{bg}\"><td align=\"right\">#{count}</td><td>#{k}</td>"
      # add in % and totals
      subtotal = 0
      # once through to sum total from values
      v.each_value {|value| subtotal += value}
      retval +="<td>#{subtotal}</td>"
      retval +="<td>#{(subtotal / total.to_f * 100).round(1)}</td>" if displayPercentages

      #now we nest the table
      retval +="<td align=\"right\">" + '<table border = "1" cellspacing="3" cellpadding="3">' + "\n"

      # only going through once right now :(
        # Rails.logger.debug "current value: #{v.inspect}"
        v.sort_by {|key,value| value}.reverse.each do |key,value|
          # Rails.logger.debug "went through for key: #{key}"
          I18n.t('VoterActionsReport.column_headers').slice(headerStartIndex, 1).each do |header|
          retval +="<tr><th></th><th>#{header}</th>"
        end
          retval +="<th>Percentage</th>" if displayPercentages
          retval +="</tr> <tr>" 
        retval +="<td>#{key}</td>" #row with key
        retval +="<td align=\"right\">#{value}</td>" #value
        retval +="<td align=\"right\">#{(value / total.to_f * 100).round(1)}</td>"  if displayPercentages#Percent
        retval += "</tr>\n" #end row
      end
      retval +="</table>\n</td>\n"
    end
    # closes table
    retval += "</table>\n"

    retval #return formatted html
  end

  # create the CSV version of the report and download it to the client
  # TODO: add support for percentages and multiple tables!
  def csv_output(accum)

    # some day the user id will be added to the filename so that it really workeys
    # guessing this creates a new file?
    fn = Rails.root.join('public','data','VoterActionsReport.csv')
    # opent the new file (w means write only)
    csv = File.open(fn,"w")

    # output the column headers
    hdrs = Array.new
    I18n.t('VoterActionsReport.column_headers').each do |h|
      # puts header on end of hdrs array, for some reason with triple parens
      hdrs.push('"' + h + '"')
    end
    # puts all the headers at the end of the file
    csv.puts hdrs.join(',')

    # output the corresponding data
    accum.each do |k,v|
      csv.puts "#{k},#{v}"
    end

    csv.close
    # will place a link to the csv file???
    ActionController::Base.helpers.link_to "CSV","/data/VoterActionsReport.csv"
  end


  def makeHtmlTable(accum, headerStartIndex, numHeaders, displayPercentages)
    #simplify accum to just first-level values
    simple_accum = Hash.new(accum)
    simple_accum.each do |k, v|
      total = 0
      v.each_value {|value| total += value}
      simple_accum[k] = total
    end

    # set basic table spacing and padding
    retval = '<table cellspacing="3" cellpadding="3">'
    # linefeed, tr = row, th = header cell (in this case, the first one which is empty)
    retval += "\n<tr><th></th>"
    # output the column headers
    # I18n is internationaliztion gem for translation
    # .t looks up the translation, in this case for column_headers(comes from locales/reports/voter_actions.yml)
    # then iterates through
    I18n.t('VoterActionsReport.column_headers').slice(headerStartIndex, numHeaders).each do |header|
      # adds in the table headers
      retval += "<th>#{header}</th>"
    end
    #percentage total will be last header
    retval += "<th>Percent Total</th>" if displayPercentages

    # end tag for the table row
    retval += "\n</tr>\n"
    # background
    bg = ''
    count = 0
    # sort_by: Sorts self in place using a set of keys generated by mapping the values in self through the given block.
    # I think it orders by value smallest to largest
    # then places in alternating lightgrey and white bgs
    total = 0
    if displayPercentages 
      # once through to sum total from values
      simple_accum.each_value {|v| total += v}
    end
    simple_accum.sort_by {|k,v| v}.reverse.each do |k,v|
      count += 1
      # will alternate between blank and lightgrey
      if bg.blank?
        bg = 'lightgrey'
      else
        bg = ''
      end

      #count is the index in table, k is the row key
      retval +="<tr bgcolor=\"#{bg}\"><td align=\"right\">#{count}</td><td>#{k}</td>"
      retval +="<td align=\"right\">#{v[0]}</td>" 

      # Rails.logger.debug "displayPercentages = #{displayPercentages}"
      # Rails.logger.debug "percentage = #{v[1]}"

      if displayPercentages
        retval +="<td align=\"right\">#{(v / total.to_f * 100).round(1)}</td></tr>\n" 
      end

    end
    # closes table
    retval += "</table>\n"

    retval #return formatted html
  end

  # create the CSV version of the report and download it to the client
  # TODO: add support for percentages and multiple tables!
  def csv_output(accum)

    # some day the user id will be added to the filename so that it really works
    # guessing this creates a new file?
    fn = Rails.root.join('public','data','VoterActionsReport.csv')
    # opent the new file (w means write only)
    csv = File.open(fn,"w")

    # output the column headers
    hdrs = Array.new
    I18n.t('VoterActionsReport.column_headers').each do |h|
      # puts header on end of hdrs array, for some reason with triple parens
      hdrs.push('"' + h + '"')
    end
    # puts all the headers at the end of the file
    csv.puts hdrs.join(',')

    # output the corresponding data
    accum.each do |k,v|
      csv.puts "#{k},#{v}"
    end

    csv.close
    # will place a link to the csv file???
    ActionController::Base.helpers.link_to "CSV","/data/VoterActionsReport.csv"
  end
end
