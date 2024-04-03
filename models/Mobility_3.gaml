/**
* Name: Mobility3
* Define behavior
* Tags: 
*/


model Mobility3

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
	
	
	// Parameters
	int no_vehicles 	;
	int no_cars  		;
	int no_bike 	 	;
	int no_pedestrian   ;
	
	
	init
	{
		create intersection from: shp_nodes;
		create road from:shp_roads where (each != nil);
		
		road_network <- as_driving_graph(road, intersection);
		create mibici 	from: shp_mibici;
		create vehicle  number: no_vehicles with: (location: one_of(intersection).location, flg_background:true);
		create vehicle  number: no_cars 	with: (location: one_of(intersection).location, flg_background:false);
		create Bike 	number: no_bike 	with: (location: one_of(mibici).location);
		create People 	number: no_pedestrian 	with: (location: one_of(intersection).location);
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
	
	bool flg_background <- false;

	init 
	{
		vehicle_length <- 1.9 #m;
		max_speed <- 100 #km / #h;
		max_acceleration <- 3.5;
		
	}

	reflex select_next_path when: current_path = nil {
		intersection goal <- one_of(intersection);
		
		loop while: goal.location = location 
		{
			goal <- one_of(intersection);
		}
		
		do compute_path graph: road_network target: goal;
	}
	
	
	reflex commute when: current_path != nil {
		do drive;
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

	reflex select_next_path when: current_path = nil 
	{
		do compute_path graph: road_network target: intersection closest_to one_of(mibici); 
	}
	
	reflex commute when: current_path != nil 
	{
		do drive;
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
		draw img_pedestrian size:10 rotate: heading;
	}

}



experiment main type:gui
{
	parameter "Traffic" 	var: no_vehicles 	<- 100 	category:"Traffic" 	  min: 50 max: 500 step: 1;
	parameter "Vehicles" 	var: no_cars  		<- 50 	category:"Population" min: 0  max: 500 step: 1;
    parameter "Bike"		var: no_bike 	 	<- 50 	category:"Population" min: 0  max: 500 step: 1;
    parameter "Pedestrian" 	var: no_pedestrian  <- 100 	category:"Population" min: 0  max: 500 step: 1;
    
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


