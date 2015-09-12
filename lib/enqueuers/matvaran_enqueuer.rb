class MatvaranEnqueuer
  def parse_urls(url)
    response = HTTParty.get(
      url,
      headers: {
        "Cookie" => "butik=a%5Fid=3; isession=marke=&searchstring=&sortering=t2+ASC&ikat=&lista=lista",
      }
    )
    response = CGI.unescape(response.body)

    doc = Nokogiri::HTML(response)

    urls = doc.css("a").map do |link|
      if (href = link.attr("href")) && href.match(/^https?:/)
        href
      end
    end.compact
  end

  def start(range = (18..452))
    range.each do |k|
      urls = parse_urls("http://norrkoping.matvaran.se/ajax_lista.asp?f=collectbasket&k=#{k}")

      urls.each do |url|
        MatvaranScraper.new.scrape(url)
      end
    end
  end
end
