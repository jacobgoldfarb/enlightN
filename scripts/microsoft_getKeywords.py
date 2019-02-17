import requests
import json
from pprint import pprint

subscription_key = '4e8fe2daa9fc425094542e4f46d25b85'
text_analytics_base_url = "https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/"

def getKeyword(paragraph):
    key_phrase_api_url = text_analytics_base_url + "keyPhrases"
    print(key_phrase_api_url)

    documents = {'documents': [
        {'id': '1', 'language': 'en',
         'text': paragraph},
    ]}

    headers = {'Ocp-Apim-Subscription-Key': subscription_key}
    response = requests.post(key_phrase_api_url, headers=headers, json=documents)
    key_phrases = response.json()
    pprint(key_phrases)

    wordList = key_phrases['documents'][0]['keyPhrases']
    print("wordList: ", end="")
    print(wordList)
    return wordList

getKeyword("We love this trail and make the trip every year. The views are breathtaking and well worth the hike!")



# import http.client, urllib.request, urllib.parse, urllib.error, base64
#
# headers = {
#     # Request headers
#     'Content-Type': 'application/json',
#     'Ocp-Apim-Subscription-Key': '{subscription key}',
# }
#
# params = urllib.parse.urlencode({
#     # Request parameters
#     'showStats': '{boolean}',
# })
#
# try:
#     conn = http.client.HTTPSConnection('westus.api.cognitive.microsoft.com')
#     conn.request("POST", "/text/analytics/v2.1-preview/entities?%s" % params, "{body}", headers)
#     response = conn.getresponse()
#     data = response.read()
#     print(data)
#     conn.close()
# except Exception as e:
#     print("[Errno {0}] {1}".format(e.errno, e.strerror))

