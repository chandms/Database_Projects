import json


file = open("airport.json",)

data = json.load(file)

l = len(data['results'][0]['columns'])
print("num of columns : ",l)

vals=[]

for item in data['results'][0]['items']:
	for y in item:
		if(y=='gmtoffset'):
			vals.append(item[y])

print(max(vals))
print(min(vals))

file.close()



