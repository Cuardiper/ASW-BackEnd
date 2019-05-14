class CommentsController < ApplicationController
  include SessionsHelper
  #before_action :logged_in_user
  skip_before_action :verify_authenticity_token
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all
    respond_to do |format|
      format.html
      format.json {render json: @comments, status: :ok, each_serializer: CommentSerializer}
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    respond_to do |format|
      format.html
      format.json {render json: @comment, status: :ok, serializer: CommentSerializer}
    end
  end
  
  # GET /comments/issue/1
  def getByIssue
    @comments = Comment.all.where(issue_id: params[:Issue_id])
    respond_to do |format|
      format.html { @comments }
      format.json { render json: @comments, status: :ok, each_serializer: CommentSerializer}
    end
  end
  
  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)
    respond_to do |format|
      if @comment.save
        format.html { redirect_back fallback_location: "/issues", notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def postOnIssue
    @idIssue = params[:Issue_id]
    @user_aux = authenticate
    if(@user_aux.nil?)
      respond_to do |format|
      format.json {render json: { 
       meta: {code: 401, error_message: "Unauthorized"}
      }}
      end
    else
      request_parameters = JSON.parse(request.body.read.to_s)
      text = request_parameters["text"]
      @comment = Comment.create(text: text, reporter_id: @user_aux.id, issue_id: @idIssue)
    end
    
    respond_to do |format|
      if @comment.save
        format.html { redirect_back fallback_location: "/issues", notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @comment, each_serializer: CommentSerializer }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
    
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    if(current_user.nil?)
      token2 = request.headers['token']
      if(token2)
        @user_aux = authenticate
        if(@user_aux.nil?)
          render json: { meta: {code: 401, error_message: "Invalid token"}}
        else
          if @comment.reporter_id == @user_aux.id
            request_parameters = JSON.parse(request.body.read.to_s)
            text = request_parameters["text"]
            if @comment.update(text: text)
              render json: @comment, status: :ok, serializer: CommentSerializer
            else
              render json: @comment.errors, status: 404
            end
          else
            render json: {
              error: "Only the reporter can edit the comment",
              status: 401
            }, status: 400
          end
        end
      else 
        render json: {
          error: "Missing token in header",
          status: 401
        }, status: 400
      end
    else #no venimos de api
      id_isue = @comment.issue_id.to_s
      respond_to do |format|
        if @comment.update(comment_params)
          format.html { redirect_to "/issues/" + id_isue, notice: 'Comment was successfully updated.' }
          format.json { render :show, status: :ok, location: @comment }
        else
          format.html { render :edit }
          format.json { render json: @comment.errors, status: :unprocessable_entity }
        end
      end
    end
  end
  

  # DELETE /comments/1
  # DELETE /comments/1.json
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
      id_isue = @comment.issue_id.to_s
      @comment.destroy
      respond_to do |format|
        format.html { redirect_back fallback_location: "/issues/" + id_isue, notice: 'Comment was successfully destroyed.' }
        format.json { render json: {"message": "Comment deleted"}, status: 204 }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
      puts("el reporter")
      puts(@comment.reporter_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:text, :issue_id, :reporter_id)
    end
end
