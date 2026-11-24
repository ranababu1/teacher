import json,os
for r in json.load(open(os.path.join(os.environ['TEMP'],'audit_run','res.json'),encoding='utf-8')):
    if r['st'] in('compile','error','timeout','harness'): print('!!',r['id'],r['type'],r['st'],(r.get('err')or'')[:260].replace('\n',' / '),'| EXP',str(r['exp'])[:150])
    elif r['st']=='ok' and r['type']=='predictOutput' and (r['exp']or'').strip()!=r['out'].strip().replace('\r',''): print('DIFF',r['id'],repr(r['exp'])[:250],repr(r['out'])[:250])
