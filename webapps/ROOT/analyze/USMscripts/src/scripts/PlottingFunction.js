
//This function plots the analyzed data as a graph using jQPlot.
function plotGreenness() {
    //This test is used to determing if both the dates and the greenness are finished being analyzed.
    if (!test) {
        window.test = true;
        return;
    } else {
        window.test = false;
        //Hide all loading items, and display the graph.
        document.getElementById("loadicon").style.visibility = "hidden";
        document.getElementById("loadCounter").style.visibility = "hidden";
        $("#loadicon").removeClass("rotate");
        document.getElementById("chart2").style.visibility = "visible";
        document.getElementById("uldiv").style.visibility = "visible";

        $("#showLastButton").remove();
        
        //Adds the "Show Last Analysis" button.
        var showLastButton = document.createElement("input");
        showLastButton.setAttribute("type", "button");
        showLastButton.setAttribute("name", "button");
        showLastButton.setAttribute("value", "Show Last Analysis");
        showLastButton.setAttribute("id", "showLastButton");
        showLastButton.onclick = showLastAnalysis;
        document.getElementById("pictureInfoDiv").appendChild(showLastButton);

        //Parses the analyzed data into a format that jQPlot accepts.
        var data = new Array();
        var seriesNameArray = new Array();
        for (var j = 0; j < window.orientations.length; j++) {
            var orientation = window.orientations[j];
            if (window.lineArray[orientation][0][0] === null) {

            } else {
                for (var i = 0; i < window.lineArray[orientation].length; i++) {
                    window.lineArray[orientation][i] = [window.dateArray[orientation][i], window.lineArray[orientation][i]];
                }
                data.push(window.lineArray[window.orientations[j]]);
                seriesNameArray.push(orientation);
            }
        }

        $.jqplot.config.enablePlugins = true;
        var plot2 = $.jqplot('chart2', data, {

            // Give the plot a title.
            title: ('Greenness Index: Post ' + parseURLforPostID()),
            legend: {
                renderer: $.jqplot.EnhancedLegendRenderer,
                show: true
            },
            series: [{
                color: '#5FAB78',
                label: seriesNameArray[0]
            },
            {
                label: seriesNameArray[1]
            },
            {
                label: seriesNameArray[2]
            },
            {
                label: seriesNameArray[3]
            },
            {
                label: seriesNameArray[4]
            },
            {
                label: seriesNameArray[5]
            },
            {
                label: seriesNameArray[6]
            },
            {
                label: seriesNameArray[7]
            },
            {
                label: seriesNameArray[8]
            }],

            // You can specify options for all axes on the plot at once with
            // the axesDefaults object.  Here, we're using a canvas renderer
            // to draw the axis label which allows rotated text.
            axesDefaults: {
                labelRenderer: $.jqplot.CanvasAxisLabelRenderer
            },

            // An axes object holds options for all axes.
            // Allowable axes are xaxis, x2axis, yaxis, y2axis, y3axis, ...
            // Up to 9 y axes are supported.
            axes: {
                // options for each axis are specified in seperate option objects.
                xaxis: {
                    renderer: $.jqplot.DateAxisRenderer,
                    rendererOptions: {
                        tickRenderer: $.jqplot.CanvasAxisTickRenderer
                    },
                    tickOptions: {
                        formatString: '%b %#d, %Y',
                        angle: -30
                    },
                    // tickInterval: '1 month',
                    label: "Date",

                    // Turn off "padding".  This will allow data point to lie on the
                    // edges of the grid.  Default padding is 1.2 and will keep all
                    // points inside the bounds of the grid.
                    pad: 0
                },

                yaxis: {
                    label: "Greenness",
                    tickOptions: {
                        formatString: '%1.2f'
                    },

                    min: .25,
                    max: .65,
                    pad: .05
                }
            },

            highlighter: {
                show: true,
                sizeAdjust: 7.5,
                formatString: '<table class="jqplot-highlighter">' +
                '<tr><td>Date:</td><td>%s</td></tr>' +
                '<tr><td>Green:</td><td>%s</td></tr>',
                bringSeriesToFront: true
            },

            cursor: {
                show: true,
                tooltipLocation: 'nw'
            }

            /*
        
            */
        });

        plot2.replot();
    }
}

function createWindowArrays()
{ 
//building the associative array to store data for all of the lines
    var lineN = new Array();
    lineN = [[null]];
    var lineNE = new Array();
    lineNE = [[null]];
    var lineE = new Array();
    lineE = [[null]];
    var lineSE = new Array();
    lineSE = [[null]];
    var lineS = new Array();
    lineS = [[null]];
    var lineSW = new Array();
    lineSW = [[null]];
    var lineW = new Array();
    lineW = [[null]];
    var lineNW = new Array();
    lineNW = [[null]];
    var lineUP = new Array();
    lineUP = [[null]];
    window.lineArray = { N: lineN, NE: lineNE, E: lineE, SE: lineSE, S: lineS, SW: lineSW, W: lineW, NW: lineNW, UP: lineUP };

    //Builds the array that holds the orientations.
    window.orientations = new  Array();
    orientations[0] = "N";
    orientations[1] = "NE";
    orientations[2] = "E";
    orientations[3] = "SE";
    orientations[4] = "S";
    orientations[5] = "SW";
    orientations[6] = "W";
    orientations[7] = "NW";
    orientations[8] = "UP";

    //Builds the associative array that holds all of the dates.
    window.dateArray = { N: new Array(), NE: new Array(), E: new Array(), SE: new Array(), S: new Array(), SW: new Array(), W: new Array(), NW: new Array(), UP: new Array() };
}


