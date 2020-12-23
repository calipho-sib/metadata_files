
def build_name_pmids_dict():
  name_pmids=dict()
  f=open('massive_experiments.txt')
  f.readline() # don't care about first line with column names
  num=1  
  while True:
    num += 1
    line=f.readline()
    if line=='': break
    fields=line.split('\t')
    names = fields[2].split(';')
    pmid  = fields[5].strip()
    # print(num, names, pmid)
    if not pmid.isdigit():
      print('WARN', 'line', num, 'pmid is not a number', names, pmid)
      continue
    for name in names:
      std_name = get_std_name(name)
      if std_name not in name_pmids: name_pmids[std_name]=set()
      name_pmids[std_name].add( int(pmid) )
  f.close()
  return name_pmids

def get_std_name(name):
  return name.replace(' ','').replace(',','').replace('_','').replace('-','').lower()

def rewrite_metadata():

  print('INFO', 'Building massive set name / pmids dictionary')

  name_pmids = build_name_pmids_dict()
  #for n in name_pmids: print(n, len( name_pmids[n] ) ) 

  print('INFO', 'Rewriting metadata.txt in metadata.new') 

  f_in=open('metadata.txt')
  f_out=open('metadata.new','w')
  massive_id = None
  massive_cc_line = None
  while True:
    line = f_in.readline()
    if line == '': break
    if line[0: 2]=="ID": 
      massive_id = None
      massive_cc_line = None 
    if line[0:13]=="ID   MassIVE ":
      massive_id = get_std_name(line.strip()[13:]) 
      #print(massive_id, line.strip())
         
    if massive_id is not None and line[0:2]=="DR": 
      # we skip outdated DR lines (list of pmids)
      continue

    elif massive_id is not None and line[0:2]=="CC":
      massive_cc_line = line

    elif massive_id is not None and line[0:2]=="//":
      # write DR lines based on new experiments.tsv file
      if massive_id in name_pmids:       
        pmids = list(name_pmids[massive_id])
        pmids.sort()
        for pmid in pmids:
          f_out.write('DR   PubMed; ' + str(pmid) + '.\n' )
      else:
        print('WARN', 'No pmids found for',  massive_id)
      
      f_out.write(massive_cc_line)
      f_out.write('//\n')   
 
    else:
      f_out.write(line)

  f_in.close()
  f_out.close()

  print('INFO', 'End')

# ------------------------------
# Main program
# ------------------------------

rewrite_metadata()

