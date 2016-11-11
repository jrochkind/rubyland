// We're loading reddit API using an ordinary AJAX fetch, because it
// seems to not require oauth or be rate-limited after all. If it becomes so,
// we can do oauth, or switch to jsonp.
// https://github.com/erikarenhill/Lightweight-JSONP/blob/2dbd3afa9f2c3395af9b8aef90cb708682237018/jsonp.js
// https://www.reddit.com/r/redditdev/comments/2ujhkr/important_api_licensing_terms_clarified/

(function() {
  var fetchErrors = 0;
  // before giving up and not doing it anymore...
  var maxFetchErrors = 3;

  function redditErrorAlert() {
    var al = document.querySelector("#alert");
    al.innerHTML = "<i class='fa fa-exclamation-triangle'></i> Couldn't contact reddit api, your ad-blocker might be stopping us.";
    al.style.opacity = 1.0;
    al.style.display = "";
    setTimeout(fadeOut.bind(undefined, al), 4000);
    ;
  }


  function liveRedditLoad(element) {
    if (fetchErrors > maxFetchErrors) {
      return;
    }

    element.innerHTML = "<i class='fa fa-spinner fa-spin'></i> Reddit";

    var url = element.dataset.linkReddit;

    var request_url = "https://www.reddit.com/r/ruby/api/info.json?url=" + escape(url);
    fetch(request_url).
      then(function (response) { return response.json() }).
      catch(function(error) {
        if (fetchErrors == 0) {
          redditErrorAlert();
        }

        fetchErrors += 1;
        element.innerHTML = "<i class='fa fa-reddit'></i> Reddit";
        console.log("Error trying to contact Reddit. Do you have an ad-blocker stopping us? " + error);
        throw error;
      }).
      then(setFromResponse.bind(this, element));
  };

  function setFromResponse(element, response) {
    var hit = response.data && response.data.children && response.data.children[0];
    if (hit) {
      var reddit_url = hit.data && hit.data.permalink;
      var numComments = hit.data && hit.data.num_comments;
      if (reddit_url) {
        element.href = "https://www.reddit.com" + reddit_url;
        if (numComments) {
          element.title = numComments + " " + (numComments > 1 ? "comments" : "comment") + " at /r/ruby"
        } else {
          element.title = "Comment at /r/ruby"
        }
        element.innerHTML = (numComments ? numComments : "") + " <i class='fa fa-comment'></i> Reddit";
      }
    } else {
      element.title = "Submit to /r/ruby"
      element.innerHTML = "<i class='fa fa-share'></i> Reddit";
    }
  }

  ready(function() {

    // Load reddit when elements are in viewport, with a pretty big `bounds`
    // to get elements some pixels off screen too. 
    // https://github.com/creativelive/appear
    appear({
      elements: function elements(){
        // work with all elements with the class "track"
        return document.querySelectorAll(".entry *[data-link-reddit]");
      },
      appear: liveRedditLoad,
      bounds: 600
    });

  });

})();