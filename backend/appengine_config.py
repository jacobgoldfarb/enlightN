from google.appengine.ext import vendor
vendor.add('Library')
import requests
import requests_toolbelt.adapters.appengine
requests_toolbelt.adapters.appengine.monkeypatch(validate_certificate=False)

from google.appengine.api import urlfetch
urlfetch.set_default_fetch_deadline(10)
