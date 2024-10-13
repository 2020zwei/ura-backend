class UserSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers
    attributes :id, :email, :first_name, :last_name, :created_at, :profile_image_url
  
    def profile_image_url
      object.avatar_url
    end
  
end  