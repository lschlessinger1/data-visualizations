int backgroundColor = color(255, 255, 255);

String path = "data.csv";
String xName, yName;
String[] names;
int[] values;
HashMap<String, Integer> nameMap;
int defaultWidth = 1000;
int defaultHeight = 750;
int prevWidth = defaultWidth;
int prevHeight = defaultHeight;
int counter = 0;

float margin = 25;

// for now just save lines and cirlces
Line[] lineArr;
Line[] lineCopy;
Circle[] circles;
int BAR_CHART = 777;
int LINE_CHART = 778;
int PI_CHART = 779;
int currentChartType = BAR_CHART;

LineChart lineChart;
BarChart barChart;
Chart currentChart;

Bar[] barCopy;

ResponsiveButton lineButton;
ResponsiveButton barButton;

// not sure how to do enums in processing, so do this int program states instead...
int NOT_TRANSITIONING = 999;
// Transition from bar chart to line chart
int VERT_RECT_TRANSITION = 1000;
int HOR_RECT_TRANSITION = 1001;
int POINT_TRANSITION = 1002;
int CONNECT_POINTS_TRANSITION = 1003;

// Transition from line chart to bar chart
int REVERSE_VERT_RECT_TRANSITION = 1004;
int REVERSE_HOR_RECT_TRANSITION = 1005;
int REVERSE_POINT_TRANSITION = 1006;
int REVERSE_CONNECT_POINTS_TRANSITION = 1007;

int CURRENT_STATE = NOT_TRANSITIONING;
int numTransitionSteps = 100;

public void setup() {
  
  size(1000, 750);
  
  // Remove this line to post online for Processing.js compatibility
  surface.setResizable(true);

  loadStrings();
  
  barChart = new BarChart();
  // figure out how to initialize line chart
  saveBars();
  lineChart = new LineChart();
  
  // for now just save circles and lines
  //circles = new Circle[values.length];
  //lineArr = new Line[values.length - 1];
  currentChart = barChart;
  
  createButtons();
  
}

public void draw() {
  background(250);
  // TODO: 
  // Bar Chart
    // dynamic padding between bars (func of num bars and width)
  // add hovering for all charts
  if (width != prevWidth || height != prevHeight) {
    // window has been resized
    prevWidth = width;
    prevHeight = height;
    
    if (currentChartType == BAR_CHART) {
      barChart = new BarChart();
      lineChart = new LineChart();
      currentChart = barChart;
    } else if (currentChartType == LINE_CHART) {
      //barChart = new BarChart();
      lineChart = new LineChart();
      currentChart = lineChart;
    }
    // create new chart and window elements
    
    //currentChart = barChart;
    createButtons();
  }
  
  drawButtons();

  handleTransition();
  
  currentChart.drawSelf();
  
  handleTooltip();
  
  counter++;
}

public void mousePressed() {
  if (lineButton.hovered()) {
    toggleLineChart();
  } else if (barButton.hovered()) {
    toggleBarChart();
  }
}

public void handleTooltip() {
  if (currentChartType == BAR_CHART) {
    for (Bar bar: barChart.bars) {
      if (bar.hovered()) {
        String name = bar.label;
        float value = nameMap.get(name);
        showToolTip(name, value, mouseX, mouseY);
      }
    }
  } else if (currentChartType == LINE_CHART) {
    // also keep the same rect boundaries
    for (DataPoint point: lineChart.points) {
      if (point.hovered()) {
        String name = point.label;
        float value = nameMap.get(name);
        showToolTip(name, value, mouseX, mouseY);
      }
    }
  }
}

public void loadStrings() {
  String[] lines = loadStrings(path);
  String[] firstLine = split(lines[0], ",");
  xName = firstLine[0];
  yName = firstLine[1];
  names = new String[lines.length - 1];
  values = new int[lines.length - 1];
  nameMap = new HashMap(lines.length - 1);

  for (int i = 1; i < lines.length; i++) {
    String[] row = split(lines[i], ",");
    names[i - 1] = row[0];
    values[i - 1] = (int)parseFloat(row[1]);
    nameMap.put(names[i - 1], values[i - 1]);
  }
}

