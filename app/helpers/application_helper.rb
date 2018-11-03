module ApplicationHelper
  def file_exists?(filename)
    require "net/http"
    url = URI.parse(ENV['AWS_ENDPOINT'] + filename)
    req = Net::HTTP.new(url.host, url.port)
    res = req.request_head(url.path)
    logger.debug(res.code)
    res.code == "304" || res.code == "200"
  end
end
