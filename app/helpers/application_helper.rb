module ApplicationHelper
  def safe_original_url(post)
    original_url(post)&.to_s
  end

  def original_url_domain(post)
    original_url(post)&.host
  end

  private
    def original_url(post)
      return if post.url.blank?

      uri = URI.parse(post.url)
      uri if uri.is_a?(URI::HTTP) && uri.host.present?
    rescue URI::InvalidURIError
      nil
    end
end
