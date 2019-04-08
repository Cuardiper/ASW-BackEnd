class IssuesController < ApplicationController
  include SessionsHelper
  before_action :logged_in_user
  before_action :set_issue, only: [:show, :edit, :update, :destroy]
  
  $s = ""
  $pi = ""
  $t = ""
  $a = ""
  # GET /issues
  # GET /issues.json
  def index
    @issues = Issue.all
    if params[:status].present? and params[:status].length != 2
      $s = params[:status].join
    end
    if params[:priority].present?
      $pi = params[:priority].join
    end
    if params[:type_issue].present?
      $t = params[:type_issue].join
    end 
    if params[:assignee_id].present?
      $a = params[:assignee_id].join
    end
    if (not params[:assignee_id].present?) and (not params[:type_issue].present?) and (not params[:priority].present?) and (not params[:status].present?)
      $s = ""
      $pi = ""
      $t = ""
      $a = ""
    end
    if params[:status].present? and params[:status].length == 2
      $s = "new","open"
    end
    
    print $s
    print $pi
    print $t
    print $a
    
    @issues = @issues.status($s).priority($pi).type_issue($t).assignee_id($a)
    
    
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
  end

  # GET /issues/new
  def new
    @issue = Issue.new
  end

  # GET /issues/1/edit
  def edit
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)

    respond_to do |format|
      if @issue.save
        format.html { redirect_to @issue, notice: 'Issue was successfully created.' }
        format.json { render :show, status: :created, location: @issue }
      else
        format.html { render :new }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /issues/1
  # PATCH/PUT /issues/1.json
  def update
    respond_to do |format|
      if @issue.update(issue_params)
        format.html { redirect_to @issue, notice: 'Issue was successfully updated.' }
        format.json { render :show, status: :ok, location: @issue }
      else
        format.html { render :edit }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
    @issue.destroy
    respond_to do |format|
      format.html { redirect_to issues_url, notice: 'Issue was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  
  def watch
    Issue.find(5).watchers.create({index_issues_users_on_issue_id: 1})
    @issue.watchers.create({issue_id: 5, user_id: 1})
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      @issue = Issue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def issue_params
      params.require(:issue).permit(:title, :description, :type_issue, :priority, :status, :votes, :creator_id, :assignee_id)
    end
    

end
