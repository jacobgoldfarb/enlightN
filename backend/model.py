from google.appengine.ext import db


class SourceInfo(db.Model):
    domain = db.StringProperty()
    host_name = db.StringProperty()
    credibility_status = db.StringProperty()
    tags = db.StringProperty()

    created_at = db.DateTimeProperty(auto_now_add=True)
    modified_at = db.DateTimeProperty(auto_now=True)
