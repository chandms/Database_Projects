import sys
import json


# to add escape character if the line has single apostrophe1
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


# takes command line arguments (store as a list)
command_line_arguments = sys.argv

# to remove the name of the program from commad argument list
argument_list = command_line_arguments[1:]

# the number of arguments can't be less than 3
if(len(argument_list)<3):
	print ("number of arguments is not valid")
	exit(1)

# input json file 
json_file_name = argument_list[0]

# new table name
table_name = argument_list[1];

# rest all are columns which need to be included in this table
columns = argument_list[2:]


# opening the json file
file = open(json_file_name,)

# loading the json data
data = json.load(file)

my_res=set()


# new scripts will be added in the folder named script
# in the same directory
sql_script_name = json_file_name.split('.')[0]
sql_script_name = 'script/'+table_name + '_script.sql'

print(sql_script_name)

# opening the script to write data in it
fw = open(sql_script_name,"w+")

# creating the string with all the columns as: a,b,c,d,e
query_col=""
for col in columns:
	if(query_col==""):
		query_col = query_col + col
	else:
		query_col = query_col + ", "
		query_col = query_col + col

# iterating over each item in the json file
for item in data['results'][0]['items']:
	# initiating the resultant string
	res_str=""
	# for each of the columns obtained 
	# in command line argument
	for cols in columns:
		# escaping single apostrophe1
		rem = esc_str(str(item[cols.lower()]))
		if(type(item[cols.lower()]) is str):
			rem = "'"+rem+"'"
		else:
			rem = str(item[cols.lower()]) # which ever case was obtained in
										  # commad line arg, is converted to
										  #lower case
		if (res_str==""):
			res_str = res_str + rem
		else:
			res_str = res_str + ", "
			res_str = res_str + rem
	res_str = "( "+res_str +" )"

	# preparing the query
	query = 'INSERT INTO '+table_name+' ( '+query_col+' ) VALUES '+res_str+' ;\n'
	my_res.add(query) # storing each query in the set 
	

# iterating over the set and storing in file
for qry in my_res:
	fw.write(qry)
	print(qry)

file.close()
fw.close()








