class GameRemixes

  attr_reader :url

  def initialize(url)
    @url = url
  end

  def mp3_urls
    remix_pages = song_paths.map { |path| connection.get(path) }
    parsed_remix_pages = remix_pages.map { |remix_page| Nokogiri::HTML(remix_page.body) }
    anchor_sets = parsed_remix_pages.map { |parsed_remix_page| parsed_remix_page.css('#panel-download a') }

    find_mp3_urls(anchor_sets)
  end

  def song_paths
    remixes_page = connection.get(url)
    parsed_remixes = Nokogiri::HTML(remixes_page.body)
    anchors = parsed_remixes.css('.area-link a')
    song_anchors = anchors.find_all { |a| a.attributes['href'].value.start_with?('/remix') }

    song_anchors.map { |anchor| anchor.attributes['href'].value }
  end

private

  def find_mp3_urls(anchor_sets)
    mp3_anchors = anchor_sets.map { |anchors| find_mp3_url(anchors) }

    mp3_anchors.map { |anchor| anchor.attributes['href'].value }
  end

  def find_mp3_url(anchors)
    anchors.find { |anchor| anchor.attributes['href'].value.start_with?('http://ocrmirror.org') }
  end

  def connection
    @connection ||= Faraday.new(url: 'http://ocremix.org') do |faraday|
      # faraday.request  :url_encoded             # form-encode POST params
      # faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

end
