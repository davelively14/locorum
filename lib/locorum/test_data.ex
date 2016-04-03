defmodule Locorum.TestData do
  def html(format) do
    case format do
      "wp_short" ->
        """
        <div class="primary-content"><p itemprop="name" class="name">Wendy's</p></div><div class="first" itemprop="address" itemscope itemtype="http://schema.org/PostalAddress"><div><span itemprop="streetAddress">2605 Bouldercrest Rd SE</span></div><div><span itemprop="addressLocality">Atlanta</span>,<span itemprop="addressRegion">GA</span><span itemprop="postalCode">30316</span></div></div>
        """
      "wp_long" ->
        """
        <div class="primary-content"><p itemprop="name" class="name">Wendy's</p></div><div class="first" itemprop="address" itemscope itemtype="http://schema.org/PostalAddress"><div><span itemprop="streetAddress">2605 Bouldercrest Rd SE</span></div><div><span itemprop="addressLocality">Atlanta</span>,<span itemprop="addressRegion">GA</span><span itemprop="postalCode">30316</span></div></div>
        <div class="primary-content"><p itemprop="name" class="name">Wendy's</p></div><div class="first" itemprop="address" itemscope itemtype="http://schema.org/PostalAddress"><div><span itemprop="streetAddress">1313 Mockingbird Ln</span></div><div><span itemprop="addressLocality">Atlanta</span>,<span itemprop="addressRegion">GA</span><span itemprop="postalCode">30312</span></div></div>
        """
      _ ->
        "Invalid Format"
    end
  end
end
