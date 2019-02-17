import requests


class CognitiveService(object):
    def __init__(self, api_key):
        self.base_api = "https://westus.api.cognitive.microsoft.com/text/analytics/v2.0"
        self.api_key = api_key

    def get_keywords(self, paragraph):
        api_url = "{}/{}".format(self.base_api, "keyPhrases")
        documents = {
            'documents': [
                {
                    'id': '1',
                    'language': 'en',
                    'text': paragraph
                }
            ]
        }
        headers = {
            'Ocp-Apim-Subscription-Key': self.api_key
        }
        response = requests.post(api_url, headers=headers, json=documents)
        key_phrases = response.json()
        word_list = key_phrases['documents'][0]['keyPhrases']
        return " ".join(word_list)
