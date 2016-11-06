(function() {
  ready(function() {
    var elements = document.querySelectorAll(".entry-head *[data-time]")
    for (var i = 0; i < elements.length; i++) {
      var element = elements[i];
      var moment = window.moment(element.dataset.time);
      element.textContent = moment.fromNow();
    }
  });
})();