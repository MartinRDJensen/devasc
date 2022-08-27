# Basic Conversions between Python data formats

## Parsing JSON
```
import json
from pprint import pprint

with open('test_json.json') as file:
    jh = file.read()
    json_py = json.loads(jh)
print("-"*10)
pprint(jh)
print(type(jh))
print("-"*10)
pprint(json_py)
print(type(json_py))
print("-"*10)
pprint(json.dumps(json_py))
print(type(json.dumps(json_py)))
```

## Parsing XML
```
import xmltodict
from pprint import pprint

with open('test_xml.xml') as fd:
    tmp = fd.read()
    doc = xmltodict.parse(tmp)

pprint(tmp)
pprint(doc)

note_content = doc['note']['body']

print(f"the body contained {note_content}")

xmlunparsed = xmltodict.unparse(doc)
pprint(xmlunparsed)
```

## Parsing YAML
```
import yaml
from pprint import pprint

with open('yamltest.yaml') as file:
    tmp = file.read()
    #yaml_py = yaml.full_load(tmp)
    yaml_py = yaml.safe_load(tmp)
print("-"*10)
pprint(tmp)
print("-"*10)
pprint(yaml_py)
print("-"*10)
```











