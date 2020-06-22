window.onload = function(){
  (function(){
    var show = function(el){
      return function(msg){
        el.innerHTML = msg + el.innerHTML;
      }
    }(document.getElementById('msgs'));
    var reloadPage = function(){
      return function(){
          window.location.reload();
      }
    }(document.getElementById('reload'));
      var ws       = new WebSocket('ws://' + window.location.host + window.location.pathname);
      ws.onopen    = function()  {  };
      ws.onclose   = function()  {  }
      ws.onmessage = function(m) {
        if (document.getElementById('reload') !== null) {
          setTimeout(function () {
            reloadPage();
          }, 3000);
        }
        show(m.data);
      };
      var sender = function(f){
        f.onsubmit = function(){
          console.log(input.value)
          ws.send('*');
          return true;
        }
      }(document.getElementById('form'));
  })();
}