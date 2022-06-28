//connect to server (fill in your own geoserver address)
var geoserverUrl = "http://localhost:8080/geoserver";
var selectedPoint = null;
var BeginMarker = null;
// from example add a empty variable
var source = null;
var target = null;

var pathLayer = null;

// Init value to same default as slider
var walking_distance = 0.5;

// Styling example for the points we select
var selectedPointStyle = {
    radius: 8,
    fillColor: "#ff7800",
    color: "#000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8
};


//initialize map & sidebar + location
var map = L.map('DogMap', {
    center: [52, 5],
    zoom: 10
});


// add sidebar
var sidebar = L.control.sidebar('sidebar').addTo(map);

// load osm map
var OpenStreetMap = L.tileLayer(
    'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http:openstreetmap.org/copyright">OpenStreetMap</a>'
    }
).addTo(map);

//intialize dog places wms map
var wmsLayer = L.tileLayer.wms('http://localhost:8080/geoserver/wms', {
    layers: 'dog:dogplaces',
    format: 'image/png',
    transparent: true,
    version: '1.1.0',
    style: 'dog2,'
}).addTo(map);

// Scalebar
L.control.scale({
    metric: true,
    imperial: false,
    position: 'bottomright'
}).addTo(map);

//geocoder
L.Control.geocoder({
    defaultMarkGeocode: false
}).on('markgeocode', function(e) {
    var latlng = e.geocode.center;
    map.fitBounds(e.geocode.bbox);
}).addTo(map);
if (!navigator.geolocation) {
    console.log("Your browser doesn't support geolocation feature!")
} else {
    {
        navigator.geolocation.getCurrentPosition(getPosition)
    };
};
var lat, long;

function getPosition(position) {
    lat = position.coords.latitude
    long = position.coords.longitude
    map.setView(([lat, long]), 15);
}
//JQuery slide bar for distance
$(function() {
    $("#slider-range-max").slider({
        range: "max",
        min: 0.5,
        max: 10,
        value: 0.5,
        step: 0.5,
        slide: function(event, ui) {
            $("#amount").val(ui.value);
            walking_distance = ui.value;
        }
    });
    $("#amount").val($("#slider-range-max").slider("value"));
});


//onclick actions 
map.on('click', function(e) {
    buffer = 52;
    buffercircle = buffer * 0.62;
    buffer3 = buffer * 1.13;
	// request nearest vertex 
    var url = `${geoserverUrl}/wfs?service=WFS&version=2.0.0&request=GetFeature&typeName=dog:nearest_vertex&outputformat=application/json&viewparams=x:${e.latlng.lng};y:${e.latlng.lat};`;
    $.ajax({
        url: url,
        async: true,
        success: function(data) {
            clickedarea = e.latlng;
            idvertex = data.features[0].properties.id;
			console.log('idvertex', idvertex)
		    // request dog route based on vertex
            var url = `${geoserverUrl}/wfs?service=WFS&version=2S.0.0&request=GetFeature&typeName=dog:dogwalking_circuit_route&outputformat=application/json&viewparams=idvertex:${idvertex};distance:${walking_distance*0.0030}`;
            $.ajax({
                url: url,
                async: true,
                success: function pie(data) {
                    console.log(data)
                    if (pathLayer !== null)
                        map.removeLayer(pathLayer);

                    pathLayer = L.geoJSON(data, {
                        pointToLayer: function(feature, latlng) {
                            return L.circleMarker(latlng, selectedPointStyle);
                        }
                    });
                    map.addLayer(pathLayer);
                }
            });

			// update street name 
			rect = L.rectangle(clickedarea.toBounds(5000));
            bxsw = rect.getBounds()._southWest.lng;
            bysw = rect.getBounds()._southWest.lat;
            bxne = rect.getBounds()._northEast.lng;
            byne = rect.getBounds()._northEast.lat;
            var url = `${geoserverUrl}/wfs?service=WFS&version=2S.0.0&request=GetFeature&typeName=dog:nearest_edge&outputformat=application/json&viewparams=x:${e.latlng.lng};y:${e.latlng.lat};bxsw:${bxsw};bysw:${bysw};bxne:${bxne};byne:${byne};`;
            $.ajax({
                url: url,
                async: true,
                success: function street(data) {
                    streetnameJ = data.features[0].properties.streetname;
					if (streetnameJ  == null){
						document.getElementById("streetname").setAttribute('value', 'n/a');
					} else {
						document.getElementById("streetname").setAttribute('value', streetnameJ);
				    }
                }
            });
        }
    });
    if (BeginMarker != undefined) {
        map.removeLayer(BeginMarker);
    };

    //Add a marker to show where you clicked.
    BeginMarker = L.marker([e.latlng.lat, e.latlng.lng]).addTo(map);
});