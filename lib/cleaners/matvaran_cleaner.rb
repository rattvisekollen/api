# coding: utf-8
class MatvaranCleaner < BaseCleaner
  def clean(raw_product)
    base_product(raw_product).tap do |product|
      product.assign_attributes(
        raw_product: raw_product,
        barcode: raw_product.barcode,
        img_urls: raw_product.img_urls,
        name: name(raw_product),
        name_secondary: name_secondary(raw_product),
        brand: brand(raw_product),
        origin: origin(raw_product),
        ingredients: ingredients(raw_product),
        eu_organic: raw_product.eu_organic
      )
    end
  end

  def name(raw_product)
    raw_product.name.mb_chars.downcase.to_s if raw_product.name
  end

  def name_secondary(raw_product)
    raw_product.name_secondary.mb_chars.downcase.to_s if raw_product.name_secondary
  end

  def brand(raw_product)
    raw_product.brand.mb_chars.downcase.to_s if raw_product.brand
  end

  def origin(raw_product)
    raw_product.origin.mb_chars.downcase.to_s if raw_product.origin
  end

  def ingredients(raw_product)
    ingredients = raw_product.ingredients

    return [] if ingredients.blank?

    ingredients = ingredients.mb_chars.downcase.to_s

    ingredients.gsub!(/\s+/, " ")

    e_numbers.each { |number, word| ingredients.gsub!(number, word) }

    illegal_foreign_patterns.each { |pattern| ingredients.gsub!(/\/( )?#{pattern}/, "") }

    ingredients.gsub!(illegal_chars_pattern, "")

    ingredients.gsub!(number_pattern, ",")

    pattern_replacements_before.each { |a, b| ingredients.gsub!(a, b) }

    illegal_patterns_pre.each { |pattern| ingredients.gsub!(pattern, "") }

    ingredients.gsub!("och ", ",")

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
    /[0-9,\.]+/
  end

  def illegal_chars_pattern
    /[\(\):\r\n\t%=]/
  end

  def separator_pattern
    /[;,.\*®\|]/
  end

  def illegal_patterns_pre
    [
      /krav(-)*( )?ekologisk ingrediens.*$/,
      /uppfö(tt|dd) .*$/,
      /råvarorna innehåller.*$/,
      /fiskad i .*$/,
      /fångstområde.*$/,
      /kan innehålla.*$/,
      /innehåller inga tillsatta konserveringsmedel/,
      /i scanmärkta produkter ingår endast svensk köttråvara/,
      /kalcium bidrar till att matsmältningsenzymerna fungerar normalt/,
      /tag ur pizzan ur förpackningen och värm i ugn på 225°c i ca 9-10 min eller tills osten smält/,
      /surhetsreglerande( )?medel/,
      /stabiliseringsmedel/,
      /konserveringsmedel/,
      /emulgeringsmedel/,
      /förtjockningsmedel/,
      /surhetsreglerandemedel/,
      /antioxidationsmedel/,
      /sötningsmedel/,
      /fuktighetsbevarande medel/,
      /klumpförebyggande medel/,
      /ingrediens(er)?/,
      /lågpastöriserad/,
      /högpastöriserad/,
      /berikad med/,
      /innehåller( också)?/,
      /produkt(en)?(er)?/,
      /totalt/,
      /uppfött (i)?/,
      /slaktat (i)?/,
      /1( )?l/,
      /utvald sockersaltad/,
      /kan innehålla spår av/,
      /fetthalt/,
      /uht-behandlad/,
      /eu-jordbruk/,
      /ej homogeniserad/,
      /garnering/,
      /kryddextrakt(er)?/,
      /färgämne(n)?/,
      /naturlig(a)?/,
      /inkl/,
      /svensk(a)?(t)?/,
      /sverige/,
      /danmark/,
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
    ]
  end

  def illegal_ingredients
    [
      "frukt",
      "helmuskel",
      "se",
      "dk",
      "kryddor",
      "andra kryddor",
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
      "kolsyrat vatten",
      "tre ankare",
      "gram",
      "g",
      "sojabas",
      "polydextros",
      "smältsalter",
      "flingor",
      "mineral",
      "svinekjøtt",
      "torkad",
      "skalad",
      "skalat",
      "polerad",
      "polerat",
      "juice från koncentrat",
      "tonnikala palana",
      "vesi",
      "suola",
      "köttmängd",
      "sötning från frukt",
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
      "av komjölk",
      "av svensk rapsgris",
      "av gris",
      "av vegetabiliskt fett",
      "skivad"
    ]
  end

  def pattern_replacements_before
    {
      /torsk-\s*och sejrom/ => "torskrom, sejrom",
      /gris-\s*och nötkött/ => "griskött, nötkött",
      /nöt-\s*och griskött/ => "griskött, nötkött",
      /förtjocknings-/ => "förtjockningsmedel",
      /ytbehandlings-/ => "ytbehandlingsmedel",
      /mono-\s*och diglycerider/ => "monoglycerider, diglycerider",
      /selleri-\s*(,|och) morotsextrakt/ => "selleriextrakt, morotsextrakt",
      /solros-\/rapsolja/ => "solrosolja, rapsolja",
      /apelsin-\s*och röd grapejuice/ => "apelsinjuice, röd grapejuice",
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
      "jordbærbiter",
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
      "rugmel",
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
      "flak",
      "byggmalt",
      "hveteskudd",
      "overfatebehandlingsmiddel",
      "svinekjøtt",
      "fløte",
      "gulrotsektrakt",
      "maisstivelse",
      "mel",
      "egg",
      "økologisk",
    ]
  end
end
