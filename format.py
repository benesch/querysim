#!/usr/bin/env python

from pygments.lexers import MySqlLexer
from pygments.formatters import HtmlFormatter
import csv
import jinja2
import pygments
import sqlparse
import sys

report = jinja2.Template("""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Query log</title>
        <style>
            {{ styles }}

            pre {
                margin: 0;
                padding: 1em;
            }

            .query {
                margin-bottom: 40px;
            }
        </style>
    </head>
    <body>
        {% for q in queries %}
            <div class="query">
                {{ q.formatted_query }}
                time: {{ q.time }}, nqueries: {{ q.nqueries }}, time per query: {{ q.time_per_query }}, site: {{ q. site }}
            </div>
        {% endfor %}
    </body>
    </html>
""")

def render_report(queries):
    return report.render({
        'queries': queries,
        'styles': HtmlFormatter().get_style_defs('.highlight')
    })

def main(file):
    with open(file, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        rows = []
        for row in reader:
            row['formatted_query'] = pygments.highlight(
                sqlparse.format(row['query'].strip(), reindent=True),
                MySqlLexer(), HtmlFormatter())
            row['time_per_query'] = row['time per query']
            rows.append(row)
        print render_report(rows)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print "usage: %s QUERYLOG" % sys.argv[0]
        sys.exit(1)
    main(sys.argv[1])
