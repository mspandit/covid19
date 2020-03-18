class AuthorsController < ApplicationController
  before_action :set_author, only: [:show, :edit, :update, :destroy]
  before_action :user_not_authorized, only: [:new, :edit, :create, :update, :destroy]
  skip_forgery_protection only: [:secret_create]

  # GET /authors
  # GET /authors.json
  def index
    @authors = Author.order(:last).page params[:page]
  end

  # GET /authors/1
  # GET /authors/1.json
  def show
  end

  # GET /authors/new
  def new
    @author = Author.new
  end

  # GET /authors/1/edit
  def edit
  end

  # POST /authors
  # POST /authors.json
  def create
    @author = Author.new(author_params)

    respond_to do |format|
      if @author.save
        format.html { redirect_to @author, notice: 'Author was successfully created.' }
        format.json { render :show, status: :created, location: @author }
      else
        format.html { render :new }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def secret_create
    @author = Author.find_or_create_by(first: author_params['first'], middle: author_params['middle'], last: author_params['last']) do |db_author|
      db_author.suffix = author_params['suffix']
      db_author.laboratory = author_params['laboratory']
      db_author.institution = author_params['institution']
      db_author.addr_line = author_params['addrLine']
      db_author.post_code = author_params['postCode']
      db_author.settlement = author_params['settlement']
      db_author.country = author_params['country']
    end

    respond_to do |format|
      if @author.valid?
        Authorship.create(paper_id: author_params['paper_id'], author_id: @author.id)
        format.html { redirect_to @author, notice: 'Author was successfully created.' }
        format.json { render :show, status: :created, location: @author }
      else
        format.html { render :new }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /authors/1
  # PATCH/PUT /authors/1.json
  def update
    respond_to do |format|
      if @author.update(author_params)
        format.html { redirect_to @author, notice: 'Author was successfully updated.' }
        format.json { render :show, status: :ok, location: @author }
      else
        format.html { render :edit }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authors/1
  # DELETE /authors/1.json
  def destroy
    @author.destroy
    respond_to do |format|
      format.html { redirect_to authors_url, notice: 'Author was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_author
      @author = Author.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def author_params
      params.require(:author).permit(:paper_id, :first, :middle, :last, :suffix, :laboratory, :institution, :addr_line, :post_code, :settlement, :country)
    end
end
