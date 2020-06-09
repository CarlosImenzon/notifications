window.onload = function(){
      (function(){
        var show = function(el){
          return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
        }(document.getElementById('msgs'));
        var ws       = new WebSocket('ws://' + window.location.host + window.location.pathname);
        ws.onopen    = function()  {  };
        ws.onclose   = function()  {  }
        ws.onmessage = function(m) { show(m.data); };
        var sender = function(f){
          f.onsubmit    = function(){
            ws.send('*');
            return false;
          }
        }(document.getElementById('form'));
      })();
    }