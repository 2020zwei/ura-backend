module Api
    module V1
      class ProductsController < BaseController
  
        def index
          unless params[:category].present?
            return render json: { success: false, message: I18n.t('General.MissingParams') }, status: :unprocessable_entity
          end
  
          response = search_by_category(params[:category].to_s)
          if response.is_a?(Net::HTTPSuccess)
            parsed_data = JSON.parse(response.body)
            top_20_products = extract_top_20_products(parsed_data)
            render json: { success: true, data: top_20_products }, status: :ok
          else
            render json: { success: false, message: "Error fetching data from API" }, status: :bad_request
          end
        end
  
        private
  
        def search_by_category(keyword)
          url = URI("https://real-time-amazon-data.p.rapidapi.com/search?query=#{keyword}&page=1&country=US&sort_by=RELEVANCE&product_condition=ALL&is_prime=false&deals_and_discounts=NONE")
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true
  
          request = Net::HTTP::Get.new(url)
          request["x-rapidapi-key"] = ENV['RAPIDAPI_KEY']
          request["x-rapidapi-host"] = 'real-time-amazon-data.p.rapidapi.com'
  
          http.request(request)
        end
  
        def extract_top_20_products(parsed_data)
          parsed_data["data"]["products"].first(20).map do |product|
            {
              asin: product["asin"],
              title: product["product_title"],
              price: product["product_price"],
              currency: product["currency"],
              product_photo: product["product_photo"]
            }
          end
        end
      end
    end
end
  