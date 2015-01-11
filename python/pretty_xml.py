import sys
from lxml import etree
xml_str = sys.argv[0]
root = etree.fromstring(xml_str)
print etree.tostring(root, pretty_print=True)
