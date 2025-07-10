module Pagination
  extend ActiveSupport::Concern

  included do
    def paginate(collection)
      page = params[:page] || 1
      per_page = params[:per_page] || 25
      per_page = [per_page.to_i, 100].min # Max limit of 100 items per page

      paginated = collection.page(page).per(per_page)

      {
        data: paginated,
        meta: pagination_meta(paginated)
      }
    end

    private

    def pagination_meta(paginated_collection)
      {
        current_page: paginated_collection.current_page,
        next_page: paginated_collection.next_page,
        prev_page: paginated_collection.prev_page,
        total_pages: paginated_collection.total_pages,
        total_count: paginated_collection.total_count,
        per_page: paginated_collection.limit_value
      }
    end
  end
end
