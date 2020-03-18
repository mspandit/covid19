class BodyTextsController < ApplicationController
  before_action :set_body_text, only: [:show, :edit, :update, :destroy]
  before_action :user_not_authorized, only: [:new, :edit, :create, :update, :destroy]
  skip_forgery_protection only: [:secret_create]
  
  # GET /body_texts
  # GET /body_texts.json
  def index
    @body_texts = BodyText.all.page params[:page]
  end

  # GET /body_texts/1
  # GET /body_texts/1.json
  def show
  end

  # GET /body_texts/new
  def new
    @body_text = BodyText.new
  end
  
  # GET /body_texts/search
  def search
    all = BodyText.search(params[:query])
    @body_texts_length = all.count
    @body_texts = all.page params[:page]
  end

  # GET /body_texts/1/edit
  def edit
  end

  # POST /body_texts
  # POST /body_texts.json
  def create
    @body_text = BodyText.new(body_text_params)

    respond_to do |format|
      if @body_text.save
        format.html { redirect_to @body_text, notice: 'Body text was successfully created.' }
        format.json { render :show, status: :created, location: @body_text }
      else
        format.html { render :new }
        format.json { render json: @body_text.errors, status: :unprocessable_entity }
      end
    end
  end

  def secret_create
    @body_text = BodyText.new(body_text_params)

    respond_to do |format|
      if @body_text.save
        format.html { redirect_to @body_text, notice: 'Body text was successfully created.' }
        format.json { render :show, status: :created, location: @body_text }
      else
        format.html { render :new }
        format.json { render json: @body_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /body_texts/1
  # PATCH/PUT /body_texts/1.json
  def update
    respond_to do |format|
      if @body_text.update(body_text_params)
        format.html { redirect_to @body_text, notice: 'Body text was successfully updated.' }
        format.json { render :show, status: :ok, location: @body_text }
      else
        format.html { render :edit }
        format.json { render json: @body_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /body_texts/1
  # DELETE /body_texts/1.json
  def destroy
    @body_text.destroy
    respond_to do |format|
      format.html { redirect_to body_texts_url, notice: 'Body text was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_body_text
      @body_text = BodyText.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def body_text_params
      params.require(:body_text).permit(:content, :paper_id, :sequence)
    end
end
