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
    er=false
    @user_aux = authenticate
    if(@user_aux.nil?)
     er=true
    else
      if params.has_key?(:watching)
        @issues = User.find(@user_aux.id).watched
      end
    end
    
    if(er == true)
      respond_to do |format|
        format.json {render json: {meta: {code: 401, error_message: "Unauthorized"}}, status: :unauthorized}
      end
    else 
      respond_to do |format|   
        format.html
        format.json {render json: @issues, status: :ok, each_serializer: IssueSerializer}
      end
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
    if(current_user.nil?)
      token2 = request.headers['token']
      if(token2)
        @user_aux = authenticate
        if(@user_aux.nil?)
          render json: { meta: {code: 401, error_message: "Invalid token"}}
        else
          request_parameters = JSON.parse(request.body.read.to_s)
          title = request_parameters["text"]
          details = request_parameters["details"]
          type = request_parameters["type"]
          priority = request_parameters["Priority"]
          assignee = request_parameters["Assignee"]
          
          if not ["bug", "enhancement", "proposal", "task"].include?(type)
            render json: { error_message: "Type must be one of: bug, enhancement, proposal, task"}, status: 403
          return
          end
          if not ["trivial", "minor", "major", "critical", "blocker"].include?(priority)
            render json: { error_message: "Priority must be one of: trivial, minor, major, critical, blocker"}, status: 403
          return
          end
          if assignee == 0
             @issue = Issue.create(title: title, description: details, type_issue: type, priority: priority, creator_id: @user_aux.id, status:"new")
          else
            assignee_aux = User.find(assignee)
            if(assignee_aux)
              @issue = Issue.create(title: title, description: details, type_issue: type, priority: priority, creator_id: @user_aux.id, assignee_id: assignee,status:"new")
            else
              error = true
            end
          end 
          
          if(error == true)
            render json: { meta: {code: 401, error_message: "Invalid Assignee"}}
          else
            if @issue.save
              respond_to do |format|
                format.json {render json: @issue, status: :created, serializer: IssueSerializer}
              end
            else
              render json: @issue.errors, status: :unprocessable_entity
            end
          end
        end
      else 
        render json: {
          error: "Missing token in header",
          status: 401
        },status: 400
      end
    
    else
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
  end

  # PATCH/PUT /issues/1
  # PATCH/PUT /issues/1.json
  def update
    comment_text = ""
    if(current_user.nil?)
      token2 = request.headers['token']
      if(token2)
        @user_aux = authenticate
        if(@user_aux.nil?)
          render json: { error_message: "Invalid token"}, status: 401
        else
          request_parameters = JSON.parse(request.body.read.to_s)
          title = request_parameters["title"]
          details = request_parameters["details"]
          type = request_parameters["type"].downcase
          priority = request_parameters["Priority"].downcase
          assignee = request_parameters["Assignee"]
          status = request_parameters["Status"].downcase
          
          if not ['new', 'open','on hold','resolved','duplicate','invalid','wontfix','closed'].include?(status)
            render json: { error_message: "status must be one of: new, open, on hold, resolved,duplicate, invalid,wontfix,closed"}, status: 403
            return
          else
            if (status !="" and status != @issue.status) 
              comment_text +="changed status to " + status + "<br>"
            else
              status = @issue.status
            end
          end
          
          if (title != "" and title != @issue.title) 
            comment_text = comment_text + "changed title to " + title + "<br>"
          else 
            title = @issue.title
          end
          
          if not ["bug", "enhancement", "proposal", "task"].include?(type)
            render json: { error_message: "Type must be one of: bug, enhancement, proposal, task"}, status: 403
            return
          else
            if (type != "" and type != @issue.type_issue)
              comment_text = comment_text + "marked as " + type + "<br>"
            else
              type = @issue.type_issue
            end
          end
          
          if not ["trivial", "minor", "major", "critical", "blocker"].include?(priority)
            render json: { error_message: "Priority must be one of: trivial, minor, major, critical, blocker"}, status: 403
            return
          else
            if (priority != "" and priority != @issue.priority)
              comment_text = comment_text + "marked as " + priority + "<br>"
            else
              priority = @issue.priority
            end
          end
          
          if (assignee != -1  and assignee != @issue.assignee_id  )
            comment_text = comment_text + "assigned issue to " + User.find(assignee).name + "<br>"
          elsif (assignee == -1)
            assignee = nil
          else 
            assignee = @issue.assignee_id
          end
          if (details != "" and details != @issue.description) 
            comment_text = comment_text + "edited description" + "<br>"
          else 
            details = @issue.description
          end
          if (comment_text != "")
            Comment.create(:text => comment_text, :reporter_id => @user_aux.id, :issue_id => @issue.id)
          end
          if @issue.update(title: title, description: details, type_issue: type, priority: priority, creator_id: @user_aux.id, assignee_id: assignee, status: status)
              render json: @issue, status: :ok, each_serializer: IssueSerializer
          else
              render json: @issue.errors, status: 404
          end
          
        end
      else 
        render json: {
          error: "Missing token in header",
          status: 401
        },status: 401
      end
    
    else
      
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
  end
  
  def status
    @issue = Issue.find(params[:id])
    @user_aux = authenticate
    if(@user_aux.nil?)
      respond_to do |format|
        format.json {render json: {meta: {code: 401, error_message: "Unauthorized"}}, status: :unauthorized}
      end
    else
      if (issue_params[:status].present? and (issue_params[:status] == "new" or 
        issue_params[:status] == "closed" or issue_params[:status] == "open" or 
        issue_params[:status] == "resolved" or issue_params[:status] == "duplicated" or 
        issue_params[:status] == "on hold" or issue_params[:status] == "invalid" or issue_params[:status] == "wontfix"))
          comment_text = ""
          if (issue_params[:status].present? and issue_params[:status] != @issue.status) 
            comment_text +="changed status to " + issue_params[:status] + "<br>"
          end
          if (comment_text != "")
            Comment.create(:text => comment_text, :reporter_id => @user_aux.id, :issue_id => @issue.id)
          end
          respond_to do |format|
            if @issue.update(issue_params)
              format.html { redirect_to @issue, notice: 'Issue was successfully updated.' }
              format.json {render json: @issue, status: :ok, serializer: IssueSerializer}
            else
              format.html { render :edit }
              format.json { render json: @issue.errors, status: :unprocessable_entity }
            end
          end
      else 
        respond_to do |format|
          format.json {render json: { error_message: "Status should be one of the following: new, closed, open, resolved, duplicated, on hold, invalid, wontfix"}, status: :bad_request}
        end
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
    apiOk = false
    if(current_user.nil?)
      token2 = request.headers['token']
      if(token2)
        @user_aux = authenticate
        if(@user_aux.nil?)
          render json: { error_message: "Invalid token"}, status: 401
        else
          apiOk = true
        end
      else
        render json: { error_message: "Missing token"}, status: 401
      end
    end
    if (not current_user.nil?) or (apiOk)
      @issue.comments.destroy_all
      @issue.attachments.destroy_all
      @issue.destroy
      respond_to do |format|
        format.html { redirect_to issues_url, notice: 'Issue was successfully deleted.' }
        format.json { render json: {message: "success"}, status: 204 }
      end
    end
  end
      

  
  def watch
    @issue = Issue.find(params[:id])
    if(current_user.nil?)
      @user_aux = authenticate
      if(@user_aux.nil?)
        respond_to do |format|
          format.json {render json: {meta: {code: 401, error_message: "Unauthorized"}}, status: :unauthorized}
        end
      else
        if(@issue.watchers.find_by(id: @user_aux.id).nil?)
          @issue.watchers << User.find(@user_aux.id)
          respond_to do |format|
            format.json {render json: @issue, status: :ok, serializer: IssueSerializer}
          end
        else
          respond_to do |format|
            format.json {render json: @issue, status: :ok, serializer: IssueSerializer }
          end
        end
      end
    else
      @issue.watchers << User.find(current_user.id)
      respond_to do |format|
          format.html { redirect_back fallback_location: "/issues", notice: "You are now watching issue #" + @issue.id.to_s }
          format.json {render json: @issue, status: :ok, serializer: IssueSerializer}
      end
    end
  end
  
  def unwatch
    @issue = Issue.find(params[:id])
    if(current_user.nil?)
      @user_aux = authenticate
      if(@user_aux.nil?)
        respond_to do |format|
          format.json {render json: {meta: {code: 401, error_message: "Unauthorized"}}, status: :unauthorized}
        end
      else
        if(@issue.watchers.find_by(id: @user_aux.id).nil?)
          respond_to do |format|
            format.json {render json: @issue, status: :ok, serializer: IssueSerializer}
          end
        else
          @issue.watchers.delete(User.find(@user_aux.id)) 
          respond_to do |format|
            format.json {render json: @issue, status: :ok, serializer: IssueSerializer }
          end
        end
      end 
    else
      @issue.watchers.delete(User.find(current_user.id)) 
      respond_to do |format|
        format.html { redirect_back fallback_location: "/issues", notice: "You are no longer watching issue #" + @issue.id.to_s }
      end
    end
  end
  
  
  
  def vote
    if(current_user.nil?)
      @user_aux = authenticate
      if(@user_aux.nil?)
        respond_to do |format|
          format.json {render json: { meta: {code: 401, error_message: "Unauthorized"}}, status: :unauthorized}
        end
      else
        if (Voto.exists?(:user_id => @user_aux.id, :issue_id => params[:id]))
          @issue = Issue.find(params[:id])
          respond_to do |format|
           format.json {render json: @issue, status: :ok, serializer: IssueSerializer }
          end
        else
          Voto.create(:user_id => @user_aux.id, :issue_id => params[:id])
          @issue = Issue.find(params[:id])
          @issue.increment!("votes")
          respond_to do |format|
            format.json {render json: @issue, status: :ok, serializer: IssueSerializer }
          end
        end
      end
    else
      Voto.create(:user_id => current_user.id, :issue_id => params[:id])
      @issue = Issue.find(params[:id])
      @issue.increment!("votes")
      respond_to do |format|
        format.html { redirect_back fallback_location: "/issues", notice: "You have voted the issue #" + params[:id].to_s }
        format.json {render json: @issue, status: :ok, serializer: IssueSerializer}
      end
    end
  end
  
  def unvote
    if(current_user.nil?)
      @user_aux = authenticate
      if(@user_aux.nil?)
        respond_to do |format|
          format.json {render json: { meta: {code: 401, error_message: "Unauthorized"}}, status: :unauthorized}
        end
      else
        if (Voto.exists?(:user_id => @user_aux.id, :issue_id => params[:id]))
          @vote = Voto.where(issue_id: params[:id], user_id: @user_aux.id).take
          @vote.destroy
          @issue = Issue.find(params[:id])
          @issue.decrement!("votes")
          respond_to do |format|
           format.json {render json: @issue, status: :ok, serializer: IssueSerializer }
          end
        else
          @issue = Issue.find(params[:id])
          respond_to do |format|
            format.json {render json: @issue, status: :ok, serializer: IssueSerializer }
          end
        end
      end
    else 
      @vote = Voto.where(issue_id: params[:id], user_id: current_user.id).take
      @vote.destroy
      @issue = Issue.find(params[:id])
      @issue.decrement!("votes")
      respond_to do |format|
        format.html { redirect_back fallback_location: "/issues", notice: "You have unvoted the issue #" + params[:id].to_s }
        format.json {render json: @issue, status: :ok, serializer: IssueSerializer }
      end
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
