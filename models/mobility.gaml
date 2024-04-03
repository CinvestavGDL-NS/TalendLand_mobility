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
		create mibici from: shp_mibici;
		create vehicle  number: 100 with: (location: one_of(intersection).location);
		create Bike 	number: 100 with: (location: one_of(mibici).location);
		create People 	number: 50 with: (location: one_of(mibici).location);
	}
}

grid cell height: 100 width: 100 neighbors: 100
{
	//Nivel de contaminación
	float pollution <- 0.0 min: 0.0 max: 100.0;
	//Actualización de color (Rojo - alta conaminación / Verde - no contaminación)
	rgb color <- #green update: rgb(255 *(pollution/30.0) , 255 * (1 - (pollution/30.0)), 0.0);
	reflex commute {
		ask (cell overlapping location)
		{
			pollution <- pollution -1;
		}
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
		draw rectangle(10#m,20#m) color:#green at:location;
	}
}


species vehicle skills: [driving] {
	rgb color <- #red;
	float pollution_generated <- 10.0;

	init 
	{
		vehicle_length <- 1.9 #m;
		max_speed <- 100 #km / #h;
		max_acceleration <- 3.5;
		
	}

	reflex select_next_path when: distance_to_goal = 0.0 {
		intersection goal <- one_of(intersection);
		
		loop while: goal.location = location 
		{
			goal <- one_of(intersection);
		}
		
		do compute_path graph: road_network target: goal;
	}
	
	
	reflex commute when: current_path != nil {
		ask (cell overlapping location)
		{
			pollution <- pollution + myself.pollution_generated;
		}
		do drive;
	}
	
	aspect base 
	{
		draw cube(6.0) color: distance_to_goal=0 ? #purple :color rotate: heading + 90 border: #black;
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

	reflex select_next_path when: current_path = nil 
	{
		do compute_path graph: road_network target: intersection closest_to one_of(mibici); // TODO: Cambiar intersection por mibici
	}
	
	reflex commute when: current_path != nil 
	{
		do drive;
	}
	
	aspect base 
	{
		draw triangle(5.0) color: color rotate: heading + 90 border: #black;
	}
}

species People skills: [driving] 
{
	rgb color <- #green;
	init 
	{
		vehicle_length <- 1.0 #m;
		max_speed <- 5 #km / #h;
		max_acceleration <- 0.5;
	}

	reflex select_next_path when: current_path = nil 
	{
		do compute_path graph: road_network target: one_of(intersection);
	}
	
	reflex commute when: current_path != nil 
	{
		do drive;
	}
	
	aspect base 
	{
		draw circle(5.0) color: color rotate: heading + 90 border: #black;
	}

}



experiment main type:gui
{
	output
	{
		display osm type:opengl
		{
			grid cell elevation: pollution * 3.0 triangulation: true transparency: 0.7;
			species road 	aspect: basic	refresh:false;
			species Bike 	aspect: base;
			species vehicle aspect: base;
			species People 	aspect: base;
			species mibici  aspect: basic	refresh: false;

		}
	}
}



