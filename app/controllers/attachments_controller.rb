class AttachmentsController < ApplicationController
  
  #Index action, attachments gets listed in the order at which they were created
 def index
  @attachments = Attachment.all
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
    if @attachment.destroy
      id_isue = @attachment.issue_id.to_s
      flash[:notice] = "Successfully deleted attachment!"
      redirect_to "/issues/" + id_isue
    else
      flash[:alert] = "Error deleting attachment!"
    end
  end
 
 private

 #Permitted parameters when creating an attachment. This is used for security reasons.
 def attachment_params
  params.require(:attachment).permit(:title, :issue_id, :file)
 end
 
end
