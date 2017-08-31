$(document).ready(function(){
  $('.rucaptcha-image').click(function(){
    currentSrc = $(this).attr('src');
    $(this).attr('src', currentSrc.split('?')[0] + '?' + (new Date()).getTime());
    return false;
  });
});
