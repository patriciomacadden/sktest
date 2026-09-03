module Post::Pagination
  extend ActiveSupport::Concern

  PAGE_SIZE = 20
  MAX_PAGE = 10_000

  class_methods do
    def paginated(page:, posts: all)
      page = normalized_page(page)
      records = posts.newest_first.offset((page - 1) * PAGE_SIZE).limit(PAGE_SIZE + 1).to_a

      [ records.first(PAGE_SIZE), page, records.length > PAGE_SIZE ]
    end

    private
      def normalized_page(value)
        page = value.is_a?(Integer) ? value : Integer(value, 10)
        page.between?(1, MAX_PAGE) ? page : 1
      rescue ArgumentError, TypeError
        1
      end
  end
end
