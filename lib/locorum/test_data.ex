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
      "local_short" ->
        """
        <div class="bucket"><div class="listing bbGray vcard courtesyListing"><div class="listBlockL"><a omn_key="BS1SEO:305:1:1105" onclick="return loc_click(this);" href="http://www.local.com/business/details/yx/atlanta-ga/lucas-group-2138799/" class="txtBlock item orgClick"><h2 class="title fn org"><b>Lucas</b> <b>Group</b></h2></a> <span class="adr fl"><span class='street-address fl'>950 E. Paces Ferry Road NE Suite 2300,&nbsp;</span><span class="locality region fl">Atlanta, GA</span>&nbsp;</span><a omn_key="BS1SEO:305:1:3003" onclick="return loc_click(this);" href="/business/details/yx/map/atlanta-ga/blucasb-bgroupb-2138799/" class="blueLink">map</a> <p class="desc txt11 clear" style="display:block;"> Lucas Group associates are North America’s premier executive recruiters, serving mid-tier to Fortune 500 ... <a style="display: inline" omn_key="BS1SEO:305:1:1114" onclick="return loc_click(this);" href="http://www.local.com/business/details/yx/atlanta-ga/lucas-group-2138799/" class="blueLink">more</a> </p> </div> <div class="fr mT5 tar">
        """
      "local_long" ->
        """
        <div class="bucket"><div class="listing bbGray vcard courtesyListing"><div class="listBlockL"><a omn_key="BS1SEO:305:1:1105" onclick="return loc_click(this);" href="http://www.local.com/business/details/yx/atlanta-ga/lucas-group-2138799/" class="txtBlock item orgClick"><h2 class="title fn org"><b>Lucas</b> <b>Group</b></h2></a> <span class="adr fl"><span class='street-address fl'>950 E. Paces Ferry Road NE Suite 2300,&nbsp;</span><span class="locality region fl">Atlanta, GA</span>&nbsp;</span><a omn_key="BS1SEO:305:1:3003" onclick="return loc_click(this);" href="/business/details/yx/map/atlanta-ga/blucasb-bgroupb-2138799/" class="blueLink">map</a> <p class="desc txt11 clear" style="display:block;"> Lucas Group associates are North America’s premier executive recruiters, serving mid-tier to Fortune 500 ... <a style="display: inline" omn_key="BS1SEO:305:1:1114" onclick="return loc_click(this);" href="http://www.local.com/business/details/yx/atlanta-ga/lucas-group-2138799/" class="blueLink">more</a> </p> </div> <div class="fr mT5 tar">
        <div class="bucket"><div class="listing bbGray vcard courtesyListing"><div class="listBlockL"><a omn_key="BS1SEO:305:1:1105" onclick="return loc_click(this);" href="http://www.local.com/business/details/yx/atlanta-ga/lucas-group-2138799/" class="txtBlock item orgClick"><h2 class="title fn org"><b>Lucas</b> <b>Group</b></h2></a> <span class="adr fl"><span class='street-address fl'>369 Loomis Ave SE</span><span class="locality region fl">Atlanta, GA</span>&nbsp;</span><a omn_key="BS1SEO:305:1:3003" onclick="return loc_click(this);" href="/business/details/yx/map/atlanta-ga/blucasb-bgroupb-2138799/" class="blueLink">map</a> <p class="desc txt11 clear" style="display:block;"> Lucas Group associates are North America’s premier executive recruiters, serving mid-tier to Fortune 500 ... <a style="display: inline" omn_key="BS1SEO:305:1:1114" onclick="return loc_click(this);" href="http://www.local.com/business/details/yx/atlanta-ga/lucas-group-2138799/" class="blueLink">more</a> </p> </div> <div class="fr mT5 tar">
        """
      _ ->
        "Invalid Format"
    end
  end
end
