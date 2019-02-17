from bs4 import BeautifulSoup
import re

def get_posts(html):
    f = open("facebook.html", 'r')
    html_doc = f.read()
    soup = BeautifulSoup(html_doc, 'html.parser')
    texts = soup.find_all("p")
    posts = []
    for text in texts:
        plainText = text.get_text()
        wordCount = len(plainText.split())
        if wordCount > 7:
            posts.append(plainText)
    return posts

posts = get_posts(html="facebook.html")
for post in posts:
    print(f"POST: {post}")