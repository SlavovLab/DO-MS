// execute function when jquery is ready and good to go
$(document).ready(function() {
  console.log('ready!');
  // $('body').addClass('fixed');
  
  // select all/select none in input files
  
  $('#files_check_all').click(function() {
    $('input[name="input_files"]').prop("checked", true);
  });
  $('#files_check_none').click(function() {
    $('input[name="input_files"]').removeAttr("checked");
  });
  
  
  // activate tooltips
  // see: https://getbootstrap.com/docs/3.3/javascript/#tooltips
  $(function () {
    $('[data-toggle="tooltip"]').tooltip()
  })
  
  // activate popovers
  // see: https://getbootstrap.com/docs/3.3/javascript/#popovers
  $(function () {
    $('[data-toggle="popover"]').popover()
  })

});

