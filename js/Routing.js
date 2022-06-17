//connect to server (fill in your own geoserver address)
var geoserverUrl = "http://localhost:8080/geoserver";
var selectedPoint = null;
var BeginMarker = null;
// from example add a empty variable
var source = null;
var target = null;

// travel points
var point_1 = null;
var point_2 = null;
var point_3 = null;
var point_4 = null;
var point_5 = null;

//initialize map & sidebar + location
var map = L.map('DogMap', { 
    center:[52, 5], 
    zoom:10}
);
// add sidebar
var sidebar = L.control.sidebar('sidebar').addTo(map);
// load osm map 
var OpenStreetMap = L.tileLayer(
    'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', 
    {
        maxZoom: 19, 
        attribution: '&copy; <a href="http:openstreetmap.org/copyright">OpenStreetMap</a>'
    }
).addTo(map);
L.Control.geocoder({defaultMarkGeocode: false}).on('markgeocode', function(e) {
    var latlng = e.geocode.center;
    map.fitBounds(e.geocode.bbox);
  }).addTo(map);
        if (!navigator.geolocation) {
            console.log("Your browser doesn't support geolocation feature!")
        } else {{
                navigator.geolocation.getCurrentPosition(getPosition)
            };
        };
		var lat, long;
		function getPosition(position) {
            // console.log(position)
            lat = position.coords.latitude
            long = position.coords.longitude
			map.setView(([lat, long]),15);
        }
//Jquerry slide bar for distance
$( function() {
    $( "#slider-range-max" ).slider({
      range: "max",
      min: 0.5,
      max: 10,
      value: 0.5,
	  step: 0.5,
      slide: function( event, ui ) {
        $( "#amount" ).val( ui.value );
      }
    });
    $( "#amount" ).val( $( "#slider-range-max" ).slider( "value" ) );
  } );

//Jquerry input bar (needs a response from the server)
$( function() {
    function log( message ) {
      $( "<div>" ).text( message ).prependTo( "#log" );
      $( "#log" ).scrollTop( 0 );
	}
});
//onclick place marker
map.on('click',function(e){
  lat = e.latlng.lat;
  lon = e.latlng.lng;
  var url = `${geoserverUrl}/wfs?service=WFS&version=2S.0.0&request=GetFeature&typeName=cite:nearest_vertex&outputformat=application/json&viewparams=x:${e.latlng.lat};y:${e.latlng.lng};`;
$.ajax({
	url: url,
	async: true,
	success: function(data) {
	}
});
	  if (BeginMarker != undefined) {
			map.removeLayer(BeginMarker);
	  };

//Add a marker to show where you clicked.
  BeginMarker = L.marker([lat,lon]).addTo(map);  
});
// shortest path part (everything below is for shortest path)
$(document).ready(function(){
	$('input[id="Routing_test"]').click(function(){
		if($(this).is(":not(:checked)")){
			alert("Checkbox is unchecked.");
		}
		else if($(this).is(":checked")){
			alert("Checkbox is checked.");
			// shortest path layer geojson
			var pathLayer = L.geoJSON(null);


			// draggable marker for starting point. Note the marker is initialized with an initial starting position
			var sourceMarker = L.marker([52.089149, 5.142144], {
				draggable: true
			})
				.on("dragend", function(e) {
					selectedPoint = e.target.getLatLng();
					getVertex(selectedPoint);
					getRoute();
				})
				.addTo(map);

			// draggbale marker for destination point.Note the marker is initialized with an initial destination positon
			var targetMarker = L.marker([52.092516, 5.116474], {
				draggable: true
			})
				.on("dragend", function(e) {
					selectedPoint = e.target.getLatLng();
					getVertex(selectedPoint);
					getRoute();
				})
				.addTo(map);

			// function to get nearest vertex to the passed point
			function getVertex(selectedPoint) {
				var url = `${geoserverUrl}/wfs?service=WFS&version=1.0.0&request=GetFeature&typeName=cite:nearest_edge&outputformat=application/json&viewparams=x:${
					selectedPoint.lng};y:${selectedPoint.lat};`;
				$.ajax({
					url: url,
					async: false,
					success: function(data) {
						loadVertex(
							data,
							selectedPoint.toString() === sourceMarker.getLatLng().toString()
						);
					}
				});
			}

			// function to update the source and target nodes as returned from geoserver for later querying
			function loadVertex(response, isSource) {
				var features = response.features;
				map.removeLayer(pathLayer);
				if (isSource) {
					source = features[0].properties.id;
				} else {
					target = features[0].properties.id;
				}
			}

			// function to get the shortest path from the give source and target nodes
			function getRoute() {
				var url = `${geoserverUrl}/wfs?service=WFS&version=1.0.0&request=GetFeature&typeName=cite:shortest_path&outputformat=application/json&viewparams=source:${source};target:${target};`;

				$.getJSON(url, function(data) {
					map.removeLayer(pathLayer);
					pathLayer = L.geoJSON(data);
					map.addLayer(pathLayer);
				});
			}
			getVertex(sourceMarker.getLatLng());
			getVertex(targetMarker.getLatLng());
			getRoute();
}
});
});