public void showToolTip(String name, float value, float x, float y) {
   fill(color(50,205,50));
   textSize(14);
   text("("+name + ", " + value+")", x, y);
}

public void createButtons() {
  float r = 0.1f;
  int yPad = 10;
  int xPad = 15;
  float x = width - (margin + width/4);
  float y = yPad + margin;
  float w =  width * r + xPad;
  float h =  height * r;
  lineButton = new ResponsiveButton(x, y, w, h,  "Line Chart");
  barButton = new ResponsiveButton(x - w - xPad, y, w, h,  "Bar Chart");
}

public void drawButtons() {
  lineButton.drawButton();
  barButton.drawButton();
}

public void toggleLineChart() {
  if (CURRENT_STATE == NOT_TRANSITIONING && currentChartType != LINE_CHART) {
    counter = 0;
    CURRENT_STATE = VERT_RECT_TRANSITION;
 
    // save initial bars
    saveBars();

  }
}

public void toggleBarChart() {
  if (CURRENT_STATE == NOT_TRANSITIONING && currentChartType != BAR_CHART) {
    counter = 0;
    CURRENT_STATE = REVERSE_CONNECT_POINTS_TRANSITION;
  }
}

public void saveBars() {
  barCopy = new Bar[barChart.bars.length];
  for (int i = 0; i < barChart.bars.length; i++) {
    Bar bar = barChart.bars[i];
    barCopy[i] = new Bar(bar.x, bar.y, bar.w, bar.h, bar.c, bar.label);
  }
}

public void handleTransition() {
  float size = 10;
  float hFinal = -size;
  float wFinal = size;
  float rFinal = wFinal;
  float rInit = size;
  if (CURRENT_STATE == VERT_RECT_TRANSITION) {
    if (counter <= numTransitionSteps) {
      verticalBarTransition(hFinal);
    } else if (counter > numTransitionSteps) {
      CURRENT_STATE = HOR_RECT_TRANSITION;
      counter = 0;
    }
  } else if (CURRENT_STATE == HOR_RECT_TRANSITION) {
    if (counter <= numTransitionSteps) {
      horizontalBarTransition(wFinal);
    } else if (counter > numTransitionSteps) {
      CURRENT_STATE = POINT_TRANSITION;
      counter = 0;
    }
  } else if (CURRENT_STATE == POINT_TRANSITION) {
    if (counter <= numTransitionSteps) {
      pointBarTransition(rFinal);
    } else if (counter > numTransitionSteps) {
      CURRENT_STATE = CONNECT_POINTS_TRANSITION;
      counter = 0;
    }
  } else if (CURRENT_STATE == CONNECT_POINTS_TRANSITION) {
    if (counter <= numTransitionSteps) {
      // create scatter plot
      connectPointsBarTransition();
    } else if (counter > numTransitionSteps) {
      CURRENT_STATE = NOT_TRANSITIONING;
      currentChartType = LINE_CHART;
      currentChart = lineChart;
      counter = 0;
    }
  } else if (CURRENT_STATE == REVERSE_CONNECT_POINTS_TRANSITION) {
    if (counter <= numTransitionSteps) {
      currentChartType = BAR_CHART;
      currentChart = barChart;
      disconnectPointsBarTransition();
    } else if (counter > numTransitionSteps) {
      CURRENT_STATE = REVERSE_POINT_TRANSITION;
      counter = 0;
    }
  } else if (CURRENT_STATE == REVERSE_POINT_TRANSITION) {
    if (counter <= numTransitionSteps) {
      barPointTransition(rInit);
    } else if (counter > numTransitionSteps) {
      CURRENT_STATE = REVERSE_HOR_RECT_TRANSITION;
      counter = 0;
    }
  } else if (CURRENT_STATE == REVERSE_HOR_RECT_TRANSITION) {
    if (counter <= numTransitionSteps) {
      reverseHorizontalBarTransition();
    } else if (counter > numTransitionSteps) {
      CURRENT_STATE = REVERSE_VERT_RECT_TRANSITION;
      counter = 0;
    }
  } else if (CURRENT_STATE == REVERSE_VERT_RECT_TRANSITION) {
    if (counter <= numTransitionSteps) {
      reverseVerticalBarTransition();
    } else if (counter > numTransitionSteps) {
      CURRENT_STATE = NOT_TRANSITIONING;
      currentChartType = BAR_CHART;
      counter = 0;
    }
  }
}

