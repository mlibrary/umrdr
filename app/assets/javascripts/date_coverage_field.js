(function( $ ) {

  $( document ).ready(function() {
    $(".date-add-coverage-button").click(function() {
      toggleDateCoverage();
      $("#date_coverage_end_year").focus();
    });

    $(".date-reset").click(function() {
      // clear end date values
      $("#date_coverage_end_year").val('');
      $("#date_coverage_end_month").val('--');
      $("#date_coverage_end_day").val('--');

      toggleDateCoverage();
      $("#date_coverage_begin_year").focus();
    });

    function toggleDateCoverage() {
      $(".date-coverage-element").toggleClass('hidden');
    }
  });

})( jQuery );
