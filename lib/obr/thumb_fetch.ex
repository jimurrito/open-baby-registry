defmodule Obr.ThumbFetch do
  @moduledoc """
  Thumbnail fetcher for items.
  """

  @placeholder "/images/shopping_cart.png"
  @headers [
    {"Content-Type", "application/xhtml+xml"},
    {"User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:139.0) Gecko/20100101 Firefox/139.0"}
  ]

  def test_fetch() do
    {:ok, response} =
      Finch.build(
        :get,
        "https://www.amazon.com/Philips-AVENT-Pacifier-SCF190-41/dp/B07TDN9MKC?crid=3FUY6YQ4HZFJO&dib=eyJ2IjoiMSJ9.yBvIQ2X8MI8g5VhcQb1gHPxpJTijTLnDL0CWpb46ih9oPaD0E95ZZL9o9DOiMP_qh4X6ZzwEuqAGFtKerk8q0WbrOtY70C4x9MpWob5oqf_ahzCyGUj66ikP_OeR-Qs78fxbDY1DGLR0_VcSddkvDgSGiKOaZovjhKlILGZEitpxo6DNoCaUoz-dvbp0bAelUg8sfq41e3l7FULINltReWDsF_39vjvv4zKzsFxU1CWcJ-A-ko3e50BcYXW-R9jGCf0PmQid6qbuBtk-sauXWJ26zde4TliWTfspOpFdYPg.evJx0yBCa4vhENGUOUHSHy3fqwiSSYnKS-MtKkwFS3I&dib_tag=se&keywords=silicone%2Bbinky&qid=1748899960&s=baby-products&sprefix=silicone%2Bbinki%2Cbaby-products%2C99&sr=1-7&th=1",
        #"https://www.walmart.com/ip/Baby-Magic-Gentle-Baby-Lotion-Original-Baby-Scent-Hypoallergenic-30-oz/15342463212",
        @headers
      )
      |> Finch.request(Obr.Finch)

    response
    #|> Map.get(:body)
    # Parse for meta content
    #|> String.split("\"")
    #|> Enum.find("", &String.contains?(&1, "https"))
  end

  #
  #
  @doc """
  Uses an item's URL to fetch the image using OpenGraph.

  > Amazon is the exception. Must provide :amz for that provider.
  """
  # AMZ Specific parser
  #def fetch(item_url, :amz) do
  #  # get body via Finch
  #  Finch.build(:get, item_url, @headers)
  #  |> Finch.request(Obr.Finch)
  #  |> case do
  #    {:ok, response} ->
  #      response
  #      |> Map.get(:body)
  #      # AMZ uses gzip encoding
  #      |> :zlib.gunzip()
  #      # Parse for meta content
  #      |> String.split("\"")
  #      |> Enum.find("", &String.contains?(&1, "png"))
  #    # |> String.split("\"")
  #    # |> Enum.find(@placeholder, &String.contains?(&1, "https"))
  #    {:error, _exception} ->
  #      @placeholder
  #  end
  #end

  #
  #
  # Open Graph parser
  @spec(fetch(binary(), atom()) :: binary(), nil)
  def fetch(item_url, _store) do
    # get body via Finch
    Finch.build(:get, item_url, @headers)
    |> Finch.request(Obr.Finch)
    |> case do
      {:ok, response} ->
        response
        |> Map.get(:body)
        # Parse for meta content
        |> String.split("<meta")
        |> Enum.find("", &String.contains?(&1, "og:image"))
        |> String.split("\"")
        |> Enum.find(@placeholder, &String.contains?(&1, "https"))

      {:error, _exception} ->
        @placeholder
    end
  end
end
