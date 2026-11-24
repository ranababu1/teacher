import json,sys,subprocess
f=sys.argv[1];o=json.loads(subprocess.run(['git','show','eb9164f:'+f],capture_output=True).stdout);n=json.load(open(f,encoding='utf-8'))
R=[]
def w(a,b,p):
    if isinstance(a,dict):
        for k in a:w(a[k],b[k],p+'.'+k)
    elif isinstance(a,list):
        for i,(x,y) in enumerate(zip(a,b)):w(x,y,p+'.%d'%i)
    elif isinstance(a,str) and a!=b:R.append((len(a.split())-len(b.split()),p,a,b))
w(o,n,'')
R.sort(reverse=True)
print(len(R))
for d,p,a,b in R[:int(sys.argv[2])]:print('\n##',d,p,'\nOLD',a,'\nNEW',b)