public void verticalBarTransition(float hFinal) {
  for (int i = 0; i < barChart.bars.length; i++) {
    Bar bar = barCopy[i];
    
    float yFinal = bar.y + bar.h;
    float y = lerp(bar.y, yFinal, counter/PApplet.parseFloat(numTransitionSteps));
    float h = lerp(bar.h, hFinal, counter/PApplet.parseFloat(numTransitionSteps));
    
    // update current bar
    Bar currBar = barChart.bars[i];
    currBar.y = y;
    currBar.h = h;
  }
}

public void horizontalBarTransition(float wFinal) {
  for (int i = 0; i < barChart.bars.length; i++) {
    Bar bar = barCopy[i];
    float center = (bar.x + bar.x + bar.w) / 2.0;
    //float x2 = bar.x + bar.w / 2;
    float x = lerp(bar.x, center - wFinal/2, counter/PApplet.parseFloat(numTransitionSteps));
    float w = lerp(bar.w, wFinal, counter/PApplet.parseFloat(numTransitionSteps));
    
    // update current bar
    Bar currBar = barChart.bars[i];
    currBar.x = x;
    currBar.w = w;
  }
}

public void pointBarTransition(float rFinal) {
  for (int i = 0; i < barChart.bars.length; i++) {
    Bar bar = barCopy[i];
    float r = lerp(bar.radius, rFinal, counter/PApplet.parseFloat(numTransitionSteps));
    
    // update current bar
    Bar currBar = barChart.bars[i];
    currBar.radius = r;
  }
}

public void connectPointsBarTransition() {
  int n = barChart.bars.length - 1;
  for (int i = 0; i < n; i++) {
    
    Bar bar = barChart.bars[i];
    Bar nextBar = barChart.bars[i + 1];
    
    float x = lerp(bar.x + bar.w/2, nextBar.x + nextBar.w/2, counter/PApplet.parseFloat(numTransitionSteps));
    float y = lerp(bar.y + bar.h/2, nextBar.y + nextBar.h/2, counter/PApplet.parseFloat(numTransitionSteps));
    Line line = lineChart.lines[i];
    line.x1 = bar.x + bar.w/2;
    line.y1 = bar.y +  bar.h/2;
    line.x2 = x;
    line.y2 = y;
    // also update the data points
    DataPoint point = lineChart.points[i];
    point.circle.x = line.x1;
    point.circle.y = line.y1;
    if (i == n - 1) {
      DataPoint lastPoint = lineChart.points[i + 1];
      lastPoint.circle.x = line.x2;
      lastPoint.circle.y = line.y2;
    }
    
    line.drawLine(2);
  }
}


public void disconnectPointsBarTransition() {
  for (int i = 0; i < lineChart.lines.length; i++) {
    Line line = lineChart.lines[i];
    if (line != null){
      float x = lerp(line.x2, line.x1, counter/PApplet.parseFloat(numTransitionSteps));
      float y = lerp(line.y2, line.y1, counter/PApplet.parseFloat(numTransitionSteps));
      Line currLine = lineChart.lines[i];
      //Line currLine = lineArr[i];
      currLine.x2 = x;
      currLine.y2 = y;
      currLine.drawLine(2);
     }
  }
}

public void barPointTransition(float rInit) {
  
  for (int i = 0; i < barChart.bars.length; i++) {
    //Bar bar = barCopy[i];
    //float r = lerp(bar.radius, 0, counter/float(numTransitionSteps));
    float r = lerp(rInit, 0, counter/PApplet.parseFloat(numTransitionSteps));
    // update current bar
    Bar currBar = barChart.bars[i];
    currBar.radius = r;
  }
}

