module ReportsHelper

  # GenRept is a simple dispatch routine, calling report generation based on module name
  def GenRept(report)

    # parameter is a report job description
    rproc_key = report.module_name
    period_name = report.period

    format = params[:report_format]
    if format.nil? or format.empty? or format.blank?
      format = flash[:report_format]
    end
logger.debug "*** GenRept: params: " + params.inspect
logger.debug "*** GenRept: flash: " + flash.inspect

    # expand period name into parameters
    period = Hash.new()
    @periods.each do |tmp|
      if tmp.name == period_name
	period['ptype'] = tmp.ptype
	period['lodate'] = tmp.lodate
	period['hidate'] = tmp.hidate
	period['voter_reg_lodate'] = tmp.voter_reg_lodate
	period['voter_req_hidate'] = tmp.voter_reg_hidate
	break
      end
    end

    # call the class based on what the rproc says
    # This is where the report is being created!!! So must be source of error
    # Question is: does rproc_key exist?
    rpt = Object.const_get(rproc_key).new
    retval = rpt.generate(format,period)

    retval
  end

  #
  # these functions implement the reports
  #

  def get_report_items(period)
    # get a list of VTRs between these dates and make a hash of the formNote
    Vtr.where("date(date) between ? and ?", period['lodate'].to_s(:db), period['hidate'].to_s(:db))
  end
  module_function :get_report_items
end
