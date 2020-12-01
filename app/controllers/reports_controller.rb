class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :edit, :update, :destroy]
  before_action :user_not_authorized, only: [:new, :edit, :create, :update, :destroy]
  skip_forgery_protection only: [:secret_create]

  # GET /reports
  # GET /reports.json
  def index
    respond_to do |format|
      format.html do
        @reports_length = Report.count
        @reports = Report.includes(:region).order(created_at: :asc).page params[:page]
      end
      format.json { render json: Report.includes(:region).order(created_at: :asc).to_json, status: :ok }
    end
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
  end

  # GET /reports/new
  def new
    @report = Report.new
  end

  # GET /reports/1/edit
  def edit
  end
  
  # GET /reports/by_country/US
  def by_country
    all = Report.order(created_at: :asc).joins(:region).where(regions: { country: params[:country] })
    respond_to do |format|
      format.html do
        @reports_length = all.length
        @reports = all.page params[:page]
      end
      format.json { render json: all.to_json, status: :ok }
    end
    
  end
  
  def compare
    
  end
  
  # GET /reports/by_region/1
  def by_region
    all = Report.where(region_id: params[:region_id]).order(created_at: :asc).page params[:page]
    respond_to do |format|
      format.html do
        @reports_length = all.length
        @reports = all.page params[:page]
      end
      format.json { render json: all.to_json, status: :ok }
    end
  end

  # POST /reports
  # POST /reports.json
  def create
    @report = Report.new(report_params)

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  def secret_create
    if params[:data]
      JSON.parse(params[:data]).each do |report|
        @report = Report.find_or_create_by(region_id: report["region_id"], created_at: report["created_at"])
        @report.confirmed = report["confirmed"] ? report["confirmed"] : @report.confirmed
        @report.deaths = report["deaths"] ? report["deaths"] : @report.deaths
        @report.save
      end
    else
      @report = Report.find_or_create_by(region_id: report_params[:region_id], created_at: report_params[:created_at])
      @report.confirmed = report_params[:confirmed] ? report_params[:confirmed] : @report.confirmed
      @report.deaths = report_params[:deaths] ? report_params[:deaths] : @report.deaths
    end
    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { render :show, status: :ok, location: @report }
      else
        format.html { render :edit }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url, notice: 'Report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def report_params
      params.require(:report).permit(:created_at, :region_id, :confirmed, :deaths, :recovered)
    end
end
