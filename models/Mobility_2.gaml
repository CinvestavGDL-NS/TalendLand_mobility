/**
* Name: Mobility2
* Create species
* Tags: 
*/


model Mobility2

global
{
	file shp_roads <- file("../includes/maps/cd_creativa_1.shp");
	file shp_nodes <- file("../includes/maps/cd_creativa_nodes_1.shp");
	
	file 		shp_mibici <- file("../includes/maps/mibici_spots.shp");
	image_file 	logo_mibici <- image_file("../includes/img/mibici_logo.png");
	
	image_file 	img_auto <- image_file("../includes/img/coche.png");
	image_file 	img_bike <- image_file("../includes/img/bicicleta.png");
	image_file 	img_pedestrian <- image_file("../includes/img/peaton.png");
	
	
	geometry shape <- envelope(shp_roads);
	graph road_network;
	
	init
	{
		create intersection from: shp_nodes;
		create road from:shp_roads where (each != nil);
		
		road_network <- as_driving_graph(road, intersection);
		create mibici 	from: shp_mibici;
		create vehicle  number: 300 with: (location: one_of(intersection).location);
		create Bike 	number: 100 with: (location: one_of(mibici).location);
		create People 	number: 200 with:  (location: one_of(intersection).location);
	}
}



species road skills: [road_skill]
{
	aspect basic
	{
		draw shape color:#grey;
	}
}


species intersection skills: [intersection_skill] ;

species mibici 
{
	aspect basic
	{
		draw logo_mibici size:20#m at:location;
	}
}


species vehicle skills: [driving] {
	rgb color <- #red;
	float pollution_generated <- 10.0;
	
	bool flg_park <- true;

	init 
	{
		vehicle_length <- 1.9 #m;
		max_speed <- 100 #km / #h;
		max_acceleration <- 3.5;
		
	}


	aspect base 
	{
		draw img_auto size:25 rotate: heading;
	}
}


species Bike skills: [driving] 
{
	rgb color <- #blue;
	init 
	{
		vehicle_length <- 1.0 #m;
		max_speed <- 18 #km / #h;
		max_acceleration <- 1.5;
	}

	
	aspect base 
	{
		draw img_bike size:15 rotate: heading+180;
	}
}

species People skills: [driving] 
{
	rgb color <- #yellow;
	init 
	{
		vehicle_length <- 1.0 #m;
		max_speed <- 5 #km / #h;
		max_acceleration <- 0.5;
	}

	
	aspect base 
	{
		draw img_pedestrian size:10 rotate: heading;
	}

}



experiment main type:gui
{
	output
	{
		display osm type:opengl
		{
			species road 	aspect: basic	refresh:false;
			species Bike 	aspect: base;
			species vehicle aspect: base;
			species People 	aspect: base;
			species mibici  aspect: basic	refresh: false;

		}
	}
}





