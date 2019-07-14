Genders = {
    male : 1 << 0,
    female : 1 << 1
}

function copyTextToClipboard(text) {
  var textArea = document.createElement("textarea");

  // Place in top-left corner of screen regardless of scroll position.
  textArea.style.position = 'fixed';
  textArea.style.top = 0;
  textArea.style.left = 0;

  // Ensure it has a small width and height. Setting to 1px / 1em
  // doesn't work as this gives a negative w/h on some browsers.
  textArea.style.width = '2em';
  textArea.style.height = '2em';

  // We don't need padding, reducing the size if it does flash render.
  textArea.style.padding = 0;

  // Clean up any borders.
  textArea.style.border = 'none';
  textArea.style.outline = 'none';
  textArea.style.boxShadow = 'none';

  // Avoid flash of white box if rendered for any reason.
  textArea.style.background = 'transparent';


  textArea.value = text;

  document.body.appendChild(textArea);

  textArea.select();
  var successful = false;
  try {
    successful = document.execCommand('copy');
    var msg = successful ? 'successful' : 'unsuccessful';
    console.log('Copying text command was ' + msg);
  } catch (err) {
    console.log('Oops, unable to copy');
  }

  document.body.removeChild(textArea);
  return successful;
}

Handlebars.getTemplate = function(name) {
  if (Handlebars.templates === undefined || Handlebars.templates[name] === undefined) {
    $.ajax({
      url : 'handlebarstemplates/' + name + '.handlebars',
      success : function(data) {
        if (Handlebars.templates === undefined) {
          Handlebars.templates = {};
        }
        Handlebars.templates[name] = Handlebars.compile(data);
      },
      async : false
    });
  }
  return Handlebars.templates[name];
};

Handlebars.registerHelper('json', function(context) {
    return JSON.stringify(context);
});

Handlebars.registerHelper("truncate", function(str, length) {
  if(str){
  	if(str.length > length){
  		return str.substring(0,length) + "...";
  	}
  }
  return str;
});

Handlebars.registerHelper("formatDate", function(datetime) {
  if(datetime){
  	var date = new Date(datetime*1000);
  	return date.getFullYear() + "-" + date.getMonth() + "-" + date.getDate();
  }else{
  	return "-";
  }
});

Handlebars.registerHelper("formatDateTime", function(datetime, type) {
  var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
];
  if(datetime){
  	var date = new Date(datetime);
    if(type == "short"){
      return date.getDate()+" "+monthNames[date.getMonth()]+" "+date.getFullYear();
    }
    /*}else if(type == "long"){
      return date.getDate()+" "+monthNames[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes()+":"+date.getSeconds();
    }*/
  	return date.toUTCString();
  }else{
  	return "-";
  }
});

Handlebars.registerHelper("formatGender", function(gender) {
  if(gender){
  	if(gender == Genders.male){
		return "Male";
  	}else if(gender == Genders.female){
  		return "Female";
  	}
  }
  return "-";
});

Handlebars.registerHelper("formatInterestedIn", function(intIn) {
  if(intIn){
  	var interestedIn = [];
  	if((intIn & Genders.male) != 0 ){
		interestedIn.push("Men");
  	}
  	if((intIn & Genders.female) != 0){
  		interestedIn.push("Women");
  	}
  	return interestedIn.length > 0 ? interestedIn.join(" & ") : "-";
  }
  return "-";
});

Handlebars.registerHelper("ageFromDate", function(date) {
  if(date){
    var today = new Date();
    var birthDate = new Date(date*1000);
    var age = today.getFullYear() - birthDate.getFullYear();
    var m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
        age--;
    }
    return age;
  }
  return "-";
});

Handlebars.registerHelper("ifEq", function(firstOption, secondOption, options){
  if(firstOption == secondOption){
    return options.fn(this);
  }else{
    return options.inverse(this);
  }
});

Handlebars.registerHelper("ifCachedImage", function(ref){
  if(imageRefCache[ref]){
    return true
  }
  return false;
});

Handlebars.registerHelper("cachedImage", function(ref){
  if(imageRefCache[ref]){
    return imageRefCache[ref];
  }
  return '';
});

Handlebars.registerPartial("chatrow", Handlebars.getTemplate("chatrow"));
Handlebars.registerPartial('userimage', Handlebars.getTemplate("userimage"))