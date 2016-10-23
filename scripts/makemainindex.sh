#!/bin/bash
cat <<HEREDOC
<!DOCTYPE HTML>
<html>
<head><title>Rapid Transit Timelines and Scale Comparison</title>
<meta http-equiv="Content-type" content="text/html;charset=UTF-8">
<style type="text/css">
div#preloader {
	position: absolute;
	left: -9999px;
	top:  -9999px;
}
div#preloader img {
	display: block;
}
div#sidebar {
	float: left;
	background: #ffffff;
	border: 1px solid;
	width: 10em;
	max-height: calc(100% - 22px);
	top: 0;
	left: 0;
	margin: 5px;
	padding: 5px;
	position: fixed;
	display: flex;
	flex-flow: column;
	text-align: left;
}
div#form {
	flex: 1;
	overflow: auto;
}
div#button a:link {
	color: #000000;
	text-decoration: none;
}
div#button a:visited {
	color: #000000;
	text-decoration: none;
}
span {
	margin-top: 5px;
	margin-bottom: 5px;
}
.map {
	border: 1px solid;
	margin-left: 5px;
	margin-right: 5px;
}
body {
	text-align: center;
}
@media screen and (-ms-high-contrast: active), (-ms-high-contrast: none) {
	/* styles for IE since flex is broken */
	div#sidebar {
		line-height: 1.2em;
		display: block;
		max-height: calc(100% - 22px);
	}
	div#form {
		height: calc(100vh - 22px - 3.6em);
	}
}
</style>
<script type="text/javascript">
HEREDOC
start=$(for city in `echo $@ | sed -e's/@//g'`; do ls $city/????.svg; done | sed -e's!^.../\(....\).svg!\1!' | sort | head -n 1)
echo "start=${start};"
echo -n "count="
expr 1 + \( \( 2015 - $start \) / 5 \) | sed -e's/$/;/'
cat <<HEREDOC
step=5;
index=count-1;
function update() {
HEREDOC
echo -n '	['
for city in $@; do echo -n '"'$city'",'; done | tr 'a-z' 'A-Z' | sed -e's/@//g; s/,$/].forEach(function(city) { if (document.getElementById(city).style.display == "inline-block") {/'
echo ''
cat << HEREDOC
		mapimg = document.getElementById(city + "map");
		mapimg.src = (city.toLowerCase() + "/small/" + (start+step*index) + ".svg");
		mapimg.title = start+step*index;
		mapimg.alt = start+step*index + " map";
	}});
}
function nextmap() {
	index = (index+1)%count;
	update();
}
function prevmap() {
	index = (index+count-1)%count;
	update();
}
function toggleshow(x) {
	span = document.getElementById(x);
	prediv = document.getElementById(x + "pre");
	mapimg = document.getElementById(x + "map");
	if (span.style.display == 'inline-block') {
		span.style.display = 'none';
		mapimg.src = "about:blank";
		imgs = prediv.getElementsByTagName("img");
		for (var i=0; i < imgs.length; i++) {
			prediv.removeChild(imgs[i]);
		}
	} else {
		mapimg.src = x.toLowerCase() + '/small/' + (start+step*index) + '.svg';
		for (var i = start; i < start + count*step; i+=step) {
			img = document.createElement("img");
			img.src = x.toLowerCase() + '/small/' + i + '.svg';
			img.width = "1"; img.height = "1"; img.alt = "";
			prediv.appendChild(img);
		}
		span.style.display = 'inline-block';
	}
}
function togglesidebar() {
	f = document.getElementById("form");
	s = document.getElementById("showall");
	h = document.getElementById("hideall");
	a = document.getElementById("collapse");
	m = document.getElementById("maps");
	if (f.style.display == 'block') {
		f.style.display = 'none';
		s.style.display = 'none';
		h.style.display = 'none';
		a.innerHTML = "[+]";
		m.style.paddingLeft = "0";
	} else {
		f.style.display = 'block';
		s.style.display = 'block';
		h.style.display = 'block';
		a.innerHTML = "[&minus;]";
		m.style.paddingLeft = "calc(10em + 22px)";
	}
}
function selectall() {
	spans = document.getElementsByTagName("span");
	for (var i=0; i < spans.length; i++) {
		if (spans[i].style.display == 'none') {
			document.getElementById(spans[i].id + "checkbox").click();
		}
	}
}
function deselectall() {
	spans = document.getElementsByTagName("span");
	for (var i=0; i < spans.length; i++) {
		if (spans[i].style.display == 'inline-block') {
			document.getElementById(spans[i].id + "checkbox").click();
		}
	}
}

