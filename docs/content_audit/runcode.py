import json,glob,os,re,subprocess,sys,tempfile,concurrent.futures as cf,ast
OUT=os.path.join(os.environ['TEMP'],'audit_run');os.makedirs(OUT,exist_ok=True)
DANGER=re.compile(r"\b(requests\.|urllib|http\.client|socket|subprocess|os\.system|os\.remove|os\.unlink|shutil|rmtree|multiprocessing|ProcessPool|input\(|openai|anthropic|boto3|fetch\(|child_process|http\.createServer|net\.|process\.kill|fs\.(unlink|rm)|express|while True|System\.in|Scanner|ProcessBuilder|java\.net|Runtime\.getRuntime)")
def guess(code,k):
    if k in('java','spring-boot'): return 'java'
    if k in('nodejs','react'): return 'javascript'
    if k in('python','statistics','ai-ml','llm-engineering','vector-databases'): return 'python'
    if k=='devops' or k=='system-design' or k=='cloud-aws' or k=='databases':
        try: ast.parse(code);return 'python' if re.search(r'\b(def|print|import|for .* in)\b',code) else None
        except Exception: return None
items=[]
for p in sorted(glob.glob(sys.argv[1] if len(sys.argv)>1 else 'assets/curriculum/*/*.json')):
    k=os.path.basename(os.path.dirname(p))
    for c in json.load(open(p,encoding='utf-8'))['concepts']:
        for i,e in enumerate(c['examples']): items.append((k,c['id']+'#ex%d'%i,'example',e['language'],e['code'],None,None))
        for e in c['exercises']:
            l=guess(e.get('code') or e.get('solutionCode') or '',k)
            if e.get('code'): items.append((k,e['id'],e['type'],l,e['code'],e.get('expectedAnswer'),e.get('solutionExplanation')))
            if e.get('solutionCode'): items.append((k,e['id'],'solution',l,e['solutionCode'],e.get('expectedAnswer'),None))
        for a in c['assessments']:
            m=re.search(r"```(python|javascript|js|java|jsx)\n(.*?)```",a['prompt'],re.S)
            if m and a['type']=='multipleChoice': items.append((k,a['id'],'mcq',{'js':'javascript'}.get(m[1],m[1]),m[2],a['options'][a['correctOptionIndex']],a['explanation']))
def run(n):
    k,i,t,l,code,exp,_=items[n];r=dict(n=n,course=k,id=i,type=t,lang=l,exp=exp)
    if l not in('python','javascript','java'): r['st']='skip-lang';return r
    if DANGER.search(code):
        r['st']='skip-danger'
        if l=='python':
            try: ast.parse(code)
            except SyntaxError as e:
                r['st']='syntax';r['err']=str(e)
        return r
    d=tempfile.mkdtemp(dir=OUT)
    env=dict(os.environ,PYTHONIOENCODING='utf-8',PYTHONUTF8='1',MPLBACKEND='Agg',NO_COLOR='1')
    try:
        if l=='python': f='main.py';cmd=[sys.executable,'-W','ignore',f]
        elif l=='javascript':
            f='main.mjs' if re.search(r'^\s*(import .* from|export )',code,re.M) else 'main.cjs';cmd=['node',f]
        else:
            cls=re.findall(r'^(?:public )?(?:final |abstract |sealed )*(?:class|interface|enum|record) (\w+)',code,re.M)
            if 'static void main' not in code or 'springframework' in code: r['st']='skip-java-frag';return r
            m=re.search(r'public (?:final |abstract )*(?:class|interface|enum|record) (\w+)',code)
            f=(m[1] if m else 'Main')+'.java';cmd=None
        open(os.path.join(d,f),'w',encoding='utf-8',newline='\n').write(code)
        if cmd is None:
            x=subprocess.run(['javac','-encoding','UTF-8','-Xlint:none',f],cwd=d,capture_output=True,text=True,timeout=60,encoding='utf-8',errors='replace')
            if x.returncode: r.update(st='compile',err=x.stderr[-500:]);return r
            mc=None
            for cl in cls:
                y=re.search(r'class %s\b.*?static void main'%cl,code,re.S)
                if y: mc=cl
            # class whose body contains main = last class declared before main
            pos=code.index('static void main');mc=[m for m in re.finditer(r'^(?:public )?(?:final |abstract )*(?:class|record|enum|interface) (\w+)',code,re.M) if m.start()<pos][-1][1]
            cmd=['java','-cp','.',mc]
        x=subprocess.run(cmd,cwd=d,capture_output=True,text=True,timeout=25,env=env,encoding='utf-8',errors='replace',stdin=subprocess.DEVNULL)
        r.update(st='ok' if x.returncode==0 else 'error',out=x.stdout[-3000:],err=x.stderr[-700:])
    except subprocess.TimeoutExpired: r['st']='timeout'
    except Exception as e: r.update(st='harness',err=repr(e))
    return r
if __name__=='__main__':
    with cf.ThreadPoolExecutor(10) as ex: R=list(ex.map(run,range(len(items))))
    json.dump([dict(r,code=items[r['n']][4],expl=items[r['n']][6]) for r in R],open(os.path.join(OUT,'res.json'),'w',encoding='utf-8'))
    import collections
    print(len(items));
    for k,v in sorted(collections.Counter((r['lang'] or '-',r['type'],r['st']) for r in R).items()): print(k,v)