public void reverseHorizontalBarTransition() {
  for (int i = 0; i < barChart.bars.length; i++) {
    Bar bar = barCopy[i];
    Bar currBar = barChart.bars[i];
    float x = lerp(currBar.x, bar.x, counter/PApplet.parseFloat(numTransitionSteps));
    float w = lerp(currBar.w, bar.w, counter/PApplet.parseFloat(numTransitionSteps));
    
    // update current bar
    
    currBar.x = x;
    currBar.w = w;
  }
}

public void reverseVerticalBarTransition() {
  for (int i = 0; i < barChart.bars.length; i++) {
    Bar bar = barCopy[i];
    Bar currBar = barChart.bars[i];
    float y = lerp(currBar.y, bar.y, counter/PApplet.parseFloat(numTransitionSteps));
    float h = lerp(currBar.h, bar.h, counter/PApplet.parseFloat(numTransitionSteps));
    
    // update current bar
    
    currBar.y = y;
    currBar.h = h;
  }
}

// The code below was revised based on Finn's button class posted on Piazza 1/19/18.
class ResponsiveButton {
  float x, y, w, h;
  int backgroundColor = color(92,184,92);
  int textColor = color(250);
  String text;
  
  ResponsiveButton(float x, float y, float w, float h, String text) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.text = text;
  }
  
  public void drawButton() {
    fill(backgroundColor);
    rect(x, y, w, h);
    
    fill(textColor);
    textSize(16);
    textAlign(CENTER);
    text(text, x + w/2, y + h/2);
  }
  
  public boolean hovered() {
    return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
  }
}

interface Drawable {
  public void drawSelf();
}

interface HasAxes {
  public void createAxes();
  public void setAxisTitles();
  public void setXAxisTicks(float tickWidth);
  public void setYAxisTicks(float tickWidth);
  public void drawAxes();
}

abstract class Chart implements Drawable, HasAxes {
  // 2 axes (tick marks, data labels, Axis label)
  // defined in terms of height and width of display
  float chartHeight, chartWidth, xShift, yShift, minValue, maxValue, maxAbsValue;
  Axis[] axes;
  boolean posValuesExist, negValuesExist;
  
  Chart() {
    
    chartHeight = height / 4;
    chartWidth = width / 4;
    
    // center shifts
    xShift = width / 2 - chartWidth / 2;
    yShift = height / 2 - chartHeight / 2;
    
    minValue = getMinValue(values);
    maxValue = getMaxValue(values);
    maxAbsValue = getMaxAbsValue(values);
    
    negValuesExist = minValue < 0;
    posValuesExist = maxValue > 0;
    
    if (negValuesExist && !posValuesExist) {
      yShift -= chartHeight / 2;
    }
  }
  
  public void drawTitle() {
    String title = xName + " vs. " + yName;
    textSize(24);
    int padding = -50;
    fill(0);
    text(title, xShift + chartWidth / 2, yShift + padding);
  }
  
  public float getMinValue(int[] a) {
    float minVal = Float.MAX_VALUE;
    for(int i = 0; i < a.length; i++) {
      int value = a[i];
      minVal = Math.min(value, minVal); 
    }
    return minVal;
  }
  
  public float getMaxValue(int[] a) {
    float maxVal = -Float.MAX_VALUE;
    for(int i = 0; i < a.length; i++) {
      int value = a[i];
      maxVal = Math.max(value, maxVal);     
    }
    return maxVal;
  }
  
  public float getMaxAbsValue(int [] a) {
    return max(abs(getMaxValue(a)), abs(getMinValue(a)));
  }
}

class LineChart extends Chart {
  DataPoint[] points;
  Line[] lines;
  
  LineChart() {
    DataPoint[] data = new DataPoint[values.length];
    float pointSpacing = chartWidth / PApplet.parseFloat(data.length);
    for (int i = 0; i < data.length; i++) {
      String name = names[i];
      float value = values[i];
      float size = 10;
      
      float x = margin + xShift + (i * pointSpacing);
      float sizeTerm = (x + x + pointSpacing) / 2.0;
      x =  sizeTerm - size/2;
      float pctValue;
      if (value >= 0)
        pctValue = value / maxAbsValue;
      else
        pctValue = value / maxAbsValue;
        
      float y = chartHeight + yShift - chartHeight * pctValue;
      
      int c = color(10, 125, 250);
      
      data[i] = new DataPoint(x, y, size, value, name, c);
    }
    points = data;
    lines = initializeLines(points);
    createAxes();
  }
  