document.onkeydown=function(keypress) {
	if(keypress.which == 65) { prevmap(); }
	if(keypress.which == 83) { nextmap(); }
}
window.onload=function() {
	inyear = parseInt(location.hash.substring(1));
	if( start < inyear & inyear < start+step*count & !(inyear % step) ) {
		index = (inyear-start)/step;
		update();
	}
}
</script>
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-19998781-1']);
  _gaq.push(['_trackPageview']);
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
</head><body>
<a href="javascript:" onclick="prevmap()">five years earlier (or press a)</a> ---
<a href="javascript:" onclick="nextmap()">five years later (or press s)</a>
<p>
<div id="maps" style="padding-left: calc(10em + 22px);">
<noscript>Sorry, the maps really don't work without javascript.</noscript>
HEREDOC

for city in $@; do
  NAME=`cat $city/name`
  UPPER=$(echo $city | tr 'a-z' 'A-Z')
  NATIVEW=$(grep ' width="' $city/small/2015.svg | head -n1 | sed -e's/.* width="\([0-9\.]*\)".*/\1/;')
  W=$(awk "BEGIN{print int(0.5+$NATIVEW*390/5376)}")
  H=$(awk "BEGIN{print int(0.5+$(grep ' height=' $city/small/2015.svg | head -n1 | sed -e's/.* height="\([0-9\.]*\)".*/\1/;')*$W/$NATIVEW)}")
  if [ -f $city/s ]; then
    echo '<span id="'$UPPER'" style="display: inline-block; vertical-align: middle"><a href="'$city'">'$NAME'<br>' \
    | sed -e's!href="nyc"!href="../subtimeline/"!; s!href="chi"!href="../ltimeline"!; s!href="bos"!href="../ttimeline"!;'
    echo '  <img class="map" id="'$UPPER'map" src="'$city'/small/2015.svg" title="2015" alt="2015 map" width="'$W'" height="'$H'"></a></span>'
  else
    echo '<span id="'$UPPER'" style="display: none; vertical-align: middle"><a href="'$city'">'$NAME'<br>' \
    | sed -e's!href="nyc"!href="../subtimeline/"!; s!href="chi"!href="../ltimeline"!; s!href="bos"!href="../ttimeline"!;'
    echo '  <img class="map" id="'$UPPER'map" src="about:blank" title="2015" alt="2015 map" width="'$W'" height="'$H'"></a></span>'
  fi
done

cat <<HEREDOC
</div>
<p>
<a href="javascript:" onclick="prevmap()">five years earlier (or press a)</a> --- 
<a href="javascript:" onclick="nextmap()">five years later (or press s)</a>
<div id=sidebar>
<div id="button" style="position: absolute; right: 5px;" onclick="togglesidebar()"><a id="collapse" href="javascript:">[&minus;]</a></div>
<div style="padding-right: 2em;">Cities to show:</div>
<div id="form" style="display: block;"><form action="#">(ordered by opening year)<br>
HEREDOC
for city in $@; do
  NAME=`cat $city/name`
  UPPER=$(echo $city | tr 'a-z' 'A-Z')
  if [ -f $city/s ]; then
    echo "<input type=\"checkbox\" id=\"${UPPER}checkbox\" onclick=\"toggleshow('$UPPER')\" checked><a href=\"$city\">$NAME</a><br>" \
      | sed -e's!href="nyc"!href="../subtimeline/"!; s!href="chi"!href="../ltimeline"!; s!href="bos"!href="../ttimeline"!;'
  else
    echo "<input type=\"checkbox\" id=\"${UPPER}checkbox\" onclick=\"toggleshow('$UPPER')\"><a href=\"$city\">$NAME</a><br>" \
      | sed -e's!href="nyc"!href="../subtimeline/"!; s!href="chi"!href="../ltimeline"!; s!href="bos"!href="../ttimeline"!;'
  fi
done
cat <<HEREDOC
</form></div>
<div id="showall" style="display: block;"><a href="javascript:selectall()">show all</a></div>
<div id="hideall" style="display: block;"><a href="javascript:deselectall()">hide all</a></div>
</div>
<p>
Based on frequent midday service at the end of the year in question (<a href="notes.html">notes</a>).  Scale 10 CSS pixels per km.
<p>
Please send any corrections or questions to threestationsquare at gmail dot com.
<p>
See also: <a href="misc">miscellaneous timelines</a>
<div style="font-size: x-small;">By <a href="/">Alexander Rapp</a> based on map data 
<a rel="license" href="http://creativecommons.org/licenses/by-sa/2.0/"><img alt="CC-BY-SA" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/2.0/80x15.png"></a>
by <a href="http://www.openstreetmap.org">OpenStreetMap</a> contributors.</div>
<div id=preloader>
HEREDOC
for city in $@; do
  UPPER=`echo $city | tr 'a-z' 'A-Z'`
  echo '<div id="'$UPPER'pre">'
  if [ -f $city/s ]; then
    for year in `seq 1840 5 2015`; do
      echo '<img src="'$city'/small/'$year'.svg" width="1" height="1" alt="">'
    done
  fi
  echo '</div>'
done
echo "</div></body></html>"