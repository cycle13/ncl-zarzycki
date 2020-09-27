import matplotlib 
import matplotlib.pyplot as plt 
import xarray as xr
import numpy as np

## Say, "the default sans-serif font is COMIC SANS"
matplotlib.rcParams['font.sans-serif'] = "Helvetica"
## Then, "ALWAYS use sans-serif fonts"
matplotlib.rcParams['font.family'] = "sans-serif"
matplotlib.rcParams['pdf.fonttype'] = 42

tcfreqarr = [10.7,13.2,19.5]
#thisvar="OMEGA500"
config="dtime1800"
varslist = ['OMEGA500', 'PRECL', 'PRECC']
configlist = ['dtime1800', 'dtime900', 'tau3600']
ourvals=np.empty([len(varslist), len(configlist)])
for ii, thisvar in enumerate(varslist):
  for jj, config in enumerate(configlist):
    filename="../freq-hist/OUT_{}_{}_MASKI.nc".format(config, thisvar)
    print(filename)
    ds_disk = xr.open_dataset(filename)
    if thisvar == 'OMEGA500':
      ourvals[ii,jj] = ds_disk['stats'][22].values
    else:
      ourvals[ii,jj] = ds_disk['stats'][27].values

# Create a dict of nice pretty names
varprettynames = {
    'OMEGA500': '$\u03C9_{500}$',
    'PRECL': 'PRECL',
    'PRECC': 'PRECC'
}

# Create a dict of nice pretty names
configprettynames = {
    'dtime1800': '$dt_{1800}$',
    'dtime900': '$dt_{900}$',
    'tau3600': '$dt_{450}$'
}

print(ourvals)

fig = plt.figure()
host = fig.add_subplot(111)

par1 = host.twinx()

host.set_xlim(10., 20.)
host.set_ylim(-2.0, -0.6)
par1.set_ylim(0, 230.)

host.set_xlabel("TC freq. per year")
host.set_ylabel("500 hPa vertical pressure velocity (Pa/s)")
par1.set_ylabel("Precipitation rate (mm/day)")

color1 = plt.cm.viridis(0)
color2 = plt.cm.viridis(0.5)
color3 = plt.cm.viridis(.9)

#p1, = host.plot(tcfreqarr, [-1.836861,-1.394003,-0.953568], 's:', color=color1,label=varprettynames[varslist[0]])
#p2, = par1.plot(tcfreqarr, [181.4097,127.4959,69.38586], 's:', color=color2, label=varprettynames[varslist[1]])
#p3, = par1.plot(tcfreqarr, [38.64863,40.21495,45.49487], 's:', color=color3, label=varprettynames[varslist[2]])

p1, = host.plot(tcfreqarr, ourvals[0,:], 's:', color=color1,label=varprettynames[varslist[0]])
p2, = par1.plot(tcfreqarr, ourvals[1,:], 's:', color=color2, label=varprettynames[varslist[1]])
p3, = par1.plot(tcfreqarr, ourvals[2,:], 's:', color=color3, label=varprettynames[varslist[2]])

lns = [p1, p2, p3]
host.legend(handles=lns, loc=(0.52,0.81))

for jj, config in enumerate(configlist):
  host.annotate(configprettynames[configlist[jj]],
            xy=(tcfreqarr[jj],-0.73),
            xytext=(tcfreqarr[jj],-0.73),
            textcoords="data",
            ha='center', va='center', rotation=45)

## Set color of axis labels
#host.yaxis.label.set_color(p1.get_color())
#par1.yaxis.label.set_color(p2.get_color())

plt.savefig("pyplot_multiple_y-axis.pdf", bbox_inches='tight')
