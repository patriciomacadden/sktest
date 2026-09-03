module ApplicationHelper
  def safe_original_url(post)
    return if post.url.blank?

    uri = URI.parse(post.url)
    uri.to_s if uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    nil
  end
end
