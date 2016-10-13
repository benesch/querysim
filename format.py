#!/usr/bin/env python3

from pygments.lexers import MySqlLexer
from pygments.formatters import HtmlFormatter
import argparse
import csv
import jinja2
import pathlib
import pygments
import sqlparse
import sys

html_report = jinja2.Template("""
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
            time: {{ q.time }}, nqueries: {{ q.nqueries }}, time per query: {{ q.time_per_query }}, site: {{ q.site }}
        </div>
    {% endfor %}
</body>
</html>
""".strip())

testie_file = jinja2.Template("""
%script
sql_parse
%stdin
{{ query }}
{% if expected_output %}
%expect stdout
{{ expected_output }}
{% endif %}
""".strip())

def do_html(rows):
    for row in rows:
        row['formatted_query'] = pygments.highlight(
            row['formatted_query'], MySqlLexer(), HtmlFormatter())
    print(html_report.render({
        'queries': rows,
        'styles': HtmlFormatter().get_style_defs('.highlight')
    }))


def too_hard(row):
    return (row['type'] != 'SELECT'
        or 'collate' in row['query']
        or 'regexp' in row['query']
        or 'limit ?' in row['query']
        or 'information_schema' in row['query'])

def do_testie(rows):
    testdir = pathlib.Path('test')
    if not testdir.exists():
        testdir.mkdir()
    else:
        for f in testdir.glob('*-hotcrp.testie'):
            f.unlink()
    rows = sorted(rows, key=lambda x: len(x['query']))
    rows = filter(lambda row: not too_hard(row), rows)
    for idx, row in enumerate(rows):
        testfile = testdir / "{:04}-hotcrp.testie".format(idx)
        testfile.write_text(testie_file.render({
            'query': row['formatted_query']
        }))


MODES = {
    'html': do_html,
    'testie': do_testie,
}

def main():
    parser = argparse.ArgumentParser(
        description='Process HotCRP-style query logs')
    parser.add_argument('mode', choices=MODES.keys())
    parser.add_argument('file', type=argparse.FileType('r'))
    args = parser.parse_args()

    rows = []
    for row in csv.DictReader(args.file):
        row['query'] = row['query'].replace('?a', ' in ?')
        row['query'] = row['query'].replace('???', '?')
        row['type'] = sqlparse.parse(row['query'])[0].get_type()
        row['formatted_query'] = sqlparse.format(row['query'].strip(), reindent=True)
        row['time_per_query'] = row['time per query']
        rows.append(row)

    modefn = MODES[args.mode]
    modefn(rows)


if __name__ == '__main__':
    main()
