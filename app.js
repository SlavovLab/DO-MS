$(document).ready(function() {
  console.log('ready!');
  $('body').addClass('fixed');
  
  // for the select all/select none buttons

  $('#exp_check_all').click(function() {
    $('input[name="Exp_Sets"]').prop("checked", true);
  });
  
  $('#exp_check_none').click(function() {
    $('input[name="Exp_Sets"]').removeAttr("checked");
  });

});

