# coding: utf-8
class MatvaranScraper
  def scrape(url)
    raw_product = RawProduct.from_hash(parse(url))

    MatvaranCleaner.new.clean(raw_product).tap { |product| product.save! }
  end

  def parse(url)
    response = HTTParty.get(url)
    doc = Nokogiri::HTML(response.body)

    anchor = doc.css(".icacontent_main").first.xpath("div")[1].xpath("div")[4]
    anchor_text = anchor.text.mb_chars.downcase.to_s

    {}.tap do |product|
      product[:source] = :matvaran

      product[:source_url] = url

      product[:barcode] = url.split("?").last

      product[:img_urls] = [doc.css(".opacity.fancyBoxAuto")[0].xpath("img").first.attributes["src"].value]

      product[:name] = doc.css(".vara").first.text

      product[:brand] = anchor.xpath("div")[0].xpath("a").text

      product[:origin] = anchor_text
      product[:origin] = product[:origin].split("ursprung")[-2] if product[:origin]
      product[:origin] = product[:origin].split("\.")[0] if product[:origin]
      product[:origin] = product[:origin].strip if product[:origin]

      product[:ingredients] = anchor_text
      product[:ingredients] = product[:ingredients].split("ingrediensförteckning")[1] if product[:ingredients]
      product[:ingredients] = product[:ingredients].split(/näringsinnehåll|näringsvärden/)[0] if product[:ingredients]

      product[:eu_organic] = true if doc.css("img[src*='http://static.matvaran.se/ica_produkt/eulovet.png']").any?
    end
  end
end
