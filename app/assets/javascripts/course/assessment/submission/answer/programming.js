//= require helpers/form_helpers
//= require helpers/course_helpers
//= require helpers/discussion/post_helpers
//= require templates/course/assessment/submission/answer/programming/add_annotation_button
//= require templates/course/assessment/submission/answer/programming/annotation_form

(function($, FORM_HELPERS,
             COURSE_HELPERS,
             DISCUSSION_POST_HELPERS) {
  /* global JST, Routes */
  'use strict';
  var DOCUMENT_SELECTOR = '.course-assessment-submission-submissions.edit ' +
    'div.answer_programming_file ';
  var render = FORM_HELPERS.renderFromPath('templates/course/assessment/submission/answer/programming/');

  /**
   * Gets the assessment ID for the given element.
   *
   * @param {jQuery} $element The element to find the associated assessment for.
   * @return {Number} The ID for the assessment the element is associated with.
   */
  function assessmentIdForElement($element) {
    var $assessment = $element.parents('.assessment:first');
    return $assessment.data('assessmentId');
  }

  /**
   * Gets the submission ID for the given element.
   *
   * @param {jQuery} $element The element to find the associated submission for.
   * @return {Number} The ID for the submission the element is associated with.
   */
  function submissionIdForElement($element) {
    var $submission = $element.parents('.submission:first');
    return $submission.data('submissionId');
  }

  /**
   * Gets the answer ID for the given element.
   *
   * @param {jQuery} $element The element to find the associated answer for.
   * @return {Number} The ID for the answer the element is associated with.
   */
  function answerIdForElement($element) {
    var $answer = $element.parents('.answer:first');
    return $answer.data('answerId');
  }

  /**
   * Finds the annotation cell for the given line within the given code block. This will create
   * a cell if the cell cannot be found.
   *
   * @param {jQuery} $code The table containing the code block.
   * @param {Number} programmingFileId The programming file which the annotation refers to.
   * @param {Number} lineNumber The line number for the annotation.
   * @return {jQuery} The cell which was found or created.
   */
  function findOrCreateAnnotationCell($code, programmingFileId, lineNumber) {
    var $cell = findAnnotationCell($code, programmingFileId, lineNumber);
    if ($cell.length > 0) {
      return $cell;
    }

    var row = createAnnotationRow(programmingFileId, lineNumber);
    findCodeLine($code, lineNumber).after(row);

    // Traverse again, so we get the inserted row instead of the disconnected row node.
    return findAnnotationCell($code, programmingFileId, lineNumber);
  }

  /**
   * Creates an annotation row for the given line number.
   *
   * @param {Number} lineNumber The line number to create an annotation row for.
   * @param {Number} programmingFileId The programming file which the annotation refers to.
   * @return {String} The markup for the annotation row.
   */
  function createAnnotationRow(programmingFileId, lineNumber) {
    return render('annotation_row', {
      annotationCellId: fileLineAnnotationCellId(programmingFileId, lineNumber),
      lineNumber: lineNumber
    });
  }

  /**
   * Creates the annotation cell ID for the given file and line number.
   *
   * This is the JavaScript port of
   * `Course::Assessment::Answer::ProgrammingHelper#file_line_annotation_cell_id`.
   *
   * @param {Number} lineNumber The line number to create an annotation row for.
   * @param {Number} programmingFileId The programming file which the annotation refers to.
   * @return {String} The ID for the given annotation cell.
   */
  function fileLineAnnotationCellId(programmingFileId, lineNumber) {
    return 'line_annotation_file_' + programmingFileId + '_line_' + lineNumber + '_annotation';
  }

  /**
   * Finds the table row representing the line content at the given line number.
   *
   * @param {jQuery} $code The table containing the code to search.
   * @param {Number} lineNumber The line number to search for.
   * @returns {jQuery} The row containing the line content.
   */
  function findCodeLine($code, lineNumber) {
    return $code.find('td.line-number[data-line-number=' + lineNumber + ']').parent();
  }

  /**
   * Finds the annotation cell for the same file, at the given line number.
   *
   * @param {jQuery} $code The table containing the code to search.
   * @param {Number} programmingFileId The programming file which the annotation refers to.
   * @param {Number} lineNumber The line number.
   * @return {jQuery} If the cell was found.
   */
  function findAnnotationCell($code, programmingFileId, lineNumber) {
    return $code.find('td#line_annotation_file_' + programmingFileId + '_line_' + lineNumber +
                      '_annotation');
  }

  /**
   * Gets the programming file ID for the given row within the code listing table.
   *
   * @param {jQuery} $element The element to find the associated answer for.
   * @return {Number} The ID for the programming file the line is associated with.
   */
  function programmingFileIdForRow($element) {
    var $programmingFile = $element.parents('.answer_programming_file');
    return $programmingFile.data('programmingFileId');
  }

  /**
   * Adds the programming annotation links to every line of code.
   *
   * @param {HTMLElement} element The table containing the code, tabulated by lines. This is the
   *   output of the Ruby `format_code_block` helper.
   */
  function addProgrammingAnnotationLinks(element) {
    var $lineNumbers = $(DOCUMENT_SELECTOR + 'table.codehilite td.line-content', element).
      not(function() {
        return $(this).find('.add-annotation').length > 0;
      });

    $lineNumbers.prepend(render('add_annotation_button'));
  }

  /**
   * Shows reply buttons for annotations.
   *
   * @param element
   */
  function showAnnotationReplyButtons(element) {
    var $button = $('.reply-annotation', element).filter(DOCUMENT_SELECTOR + '*');
    $button.show();
  }

  /**
   * Handles the click event when the add annotation button is clicked.
   *
   * @param {Event} e The event object.
   */
  function onAddProgrammingAnnotation(e) {
    var $target = $(e.target);
    var $line = $target.parents('tr:first');

    var courseId = COURSE_HELPERS.courseIdForElement($target);
    var assessmentId = assessmentIdForElement($target);
    var submissionId = submissionIdForElement($target);
    var answerId = answerIdForElement($target);
    var programmingFileId = programmingFileIdForRow($target);
    var lineNumber = $line.find('.line-number').data('lineNumber');

    var $code = $line.parents('table:first');
    var $cell = findOrCreateAnnotationCell($code, programmingFileId, lineNumber);
    findOrCreateAnnotationForm($cell, courseId, assessmentId, submissionId, answerId,
                               programmingFileId, lineNumber);
  }

  /**
   * Creates an annotation form for the user to enter his annotation.
   *
   * @param {jQuery} $element The element to search for the form.
   * @param {Number} courseId The course ID that the annotation is associated ith.
   * @param {Number} assessmentId The assessment ID that the annotation is associated with.
   * @param {Number} submissionId The submission ID that the annotation is associated with.
   * @param {Number} answerId The answer ID that the annotation is associated with.
   * @param {Number} programmingFileId The programming answer file ID that the annotation is
   *   associated with.
   * @param {Number} lineNumber The line number that the user is annotating.
   * @param {Number} parentId The parent post ID that the annotation will be associated with.
   * @return {jQuery} The annotation form which was found or created.
   */
  function findOrCreateAnnotationForm($element, courseId, assessmentId, submissionId, answerId,
                                      programmingFileId, lineNumber, parentId) {
    var $annotationForm = findAnnotationForm($element);
    if ($annotationForm.length > 0) {
      return $annotationForm;
    }

    return createAnnotationForm($element, courseId, assessmentId, submissionId, answerId,
                                programmingFileId, lineNumber, parentId);
  }

  /**
   * Finds the annotation form in the given cell.
   *
   * @param {jQuery} $element The annotation cell to search for the form.
   * @return {jQuery} The annotation form which was found.
   */
  function findAnnotationForm($element) {
    return $element.find('> div.annotation-form');
  }

  /**
   * Creates an annotation form for the user to enter his annotation.
   *
   * @param {jQuery} $element The element to search for the form.
   * @param {Number} courseId The course ID that the annotation is associated with.
   * @param {Number} assessmentId The assessment ID that the annotation is associated with.
   * @param {Number} submissionId The submission ID that the annotation is associated with.
   * @param {Number} answerId The answer ID that the annotation is associated with.
   * @param {Number} programmingFileId The programming answer file ID that the annotation is
   *   associated with.
   * @param {Number} lineNumber The line number that the user is annotating.
   * @param {Number} parentId The parent post ID that the annotation will be associated with.
   * @return {jQuery} The annotation form which was created.
   */
  function createAnnotationForm($element, courseId, assessmentId, submissionId, answerId,
                                programmingFileId, lineNumber, parentId) {
    $element.append(render('annotation_form', {
      courseId: courseId,
      assessmentId: assessmentId,
      submissionId: submissionId,
      answerId: answerId,
      programmingFileId: programmingFileId,
      lineNumber: lineNumber,
      parentId: parentId
    }));

    return findAnnotationForm($element);
  }

  /**
   * Handles the reset of the annotation form.
   *
   * @param e The event object.
   */
  function onAnnotationFormResetted(e) {
    var $button = $(e.target);
    var $replyButton = $button.parents('.line-annotation:first').find('.reply-annotation');

    FORM_HELPERS.removeParentForm($button);
    $replyButton.show();
  }

  /**
   * Blocks the submission of the submission form if we click on a submit button within the
   * annotation form.
   *
   * @param e The event object.
   */
  function onAnnotationFormSubmitted(e) {
    var $button = $(e.target);
    var $form = FORM_HELPERS.parentFormForElement($button);
    FORM_HELPERS.submitAndDisableForm($form, onAnnotationFormSubmitSuccess,
                                             onAnnotationFormSubmitFail);
    e.preventDefault();
  }

  /**
   * Handles the successful annotation save event.
   *
   * @param {HTMLElement} form The form which was submitted
   */
  function onAnnotationFormSubmitSuccess(_, form) {
    $(form).remove();
  }

  /**
   * Handles the errored annotation save event.
   *
   * @param {HTMLElement} form The form which was submitted
   */
  function onAnnotationFormSubmitFail(_, form) {
    var $form = $(form);
    FORM_HELPERS.findFormFields($form).prop('disabled', false);

    // TODO: Implement error recovery.
  }

  /**
   * Creates a form to reply to a given annotation post.
   *
   * @param {jQuery} $post The annotation post to reply to.
   */
  function findOrCreateAnnotationReplyFormForPost($post) {
    var $replies = $post.next('div.replies');
    var courseId = COURSE_HELPERS.courseIdForElement($post);
    var assessmentId = assessmentIdForElement($post);
    var submissionId = submissionIdForElement($post);
    var answerId = answerIdForElement($post);
    var programmingFileId = programmingFileIdForRow($post);
    var lineNumber = $post.parents('.line-annotation:first').data('lineNumber');
    var postId = $post.data('postId');

    return findOrCreateAnnotationForm($replies, courseId, assessmentId, submissionId, answerId,
                                      programmingFileId, lineNumber, postId);
  }

  /**
   * Handles the annotation reply button click event. Replying to an annotation is
   * equivalent to replying to its last post.
   *
   * @param e The event object.
   */
  function onAnnotationReply(e) {
    var $element = $(e.target);
    var $post = $element.parents('.line-annotation:first').find('.discussion_post:last');
    var $form = findOrCreateAnnotationReplyFormForPost($post);

    $element.hide();
    $form.find('textarea').focus();
    e.preventDefault();
  }

  addProgrammingAnnotationLinks(document);
  showAnnotationReplyButtons(document);
  $(document).on('DOMNodeInserted', function(e) {
    addProgrammingAnnotationLinks(e.target);
    showAnnotationReplyButtons(e.target);
  });
  $(document).on('click', DOCUMENT_SELECTOR + 'table.codehilite .add-annotation',
    onAddProgrammingAnnotation);
  $(document).on('click', DOCUMENT_SELECTOR + '.annotation-form input[type="reset"]',
    onAnnotationFormResetted);
  $(document).on('click', DOCUMENT_SELECTOR + '.annotation-form input[type="submit"]',
    onAnnotationFormSubmitted);
  $(document).on('click', DOCUMENT_SELECTOR + '.discussion_topic .reply-annotation',
    onAnnotationReply);
  DISCUSSION_POST_HELPERS.initializeToolbar(document, DOCUMENT_SELECTOR + '.line-annotation ');
})(jQuery, FORM_HELPERS,
           COURSE_HELPERS,
           DISCUSSION_POST_HELPERS);
