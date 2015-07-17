namespace("kivi", function(ns) {
  ns._locale = {};
  ns._date_format   = {
    sep: '.',
    y:   2,
    m:   1,
    d:   0
  };
  ns._number_format = {
    decimalSep:  ',',
    thousandSep: '.'
  };

  ns.setup_formats = function(params) {
    var res = (params.dates || "").match(/^([ymd]+)([^a-z])([ymd]+)[^a-z]([ymd]+)$/);
    if (res) {
      ns._date_format                      = { sep: res[2] };
      ns._date_format[res[1].substr(0, 1)] = 0;
      ns._date_format[res[3].substr(0, 1)] = 1;
      ns._date_format[res[4].substr(0, 1)] = 2;
    }

    res = (params.numbers || "").match(/^\d*([^\d]?)\d+([^\d])\d+$/);
    if (res)
      ns._number_format = {
        decimalSep:  res[2],
        thousandSep: res[1]
      };
  };

  ns.parse_date = function(date) {
    var parts = date.replace(/\s+/g, "").split(ns._date_format.sep);
    date     = new Date(
      ((parts[ ns._date_format.y ] || 0) * 1) || (new Date).getFullYear(),
       (parts[ ns._date_format.m ] || 0) * 1 - 1, // Months are 0-based.
       (parts[ ns._date_format.d ] || 0) * 1
    );

    return isNaN(date.getTime()) ? undefined : date;
  };

  ns.format_date = function(date) {
    if (isNaN(date.getTime()))
      return undefined;

    var parts = [ "", "", "" ]
    parts[ ns._date_format.y ] = date.getFullYear();
    parts[ ns._date_format.m ] = (date.getMonth() <  9 ? "0" : "") + (date.getMonth() + 1); // Months are 0-based, but days are 1-based.
    parts[ ns._date_format.d ] = (date.getDate()  < 10 ? "0" : "") + date.getDate();
    return parts.join(ns._date_format.sep);
  };

  ns.parse_amount = function(amount) {
    if ((amount == undefined) || (amount == ''))
      return 0;

    if (ns._number_format.decimalSep == ',')
      amount = amount.replace(/\./g, "").replace(/,/g, ".");

    amount = amount.replace(/[\',]/g, "")

    return eval(amount);
  };

  ns.round_amount = function(amount, places) {
    var neg  = amount >= 0 ? 1 : -1;
    var mult = Math.pow(10, places + 1);
    var temp = Math.abs(amount) * mult;
    var diff = Math.abs(1 - temp + Math.floor(temp));
    temp     = Math.floor(temp) + (diff <= 0.00001 ? 1 : 0);
    var dec  = temp % 10;
    temp    += dec >= 5 ? 10 - dec: dec * -1;

    return neg * temp / mult;
  };

  ns.format_amount = function(amount, places) {
    amount = amount || 0;

    if ((places != undefined) && (places >= 0))
      amount = ns.round_amount(amount, Math.abs(places));

    var parts = ("" + Math.abs(amount)).split(/\./);
    var intg  = parts[0];
    var dec   = parts.length > 1 ? parts[1] : "";
    var sign  = amount  < 0      ? "-"      : "";

    if (places != undefined) {
      while (dec.length < Math.abs(places))
        dec += "0";

      if ((places > 0) && (dec.length > Math.abs(places)))
        dec = d.substr(0, places);
    }

    if ((ns._number_format.thousandSep != "") && (intg.length > 3)) {
      var len   = ((intg.length + 2) % 3) + 1,
          start = len,
          res   = intg.substr(0, len);
      while (start < intg.length) {
        res   += ns._number_format.thousandSep + intg.substr(start, 3);
        start += 3;
      }

      intg = res;
    }

    var sep = (places != 0) && (dec != "") ? ns._number_format.decimalSep : "";

    return sign + intg + sep + dec;
  };

  ns.t8 = function(text, params) {
    var text = ns._locale[text] || text;

    if( Object.prototype.toString.call( params ) === '[object Array]' ) {
      var len = params.length;

      for(var i=0; i<len; ++i) {
        var key = i + 1;
        var value = params[i];
        text = text.split("#"+ key).join(value);
      }
    }
    else if( typeof params == 'object' ) {
      for(var key in params) {
        var value = params[key];
        text = text.split("#{"+ key +"}").join(value);
      }
    }

    return text;
  };

  ns.setupLocale = function(locale) {
    ns._locale = locale;
  };

  ns.set_focus = function(element) {
    var $e = $(element).eq(0);
    if ($e.data('ckeditorInstance'))
      ns.focus_ckeditor_when_ready($e);
    else
      $e.focus();
  };

  ns.focus_ckeditor_when_ready = function(element) {
    $(element).ckeditor(function() { ns.focus_ckeditor(element); });
  };

  ns.focus_ckeditor = function(element) {
    var editor   = $(element).ckeditorGet();
		var editable = editor.editable();

		if (editable.is('textarea')) {
			var textarea = editable.$;

			if (CKEDITOR.env.ie)
				textarea.createTextRange().execCommand('SelectAll');
			else {
				textarea.selectionStart = 0;
				textarea.selectionEnd   = textarea.value.length;
			}

			textarea.focus();

		} else {
			if (editable.is('body'))
				editor.document.$.execCommand('SelectAll', false, null);

			else {
				var range = editor.createRange();
				range.selectNodeContents(editable);
				range.select();
			}

			editor.forceNextSelectionCheck();
			editor.selectionChange();

      editor.focus();
		}
  };

  ns.init_tabwidget = function(element) {
    var $element   = $(element);
    var tabsParams = {};
    var elementId  = $element.attr('id');

    if (elementId) {
      var cookieName      = 'jquery_ui_tab_'+ elementId;
      tabsParams.active   = $.cookie(cookieName);
      tabsParams.activate = function(event, ui) {
        var i = ui.newTab.parent().children().index(ui.newTab);
        $.cookie(cookieName, i);
      };
    }

    $element.tabs(tabsParams);
  };

  ns.init_text_editor = function(element) {
    var layouts = {
      all:     [ [ 'Bold', 'Italic', 'Underline', 'Strike', '-', 'Subscript', 'Superscript' ], [ 'BulletedList', 'NumberedList' ], [ 'RemoveFormat' ] ],
      default: [ [ 'Bold', 'Italic', 'Underline', 'Strike', '-', 'Subscript', 'Superscript' ], [ 'BulletedList', 'NumberedList' ], [ 'RemoveFormat' ] ]
    };

    var $e      = $(element);
    var buttons = layouts[ $e.data('texteditor-layout') || 'default' ] || layouts['default'];
    var config  = {
      entities:      false,
      language:      'de',
      removePlugins: 'resize',
      toolbar:       buttons
    }

    var style = $e.prop('style');
    $(['width', 'height']).each(function(idx, prop) {
      var matches = (style[prop] || '').match(/(\d+)px/);
      if (matches && (matches.length > 1))
        config[prop] = matches[1];
    });

    $e.ckeditor(config);

    if ($e.hasClass('texteditor-autofocus'))
      $e.ckeditor(function() { ns.focus_ckeditor($e); });
  };

  ns.reinit_widgets = function() {
    ns.run_once_for('.datepicker', 'datepicker', function(elt) {
      $(elt).datepicker();
    });

    if (ns.PartPicker)
      ns.run_once_for('input.part_autocomplete', 'part_picker', function(elt) {
        kivi.PartPicker($(elt));
      });

    if (ns.CustomerVendorPicker)
      ns.run_once_for('input.customer_vendor_autocomplete', 'customer_vendor_picker', function(elt) {
        kivi.CustomerVendorPicker($(elt));
      });

    if (ns.ChartPicker)
      ns.run_once_for('input.chart_autocomplete', 'chart_picker', function(elt) {
        kivi.ChartPicker($(elt));
      });


    var func = kivi.get_function_by_name('local_reinit_widgets');
    if (func)
      func();

    ns.run_once_for('.tooltipster', 'tooltipster', function(elt) {
      $(elt).tooltipster({
        contentAsHTML: false,
        theme: 'tooltipster-light'
      })
    });

    ns.run_once_for('.tooltipster-html', 'tooltipster-html', function(elt) {
      $(elt).tooltipster({
        contentAsHTML: true,
        theme: 'tooltipster-light'
      })
    });

    ns.run_once_for('.tabwidget', 'tabwidget', kivi.init_tabwidget);
    ns.run_once_for('.texteditor', 'texteditor', kivi.init_text_editor);
  };

  ns.submit_ajax_form = function(url, form_selector, additional_data) {
    $(form_selector).ajaxSubmit({
      url:     url,
      data:    additional_data,
      success: ns.eval_json_result
    });

    return true;
  };

  // Return a function object by its name (a string). Works both with
  // global functions (e.g. "check_right_date_format") and those in
  // namespaces (e.g. "kivi.t8").
  // Returns null if the object is not found.
  ns.get_function_by_name = function(name) {
    var parts = name.match("(.+)\\.([^\\.]+)$");
    if (!parts)
      return window[name];
    return namespace(parts[1])[ parts[2] ];
  };

  // Open a modal jQuery UI popup dialog. The content can be either
  // loaded via AJAX (if the parameter 'url' is given) or simply
  // displayed if it exists in the DOM already (referenced via
  // 'id') or given via param.html. If an existing DOM div should be used then
  // the element won't be removed upon closing the dialog which allows
  // re-opening it later on.
  //
  // Parameters:
  // - id: dialog DIV ID (optional; defaults to 'jqueryui_popup_dialog')
  // - url, data, type: passed as the first three arguments to the $.ajax() call if an AJAX call is made, otherwise ignored.
  // - dialog: an optional object of options passed to the $.dialog() call
  ns.popup_dialog = function(params) {
    var dialog;

    params            = params        || { };
    var id            = params.id     || 'jqueryui_popup_dialog';
    var dialog_params = $.extend(
      { // kivitendo default parameters:
          width:  800
        , height: 500
        , modal:  true
      },
        // User supplied options:
      params.dialog || { },
      { // Options that must not be changed:
        close: function(event, ui) { if (params.url || params.html) dialog.remove(); else dialog.dialog('close'); }
      });

    if (!params.url && !params.html) {
      // Use existing DOM element and show it. No AJAX call.
      dialog =
        $('#' + id)
        .bind('dialogopen', function() {
          ns.run_once_for('.texteditor-in-dialog,.texteditor-dialog', 'texteditor', kivi.init_text_editor);
        })
        .dialog(dialog_params);
      return true;
    }

    $('#' + id).remove();

    dialog = $('<div style="display:none" class="loading" id="' + id + '"></div>').appendTo('body');
    dialog.dialog(dialog_params);

    if (params.html) {
      dialog.html(params.html);
    } else {
      // no html? get it via ajax
      $.ajax({
        url:     params.url,
        data:    params.data,
        type:    params.type,
        success: function(new_html) {
          dialog.html(new_html);
          dialog.removeClass('loading');
        }
      });
    }

    return true;
  };

  // Run code only once for each matched element
  //
  // This allows running the function 'code' exactly once for each
  // element that matches 'selector'. This is achieved by storing the
  // state with jQuery's 'data' function. The 'identification' is
  // required for differentiating unambiguously so that different code
  // functions can still be run on the same elements.
  //
  // 'code' can be either a function or the name of one. It must
  // resolve to a function that receives the jQueryfied element as its
  // sole argument.
  //
  // Returns nothing.
  ns.run_once_for = function(selector, identification, code) {
    var attr_name = 'data-run-once-for-' + identification.toLowerCase().replace(/[^a-z]+/g, '-');
    var fn        = typeof code === 'function' ? code : ns.get_function_by_name(code);
    if (!fn) {
      console.error('kivi.run_once_for(..., "' + code + '"): No function by that name found');
      return;
    }

    $(selector).filter(function() { return $(this).data(attr_name) != true; }).each(function(idx, elt) {
      var $elt = $(elt);
      $elt.data(attr_name, true);
      fn($elt);
    });
  };

  // Run a function by its name passing it some arguments
  //
  // This is a function useful mainly for the ClientJS functionality.
  // It finds a function by its name and then executes it on an empty
  // object passing the elements in 'args' (an array) as the function
  // parameters retuning its result.
  //
  // Logs an error to the console and returns 'undefined' if the
  // function cannot be found.
  ns.run = function(function_name, args) {
    var fn = ns.get_function_by_name(function_name);
    if (fn)
      return fn.apply({}, args);

    console.error('kivi.run("' + function_name + '"): No function by that name found');
    return undefined;
  };
});

kivi = namespace('kivi');
