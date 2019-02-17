from .handlers import *


app = webapp2.WSGIApplication([
    webapp2.Route(template='/verification/check',
                  handler=VerificationHandler,
                  handler_method='check',
                  methods=['GET', 'POST']),
])
