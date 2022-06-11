//connect to server (fill in your own geoserver address)
var geoserverUrl = "http://localhost:8080/geoserver";
var selectedPoint = null;

// from example add a empty variable
var source = null;
var target = null;

// travel points
var point_1 = null;
var point_2 = null;
var point_3 = null;
var point_4 = null;
var point_5 = null;

//initialize map & sidebar
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

//Jquerry settings menu
$( function() {
    $( "#speed" ).selectmenu();
 
    $( "#files" ).selectmenu();
 
    $( "#number" )
      .selectmenu()
      .selectmenu( "menuWidget" )
      .addClass( "overflow" );
  } );
//Jquerry routing button
$( "#RoutingSP" ).controlgroup();

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
	var url = `${geoserverUrl}/wfs?service=WFS&version=1.0.0&request=GetFeature&typeName=cite:nearest_vertex&outputformat=application/json&viewparams=x:${
		selectedPoint.lng
	};y:${selectedPoint.lat};`;
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
