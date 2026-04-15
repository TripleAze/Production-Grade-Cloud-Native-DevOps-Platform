from __future__ import unicode_literals, print_function

import uuid

from flask import current_app, jsonify
from flask import session
from flask_socketio import emit, send, SocketIO
from pyms.flask.app import Microservice

from project.models.init_db import db
from project.models.models import Message

__author__ = "Alberto Vara"
__email__ = "a.vara.1986@gmail.com"
__version__ = "0.1.0"

from werkzeug.middleware.proxy_fix import ProxyFix

socketio = SocketIO()

ms = Microservice(path=__file__)
app = ms.create_app()
# Trusting two proxies since we saw a chain of IPs in the logs
# Trust the full chain of IPs from ALB (saw 2+ IPs in logs)
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=3, x_proto=1, x_host=1, x_port=1, x_prefix=1)


def get_messages():
    """Fetch all messages from the database directly"""
    query = Message.query.all()
    return [i.serialize for i in query]


def post_message(data):
    """Save a new message to the database directly"""
    message_obj = Message(
        user_id=data.get("user_id"),
        username=data.get("username"),
        message=data.get("message")
    )
    db.session.add(message_obj)
    db.session.commit()
    return message_obj.serialize


users_connected = []


@app.route("/")
def index():
    return jsonify({})


@socketio.on('connect', namespace='/chat')
def on_connect():
    current_app.logger.info("USER CONNECTED")
    for msg in get_messages():
        emit('msgs', msg)


@socketio.on('log-in', namespace='/chat')
def login(data):
    user_id = session.get("user_id", "")
    if not user_id:
        user_id = str(uuid.uuid4())
        session["user_id"] = user_id
    data = {"id": user_id, "username": data.get("username", "")}

    users_connected.append(data)
    current_app.logger.info(data)
    # # Send in broadcast the actual number of connected users
    emit('users_connected', len(users_connected), broadcast=True)

    send(dict(user_id=user_id, welcome="Hola {}".format(data["username"])))


@socketio.on('disconnect', namespace='/chat')
def on_disconnect():
    # Removing the user from all the rooms where he is and broadcasting the new number
    user_id = session.get("user_id", "")
    for user in users_connected:
        if user["id"] == user_id:
            users_connected.remove(user)

    # Sending the new number of users connected
    emit('users_connected', len(users_connected), broadcast=True)


@socketio.on('send_msg', namespace='/chat')
def send_msg(data):
    # Send in broadcast the actual number of connected users

    current_app.logger.info(
        "[EVENT] User {} send message {}".format(session.get("user_id", ""), data["message"], ))
    msg = {"user_id": session.get("user_id", ""), "username": data.get("username", ""), "message": data["message"]}
    result_msg = post_message(msg)
    emit('msgs', result_msg, broadcast=True)


def create_app():
    """Initialize the Flask app, register blueprints and intialize all libraries like Swagger, database, the trace system...
    return the app and the database objects.
    :return:
    """
    db.init_app(app)
    with app.app_context():
        db.create_all()  # Simple schema initialization for RDS
    # Deep debugging + permissive CORS for ALB environment
    socketio.init_app(
        app,
        logger=True,
        engineio_logger=True,
        cors_allowed_origins="*",
        async_mode='eventlet'
    )
    return app

