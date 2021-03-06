class ReportsController < ApplicationController
  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.all
    @report = Report.new
    @periods = Period.all # bfh: to support matching periods with reports
    @rprocs = Rproc.all # bfh: to support matching reports with report procedures

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reports }
    end
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
    logger.debug "*** in the show controller..."
    @report = Report.find(params[:id])
    @rprocs = Rproc.all # bfh: to support matching reports with report procedures
    @periods = Period.all # bfh: to support matching periods with reports

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report }
    end

    @report.update_attribute(:updated_at, Time.now) 
  end

  # GET /reports/new
  # GET /reports/new.json
  def new
    @report = Report.new
    @periods = Period.all # bfh: to support matching periods with reports

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report }
    end
  end

  # GET /reports/1/edit
  def edit
    @periods = Period.all # bfh: to support matching periods with reports
    @rprocs = Rproc.all # bfh: to support matching reports with report procedures
    @report = Report.find(params[:id])
  end

  # POST /reports
  # POST /reports.json
  def create
    @report = Report.new(params[:report])
    @periods = Period.all # bfh: to support matching periods with reports
    @rprocs = Rproc.all # bfh: to support matching reports with report procedures

    flash[:report_format] = params[:report_format]

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render json: @report, status: :created, location: @report }
      else
        format.html { render action: "new" }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reports/1
  # PUT /reports/1.json
  def update
    @report = Report.find(params[:id])

    respond_to do |format|
      if @report.update_attributes(params[:module_name])
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report = Report.find(params[:id])
    @report.destroy

    respond_to do |format|
      format.html { redirect_to reports_url }
      format.json { head :no_content }
    end
  end

  #
  # BFH handle jQuery database query for form
  #
  def getFormats
      @rproc_data = Rproc.where(module_name: params[:mn]).first
      if @rproc_data.blank?
        render :text => "record_not_found"
      else
	tmp = Hash.new()
	tmp['pdf'] = @rproc_data.pdf_support;
	tmp['csv'] = @rproc_data.csv_support;
	tmp['html'] = @rproc_data.html_support;
        render :text => tmp.collect { |k, v| "#{k}:#{v}" }.join('~')
      end
    end
end
