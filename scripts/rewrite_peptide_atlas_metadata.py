
def build_name_pmids_dict():
  name_pmids=dict()
  f=open('Hs_All_sample.tsv')
  f.readline() # don't care about first line with column names
  num=1  
  while True:
    num += 1
    line=f.readline()
    if line=='': break
    fields=line.split('\t')
    name = fields[2]
    std_name = get_std_name(name)
    pmid  = fields[3]
    #print(num, name, std_name, pmid)
    if not pmid.isdigit():
      print('WARN 1', 'line', num, 'pmid is not a number', name, pmid)
      continue
    if std_name not in name_pmids: name_pmids[std_name]=set()
    name_pmids[std_name].add( int(pmid) )
  f.close()
  return name_pmids



def build_name_samples_dict():
  name_samples=dict()
  f=open('Hs_All_sample.tsv')
  f.readline() # don't care about first line with column names
  num=1  
  while True:
    num += 1
    line=f.readline()
    if line=='': break
    fields=line.split('\t')
    name = fields[2]
    std_name = get_std_name(name)
    sample  = fields[0]
    #print(num, name, std_name, sample)
    if not sample.isdigit():
      print('WARN 2', 'line', num, 'sample is not a number', name, sample)
      continue
    if std_name not in name_samples: name_samples[std_name]=set()
    name_samples[std_name].add( int(sample) )
  f.close()
  return name_samples



def get_std_name(name):
  return name.replace(' ','').replace(',','').replace('_','').replace('-','').lower()



def rewrite_metadata():

  f_in=open('metadata.txt')
  f_out=open('metadata.peptide_atlas.new','w')
  atlas_id = None
  atlas_cc_line = None
  while True:
    line = f_in.readline()
    if line == '': break
    if line[0: 2]=="ID": 
      atlas_id = None
      atlas_cc_line = None 
    if line[0:18]=="ID   PeptideAtlas ":
      atlas_id = get_std_name(line.strip()[18:]) 
      #print(atlas_id, line.strip())
         
    if atlas_id is not None and line[0:2]=="DR": 
      # we skip outdated DR lines (list of pmids)
      continue

    elif atlas_id is not None and line[0:2]=="CC":
      if line[0:10]=="CC   File:":
        atlas_cc_line = line
      else:
        # we skip outdated CC lines (list of samples)
        continue

    elif atlas_id is not None and line[0:2]=="//":
      # write DR lines based on new experiments.tsv file
      if atlas_id in name_pmids:       
        pmids = list(name_pmids[atlas_id])
        pmids.sort()
        for pmid in pmids:
          f_out.write('DR   PubMed; ' + str(pmid) + '.\n' )
      else:
        print('WARN 3', 'No pmids found for',  atlas_id)

      if atlas_id in name_samples:
        samples = list(name_samples[atlas_id])
        samples.sort()
        samples_str = "; ".join(str(s) for s in samples)
        f_out.write('CC   PeptideAtlas sampleID(s): ' + samples_str + '.\n' )
      else:
        print('WARN 4', 'No samples found for',  atlas_id)

      f_out.write(atlas_cc_line)
      f_out.write('//\n')   
 
    else:
      f_out.write(line)

  f_in.close()
  f_out.close()


# ------------------------------
# Main program
# ------------------------------

print('INFO', 'Building peptide atlas set name / pmids dictionary')
name_pmids = build_name_pmids_dict()
print("INFO", "dico name_pmids   size", len(name_pmids)   )

print('INFO', 'Building peptide atlas set name / samples dictionary')
name_samples = build_name_samples_dict()
print("INFO", "dico name_samples size", len(name_samples) )

print('INFO', 'Rewriting metadata.txt in metadata.peptide_atlas.new') 
rewrite_metadata()
print("End")

