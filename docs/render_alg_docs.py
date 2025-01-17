from pathlib import Path
import json
from docs_utils import *
import bibtexparser

def info_to_table(info, p):
    tab = ".. list-table:: \n\n"#+p.name+"\n\n"

    if info["package"]["title"] == "":
        tab += "   * - Package\n"    
        tab += "     - \n"
        tab += "   * - Version\n"
        tab += "     - \n"
    else:
        tab += "   * - Package\n"    
        tab += "     - `"+info["package"]["title"]+" <"+info["package"]["url"]+">`__\n"    
        tab += "   * - Version\n"
        tab += "     - "+info["version"]+"\n"
    tab += "   * - Language\n"
    tab += "     - "+str2link(info["language"])+"\n"
    tab += "   * - Docs\n"
    if info["docs_url"] == "":
        tab += "     - \n"
    else:
        tab += "     - `here <"+info["docs_url"]+">`__\n"
    tab += "   * - Paper\n"
    tab += "     - "
    
    if (p/'bibtex.bib').is_file():
        with open(p/'bibtex.bib') as bibtex_file:
            bibtex_database = bibtexparser.load(bibtex_file)        

        if len(bibtex_database.entries) > 0:            
            for ref in bibtex_database.entries:
                
                tab += ":footcite:t:`"+ref["ID"] +"`, "
        else:
            tab += "  "
    # for i in range(len(info["papers"])):
    #     if info["papers"][i]["title"] != "":
    #         tab += "`"+info["papers"][i]["title"]+" <"+info["papers"][i]["url"]+">`_, "  
    else:
        tab += "  "
    tab = tab[:-2]
    tab += "\n"
    tab += "   * - Graph type\n"
    tab += "     - "
    for i in range(len(info["graph_types"])):
        tab += str2link(info["graph_types"][i]) +", "
    tab = tab[:-2]
    tab += "\n"
    tab += "   * - Docker \n"
    tab += "     - " +get_docker_img(p / "rule.smk") + "\n"
    #tab += "     - `"+info["docker_image"]+" <https://hub.docker.com/r/"+info["docker_image"].split("/")[0]+"/"+info["docker_image"].split("/")[1].split(":")[0]+">`__\n"
    tab += "   * - Module folder\n"
    tab += "     - `"+p.name+" <https://github.com/felixleopoldo/benchpress/tree/master/workflow/rules/structure_learning_algorithms/"+p.name+">`__\n"
    tab += "\n"
    return tab

def info_to_small_table():
    algspath = Path("../workflow/rules/structure_learning_algorithms")
    tab = ""
    tab += ".. list-table:: \n"#+p.name+"\n\n"
    tab +="   :header-rows: 1 \n\n"
    tab += "   * - Algorithm\n" 
    tab += "     - Graph\n" 
    #tab += "     - Lang.\n" 
    tab += "     - Package\n" 
    #tab += "     - Version\n" 
    tab += "     - Module\n" 
    
    for p in sorted(algspath.iterdir()):
        if p.name.startswith("."):
            continue
        #print(p.name)
        j = p/"info.json"
        if p.name == "docs.rst" or p.name == ".DS_Store":
            continue
        with open(j) as json_file:
            info = json.load(json_file)
            
        if "in_docs" in info and info["in_docs"] is False:
            continue

        #tab += "     - "+info["title"]+"\n"
        tab += "   * - "+info["title"]+"\n"
        tab += "     - "
        for i in range(len(info["graph_types"])):
            tab += str2link(info["graph_types"][i]) +", "
        tab = tab[:-2]
        
        tab += "\n"
        #tab += "     - "+info["language"]+"\n"
        if info["package"]["title"] == "":
            tab += "     - \n"
        else:
            tab += "     - `"+info["package"]["title"]+" <"+info["package"]["url"]+">`__\n"    
        #tab += "     - "+info["version"]+"\n"
        tab += "     - "+p.name+"_ \n"    
        
    tab += "\n"
    return tab

algspath = Path("../workflow/rules/structure_learning_algorithms")

f = open("source/algs_desc.rst", "r")
content = f.read()

outpur_str = ""
outpur_str += ".. _"+algspath.name+": \n\n"
outpur_str += "Algorithms\n"
outpur_str += "="*len(algspath.name) + "="*10
outpur_str += "\n\n"
outpur_str += content
outpur_str += "\n\n"
outpur_str += info_to_small_table()
outpur_str += "\n\n"
for p in sorted(algspath.iterdir()):

    if not p.is_dir():
        continue
    if p.name == "docs.rst" or p.name == ".DS_Store":
        continue
        
    d = p/"docs.rst"
    j = p/"info.json"
    s = p/"schema.json"
    if d.is_file():        
        f = open(d, "r")
        content = f.read()

    with open(j) as json_file:
        info = json.load(json_file)

    if "in_docs" in info and info["in_docs"] is False:
        continue
    
    schema = None

    with open(s) as json_file:    
        schema = json.load(json_file)
    
        if "examples" in schema["items"]:
            dump = json.dumps(schema["items"]["examples"], indent=2)
        else: dump = ""
    
  
    #outpur_str += "\n\n\n"
    #outpur_str +=".. _" + p.name +": "
    outpur_str += "\n\n"
    outpur_str += ".. _"+p.name+": \n\n"
    #outpur_str +="``" + p.name +"`` \n"
    outpur_str +="" + p.name +" \n"
    #outpur_str +="" + info["title"] +" ("+p.name+") \n"
    outpur_str +="-"*len(p.name) + "-"*4 + "\n"

    
    outpur_str += "\n"
    outpur_str += ".. rubric:: "+ info["title"]    
    outpur_str += "\n\n"
    outpur_str += info_to_table(info, p)
    outpur_str += "\n\n"
    outpur_str += ".. rubric:: Description"    
    if content != "":    
        outpur_str += "\n\n"
        outpur_str += content
    outpur_str += "\n\n"
    
    with open(s) as json_file:    
        schema = json.load(json_file)

    tmp = any(["description" in obj 
           for prop, obj in schema["items"]["properties"].items() 
           if prop != "id"])

    if tmp:
        outpur_str += ".. rubric:: Some fields described \n"
        for prop, obj in sorted(schema["items"]["properties"].items()):
            if prop == "id":
                continue
            if "description" in obj:                
                outpur_str += "* ``{}`` {} \n".format(prop, obj["description"])
    
    # # downloadable linke to config files in config folder
    # outpur_str += "\n\n\n"
    # outpur_str += ".. rubric:: Config files"
    # outpur_str += "\n\n"
    # for conffile in (p / "config").glob("*.json"):
    #     xx = str(".."/ conffile)
    #     outpur_str += ":download:`"+conffile.name+" <"+xx + ">` \n"
                
    outpur_str += "\n\n"
    
    outpur_str += ".. rubric:: Example JSON"
    outpur_str += "\n\n\n"
    outpur_str += ".. code-block:: json"    
    outpur_str += "\n\n"
    outpur_str += '    '.join(('\n'+dump.strip()).splitlines(True))
    outpur_str += "\n\n"
    outpur_str += ".. footbibliography::"
    outpur_str += "\n\n"

with open("source/available_structure_learning_algorithms.rst", "w") as text_file:
    text_file.write(outpur_str)