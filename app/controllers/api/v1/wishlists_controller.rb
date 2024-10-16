module Api
    module V1
      class WishlistsController < BaseController
  
        def index
          user = current_api_v1_user
          wishlist = user.wishlist
          data = wishlist.present? ? wishlist_response(wishlist) : {}
            render json: { success: true, data: data }, status: :ok
        rescue StandardError => e
          render json: { success: false, message: e.message }, status: :unprocessable_entity
        end
  
        def create
          if params[:product_asin].blank?
            return render json: { success: false, message: I18n.t('General.MissingParams') }, status: :unprocessable_entity
          end
  
          ActiveRecord::Base.transaction do
            user = current_api_v1_user
            wishlist = Wishlist.find_or_create_by!(user_id: user.id, title: user.email)
            product = create_product
            
            if product.present?
              add_products_to_wishlist(wishlist, product)
            else
              raise ActiveRecord::RecordInvalid, "Product could not be created"
            end
            
            render json: { success: true, data: wishlist_response(wishlist) }, status: :ok
          end
        rescue ActiveRecord::RecordInvalid => e
          render json: { success: false, message: e.message }, status: :unprocessable_entity
        rescue StandardError => e
          render json: { success: false, message: "An error occurred. Please try again." }, status: :unprocessable_entity
        end

        def destroy
          user = current_api_v1_user
          wishlist = user.wishlist
        
          if wishlist.nil?
            return render json: { success: false, message: "Wishlist not found!" }, status: :not_found
          end
        
          product = wishlist.wishlist_products.find_by(product_id: params[:id])
        
          if product.present?
            product.destroy!
            render json: { success: true, message: "Product successfully removed from wishlist!" }, status: :ok
          else
            render json: { success: false, message: "Product not found in wishlist!" }, status: :not_found
          end
        
        rescue ActiveRecord::RecordNotDestroyed => e
          render json: { success: false, message: "Failed to remove product from wishlist: #{e.message}" }, status: :unprocessable_entity
        rescue StandardError => e
          render json: { success: false, message: "An error occurred: #{e.message}" }, status: :internal_server_error
        end
        
  
        private
  
        def create_product
          product = Product.find_or_initialize_by(amazon_id: params[:product_asin])
          product.assign_attributes(
            name: params[:name],
            image_url: params[:image_url],
            price: params[:price],
            affiliate_link: params[:affiliate_link]
          )
          product.save!
          product
        end
  
        def add_products_to_wishlist(wishlist, product)
          wishlist.wishlist_products.find_or_create_by!(product: product)
        end
  
        def wishlist_response(wishlist)
          {
            id: wishlist.id,
            title: wishlist.title,
            description: wishlist.description,
            created_at: wishlist.created_at,
            products: wishlist.products.map do |product|
              {
                id: product.id,
                asin: product.amazon_id,
                name: product.name,
                price: product.price,
                image_url: product.image_url,
                affiliate_link: product.affiliate_link
              }
            end
          }
        end
  
      end
    end
  end
  