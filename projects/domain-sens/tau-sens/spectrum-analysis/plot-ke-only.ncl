load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
;  Colin Zarzycki 6/1/17
;  read output spectra from KE calculations
;  averages over time dimension (smoother KE profiles based on Skamarock et al.) if > 1
;  much faster than calc'ing/plotting each time


begin

plottitle="ne0conus60x4_200mb_KE"
; filelist = *.nc outputs from calc-ke-colin-regglob.ncl
; filelabs = labels for plot
do_normalize=True
plot_ref_lines=True

filelist=(/"spectrum_VORT850_MASKI_F_tau3600_lowdmpdz2.nc","spectrum_VORT850_MASKI_F_dtime1800.nc","spectrum_VORT850_MASKI_F_tau3600.nc","spectrum_VORT850_MASKI_F_dtime900.nc"/)
;filelabs=(/"reduced HV","control","spectrum_hindcast_conus_30_x8_CAM5_L30.nc"/)
filelabs=filelist

nfiles=dimsizes(filelist)

k   = new((/nfiles,1000/),"float")
spc = new((/nfiles,1000/),"float")
kkm = new((/nfiles,1000/),"float")

do ii = 0,nfiles-1
  f1=addfile(filelist(ii),"r")
  k1a=f1->x
  spc1a=f1->spc
  kkm1a=f1->k

  k1 = dim_avg_n_Wrap(k1a,0)
  spc1=dim_avg_n_Wrap(spc1a,0)
  kkm1=dim_avg_n_Wrap(kkm1a,0)
  numbands=dimsizes(k1)
  numbandsm1=numbands-1
  k(ii,0:numbandsm1)=tofloat(k1)
  spc(ii,0:numbandsm1)=tofloat(spc1)
  kkm(ii,0:numbandsm1)=tofloat(kkm1)
  if (do_normalize) then
    spc(ii,0:numbandsm1) = spc(ii,0:numbandsm1) / dim_avg_n_Wrap(spc(ii,0:4),0)
  end if

  print(k1+" "+kkm1+" "+spc1)
  delete(k1a)
  delete(spc1a)
  delete(kkm1a)
  delete(k1)
  delete(spc1)
  delete(kkm1)
  delete(numbands)
  delete(numbandsm1)
  delete(f1)
end do

print("here")

spc(:,119) = spc@_FillValue

;if (do_normalize) then
;  normix=1
;  do ii = 0,nfiles-1
;    spc(ii,:) = spc(ii,:) / spc(normix,:)
;  end do
;end if


;-------------------------------------------------------------------------------

wks = gsn_open_wks("x11",plottitle)


  lthick = 3.0

  res=True
  res@gsnDraw=False
  res@gsnFrame=False

  res@vpWidthF = 0.7
  res@vpHeightF = 0.5

  res@xyXStyle ="Log"
  res@xyYStyle ="Log"
  res@tmXBMinorPerMajor = 8   
  res@tmXTMinorPerMajor = 8   
  res@tmYRMinorPerMajor = 8   
  res@tmYLMinorPerMajor = 8   
  res@tmYLLabelFont = 21    ;  21 = helvetica
  res@tmXBLabelFont = 21    ;  22 = helvetica-bold 

  res@tiMainString           = plottitle
  res@tiXAxisString          = "Wavenumber (k)"
  res@tiYAxisString          = "Kinetic energy, Power (m^2/s^2)"
  res@xyLineThicknessF = lthick

  colors = (/"white","black","OrangeRed4","Red3",\
  "red1","Red3","Red4","Blue",\
  "OrangeRed1","OrangeRed2","OrangeRed3","OrangeRed4","DarkOrange",\
  "red1","red2","red3","red4",\
  "DarkTurquoise","Turquoise","Cyan","blue",\
  "gold","greenyellow",\
  "GoldenRod","DarkGoldenRod1","lightgoldenrod1","lightyellow","lightgoldenrodyellow","khaki1"\
  /)
  gsn_define_colormap(wks, colors)
    
  res@trXMinF = 5      
  res@trXMaxF = 120      
  res@trYMinF = 4e-3     
  res@trYMaxF = 8e-1 
  
  res@xyDashPattern = 0

  res@pmLegendDisplayMode    = "Always"   ; Display a legend

  res@xyLineColors = (/"turquoise","red","green","blue"/)
  ;do ii = 0,nfiles-1
  ;   = colors(ii)
  ;  plot  = gsn_xy (wks,k(ii,:),spc(ii,:),res) ; create plot
  ;end do

  ;res@trYMinF                = -3.5      ; Leave space at bottom for legend

  res@xyExplicitLegendLabels = filelabs

  res@lgJustification        = "TopRight"
  res@pmLegendOrthogonalPosF = -1.18    ; Move into plot
  res@pmLegendParallelPosF   = 0.99       ; Move to right
  res@pmLegendWidthF         = 0.15       ; Decrease width
  res@pmLegendHeightF        = 0.10       ; Decrease height
  res@lgBoxMinorExtentF      = 0.15       ; Shorten the legend lines
  res@lgLabelFontHeightF     = 0.010     ; Change the font size

  plot  = gsn_csm_xy (wks,k,spc,res) ; create plot

  ;xref = (/5E-6,5E-5/)
  ;spc_ref = 5*(xref*100000)^(-3) ; make it 6 @ k=15

  if (plot_ref_lines) then
    polyres                  = True
    polyres@gsLineThicknessF = lthick
    polyres@gsLineColor = "black"

    xref = (/1.,300./)
    spc_ref = .001*(xref)^(-1) ; make it 6 @ k=15
    dum2=gsn_add_polyline(wks,plot,xref,spc_ref,polyres)
  end if

  draw(plot)
  frame(wks)
;  frame(wks)                                     ; now advance
  



end
