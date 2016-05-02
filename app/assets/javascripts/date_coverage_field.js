(function( $ ) {

  $( document ).ready(function() {
    $(".date-add-coverage-button").click(function() {
      toggleDateCoverage();
    });

    $(".date-reset").click(function() {
      // clear end date values
      $("#date_coverage_2_year").val('');
      $("#date_coverage_2_month").val('--');
      $("#date_coverage_2_day").val('--');

      toggleDateCoverage();
    });

    function toggleDateCoverage() {
      $(".date-coverage-element").toggleClass('hidden');
      $("#date_coverage_1_year").focus();
    }
  });

})( jQuery );  