  public Line[] initializeLines(DataPoint[] datapoints) {
    Line[] lineArr = new Line[datapoints.length - 1];
    
    for (int i = 0; i < lineArr.length; i++) {
      DataPoint point = datapoints[i];
      DataPoint nextPoint = datapoints[i + 1];
      float x1 = point.circle.x + point.circle.r/2;
      float x2 = nextPoint.circle.x + nextPoint.circle.r/2;
      float y1 = point.circle.y + point.circle.r/2;
      float y2 = nextPoint.circle.y + nextPoint.circle.r/2;
      Line line = new Line(x1, y1, x2, y2);
      lineArr[i] = line;
    }
    
    return lineArr;
  }
  
  public void createAxes() {

    axes = new Axis[2];
    // horizontal axis: all names 
    axes[0] = new Axis(xName, margin + xShift, chartHeight + yShift, margin + chartWidth + xShift, chartHeight + yShift);
    // if there are negative values, extend y axis down
    if (negValuesExist && posValuesExist) {
      chartHeight *= 2;
    }
    // vertical axis: all values (ages)
    axes[1] = new Axis(yName, margin + xShift, margin + yShift, margin + xShift, chartHeight + yShift);
    setAxisTitles();
    
    float tickWidth = 5;
    setXAxisTicks(tickWidth);
    setYAxisTicks(tickWidth);
  }

  public void setAxisTitles() {
    int axisTitlePad = 50;   
    axes[0].setTitlePos(xShift + chartWidth / 2, yShift + chartHeight + axisTitlePad);
    axes[1].setTitlePos(xShift - axisTitlePad, yShift + chartHeight / 2);
  }
  
  
  public void setXAxisTicks(float tickWidth) {
    // for data point, draw a tick mark on x axis and labels
    for (DataPoint point: points) {
      float x = point.circle.x + point.circle.r / 2;
      
      float hTerm = 0;
      if (negValuesExist) {
        hTerm = -chartHeight/2;
      }
      float y1 = hTerm + chartHeight + yShift - tickWidth;
      float y2 = hTerm + chartHeight + yShift + tickWidth;
      Line line = new Line(x, y1, x, y2);
      int tickLabelPad = 15;
      float fontSize = PApplet.parseInt(min(11, 6 * (width / PApplet.parseFloat(defaultWidth))));
      Tick tick = new Tick(point.label, line, tickLabelPad, fontSize);
      axes[0].addTick(tick);
    }
  }
  
  public void setYAxisTicks(float tickWidth) {
    float x1 = xShift - tickWidth + margin;
    float x2 = xShift + tickWidth + margin;
    float y1 = yShift + margin;
    float y2 = yShift + chartHeight;
    int numTicks = 10;
    
    for (int i = 0; i < numTicks + 1; i++) {
      float y = lerp(y1, y2, i/PApplet.parseFloat(numTicks));
      Line line = new Line(x1, y, x2, y);
      int reverseIndex = -1 * (i - numTicks);
      float lowerBound = negValuesExist ? -maxAbsValue : 0;
      float upperBound = posValuesExist ? maxAbsValue : 0;
      float val = lerp(lowerBound, upperBound, reverseIndex/PApplet.parseFloat(numTicks));
      String label = String.format("%." + 1 + "f", val);
      int tickLabelPad = -35;
      float fontSize = PApplet.parseInt(min(11, 6 * (height / PApplet.parseFloat(defaultHeight))));
      Tick tick = new Tick(label, line, tickLabelPad, fontSize);
      axes[0].addTick(tick);
    }
  }
  
  public void drawAxes() {
    for (Axis axis : axes) {
      axis.drawAxis();
    }
  }
  
  public void drawData() {
    for (DataPoint point: points) {
      point.drawPoint();
    }

    for (Line line: lines) {
      line.drawLine(2);
    }
  }
  
