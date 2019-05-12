class IssuesController < ApplicationController
  include SessionsHelper
  #before_action :logged_in_user
  skip_before_action :verify_authenticity_token
  before_action :set_issue, only: [:show, :edit, :update, :destroy]
  helper_method :sort_column, :sort_direction
  
  $s = ""
  $pi = ""
  $t = ""
  $a = ""
  # GET /issues
  # GET /issues.json
  def index
    respond_to do |format|
      @issues = Issue.all.order(sort_column + " " + sort_direction)
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
      if params[:status].present? and params[:status].length != 2 and params[:status].join == "unresolved"
        $s = "new","open"
      end
      
      
      @issues = @issues.status($s).priority($pi).type_issue($t).assignee_id($a)
      if params.has_key?(:watcher)
        @issues = User.find(params[:watcher]).watched
      end
    
      format.html
      format.json {render json: @issues, status: :ok, each_serializer: IssueSerializer}
    end
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
    respond_to do |format|
      format.html
      format.json {render json: @issue, status: :ok, serializer: IssueSerializer}
    end
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
    comment_text = ""
    if (issue_params[:status].present? and issue_params[:status] != @issue.status) 
      comment_text +="changed status to " + issue_params[:status] + "<br>"
    end
    if (issue_params[:title].present? and issue_params[:title] != @issue.title) 
      comment_text = comment_text + "changed title to " + issue_params[:title] + "<br>"
    end
    if (issue_params[:type_issue].present? and issue_params[:type_issue] != @issue.type_issue)
      comment_text = comment_text + "marked as " + issue_params[:type_issue] + "<br>"
    end
    if (issue_params[:priority].present? and issue_params[:priority] != @issue.priority)
      comment_text = comment_text + "marked as " + issue_params[:priority] + "<br>"
    end
    if (issue_params[:assignee_id].present? and issue_params[:assignee_id] != @issue.assignee_id)
      comment_text = comment_text + "assigned issue to " + User.find(issue_params[:assignee_id]).name + "<br>"
    end
    if (issue_params[:description].present? and issue_params[:description] != @issue.description) 
      comment_text = comment_text + "edited description" + "<br>"
    end
    if (comment_text != "")
      Comment.create(:text => comment_text, :reporter_id => current_user.id, :issue_id => @issue.id)
    end
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
    @issue = Issue.find(params[:id])
    @issue.comments.destroy_all
    @issue.attachments.destroy_all
    @issue.destroy
    respond_to do |format|
      format.html { redirect_to issues_url, notice: 'Issue was successfully deleted.' }
      format.json { render json: {"message": "success"}, status: :ok }
    end
  end

  
  def watch
    if(current_user.nil?)
     @issue = Issue.find(params[:id])
      @user_aux = authenticate
      if(@user_aux.nil?)
        respond_to do |format|
          format.json {render json: {meta: {code: 401, error_message: "Unauthorized"}}}
        end
      else
        if(@issue.watchers.find(User.find(@user_aux.id)).nil?)
          @issue.watchers << User.find(@user_aux.id)
        else
          respond_to do |format|
            format.json {render json: {meta: {code: 204, error_message: "You have already watched this issue!"}}}
          end
        end
      end
    else
      @issue = Issue.find(params[:id])
      @issue.watchers << User.find(current_user.id)
    end
    respond_to do |format|
        format.html { redirect_back fallback_location: "/issues", notice: "You are now watching issue #" + @issue.id.to_s }
        format.json {render json: @issue, status: :ok, serializer: IssueSerializer}
    end
  end
  
  def unwatch
    @issue = Issue.find(params[:id])
    @issue.watchers.delete(User.find(current_user.id)) 
    respond_to do |format|
      format.html { redirect_back fallback_location: "/issues", notice: "You are no longer watching issue #" + @issue.id.to_s }
    end
  end
  
  
  
  def vote
    respond_to do |format|
      if(current_user.nil?)
        @user_aux = authenticate
        if(@user_aux.nil?)
          respond_to do |format|
          format.json {render json: { 
           meta: {code: 401, error_message: "Unauthorized"}
          }}
        end
        else
          if !Voto.exists?(:issue_id => params[:id], :user_id => @user_aux.id)
            Voto.create(:user_id => @user_aux.id, :issue_id => params[:id])
            @issue = Issue.find(params[:id])
            @issue.increment!("votes")
          else
            respond_to do |format|
              format.json {render json: {meta: {code: 204, error_message: "You have already voted this issue!"}}}
            end
          end
        end
      else
        Voto.create(:user_id => current_user.id, :issue_id => params[:id])
        @issue = Issue.find(params[:id])
        @issue.increment!("votes")
      end
      format.html { redirect_back fallback_location: "/issues", notice: "You have voted the issue #" + params[:id].to_s }
      format.json { render json: @issue, status: :ok }
    end
  end
  
  def unvote
    @vote = Voto.where(issue_id: params[:id], user_id: current_user.id).take
    @vote.destroy
    @issue = Issue.find(params[:id])
    @issue.decrement!("votes")
    respond_to do |format|
      format.html { redirect_back fallback_location: "/issues", notice: "You have unvoted the issue #" + params[:id].to_s }
    end
  end
  
  
  
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      @issue = Issue.find(params[:id])
      render json: { error: 'Issue not found' }, status: :not_found if @issue.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def issue_params
      params.require(:issue).permit(:title, :description, :type_issue, :priority, :status, :creator_id, :assignee_id)
    end
    
    def sort_column
      Issue.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
      #Issue.select("issues.id, issues.type_issue, issues.priority, issues.status,issues.votes, issues.created_at, issues.updated_at , users.name")
      #.joins(:assignee).column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    
end
