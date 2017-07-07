//UserLabels para ChartJs				 
				 var ths = document.getElementsByTagName('th');
				 var userLabels = [];
				 for(var i = 1; i < ths.length; i++){
					userLabels.push(ths[i].textContent);
				};
				console.log(userLabels);

				 //ClassLabels para ChartJs					 
				 var tbodies = document.getElementsByTagName("tbody");
				 var trs = tbodies[0].children;
				 //var tds = trs[0].children;
				 var classLabels = [];
				 for(var i = 0; i < trs.length; i++){
					classLabels.push(trs[i].children[0].textContent);
				};
				 console.log(classLabels);

				//UserValues(data) para ChartJs 
				var values = [];
				var userValues = [];
				for(var i = 1; i < ths.length; i++){
					for(var j = 0; j < classLabels.length; j++){
						values.push(trs[j].children[i].textContent);
					}
					userValues.push(values);
					values = [];
				};
				console.log(userValues);

				//Data para ChartJs
				//var data = userValues[0];
				//Datasets para ChartJs
				var datasets = [];
				for(var i = 0; i < userLabels.length; i++){
					datasets.push(
					{
						label: ths[i].textContent,
						fillColor: "rgba(220,220,220,0.5)",
						strokeColor: "rgba(220,220,220,0.8)",
						highlightFill: "rgba(220,220,220,0.75)",
                        highlightStroke: "rgba(220,220,220,1)",
						data: userValues[i]
					})
				};
				console.log(datasets);

				//var label = [];				
				var labels = classLabels;
				var options = {responsive:true};
				var data = {
					labels,
                    datasets
                };

				window.onload = function(){
                    var ctx = document.getElementById("GraficoBarra").getContext("2d");
                    var BarChart = new Chart(ctx).Bar(data, options);
                }; 