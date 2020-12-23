show_file=False
f=open("../metadata.txt")
while True:
  line = f.readline()
  if line=='': break
  line=line.strip()
  if line[0:2]=="ID":
    show_file=False
    if line[0:13]=="ID   MassIVE ": 
      show_file=True
      #print(line)
  if line[0:2]=="CC":
    if show_file: print(line[11:])

f.close()
