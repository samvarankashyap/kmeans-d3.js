<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
<style>
.chart {

}

.main text {
    font: 10px sans-serif;	
}

.axis line, .axis path {
    shape-rendering: crispEdges;
    stroke: black;
    fill: none;
}

circle {
    fill: steelblue;
}

</style>
    
 <script type="text/javascript" src="/static/d3.v2.js"></script>
	
<script>


$( document ).ready(function() {
    $("#cluster_image").hide()
    $("#caption").hide()
    console.log( "ready!" );
               $( "#show" ).click(function() {
                        var postObj = {};
                        $("#error").html("");
                        postObj["x_param"] = $( "#x_param" ).val();
                        postObj["y_param"] = $( "#y_param" ).val();
                        postObj["noofclusters"] = $( "#noofclusters" ).val();
                        var intRegex = /^\d+$/;
                        var str = $('#noofclusters').val();
                        if(intRegex.test(str)){
                        console.log(postObj);
               			$.post("/clusterimage",postObj,
    				function(data, status){
                                	//$("#content").text(data);
                                        console.log(data);
                                        var res = data.split("#");
                                        $("#cluster_image").attr("src", "/static/"+res[0])
                                        $("#cluster_image").show()
                                        $("#caption").show()
                                        $("#error").html(res[1]);
               			});
                        }
                        else{
                         $("#error").html("Number of clusters invalid")
                         }
		});
               $( "#scatter" ).click(function() {
                      console.log("this is scatter ");
                      var postObj = {};
                        $("#error").html("");
                        postObj["x_param"] = $( "#x_param1" ).val();
                        postObj["y_param"] = $( "#y_param1" ).val();
                        $.post("/scatterplot",postObj,
                                function(data, status){
                                        //$("#content").text(data);
                                        console.log(data);
                                        //var data = [[5,3], [10,17], [15,4], [2,8]];
   					var data = JSON.parse(data);
    					var margin = {top: 20, right: 15, bottom: 60, left: 60}
      					, width = 960 - margin.left - margin.right
      					, height = 500 - margin.top - margin.bottom;
    
    			var x = d3.scale.linear()
              .domain([0, d3.max(data, function(d) { return d[0]; })])
              .range([ 0, width ]);
    
    var y = d3.scale.linear()
    	      .domain([0, d3.max(data, function(d) { return d[1]; })])
    	      .range([ height, 0 ]);
 
    var chart = d3.select('div')
	.append('svg:svg')
	.attr('width', width + margin.right + margin.left)
	.attr('height', height + margin.top + margin.bottom)
	.attr('class', 'chart')

    var main = chart.append('g')
	.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
	.attr('width', width)
	.attr('height', height)
	.attr('class', 'main')   
        
    // draw the x axis
    var xAxis = d3.svg.axis()
	.scale(x)
	.orient('bottom');

    main.append('g')
	.attr('transform', 'translate(0,' + height + ')')
	.attr('class', 'main axis date')
	.call(xAxis);

    // draw the y axis
    var yAxis = d3.svg.axis()
	.scale(y)
	.orient('left');

    main.append('g')
	.attr('transform', 'translate(0,0)')
	.attr('class', 'main axis date')
	.call(yAxis);

    var g = main.append("svg:g"); 
    
    g.selectAll("scatter-dots")
      .data(data)
      .enter().append("svg:circle")
          .attr("cx", function (d,i) { return x(d[0]); } )
          .attr("cy", function (d) { return y(d[1]); } )
          .attr("r", 8);
        });
                                });

               $( "#bar" ).click(function() {
                      console.log("this is bar ");
                      var postObj = {};
                        $("#error").html("");
                        postObj["x_param"] = $( "#x_param2" ).val();
                        postObj["y_param"] = $( "#y_param2" ).val();
                        $.post("/bargraph",postObj,
                                function(data, status){
                                        //$("#content").text(data);
                                        console.log(data);
					  var dataset = JSON.parse(data);

                                       var w = 1500;
        var h = 500;
        //var dataset = [ { key: 0, value: 5 },{ key: 1, value: 10 },{ key: 2, value: 13 },{ key: 3, value: 19 },{ key: 4, value: 21 },{ key: 5, value: 25 },{ key: 6, value: 22 },{ key: 7, value: 18 },{ key: 8, value: 15 },{ key: 9, value: 13 },{ key: 10, value: 11 },{ key: 11, value: 12 },{ key: 12, value: 15 },{ key: 13, value: 20 },{ key: 14, value: 18 },{ key: 15, value: 17 },{ key: 16, value: 16 },{ key: 17, value: 18 },{ key: 18, value: 23 },{ key: 19, value: 25 } ];

var xScale = d3.scale.ordinal()
				.domain(d3.range(dataset.length))
				.rangeRoundBands([0, w], 0.10); 

var yScale = d3.scale.linear()
				.domain([0, d3.max(dataset, function(d) {return d.value;})])
				.range([0, h]);

var key = function(d) {
	return d.key;
};

//Create SVG element
var svg = d3.select("div")
			.append("svg")
			.attr("width", w)
			.attr("height", h);

//Create bars
svg.selectAll("rect")
   .data(dataset, key)
   .enter()
   .append("rect")
   .attr("x", function(d, i) {
		return xScale(i);
   })
   .attr("y", function(d) {
		return h - yScale(d.value);
   })
   .attr("width", xScale.rangeBand())
   .attr("height", function(d) {
		return yScale(d.value);
   })
   .attr("fill", function(d) {
		return "rgb(0, 0, " + (d.value * 10) + ")";
   })

	//Tooltip
	.on("mouseover", function(d) {
		//Get this bar's x/y values, then augment for the tooltip
		var xPosition = parseFloat(d3.select(this).attr("x")) + xScale.rangeBand() / 2;
		var yPosition = parseFloat(d3.select(this).attr("y")) + 14;
		
		//Update Tooltip Position & value
		d3.select("#tooltip")
			.style("left", xPosition + "px")
			.style("top", yPosition + "px")
			.select("#value")
			.text(d.value);
		d3.select("#tooltip").classed("hidden", false)
	})
	.on("mouseout", function() {
		//Remove the tooltip
		d3.select("#tooltip").classed("hidden", true);
	})	;

//Create labels
svg.selectAll("text")
   .data(dataset, key)
   .enter()
   .append("text")
   .text(function(d) {
		return d.value;
   })
   .attr("text-anchor", "middle")
   .attr("x", function(d, i) {
		return xScale(i) + xScale.rangeBand() / 2;
   })
   .attr("y", function(d) {
		return h - yScale(d.value) + 14;
   })
   .attr("font-family", "sans-serif") 
   .attr("font-size", "11px")
   .attr("fill", "white");
   
var sortOrder = false;
var sortBars = function () {
    sortOrder = !sortOrder;
    
    sortItems = function (a, b) {
        if (sortOrder) {
            return a.value - b.value;
        }
        return b.value - a.value;
    };

    svg.selectAll("rect")
        .sort(sortItems)
        .transition()
        .delay(function (d, i) {
        return i * 50;
    })
        .duration(1000)
        .attr("x", function (d, i) {
        return xScale(i);
    });

    svg.selectAll('text')
        .sort(sortItems)
        .transition()
        .delay(function (d, i) {
        return i * 50;
    })
        .duration(1000)
        .text(function (d) {
        return d.value;
    })
        .attr("text-anchor", "middle")
        .attr("x", function (d, i) {
        return xScale(i) + xScale.rangeBand() / 2;
    })
        .attr("y", function (d) {
        return h - yScale(d.value) + 14;
    });
};
// Add the onclick callback to the button
d3.select("#sort").on("click", sortBars);
d3.select("#reset").on("click", reset);
function randomSort() {
	svg.selectAll("rect")
        .sort(sortItems)
        .transition()
        .delay(function (d, i) {
        return i * 50;
    })
        .duration(1000)
        .attr("x", function (d, i) {
        return xScale(i);
    });

    svg.selectAll('text')
        .sort(sortItems)
        .transition()
        .delay(function (d, i) {
        return i * 50;
    })
        .duration(1000)
        .text(function (d) {
        return d.value;
    })
        .attr("text-anchor", "middle")
        .attr("x", function (d, i) {
        return xScale(i) + xScale.rangeBand() / 2;
    })
        .attr("y", function (d) {
        return h - yScale(d.value) + 14;
    });
}
function reset() {
	svg.selectAll("rect")
		.sort(function(a, b){
			return a.key - b.key;
		})
		.transition()
        .delay(function (d, i) {
        return i * 50;
		})
        .duration(1000)
        .attr("x", function (d, i) {
        return xScale(i);
		});
		
	svg.selectAll('text')
        .sort(function(a, b){
			return a.key - b.key;
		})
        .transition()
        .delay(function (d, i) {
        return i * 50;
    })
        .duration(1000)
        .text(function (d) {
        return d.value;
    })
        .attr("text-anchor", "middle")
        .attr("x", function (d, i) {
        return xScale(i) + xScale.rangeBand() / 2;
    })
        .attr("y", function (d) {
        return h - yScale(d.value) + 14;
    });
};

                                        
                                });

                });

});
</script>

