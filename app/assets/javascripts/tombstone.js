$(document).ready(function() {

$('#select-tombstone').on('change', function() {
    var aLink = $('.tomb'),
        selVal = $(this).val(),
        staticLink = "www.random.org";
  
        link = $(aLink).attr('href')
        link = link.replace(/\?.*/,"")

    $(aLink).attr('href', link + "?locale=en&tombstone=" + selVal);    
})

});