  public void drawSelf() {
    drawData();
    drawAxes();
    drawTitle();
  }
}

class BarChart extends Chart {
  int numBars;
  Bar[] bars;

  BarChart() {    
    numBars = getNumBars();
    createBars();
    createAxes();
  }

  public void createBars() {
    // same width and y for all bars
    float barWidth = chartWidth / numBars; // no padding for now
    float y = chartHeight + yShift;
    bars = new Bar[numBars];
  
    //int i = 0;
    for (int i = 0; i < values.length; i++) {
      String name = names[i];
      float value = values[i];
      //float value = nameMap.get(name);
      float pctValue;
      
      if (value >= 0)
        pctValue = value / maxAbsValue;
      else
        pctValue = value / maxAbsValue;
        
      float barHeight = chartHeight * pctValue * -1;
      int c = color(10, 125, 250);
      float x = i * barWidth + margin + xShift;
      bars[i] = new Bar(x, y, barWidth, barHeight, c, name);
      //i++;
    }
  }

  public void createAxes() {
    axes = new Axis[2];
    // horizontal axis: all names 
    axes[0] = new Axis(xName, margin + xShift, chartHeight + yShift, margin + chartWidth + xShift, chartHeight + yShift);
    // if there are negative values, extend y axis down
    if (negValuesExist && posValuesExist) {
      chartHeight *= 2;
    }
    // vertical axis: all values (ages)
    axes[1] = new Axis(yName, margin + xShift, margin + yShift, margin + xShift, chartHeight + yShift);
    
    setAxisTitles();
    
    float tickWidth = 5;
    setXAxisTicks(tickWidth);
    setYAxisTicks(tickWidth);
  }
  
  public void setAxisTitles() {
    int axisTitlePad = 50;   
    axes[0].setTitlePos(xShift + chartWidth / 2, yShift + chartHeight + axisTitlePad);
    axes[1].setTitlePos(xShift - axisTitlePad, yShift + chartHeight / 2);
  }
  
  public void setXAxisTicks(float tickWidth) {
    // for each bar, draw a tick mark on x axis and labels
    for (Bar bar: bars) {
      float x = bar.x + bar.w / 2;
      float y1 = bar.y - tickWidth;
      float y2 = bar.y + tickWidth;
      Line line = new Line(x, y1, x, y2);
      int tickLabelPad = 15;
      float fontSize = PApplet.parseInt(min(11, 6 * (width / PApplet.parseFloat(defaultWidth))));
      Tick tick = new Tick(bar.label, line, tickLabelPad, fontSize);
      axes[0].addTick(tick);
    }
  }
  
  public void setYAxisTicks(float tickWidth) {
    float x1 = xShift - tickWidth + margin;
    float x2 = xShift + tickWidth + margin;
    float y1 = yShift + margin;
    float y2 = yShift + chartHeight;
    int numTicks = 10;
    
    for (int i = 0; i < numTicks + 1; i++) {
      float y = lerp(y1, y2, i/PApplet.parseFloat(numTicks));
      Line line = new Line(x1, y, x2, y);
      int reverseIndex = -1 * (i - numTicks);
      float lowerBound = negValuesExist ? -maxAbsValue : 0;
      float upperBound = posValuesExist ? maxAbsValue : 0;
      float val = lerp(lowerBound, upperBound, reverseIndex/PApplet.parseFloat(numTicks));
      String label = String.format("%." + 1 + "f", val);
      int tickLabelPad = -35;
      float fontSize = PApplet.parseInt(min(11, 6 * (height / PApplet.parseFloat(defaultHeight))));
      Tick tick = new Tick(label, line, tickLabelPad, fontSize);
      axes[0].addTick(tick);
    }
  }
  
  public void drawAxes() {
    for (Axis axis : axes) {
      axis.drawAxis();
    }
  }
  
  public void drawBars() {
    for (Bar bar : bars) {
      bar.drawBar();
    }
  }
    
  public void drawSelf() {
    drawBars();
    drawAxes();
    drawTitle();
  }
  
  // helpers //    
  public int getNumBars() {
    return nameMap.size();
  }
 
}

