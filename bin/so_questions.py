#!/usr/bin/env python
import json
import zlib
import urllib2
import pprint
from bottle import route, run

query = "https://api.stackexchange.com/2.0/questions?site=stackoverflow"

def getjson(query):
  return json.loads(
    zlib.decompress(
      urllib2.urlopen(query).read(), 
      16+zlib.MAX_WBITS
    )
  )

def json2questions(json_query):
  return map( 
    lambda x: {
      "title":x["title"], 
      "answers":x["answer_count"], 
      "link":x["link"], 
      "rep":x["owner"]["reputation"]
    }, 
    filter(
      lambda x: not x["is_answered"], 
      json_query["items"]
    )
  )

def questions2html(questions):
  template = """
  <div class="question">
      <p><a href="%(link)s">%(title)s</a> (%(rep)d)[%(answers)d]</p>
  </div>
  """
  return "".join(map(lambda x: template%x, questions))


def html2page(html):
  return """
  <html>
  <body>
  %s
  </body>
  </html>"""%html

@route("/")
def home():
  return html2page(questions2html(json2questions(getjson(query))))


if __name__ == "__main__":
  run(host='localhost', port=8080, debug=True, reloader=True)  

# print 
