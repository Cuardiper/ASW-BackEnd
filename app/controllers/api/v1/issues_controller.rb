class Api::V1::IssuesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_issue, only: [:show, :update, :destroy]

  # GET /issues
  def index
    @issues = Issue.all
    json_response(@issues)
  end
  
  # GET /issues/1
  def show
    json_response(@issue)
  end
  
  # POST /todos
  def create
    @issue = Issue.create!(issue_params)
    json_response(@issue, :created)
  end
  
  # PUT/PATCH /issues/1
  def update
    @issue.update(issue_params)
    head :no_content
  end
  
  def destroy
    @issue.destroy
    head :no_content
  end
  
  private

  def issue_params
    # whitelist params
    params.permit(:description, :status)
  end

  def set_issue
    @issue = Issue.find(params[:id])
  end
  
end