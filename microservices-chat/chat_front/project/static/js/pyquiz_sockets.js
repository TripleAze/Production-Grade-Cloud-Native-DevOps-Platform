var namespace = '/chat';
var user_id = "";
var username = "";
var socketConnected = false;
var pendingUsername = null;

// Create socket
var socket = io(service_host + namespace, {
    transports: ['websocket', 'polling'],
    reconnection: true,
    reconnectionAttempts: 5
});

// Register connect listener IMMEDIATELY (before DOM ready)
socket.on('connect', function () {
    console.log("SOCKET CONNECTED");
    socketConnected = true;
    $("#start-off").css("display", "none");
    $("#start-on").css("display", "block");

    // If we already have username (from prompt), emit login
    if (pendingUsername) {
        console.log("Emitting login for:", pendingUsername);
        socket.emit('log-in', {"username": pendingUsername});
    }
});

function send_msg(response) {
    var msg = {"message": response, "username": username};
    console.log("Enviado mensaje: ");
    console.log(msg);
    socket.emit('send_msg', msg);
}

$(document).ready(function () {
    console.log("DOM ready, service_host:", service_host);
    console.log("Socket already connected?", socketConnected);

    // Show prompt immediately on DOM ready
    setTimeout(function() {
        username = prompt("Introduce tu nick", "Harry Potter");
        console.log("User entered:", username);
        if (username) {
            pendingUsername = username;
            if (socketConnected) {
                console.log("Socket already connected, emitting login now");
                socket.emit('log-in', {"username": username});
            } else {
                console.log("Waiting for socket connection...");
            }
        }
    }, 100);

    socket.on('users_connected', function (lenUsers) {
        $('#user-cnt').text(lenUsers);
        console.log("users connected: " + lenUsers);
    });
    socket.on('msgs', function (data) {
        console.log("llegó mensaje:");
        console.log(data);
        var position = "";
        var username_sender = "";
        var color = "";
        if (data.user_id === user_id || data.username === username) {
            position = "right";
            color = "light-green lighten-4";
        } else {
            color = "grey lighten-5";
            username_sender = '<div>' + data.username + '</div>';
        }
        var msg = '<div class="row ' + color + '">' +
            username_sender +
            '<div class="col  s12 m12" ><p class="' + position + '">' +
            data.message +
            '</p></div></div>';
        $('#msgs').append(msg);

        $('main').scrollTop($('main')[0].scrollHeight);
    });
    $("#send_msg").submit(function (e) {
        e.preventDefault();
        send_msg($("#msg_input").val());
    });
    socket.on('message', function (data) {
        console.log("Message recived");
        console.log(data);
        if (data.welcome) {
            $('#msg').text(data.welcome + "!!");
        } else {
            $('#msg').text(data.message);
        }
        if (data.user_id) {
            user_id = data.user_id;
        }
        $('#modal1').modal('open');
    });

});