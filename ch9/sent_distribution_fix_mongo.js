function range(start, stop, step){
  if (typeof stop=='undefined'){
      // one param defined
      stop = start;
      start = 0;
  };
  if (typeof step=='undefined'){
      step = 1;
  };
  if ((step>0 && start>=stop) || (step<0 && start<=stop)){
      return [];
  };
  var result = [];
  for (var i=start; step>0 ? i<stop : i>stop; i+=step){
      result.push(i);
  };
  return result;
};
        
// Get "00" - "23"
function makeHourRange(num) {
  return num < 10 ? "0" + num.toString() : num.toString();
}

function fillBlanks(rawData) {
  var hourRange = range(0,24);
  var ourData = Array();
  for (hour in hourRange)
  {
    var hourString = makeHourRange(hour);
    var found = false;
    for(x in rawData)
    {
      if(rawData[x]['sent_hour'] == hourString)
      {
        found = true;
        break;
      }
    }
    if(found == true)
    {
      ourData.push(rawData[x]);
    }
    else
    {
      ourData.push({'sent_hour': hourString, 'total': 0})
    }
  }
  return ourData;
}

use agile_data
data = sent_dist.findOne();
fillBlanks(data['sent_distribution']);