</head>

<body>

<!--
field_names = ['Report No.','Report Date','Sent to Manufacturer / Importer / Private Labeler','Publication Date','Category of Submitter','Product Description','Product Category','Product Sub Category','Product Type','Product Code','Manufacturer / Importer / Private Labeler Name','Brand','Model Name or Number','Serial Number','UPC','Date Manufactured','Manufacturer Date Code','Retailer','Retailer State','Purchase Date','Purchase Date Is Estimate','Incident Description','City','State','ZIP','Location','(Primary) Victim Severity','(Primary) Victims Gender','My Relation To The (Primary) Victim','(Primary) Victims Age (years)','Submitter Has Product','Product Was Damaged Before Incident','Damage Description','Damage Repaired','Product Was Modified Before Incident','Have You Contacted The Manufacturer','If Not Do You Plan To','Answer Explanation','Company Comments','Associated Report Numbers']
-->
<br>
<img id="cluster_image" src='' ></img>
<h2 id="caption">No.of X axis vs No.of Y axis<h2>

<select id="x_param">
<option value='LINE_NUMBER'>linenum</option>
<option value='ESTIMATE'>Estimate</option>
<option value='MARGIN_OF_ERROR'>MariginofError</option>
</select>

<select id="y_param">
<option value='LINE_NUMBER'>linenum</option>
<option value='ESTIMATE'>Estimate</option>
<option value='MARGIN_OF_ERROR'>MariginofError</option>
</select>

