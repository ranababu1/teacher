import json,sys,re,subprocess,os,ast
sys.stdout.reconfigure(encoding='utf-8')
REPO=os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','..'))
BASE='eb9164f'
TIC=re.compile(r" -- |—|\bgenuine(?:ly)?\b|\bactual(?:ly)?\b|\bexactly\b|\bprecise(?:ly)?\b|\bspecifically\b|\bdirectly\b|\bentirely\b|\bexplicit(?:ly)?\b|\bdeliberate(?:ly)?\b|\bsimply\b|\breal\b|\bconcrete(?:ly)?\b|\bstructural(?:ly)?\b|load-bearing|\bhonest(?:ly)?\b|\bworth (?:noting|being|naming|stating)|\b[Tt]h(?:is|e) concept (?:is|names|states|describes|explains|draws|warns)|\bsilently\b|\bquietly\b",re.I)
errs=[]
def prose(m):
    t=[]
    for c in m['concepts']:
        t+=[s['body'] for s in c['explanation']['sections']]+[e['explanation'] for e in c['examples']]+[x['clarification'] for x in c['misconceptions']]
        t+=[e.get('solutionExplanation')or'' for e in c['exercises']]+[(a.get('explanation')or'')+' '+(a.get('modelAnswer')or'') for a in c['assessments']]
    return '\n'.join(t)
plain=lambda s:re.sub(r'\s+',' ',s.replace('```',' ').replace('`','')).strip()
POS=re.compile(r"\b[Oo]ptions? ([A-D]|[1-4])\b|\b(first|last|previous) option\b|\bof the above\b")
def cmp(a,b,path):
    if type(a)!=type(b) and not(isinstance(a,(int,float)) and isinstance(b,(int,float))): errs.append(f'{path}: type changed');return
    if isinstance(a,dict):
        if list(a)!=list(b): errs.append(f'{path}: keys {list(a)} -> {list(b)}');return
        for k in a:
            if k in('id','type','difficulty','estimatedMinutes','prerequisites','correctOptionIndex','learningPathId','moduleId','topicId','language','difficultyLevel','order') and a[k]!=b[k]: errs.append(f'{path}.{k}: changed')
            cmp(a[k],b[k],f'{path}.{k}')
    elif isinstance(a,list):
        if len(a)!=len(b): errs.append(f'{path}: length {len(a)} -> {len(b)}');return
        for i,(x,y) in enumerate(zip(a,b)): cmp(x,y,f'{path}[{i}]')
    elif isinstance(a,str):
        if a.strip() and not b.strip(): errs.append(f'{path}: emptied')
for p in sys.argv[1:]:
    p=os.path.abspath(p);rel=os.path.relpath(p,REPO).replace('\\','/')
    raw=open(p,encoding='utf-8',newline='').read()
    try: new=json.loads(raw)
    except Exception as e: errs.append(f'{rel}: invalid JSON {e}');continue
    old_raw=subprocess.run(['git','-C',REPO,'show',f'{BASE}:{rel}'],capture_output=True).stdout.decode('utf-8');old=json.loads(old_raw)
    cmp(old,new,rel.split('/')[-1])
    if raw.replace('\r\n','\n').count('\n')!=old_raw.replace('\r\n','\n').count('\n'): errs.append(f'{rel}: line count changed {old_raw.count(chr(10))} -> {raw.count(chr(10))} (keep formatting)')
    L=n=S=0
    for c in new['concepts']:
        for a in c['assessments']:
            if a['type']!='multipleChoice': continue
            n+=1;o=a['options'];ci=a['correctOptionIndex'];ln=[len(x) for x in o]
            L+=ln[ci]>=max(ln);S+=ln[ci]<=min(ln)
            if len(set(o))!=len(o): errs.append(a['id']+': duplicate options')
            for t in [a['explanation']]+o:
                if POS.search(t): errs.append(a['id']+': refers to option by position: '+t[:80])
            for q in re.findall('“([^”]*)…”',a['explanation']):
                h=[i for i,x in enumerate(o) if plain(x).startswith(plain(q))]
                if q and (len(h)!=1 or h[0]==ci): errs.append(f"{a['id']}: quote “{q}…” matches options {h} (correct {ci})")
    if n and L/n>=.67: errs.append(f'{rel}: correct is longest in {L}/{n}')
    if n and S/n>=.67: errs.append(f'{rel}: correct is shortest in {S}/{n}')
    po,pn=prose(old),prose(new);wo,wn=len(po.split()),len(pn.split())
    print(f"{rel}: words {wo}->{wn} ({100*wn/wo:.0f}%), tics/1k {1000*len(TIC.findall(po))/wo:.1f}->{1000*len(TIC.findall(pn))/wn:.1f}")
    if wn<.72*wo: errs.append(f'{rel}: prose shrank to {100*wn/wo:.0f}% of the original; check nothing useful was deleted')
print('\n'.join(errs[:60]) if errs else 'OK')
sys.exit(1 if errs else 0)
