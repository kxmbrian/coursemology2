//= require helpers/discussion/edit_post
//= require helpers/discussion/delete_post

var DISCUSSION_POST_HELPERS = (function($, EDIT_DISCUSSION_POST, DELETE_DISCUSSION_POST) {
  /* global JST, Routes */
  'use strict';

  /**
   * Shows the comments toolbar for submissions.
   *
   * This allows comments to be deleted.
   *
   * @param element
   */
  function showCommentToolbar(element, selector) {
    var $comments = $('.discussion_post', element).filter(selector + '*');
    $comments.find('.toolbar').show();
  }

  //  TODO
  function initializeToolbar(element, selector) {
    showCommentToolbar(element, selector);
    $(document).on('DOMNodeInserted', function(e) {
      showCommentToolbar(e.target, selector);
    });
    EDIT_DISCUSSION_POST.initialize(element, selector);
    DELETE_DISCUSSION_POST.initialize(element, selector);
  }

  return {
    initializeToolbar: initializeToolbar
  };
}(jQuery, EDIT_DISCUSSION_POST, DELETE_DISCUSSION_POST));
