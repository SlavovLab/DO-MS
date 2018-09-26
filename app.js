// execute function when jquery is ready and good to go
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
  
  // select all/select none in input files
  
  $('#files_check_all').click(function() {
    $('input[name="input_files"]').prop("checked", true);
  });
  $('#files_check_none').click(function() {
    $('input[name="input_files"]').removeAttr("checked");
  });

  /*var a = document.getElementById('fileIn');
  if(a.value === "") {
      noFile.innerHTML = "No folder choosen";
  } else {
      noFile.innerHTML = "";
  }
  
  document.getElementById("fileIn").addEventListener("change", function(e) {

    let files = e.target.files;
    var arr = new Array(files.length*2);
    for (let i=0; i<files.length; i++) {
      //console.log(files[i])
      console.log(files[i].webkitRelativePath);
      //console.log(files[i].name);
      arr[i] = files[i].webkitRelativePath;
      arr[i+files.length] = files[i].name;
    }

    //Shiny.onInputChange("mydata", arr);

  });*/

});

