from Bio import Entrez
import xml.etree.ElementTree as ET
import re
import csv

f = open('tamp/titles.csv')
title_pattern = re.compile("T1  - ")

pmid_file = open('pmids.csv', 'w+')
csvwriter = csv.writer(pmid_file, delimiter=',', quotechar='"')

Entrez.email = "birol_senturk@brown.edu"

for l in f:
	query_term = re.sub('[^A-Za-z0-9 -.]+', '', l).strip()
	cit_d = {"title" : t}
	record = Entrez.esearch(db='pubmed', term = query_term, field='title')
	r = Entrez.read(record)
	csvwriter.writerow([query_term] + r['IdList'])

f.close()
pmid_file.close()