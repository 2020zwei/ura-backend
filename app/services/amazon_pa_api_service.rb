require 'vacuum'

class AmazonPaApiService
  RATE_LIMIT = 1 # requests per second
  MAX_RETRIES = 3

  def initialize
    @client = Vacuum.new(
      marketplace: 'US',
      access_key: ENV["PAAPI_ACCESS_KEY_ID"],
      secret_key: ENV["PAAPI_SECRET_ACCESS_KEY"],
      partner_tag: ENV["PARTNER_TAG"]
    )
    @last_request_time = Time.now - 1.day
  end

  def search_products(keywords, page = 1)
    retries = 0
    begin
      throttle_request
      response = @client.search_items(
        keywords: keywords,
        search_index: 'All',
        item_page: page,
        resources: ['ItemInfo.Title', 'Offers.Listings.Price', 'Images.Primary.Medium']
      )
      parse_response(response.to_h)
    rescue Vacuum::Error => e
      if retries < MAX_RETRIES
        retries += 1
        sleep_time = 2**retries # Exponential backoff
        Rails.logger.warn "API error. Retrying in #{sleep_time} seconds (Attempt #{retries}/#{MAX_RETRIES})"
        sleep sleep_time
        retry
      else
        Rails.logger.error "Max retries reached. Amazon API request failed: #{e.message}"
        raise AmazonApiError, "Unable to fetch products. Please try again later."
      end
    rescue => e
      Rails.logger.error "Amazon API request failed: #{e.message}"
      raise AmazonApiError, "An error occurred while fetching products. Please try again later."
    end
  end

  private

  def throttle_request
    time_since_last_request = Time.now - @last_request_time
    sleep_time = [0, (1.0 / RATE_LIMIT) - time_since_last_request].max
    sleep(sleep_time) if sleep_time > 0
    @last_request_time = Time.now
  end

  def parse_response(response)
    items = response.dig('SearchResult', 'Items') || []
    items.map do |item|
      {
        asin: item['ASIN'],
        title: item.dig('ItemInfo', 'Title', 'DisplayValue'),
        price: item.dig('Offers', 'Listings', 0, 'Price', 'DisplayAmount'),
        image_url: item.dig('Images', 'Primary', 'Medium', 'URL')
      }
    end
  end
end

class AmazonApiError < StandardError; end