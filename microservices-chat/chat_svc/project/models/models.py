# encoding: utf-8
from __future__ import absolute_import, print_function, unicode_literals

import datetime

from sqlalchemy import Column, Integer, String, DateTime

from project.models.init_db import db


class Message(db.Model):
    """Message model for chat history"""
    __tablename__ = 'messages'

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String(50), nullable=True)
    username = Column(String(100), nullable=False)
    message = Column(String(500), nullable=False)
    timestamp = Column(DateTime, default=datetime.datetime.now)

    @property
    def serialize(self) -> dict:
        """Return object data in easily serializeable format"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'username': self.username,
            'message': self.message,
        }
