class UsReportsController < ApplicationController
  before_action :set_us_report, only: [:show, :edit, :update, :destroy]
  before_action :user_not_authorized, only: [:new, :edit, :create, :update, :destroy]
  skip_forgery_protection only: [:secret_create]

  # GET /us_reports
  # GET /us_reports.json
  def index
    @us_reports = UsReport.all
  end
  
  # GET /us_reports/state/AL.json
  def state
    @us_reports = UsReport.where(state: UsReport.long(params[:state]), county: nil).order(created_at: :asc)
    respond_to do |format|
      format.json { render json: @us_reports.to_json, status: :ok }
    end
  end

  # GET /us_reports/1
  # GET /us_reports/1.json
  def show
  end

  # GET /us_reports/new
  def new
    @us_report = UsReport.new
  end

  # GET /us_reports/1/edit
  def edit
  end

  # POST /us_reports
  # POST /us_reports.json
  def create
    @us_report = UsReport.new(us_report_params)

    respond_to do |format|
      if @us_report.save
        format.html { redirect_to @us_report, notice: 'Us report was successfully created.' }
        format.json { render :show, status: :created, location: @us_report }
      else
        format.html { render :new }
        format.json { render json: @us_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /us_reports/SECRET.json
  def secret_create
    if params[:data]
      JSON.parse(params[:data]).each do |us_report|
        @us_report = UsReport.find_or_create_by(state: us_report["state"], county: us_report["county"], created_at: us_report["created_at"])
        @us_report.cases = us_report["cases"] ? us_report["cases"] : @us_report.cases
        @us_report.deaths = us_report["deaths"] ? us_report["deaths"] : @us_report.deaths
        @us_report.save
      end
    else
      @us_report = UsReport.find_or_create_by(state: us_report_params[:state], county: us_report_params[:county], created_at: us_report_params[:created_at])
      @us_report.cases = us_report_params[:cases] ? us_report_params[:cases] : @us_report.cases
      @us_report.deaths = us_report_params[:deaths] ? us_report_params[:deaths] : @us_report.deaths
    end
    respond_to do |format|
      if @us_report.save
        format.html { redirect_to @us_report, notice: 'Us report was successfully created.' }
        format.json { render :show, status: :created, location: @us_report }
      else
        format.html { render :new }
        format.json { render json: @us_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /us_reports/1
  # PATCH/PUT /us_reports/1.json
  def update
    respond_to do |format|
      if @us_report.update(us_report_params)
        format.html { redirect_to @us_report, notice: 'Us report was successfully updated.' }
        format.json { render :show, status: :ok, location: @us_report }
      else
        format.html { render :edit }
        format.json { render json: @us_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /us_reports/1
  # DELETE /us_reports/1.json
  def destroy
    @us_report.destroy
    respond_to do |format|
      format.html { redirect_to us_reports_url, notice: 'Us report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_us_report
      @us_report = UsReport.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def us_report_params
      params.require(:us_report).permit(:county, :state, :cases, :deaths, :created_at)
    end
end
