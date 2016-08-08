
// Get the distance of an element from the top of the window

var getElemDistance = function ( elem ) {
  var location = 0;

  if (elem.offsetParent) {
      do {
          location += elem.offsetTop;
          elem = elem.offsetParent;
      } while (elem);
  }
  return location >= 0 ? location : 0;
};


// Fire this code when the page is scrolled or resized
function checkScroll() {

  var scrollTop = $(window).scrollTop();

  // Grab homeContent distance from top of screen
  var homeContent = getElemDistance( $('.homeContent')[0]);

  var leftEdge = $(".homeContent").offset().left;

  // Find where the menu should be fixed from the left side of screen


  //
  if(scrollTop > homeContent) {
    $('.docsMenu').addClass('fixed');
    $('.docsMenu').css({left: leftEdge+20});
  } else {
    $('.docsMenu').removeClass('fixed');
    $('.docsMenu').css({left: "20px"});

  }

}


  window.addEventListener('scroll', checkScroll, false);
  window.addEventListener('resize', checkScroll, false);
