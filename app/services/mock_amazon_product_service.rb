class MockAmazonProductService
    ITEMS_PER_PAGE = 10
    CATEGORIES = ['Electronics', 'Books', 'Home & Kitchen', 'Clothing', 'Toys & Games']
  
    def initialize
      @products = generate_mock_products(1000)  # Generate 1000 mock products
    end
  
    def search_products(keywords, page = 1, category = nil)
      sleep(0.5)  # Simulate API delay
  
      filtered_products = @products.select do |product|
        product[:title].downcase.include?(keywords.downcase) &&
          (category.nil? || product[:category] == category)
      end
  
      paginate(filtered_products, page)
    end
  
    def get_product(asin)
      sleep(0.2)  # Simulate API delay
      @products.find { |p| p[:asin] == asin }
    end
  
    private
  
    def generate_mock_products(count)
      count.times.map do |i|
        {
          asin: "B00#{format('%06d', i)}",
          title: "#{Faker::Commerce.product_name} #{i + 1}",
          description: Faker::Lorem.paragraph(sentence_count: 3),
          price: Faker::Commerce.price(range: 10..500.0),
          category: CATEGORIES.sample,
          rating: rand(1.0..5.0).round(1),
          review_count: rand(0..1000),
          image_url: "https://picsum.photos/seed/#{i}/300/300"
        }
      end
    end
  
    def paginate(products, page)
      start_index = (page - 1) * ITEMS_PER_PAGE
      end_index = start_index + ITEMS_PER_PAGE - 1
      paginated_products = products[start_index..end_index] || []
  
      {
        products: paginated_products,
        total_pages: (products.length.to_f / ITEMS_PER_PAGE).ceil,
        current_page: page
      }
    end
end