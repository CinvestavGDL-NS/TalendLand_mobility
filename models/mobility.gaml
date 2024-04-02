/**
* Name: mobility
* Based on the internal empty template. 
* Author: Lili
* Tags: 
*/


model mobility

global
{
	file shp_roads <- file("../includes/maps/cd_creativa_1.shp");
	file shp_nodes <- file("../includes/maps/cd_creativa_nodes_1.shp");
	
	file 		shp_mibici <- file("../includes/maps/mibici_spots.shp");
	image_file logo_mibici <- image_file("../includes/img/logo.png");
	
	
	geometry shape <- envelope(shp_roads);
	graph road_network;
	
	init
	{
		create intersection from: shp_nodes;
		create road from:shp_roads where (each != nil);
		
		road_network <- as_driving_graph(road, intersection);

		create Bike number: 100 with: (location: one_of(intersection).location);

		
		create mibici from: shp_mibici;
		

		create vehicle number: 100 with: (location: one_of(intersection).location);
		
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
		draw circle(10#m) color:#green at:location;
	}
}

species vehicle skills: [driving] {
	rgb color <- #red;
	init {
		vehicle_length <- 1.9 #m;
		max_speed <- 100 #km / #h;
		max_acceleration <- 3.5;
	}

	reflex select_next_path when: current_path = nil {
		// A path that forms a cycle
		do compute_path graph: road_network target: one_of(intersection);
	}
	
	reflex commute when: current_path != nil {
		do drive;
	}
	aspect base {
		draw cube(5.0) color: color rotate: heading + 90 border: #black;
	}
}

species Bike skills: [driving] {
	rgb color <- #blue;
	init {
		vehicle_length <- 1.5 #m;
		max_speed <- 18 #km / #h;
		max_acceleration <- 1.5;
	}

	reflex select_next_path when: current_path = nil {
		// A path that forms a cycle
		do compute_path graph: road_network target: one_of(intersection);
	}
	
	reflex commute when: current_path != nil {
		do drive;
	}
	aspect base {
		draw triangle(4.0) color: color rotate: heading + 90 border: #black;
	}
}


experiment main type:gui
{
	output
	{
		display osm type:opengl
		{
			species road aspect: basic;
			species Bike aspect: base;
			species vehicle aspect: base;
			species mibici  aspect:basic;
		}
	}
}



