# Builds assets/icon/app_icon_{background,foreground,full}.png from the
# supplied reference artwork. Run from the repo root:
#   python3 tool/make_icon.py   (needs numpy, pillow, scipy)
# then: dart run flutter_launcher_icons
import sys
import numpy as np
from PIL import Image
from scipy import ndimage
src=np.asarray(Image.open(sys.argv[1] if len(sys.argv)>1 else 'assets/icon/source/teacher_icon_reference.png').convert('RGB')).astype(float)
H,W,_=src.shape
ys=np.arange(40,445)
samp=np.median(np.concatenate([src[ys,30:60],src[ys,426:456]],axis=1),axis=1)
fits=[np.polyfit(ys,samp[:,c],2) for c in range(3)]
bgrow=lambda y: np.stack([np.polyval(f,y) for f in fits],-1)
# background 1024
y=np.linspace(0,H-1,1024)
bg=np.clip(bgrow(y),0,255)
bgimg=np.repeat(bg[:,None,:],1024,axis=1).astype(np.uint8)
Image.fromarray(bgimg).save('assets/icon/app_icon_background.png')
print('bg top',bg[0].round(),'bottom',bg[-1].round())
# cutout
B=bgrow(np.arange(H))[:,None,:]
d=np.abs(src-B).max(-1)
m=d>14
m=ndimage.binary_closing(m,iterations=5)
m=ndimage.binary_fill_holes(m)
m=ndimage.binary_opening(m,iterations=2)
lab,n=ndimage.label(m); sizes=ndimage.sum(m,lab,range(1,n+1)); m=lab==(1+np.argmax(sizes))
# supersample for a smooth edge
big=Image.fromarray((m*255).astype(np.uint8)).resize((W*4,H*4),Image.LANCZOS)
from PIL import ImageFilter
big=big.filter(ImageFilter.GaussianBlur(3)).point(lambda v: max(0,min(255,(v-128)*3+128)))
a=np.asarray(big.resize((W,H),Image.LANCZOS)).astype(float)/255
col=src
rgba=np.dstack([col,a*255]).astype(np.uint8)
im=Image.fromarray(rgba,'RGBA')
bb=im.getbbox(); print('bbox',bb)
crop=im.crop(bb)
# premultiplied resize to avoid fringes
def resize_rgba(img,size):
    arr=np.asarray(img).astype(float); al=arr[...,3:]/255
    pm=np.dstack([arr[...,:3]*al,al*255]).astype(np.float32)
    ch=[np.asarray(Image.fromarray(pm[...,i],'F').resize(size,Image.LANCZOS)) for i in range(4)]
    al2=np.clip(ch[3],0,255)/255
    rgb=np.clip(np.stack(ch[:3],-1)/np.maximum(al2,1e-4)[...,None],0,255)
    return Image.fromarray(np.dstack([rgb,al2*255]).astype(np.uint8),'RGBA')
# Book fills ~80% of the layer width: One UI renders the whole layer
# under its squircle, so a safe-circle-sized book looked tiny there (see
# changelog 0.17.2). Pure circle masks trim the corners slightly.
w=int(1024*0.80); h=round(crop.height*w/crop.width)
book=resize_rgba(crop,(w,h))
fg=Image.new('RGBA',(1024,1024),(0,0,0,0)); fg.paste(book,((1024-w)//2,(1024-h)//2),book)
fg.save('assets/icon/app_icon_foreground.png')
full=Image.fromarray(bgimg).convert('RGBA'); full.alpha_composite(fg); full.convert('RGB').save('assets/icon/app_icon_full.png')
print('book px',w,h)
