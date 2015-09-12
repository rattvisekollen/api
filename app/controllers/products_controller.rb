# coding: utf-8
class ProductsController < ApplicationController
  before_filter :product

  def show
    render json: @product
  end

  def update
    if @product
      @product.update!(product_params)
    else
      @product = Product.create!(product_params)
    end

    render json: { success: true }
  end

  def count
    render json: { count: Product.count }
  end

  private

  def product
    @product = Product.find_by_barcode(params[:barcode])
  end

  def product_params
    params.require(:product).permit!
  end

  def sample_product
    {
      source: :matvaran,
      source_url: "http://norrkoping.matvaran.se/i_vara.asp?7310070382108",
      barcode_raw: "7310070382108",
      barcode: "7310070382108",
      name_raw: "7up Light",
      name: "7up Light",
      manufacturer_raw: "7up",
      manufacturer: "7up",
      origin_raw: "Sverige",
      origin: "Sverige",
      ingredients_raw:  "Ingredienser: Kolsyrat vatten, syra (citronsyra, äppelsyra), naturlig citron- och limearom, surhetsreglerande medel (natriumcitrat), sötningsmedel (aspartam, acesulfam K),  konserveringsmedel (natriumbensoat).\r\n\r\nInnehåller en källa till fenylalanin.",
      ingredients:  [
        "kolsyrat vatten",
        "syra",
        "citronsyra",
        "äppelsyra",
        "naturlig citron-",
        "limearom",
        "surhetsreglerande medel",
        "natriumcitrat",
        "sötningsmedel",
        "aspartam",
        "acesulfam k",
        "natriumbensoat",
        "innehåller en källa till fenylalanin"
      ]
    }
  end
end
