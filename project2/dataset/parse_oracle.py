import sys
import json

def esc_str(line):
	new_line=""
	g=0;
	for i in line:
		if(i=="'"):
			g=1
			new_line=new_line+"''"
		else:
			new_line = new_line+i
	return new_line


command_line_arguments = sys.argv

argument_list = command_line_arguments[1:]

if(len(argument_list)<3):
	print ("number of arguments is not valid")
	exit(1)

json_file_name = argument_list[0]

table_name = argument_list[1];

columns = argument_list[2:]



file = open(json_file_name,)

data = json.load(file)

my_res=set()

sql_script_name = json_file_name.split('.')[0]
sql_script_name = 'test_script/'+table_name + '_script.sql'

print(sql_script_name)
fw = open(sql_script_name,"w+")

query_col=""
for col in columns:
	if(query_col==""):
		query_col = query_col + col
	else:
		query_col = query_col + ", "
		query_col = query_col + col

for item in data['results'][0]['items']:
	res_str=""
	for cols in columns:
		rem = esc_str(str(item[cols.lower()]))
		if(type(item[cols.lower()]) is str):
			rem = "'"+rem+"'"
		else:
			rem = str(item[cols.lower()])
		if (res_str==""):
			res_str = res_str + rem
		else:
			res_str = res_str + ", "
			res_str = res_str + rem
	res_str = "( "+res_str +" )"
	query = 'INSERT INTO '+table_name+' ( '+query_col+' ) VALUES '+res_str+' ;\n'
	my_res.add(query)
	


for qry in my_res:
	fw.write(qry)
	print(qry)

file.close()
fw.close()








