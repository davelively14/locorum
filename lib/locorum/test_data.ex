defmodule Locorum.TestData do
  def html(format) do
    case format do
      "white_pages" ->
        """
        <div class="first" itemprop="address" itemscope itemtype="http://schema.org/PostalAddress"><div><span itemprop="streetAddress">2605 Bouldercrest Rd SE</span></div><div><span itemprop="addressLocality">Atlanta</span>,<span itemprop="addressRegion">GA</span><span itemprop="postalCode">30316</span></div></div>
        """
      _ ->
        "Invalid Format"
    end
  end
end