<input type="text" id="noofclusters">
<br>
<br>
<input type="button" id="show" value="cluster">
<br>
<h2>Plot a scatter plot </h2>
<select id="x_param1">
<option value='LINE_NUMBER'>linenum</option>
<option value='ESTIMATE'>Estimate</option>
<option value='MARGIN_OF_ERROR'>MariginofError</option>
</select>
<br>
<select id="y_param1">
<option value='LINE_NUMBER'>linenum</option>
<option value='ESTIMATE'>Estimate</option>
<option value='MARGIN_OF_ERROR'>MariginofError</option>
</select>
<br>
<input type="button" id="scatter" value="scatter">

<h2>Plot a bar graph </h2>

<select id="x_param2">
<option value='LINE_NUMBER'>linenum</option>
<option value='ESTIMATE'>Estimate</option>
<option value='MARGIN_OF_ERROR'>MariginofError</option>
</select>
<br>
<select id="y_param2">
<option value='LINE_NUMBER'>linenum</option>
<option value='ESTIMATE'>Estimate</option>
<option value='MARGIN_OF_ERROR'>MariginofError</option>
</select>
<br>
<input type="button" id="bar" value="barplot">
<input type="button" id="sort" value="sort">
<input type="button" id="reset" value="reset">
<br>
<div id="error"></div>
</body>
</html>
