jQuery ->
  text_max = 140

  update_counter = ->
    text_length = $("#micropost_content").val().length
    text_remaining = text_max - text_length
    $(".char-counter").html text_remaining + ' characters left.'
    text_remaining

  # Update counter when user writes into the textarea
  $("#micropost_content").keyup ->
    text_remaining = update_counter()
    if text_remaining <= 0 and not $(".char-counter").hasClass "red-text"
      $(".char-counter").addClass "red-text"
    else if text_remaining > 0 and $(".char-counter").hasClass "red-text"
      $(".char-counter").removeClass "red-text"

  # Run update_counter after load
  update_counter()
