class SendinblueContactService
    def initialize(user)
      @user = user
      @api_instance = SibApiV3Sdk::ContactsApi.new
      @api_key = ENV["API_V3_KEY"]
      configure_api
    end
  
    def create_contact
      create_contact_payload = {
        'email' => @user.email,
        'listIds' => [2]
      }
  
      begin
        result = @api_instance.create_contact(create_contact_payload)
        Rails.logger.info "Sendinblue contact created: #{result}"
      rescue SibApiV3Sdk::ApiError => e
        Rails.logger.error "Error creating Sendinblue contact: #{e}"
      end
    end
  
    private
  
    def configure_api
      SibApiV3Sdk.configure do |config|
        config.api_key['api-key'] = @api_key
      end
    end
  end
  