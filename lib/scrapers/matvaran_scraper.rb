# coding: utf-8
class MatvaranScraper < BaseScraper
  def scrape(url)
    parsed_product = parse(url)

    product = Product.find_or_create_by(barcode: parsed_product[:barcode])

    product.update(parsed_product)
  rescue => e
    puts "Unable to scrape #{url}"
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

      product[:img_url] = doc.css(".opacity.fancyBoxAuto")[0].xpath("img").first.attributes["src"].value

      product[:name_raw] = doc.css(".vara").first.text
      product[:name] = product[:name_raw].mb_chars.downcase.to_s if product[:name_raw]

      product[:brand_raw] = anchor.xpath("div")[0].xpath("a").text
      product[:brand] = product[:brand_raw].mb_chars.downcase.to_s if product[:brand_raw]

      product[:origin_raw] = anchor_text
      product[:origin_raw] = product[:origin_raw].split("ursprung")[-2] if product[:origin_raw]
      product[:origin_raw] = product[:origin_raw].split("\.")[0] if product[:origin_raw]
      product[:origin_raw] = product[:origin_raw].strip if product[:origin_raw]
      product[:origin] = product[:origin_raw].mb_chars.downcase.to_s if product[:origin_raw]

      product[:ingredients_raw] = anchor_text
      product[:ingredients_raw] = product[:ingredients_raw] if product[:ingredients_raw]
      product[:ingredients_raw] = product[:ingredients_raw].split("ingrediensförteckning")[1] if product[:ingredients_raw]
      product[:ingredients_raw] = product[:ingredients_raw].split(/näringsinnehåll|näringsvärden/)[0] if product[:ingredients_raw]
      product[:ingredients] = parse_ingredients(product[:ingredients_raw])

      product[:eu_organic] = true if doc.css("img[src*='http://static.matvaran.se/ica_produkt/eulovet.png']").any?
    end
  end

  def parse_ingredients(ingredients)
    return [] if ingredients.blank?

    ingredients = ingredients.mb_chars.downcase.to_s

    ingredients.gsub!(/\s+/, " ")

    e_numbers.each { |number, word| ingredients.gsub!(number, word) }

    illegal_foreign_patterns.each { |pattern| ingredients.gsub!(/\/( )?#{pattern}/, "") }

    pattern_replacements_before.each { |a, b| ingredients.gsub!(a, b) }

    illegal_patterns_pre.each { |pattern| ingredients.gsub!(pattern, "") }

    ingredients.gsub!("och ", ",")
    ingredients.gsub!(number_pattern, ",")
    ingredients.gsub!(illegal_chars_pattern, "")

    ingredients = ingredients.split(separator_pattern)
    ingredients = ingredients.reject(&:blank?)
    ingredients = ingredients.map(&:strip)

    illegal_prefixes.each do |pre|
      ingredients = ingredients.map { |s| s.start_with?(pre) ? s.gsub(pre, "") : s }
    end

    illegal_suffixes.each do |suf|
      ingredients = ingredients.map { |s| s.end_with?(suf) ? s.gsub(suf, "") : s }
    end

    pattern_replacements_after.each do |a, b|
      ingredients = ingredients.map { |s| s == a ? b : s }
    end

    ingredients = ingredients.map(&:strip)
    ingredients = ingredients - illegal_ingredients
    ingredients = ingredients.uniq
    ingredients = ingredients.reject(&:blank?)
  end

  def number_pattern
    /[0-9,\.]+(\s*%)?(\s*g)?/
  end

  def illegal_chars_pattern
    /[:\r\n\t]/
  end

  def separator_pattern
    /[\(\);,.\*®\|]/
  end

  def illegal_patterns_pre
    [
      /surhetsreglerande( )?medel/,
      /stabiliseringsmedel/,
      /konserveringsmedel/,
      /emulgeringsmedel/,
      /förtjockningsmedel/,
      /surhetsreglerandemedel/,
      /antioxidationsmedel/,
      /sötningsmedel/,
      /fuktighetsbevarande medel/,
      /ingrediens(er)?/,
      /lågpastöriserad/,
      /högpastöriserad/,
      /berikad med/,
      /innehåller( också)?/,
      /produkt(en)?(er)?/,
      /1( )?l/,
      /utvald sockersaltad/,
      /fångstområde.+$/,
      /kan innehålla spår av/,
      /fetthalt/,
      /uht-behandlad/,
      /eu-jordbruk/,
      /ej homogeniserad/,
      /garnering/,
      /krav-( )*ekologisk ingrediens( ej standardiserad)?/,
      /kryddextrakt(er)?/,
      /kalcium bidrar till att matsmältningsenzymerna fungerar normalt/,
      /tag ur pizzan ur förpackningen och värm i ugn på 225°c i ca 9-10 min eller tills osten smält/,
      /färgämne(n)?/,
      /naturlig(a)?/,
      /inkl/,
      /svensk(a)?(t)?/,
      /sverige/,
      /ursprung(sland)?/,
      /mjölken är/,
      /tillsatt/,
      /lämplig för veganer/,
      /ekologisk/,
      /(från|av) mjölk/,
      /smakförstärkare/,
      /delvis härdade vegetabiliska fetter/,
      /vegetabiliska oljor/,
      /ätfärdig/,
      /sv\/no\/dk/,
      /fiskad i nordostatlanten fångstzon 27/,
    ]
  end

  def illegal_ingredients
    [
      "frukt",
      "helmuskel",
      "se",
      "dk",
      "kryddor",
      "bärberedning",
      "färg",
      "aromer",
      "andra",
      "smakberedning",
      "krav-",
      "vitaminer",
      "arom",
      "aromer",
      "syra",
      "vatten",
      "tre ankare",
      "gram",
      "g",
      "sojabas",
      "polydextros",
      "smältsalter",
    ]
  end

  def illegal_prefixes
    [
      "motsvarar",
      "minst",
      "hackade",
      "hackad",
      "naturlig",
      "naturliga",
      "sötningsmedel",
      "förtjockningsmedel",
      "fuktighetsbevarande medel",
      "fyllnadsmedel",
      "färgämne",
      "surhetsreglerande medel",
      "ytbehandlingsmedel",
      "antioxidationsmedel",
      "antioxidantmedel",
      "innehåller",
      "kokt",
      "rökt",
      "svenska",
      "svensk",
      "pastöriserad",
      "bl.a.",
      "bl a",
    ]
  end

  def illegal_suffixes
    [
      "med",
      " av komjölk",
      " av svensk rapsgris",
      " av vegetabiliskt fett",
    ]
  end

  def pattern_replacements_before
    {
      /torsk- och sejrom/ => "torskrom, sejrom",
      /gris- och nötkött/ => "griskött, nötkött",
      /förtjocknings-/ => "förtjockningsmedel",
      /ytbehandlings-/ => "ytbehandlingsmedel",
      /mono-( )?och diglycerider/ => "monoglycerider, diglycerider",
    }
  end

  def pattern_replacements_after
    {
      "portionssnus dosa" => "portionssnus",
      "shea" => "sheaolja",
      "palm" => "palmolja",
      "raps" => "rapsolja",
      "kokosnöt" => "kokosnötsolja",
    }
  end

  def illegal_foreign_patterns
    [
      "mælkeprotein",
      "mælk",
      "højpasteuriseret",
      "jordbær",
      "hyldebær-",
      "piskefløde",
      "sukker",
      "mysepulver",
      "rosin",
      "sødestoffer",
      "søtningsstoffer",
      "hærdet",
      "herdet",
      "voks",
      "emulgator",
      "farvestof",
      "sojabønnelecitin",
      "fortykningsmiddel",
      "overfadebehandlingmiddel",
      "hvetemel",
      "hvedemel",
      "vegetabilske",
      "oljer",
      "olier",
      "palme",
      "kokos",
      "sirup",
      "bakepulver",
      "bagepulver",
      "ingefær",
      "kryddernelliker",
      "kan inneholde spor av mandler",
      "kan indeholde spor af mandler",
      "græskarkerner",
      "fuldkornsrugmel",
      "fullkornsrugmel",
      "speltmel",
      "melonkerner",
      "vand",
      "hvedeklid",
      "hvetekli",
      "bygmalt",
      "surdej",
      "rug",
      "rapsolie",
      "honning",
      "gjær",
      "vegetabilsk fett",
      "kan inneholde spor av melk",
      "valmuefrø",
      "overfladebehandlingsmidler",
      "sesamfrø",
      "hvetekim",
    ]
  end
end
