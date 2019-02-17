import requests
import sys
import json
from bs4 import BeautifulSoup

def retrieveHeadlines(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    headlineSoup = soup.find_all("h1")
    headlineList = []
    for h in headlineSoup:
        headlineList.append(h.get_text())
    return headlineList
