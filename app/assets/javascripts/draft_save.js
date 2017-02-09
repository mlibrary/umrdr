$(document).ready(function() {
    
$('#isDraft').click(function() {
  if($(this).is(":checked")) {
    $('#with_files_submit').val("Save as Draft");
   }
   else
   {
     $('#with_files_submit').val("Publish");
    }       
});

});
