/**
* Name: Mobility1
* Load maps
*
* Tags: 
*/


model Mobility1


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




experiment main type:gui
{
	output
	{
		display map type:opengl
		{
			species road 	aspect: basic	refresh:false;
			species mibici  aspect: basic	refresh: false;

		}
	}
}