class Bar {
  float x, y, w, h, radius;
  int c;
  String label;
  boolean hasStroke = true;

  Bar(float x, float y, float w, float h, int c, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
    this.label = label;
    this.radius = 0;
  }

  public void drawBar() {
    fill(c);
    if (hasStroke) {
      strokeWeight(1);
    } else {
      noStroke();
    }
    
    rect(x, y, w, h, radius);
  }
  
  public boolean hovered() {
    if (h > 0)
      return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
    else
      return (mouseX >= x && mouseX <= x + w && mouseY <= y && mouseY >= y + h);
    //return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
  }
  
  public String toString() {
    String coords = Float.toString(x) + "," + Float.toString(y) + "," + Float.toString(w) + "," + Float.toString(h);
    return "(x,y,w,h) = (" + coords + "), color: " + c + ", label: " + label;
  }
}

class Axis {
  String name;
  Line line;
  float titleX, titleY;
  ArrayList<Tick> ticks;
  float tickWidth;

  Axis(String name, float x_1, float y_1, float x_2, float y_2) {
    this.name = name;
    this.line = new Line(x_1, y_1, x_2, y_2);
    this.ticks = new ArrayList<Tick>();
    this.tickWidth = 5;
  }
  
  public void setTitlePos(float x, float y) {
    titleX = x;
    titleY = y;
  }
  
  public void setTickWidth(float tickWidth) {
    this.tickWidth = tickWidth;
  }
  
  public void addTick(Tick tick) {
    ticks.add(tick);
  }
  
  public void drawAxis() {
    line.drawLine(3);
    fill(10);
    textSize(16);
    text(name, titleX, titleY);
    drawTicks();
  }
  
  public void drawTicks() {
    for (Tick tick: ticks) {
      tick.drawTick();
    }
  }
}

class Tick {
  String label;
  Line line;
  float tickLabelPadding;
  float fontSize;
  
  Tick(String label, Line line, float tickLabelPadding, float fontSize) {
    this.label = label;
    this.line = line;
    this.tickLabelPadding = tickLabelPadding;
    this.fontSize = fontSize;
  }
  
  public void drawTick() { 
      textAlign(CENTER);
      textSize(this.fontSize);
      fill(75);
      // determine if line is vertical or horizontal
      float x, y;
      if (line.x1 == line.x2) {
        // x axis
        x = line.x1;
        y = line.y2 + tickLabelPadding;
        
      } else {
        // y axis
        x = line.x2 + tickLabelPadding;
        y = line.y1;
      }
      if (label.length() > 3) {
        label = label.substring(0, 3) + "...";
      }
      text(label, x, y);
      line.drawLine(3);
  }
}

class DataPoint {
  Circle circle;
  String label;
  float value;
  
  DataPoint(float x, float y, float size, float value, String label, int c) {
    this.circle = new Circle(x, y, size, c);
    this.value = value;
    this.label = label;
  }
  
  public void drawPoint() {
    this.circle.drawCircle();
  }
  
  
  public boolean hovered() {
    float r = circle.r;
    return (mouseX >= circle.x && mouseX <= circle.x + r && mouseY >= circle.y && mouseY <= circle.y + r);
  }
}

class Line {
  float x1, x2, y1, y2;

  Line(float x_1, float y_1, float x_2, float y_2) {
    this.x1 = x_1;
    this.y1 = y_1;
    this.x2 = x_2;
    this.y2 = y_2;
  }

  public void drawLine(int weight) {
    strokeWeight(weight); 
    line(x1, y1, x2, y2);
  }

  public String toString() {
    String coords = Float.toString(x1) + "," + Float.toString(y1) + "," + Float.toString(x2) + "," + Float.toString(y2);
    return "(x1,y1,x2,y2) = (" + coords + ")";
  }
}

class Circle {
  float x, y, r;
  int c;
  
  Circle(float x, float y, float r, int c) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.c = c;
  }
  
  public void drawCircle() {
    ellipseMode(CENTER);
    fill(c);
    //noStroke();
    ellipse(x, y, r, r);
  }

}