  $('select').change(set_formats);

  function set_formats(){
    // get the module name of which we speak
    var mn = $("#report_module_name").val();

    // if there is no module name, then do nothing
    if (!mn || mn === 'getFormats') {
      return;
    }

    // trigger a call to the controller
    $.ajax({
      url: '/reports/getFormats/' + mn, type: 'get', dataType: 'html',
      processData: false,
      success: function(data) {
        if (data == "record_not_found") {
          alert("Record not found");
        }
	else if (data == "error") {
          alert("Error");
        }
        else {
	  // parse the string into key:value pairs to set the appropriate format
	  var eqs = data.split('~');
	  var ec = eqs.length;
	  for (var i = 0; i < ec; i++) {
	    var tuple = eqs[i].split(':');
	    var tag = tuple[0];
	    var val = true;
	    if (tuple[1] == 'true') {
	      val = false;
	    }
	    if (tag === 'pdf') {
              $("#format_pdf").prop("disabled",val);
	    }
	    if (tag === 'csv') {
              $("#format_csv").prop("disabled",val);
	    }
	    if (tag === 'html') {
              $("#format_html").prop("disabled",val);
	    }
	  }

	  // force the browser to redraw the controls in question
          $("#format_pdf").prop("checked",false).checkboxradio('refresh');
          $("#format_csv").prop("checked",false).checkboxradio('refresh');
          $("#format_html").prop("checked",false).checkboxradio('refresh');
        } // there was data from the query
      } // anonymous function
    }); // ajax call
  } // set_formats()

  function validate_form(){
    // our return code: assume the best
    var rc = true; 

    // get the module name of which we speak
    var mn = $("#report_module_name").val();

    // do we have a valid module name?
    if (mn && mn !== '-- choose') {
      ;
    } else {
      rc = false;
      alert('Please choose a report module first');
    }

    // do we have a valid format?
    if ($("#report_format_pdf").prop("checked")) {
      ;
    } else if ($("#report_format_csv").prop("checked")) {
      ;
    } else if ($("#report_format_html").prop("checked")) {
      ;
    } else {
      rc = false;
      alert('Please choose a report output format first');
    }

    return rc;
  }
/* eof */
