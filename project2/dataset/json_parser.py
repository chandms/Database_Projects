import json


file = open("country-other-localname.json",)

data = json.load(file)

l = len(data['results'][0]['columns'])
print("num of columns : ",l)

s = set()

for item in data['results'][0]['items']:
	if(len(item)!=l):
		print (item)
	for y in item:
		if(item[y]==""):
			s.add(y)
print(s)

file.close()



