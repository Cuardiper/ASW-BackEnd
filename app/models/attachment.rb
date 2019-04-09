class Attachment < ApplicationRecord
  #Mounts paperclip file
  has_attached_file :file
  
  #Use this if you do not want to validate the uploaded file type.
  do_not_validate_attachment_file_type :file

end
