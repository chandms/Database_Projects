import sys
import json
import pymongo
from json import JSONEncoder
from bson.json_util import loads, dumps

## connecting with local mongo client
myclient = pymongo.MongoClient("mongodb://localhost:27017/")
## using data base named cs541
mydb = myclient["cs541"]


## storing command line argument
command_line_arguments = sys.argv

## removing the parser's name from cmd args
argument_list = command_line_arguments[1:]

## json file to parse
json_file_name = argument_list[0]

## collection name
table_name = argument_list[1]

## number of columns to consider 
num_of_cols = int(argument_list[2])

## number of coluns which can be nested
num_of_q = int(argument_list[3])


id_of_last_col = 4+num_of_cols

columns = argument_list[4:id_of_last_col]
print(columns)


checks = []
lst1=[]
lst2=[]
lst3=[]

## storing the mapping 
## for each of the selected for nested element
## take input -> how many dependency (integer)
## for each, we take user input as below
## (collection_name  name_of_the_element_in_collection here_name)
print(id_of_last_col, len(argument_list))
for j in range(id_of_last_col,id_of_last_col+num_of_q):
	checks.append(argument_list[j])
	print(argument_list[j])
	ct = input("enter number of associated collections with \n")
	ct = int(ct)
	tl1=[]
	tl2=[]
	tl3=[]
	for y in range(ct):
		ln = input()
		tab,rel,act = ln.split() # table name, name in real table, here name
		tl1.append(tab)
		tl2.append(rel)
		tl3.append(act)
	lst1.append(tl1)
	lst2.append(tl2)
	lst3.append(tl3)





print(checks) ## for the columns we need to query
print(lst1) ## the collection, we need to query
print(lst2) ## the column we need to input
print(lst3)


mycol = mydb[table_name]






## opening the json file
file = open(json_file_name,)

data = json.load(file)

my_res=set()

## ouput is stored under mongo_script folder
sql_script_name = json_file_name.split('.')[0]
sql_script_name = 'mongo_script/'+table_name + '_script.json'

print(sql_script_name)

## opeing the json file in write mode
fw = open(sql_script_name,"w+")

my_list=[]

my_set=set()

it=0

## iterating over the items
for item in data['results'][0]['items']:
	dct={}
	data_dct={}

	# storing the values associated with
	# each selected column for the document
	for cols in columns:
		data_dct[cols]=item[cols.lower()]

	## creating the query to get information
	## about the nested object
	for cols in columns:
		flag=0
		if(cols in checks):
			qc={}
			flag=1
			id_col = checks.index(cols)
			x = lst1[id_col]
			y = lst2[id_col]
			z = lst3[id_col]
			mc = mydb[x[0]]
			# for only one dependency, we can directly query
			if(len(x)==1):
				my_q={y[0]:item[cols.lower()]}
				my_d = mc.find(my_q)
			else:
				# adding and to depending parameters
				qlst=[]
				for ui in range(len(x)):
					g = y[ui].split('.')[0]
					qq = {y[ui]:data_dct[z[ui]]}
					qlst.append(qq)
				qc["$and"]=qlst 
				my_d = mc.find(qc)
		if flag==0:	
			rem = str(item[cols.lower()])
			if(type(item[cols.lower()]) is str):
				dct[cols]=rem
			else:
				rem = item[cols.lower()]
				dct[cols]=rem
		else:
			ll = list(my_d)
			if(len(ll)>=1):
				dct[cols]=ll[0]

	if(str(dct) not in my_set):
		my_list.append(dct)
		my_set.add(str(dct))
	it+=1




# inserting the records 
ack = mycol.insert_many(my_list)

print("ack: ", ack)


## output is a json file which can be uploaded directly in compass
for j in my_list:
	st = dumps(j)
	fw.write(st+"\n")




file.close()
fw.close()








