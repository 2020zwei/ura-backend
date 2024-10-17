module Api
    module V1
      class ProductsController < BaseController
        skip_before_action :authenticate_api_v1_user!, only: [:index, :product_detail]

  
        def index
          unless params[:category].present?
            return render json: { success: false, message: I18n.t('General.MissingParams') }, status: :unprocessable_entity
          end

          response = Product.where("name ILIKE ?", "%#{params[:category]}%")
                            .order(rating: :desc)
          top_10_products = extract_top_10_products(response)
          render json: { success: true, data: top_10_products }, status: :ok
        end
  
        def product_detail
          unless params[:product_asin].present?
            return render json: { success: false, message: I18n.t('General.MissingParams') }, status: :unprocessable_entity
          end
          product = Product.find_by(amazon_id: params[:product_asin])
          if product
            response = product_list(product)
            render json: { success: true, data: response }, status: :ok
          else
            render json: { success: false, message: "Product not Found" }, status: :bad_request
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
          parsed_data["data"]["products"].first(10).map do |product|
            {
              asin: product["asin"],
              title: product["product_title"],
              price: product["product_price"],
              currency: product["currency"],
              product_photo: product["product_photo"]
            }
          end
        end

        def get_product_detail(asin)
          url = URI("https://real-time-amazon-data.p.rapidapi.com/product-details?asin=#{asin}&country=US")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["x-rapidapi-key"] = ENV['RAPIDAPI_KEY']
        request["x-rapidapi-host"] = 'real-time-amazon-data.p.rapidapi.com'

        response = http.request(request)
        end

        def extract_top_10_products(products)
          products.first(10).map do |product|
            {
              asin: product&.amazon_id,
              title: product&.name,
              price: product&.price,
              currency: "USD",
              product_photo: product&.image_url
            }
          end
        end

        def product_list(product)
          list = {
            id: product&.id,
            asin: product&.amazon_id,
            product_title: product&.name,
            product_description: product&.description.present? ? product&.description : product&.name,
            product_photo: product&.image_url,
            product_price: product&.price,
            product_url: product&.affiliate_link,
            product_photos: product&.images.present? ? product&.images : [product&.image_url]
          }
          list
        end
      end
    end
end
  