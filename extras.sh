#!/bin/bash

slicerHome="/home/lapsi/Documentos/Slicer-4.3.0-linux-amd64"
freeSurferHome="/usr/local/freesurfer"
estudo=$1
sujeito=$2



#corregisto da lhOCC, rhOcc, aparc+aseg

$slicerHome'/Slicer3' --launch $slicerHome'/lib/Slicer3/Plugins/ResampleVolume2' /usr/local/freesurfer/subjects/$sujeito/mri/lhoccipital.nii.gz $estudo/lhocc.nhdr -f $estudo/transform2.tfm -R $estudo/mask.nrrd --bulk --transform_order output-to-input -i nn

$slicerHome'/Slicer3' --launch $slicerHome'/lib/Slicer3/Plugins/ResampleVolume2' /usr/local/freesurfer/subjects/$sujeito/mri/rhoccipital.nii.gz $estudo/rhocc.nhdr -f $estudo/transform2.tfm -R $estudo/mask.nrrd --bulk --transform_order output-to-input -i nn

$slicerHome'/Slicer3' --launch $slicerHome'/lib/Slicer3/Plugins/ResampleVolume2' /usr/local/freesurfer/subjects/$sujeito/mri/aparc.a2009s+aseg.nii.gz $estudo/aparc.a2009s+aseg.nhdr -f $estudo/transform2.tfm -R $estudo/mask.nrrd --bulk --transform_order output-to-input -i nn


#All fiberbundle

'/home/lapsi/Documentos/Slicer3-3.6.3-2011-03-04-linux-x86_64/Slicer3' --launch '/home/lapsi/Documentos/Slicer3-3.6.3-2011-03-04-linux-x86_64/lib/Slicer3/Plugins/Seeding' /usr/local/Estudos/EstudoOCD/Analise_DTI_OCD/ControloDICOM/ANJOS_ANTONIO_MIGUEL_NEVES_FERREIRA/lili/dti.nhdr /usr/local/Estudos/EstudoOCD/Analise_DTI_OCD/ControloDICOM/ANJOS_ANTONIO_MIGUEL_NEVES_FERREIRA/lili/mask.nrrd /usr/local/Estudos/EstudoOCD/Analise_DTI_OCD/ControloDICOM/ANJOS_ANTONIO_MIGUEL_NEVES_FERREIRA/lili/allFB.vtp -s 2 -f FractionalAnisotropy -o 1

#criar o cc
$slicerHome'/Slicer' --launch $slicerHome'/lib/Slicer-4.3/cli-modules/ThresholdScalarVolume' --thresholdtype Outside -l 251 -u 255 $estudo/asegFinal.nhdr $estudo/cc.nhdr

#processartractography $n>4 -> label numbers
i=1
for p in $*; do
if [ $i -gt 2 ]; then
$slicerHome'/Slicer3' --launch $slicerHome'/lib/Slicer3/Plugins/Seeding' $estudo/dti.nhdr $estudo/aseg$p.vtp  -a $estudo/asegFinal.nhdr -s 1 -f FractionalAnisotropy -o $p
fi
let i=i+1
done
