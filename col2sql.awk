# fixed width import
cat >in.tmp <<EOF
id Name          Address             Phone
1  John Doe      My street           555-1212
2  Marc O'Donnel His street          555-1313
EOF

gawk -v pos="1,4,18,38" -v table=T1 \
'BEGIN{
	if (table) TABLE    = table
	else TABLE = "mytable"
	NROFCOL=split(pos,tmp,",")
	q = "\x27"
	wd=""
	for (i=1;i<NROFCOL;i++) wd = wd sprintf("%d ",tmp[i+1]-tmp[i])
	wd = wd "999"
	FIELDWIDTHS = wd
	fmtins = "INSERT INTO %s (%s) VALUES (%s);\n"
}
function trim(s){
	sub(/^[[:blank:]]+/,"",s)
	sub(/[[:blank:]]+$/,"",s)
	return s
}
function quote(s){
	sub(q,q q,s)
	return s
}
function isnum(s){
	gsub(/[[:digit:]]+/,"",s)
	return (s=="")
}
(FNR==1){
	COLLIST = ""
	for (i=1;i<=NROFCOL;i++){
		COLLIST = COLLIST ((COLLIST)?",":"") trim($i)
	}
	printf "-- fieldwidths %s\n",FIELDWIDTHS
	printf "-- columnlist %s\n",COLLIST
	printf "CREATE TABLE %s (%s);\n",TABLE,COLLIST
	next
}
{
	VALLIST = ""
	for (i=1;i<=NROFCOL;i++){
		val = trim($i)
		if (isnum(val)){
			VALLIST = VALLIST ((VALLIST)?",":"") val
		} else {
			VALLIST = VALLIST ((VALLIST)?",":"") q quote(val) q
		}
	}
	printf fmtins,TABLE,COLLIST,VALLIST
}' in.tmp     # | sqlite3 import.sqlite
