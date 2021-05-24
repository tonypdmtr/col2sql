###############################################################################
# [gawk] col2sql.awk -v p[os]=1,15,35 -v t[able]=T1 [<] filename
###############################################################################

BEGIN{
    if ((t) && (!table)) table = t
    if ((p) && (!pos)) pos = p
    if ((!table) && (!pos)) {
      printf "Usage: col2sql.awk -v p[os]=n1,n2,... -v t[able]=table_name\n"
      abort()
    }
    if (table) TABLE = table
    else TABLE = "mytable"
    NROFCOL=split(pos,tmp,",")
    q = "\x27"
    wd=""
    for (i=1; i<NROFCOL; i++)
      wd = wd sprintf("%d ",tmp[i+1]-tmp[i])
    wd = wd "9999"
    FIELDWIDTHS = wd
    fmtins = "INSERT INTO %s (%s) VALUES (%s);\n"
}

###############################################################################

END{
    if (!exit_flag) printf "END;\n"
}

###############################################################################

function abort() {
    exit_flag = 1
    exit
}

################################################################################

function trim(s){
    sub(/^[[:blank:]]+/,"",s)
    sub(/[[:blank:]]+$/,"",s)
    return s
}

################################################################################

function quote(s){
    sub(q,q q,s)
    return s
}

################################################################################

function isnum(s){
    gsub(/[[:digit:]]+/,"",s)
    return (s=="")
}

################################################################################

(FNR==1){
    COLLIST = ""
    for (i=1; i<=NROFCOL; i++){
        COLLIST = COLLIST ((COLLIST)?",":"") "\"" trim($i) "\""
    }
    printf "------------------------------------------\n"
    printf "-- Field widths %s\n",FIELDWIDTHS
    printf "-- Column list %s\n",COLLIST
    printf "------------------------------------------\n"
    printf "CREATE TABLE %s (%s);\n",TABLE,COLLIST
    printf "BEGIN;\n"
    next
}

################################################################################

{
    VALLIST = ""
    for (i=1; i<=NROFCOL; i++){
        val = trim($i)
        if (isnum(val)){
            VALLIST = VALLIST ((VALLIST)?",":"") val
        } else {
            VALLIST = VALLIST ((VALLIST)?",":"") q quote(val) q
        }
    }
    printf fmtins,TABLE,COLLIST,VALLIST
}

################################################################################
