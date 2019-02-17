from .handlers import *


app = webapp2.WSGIApplication([
    webapp2.Route(template='/source_info/upload',
                  handler=SourceInfoHandler,
                  handler_method='upload',
                  methods=['GET', 'POST']),
])
