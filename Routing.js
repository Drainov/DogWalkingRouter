//initialize map & sidebar
var map = L.map('DogMap', { center:[45.0, 12.0000], zoom:10});

var sidebar = L.control.sidebar('sidebar').addTo(map);

var OpenStreetMap = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {maxZoom: 19, attribution: '&copy; <a href="http:openstreetmap.org/copyright">OpenStreetMap</a>'}).addTo(map);