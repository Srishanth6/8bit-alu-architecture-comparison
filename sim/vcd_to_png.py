"""Convert sim/alu_wave.vcd (from tb/tb_alu_wave.v) into docs/alu_waveform.png.
Run from the repository root:  python3 sim/vcd_to_png.py  (needs matplotlib)
"""
import matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt
ids={}; ch={}; t=0; depth=0; ts=1
lines=open('sim/alu_wave.vcd').read().split('\n')
for i,l in enumerate(lines):
    p=l.split()
    if not p: continue
    if p[0]=='$timescale':
        u=' '.join(lines[i:i+3]); ts=1000 if 'ps' in u else 1
    if p[0]=='$scope': depth+=1
    elif p[0]=='$upscope': depth-=1
    elif p[0]=='$var' and depth==1: ids[p[3]]=p[4]
    elif p[0][0]=='#': t=int(p[0][1:])/ts
    elif p[0][0]=='b' and len(p)==2 and p[1] in ids:
        ch.setdefault(ids[p[1]],{})[t]=None if 'x' in p[0] else int(p[0][1:],2)
    elif p[0][0] in '01xz' and len(p)==1 and p[0][1:] in ids:
        ch.setdefault(ids[p[0][1:]],{})[t]=int(p[0][0]) if p[0][0] in '01' else None
END=t
sig=['opcode','A','B','Y_rca','Y_cla','C_r','C_c','Z_r','Z_c','N_r','N_c','V_r','V_c']
fig,ax=plt.subplots(len(sig),1,figsize=(13,9),sharex=True)
for a,s in zip(ax,sig):
    c=sorted(ch[s].items()); bus=s in('opcode','A','B','Y_rca','Y_cla')
    for k,(t0,v) in enumerate(c):
        t1=c[k+1][0] if k+1<len(c) else END
        if bus:
            a.plot([t0,t0+.4,t1-.4,t1],[.5,1,1,.5],'b',lw=1);a.plot([t0,t0+.4,t1-.4,t1],[.5,0,0,.5],'b',lw=1)
            a.text((t0+t1)/2,.5,'x' if v is None else f'{v:02X}',ha='center',va='center',fontsize=8)
        else:
            a.plot([t0,t1],[v,v],'g')
            if k+1<len(c): a.plot([t1,t1],[v,c[k+1][1]],'g')
    a.set_yticks([]);a.set_ylabel(s,rotation=0,ha='right',va='center');a.set_ylim(-.2,1.2)
ax[-1].set_xlabel('time (ns)')
fig.suptitle('8-bit ALU, RCA vs CLA: directed stimulus (Icarus Verilog 12.0, tb/tb_alu_wave.v)')
plt.tight_layout();plt.savefig('docs/alu_waveform.png',dpi=110)
