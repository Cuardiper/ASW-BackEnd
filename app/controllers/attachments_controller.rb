class AttachmentsController < ApplicationController
  include SessionsHelper
  #before_action :logged_in_user
  skip_before_action :verify_authenticity_token
  
  #Index action, attachments gets listed in the order at which they were created
 def index
  @attachments = Attachment.all
  render json: @attachments, status: :ok, each_serializer: AttachmentSerializer
 end
 
 def findByIssue
  @attachments = Attachment.all.where(issue_id: params[:Issue_id])
  #render json: @attachments.to_json() 
  render json: @attachments, status: :ok, each_serializer: AttachmentSerializer
 end

 #New action for creating a new attachment
 def new
  @attachment = Attachment.new
 end
 
 #Create action ensures that submitted attachment gets created if it meets the requirements
 def create
  @attachment = Attachment.new(attachment_params)
  if @attachment.save
   id_isue = @attachment.issue_id.to_s
   flash[:notice] = "Successfully added new attachment!"
   redirect_to "/issues/" + id_isue
  else
   flash[:alert] = "Error adding new attachment!"
   render :new
  end
 end
 
 #Destroy action for deleting an already uploaded image
  def destroy
    @attachment = Attachment.find(params[:id])
    if(current_user.nil?)
      token2 = request.headers['token']
      if(token2)
        @user_aux = authenticate
        if(@user_aux.nil?)
          render json: { meta: {code: 401, error_message: "Invalid token"}}
        else
          if @attachment.destroy
            render json: {message: "success"}, status: 204
          else
            render json: { meta: {code: 422, error_message: "Unprocessable Entity"}}
          end
        end
      else
        render json: { error: "Missing token in header",status: 401 },status: 400
      end
    else
      if @attachment.destroy
        id_isue = @attachment.issue_id.to_s
        flash[:notice] = "Successfully deleted attachment!"
        redirect_to "/issues/" + id_isue
      else
        flash[:alert] = "Error deleting attachment!"
      end
    end
  end
 
 private

 #Permitted parameters when creating an attachment. This is used for security reasons.
 def attachment_params
  params.require(:attachment).permit(:title, :issue_id, :file)
 end
 
end

