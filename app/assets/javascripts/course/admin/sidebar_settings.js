// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
(function() {
  'use strict';
  $(document).on('page:load ready', function() {
    var $edit = $('.course-admin-sidebar-settings.edit');
    var $table = $('table.sidebar-items', $edit);
    $('.weight', $table).hide();
    $('.reorder', $table).show();

    $('tbody', $table).sortable({
      axis: 'y',
      stop: function() {
        $('.weight input', $table).val(function(index) { return index + 1; });
      }
    }).disableSelection();
  });
})();
