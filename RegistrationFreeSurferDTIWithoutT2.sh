#!/bin/bash
##script para gerar as tratografias das labels para aseg, e gera ficheiro fa, trace, prependicular e parralel difusitivity; ainda gera um labelmap com o corpo caloso (partes)
##versão sem imagem T2
##Version Slicer4.3

SlicerHome="/home/lapsi/Documentos/Slicer-4.3.0-linux-amd64"
FreeSurferHome="/usr/local/freesurfer"
DTIPrepHome="/home/lapsi/Documentos/extencoesSlicer/DTIPrep_1.1.6_linux64/"

estudo=$1
sujeito=$2


#mkdir $study/$sujeito

#estudo=$study/$sujeito


##convertToNrrd DTI - dicom diretory:$3 $SlicerHome/
##duas oportunidades: 1)com os DICOM 2)comFSL-NIFTI e depois 3)Phillips

##1)Dicom Siemens and Phillips
'/home/lapsi/Documentos/Slicer-4.3.0-linux-amd64/Slicer' --launch '/home/lapsi/Documentos/Slicer-4.3.0-linux-amd64/lib/Slicer-4.3/cli-modules/DWIConvert' --conversionMode DicomToNrrd --inputDicomDirectory $3 --outputVolume $estudo/dwi.nhdr

##2)FSL-NIFTI Siemens
#$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DWIConvert' --conversionMode FSLToNrrd --outputVolume $estudo/dwi.nhdr --inputVolume $estudo/*.nii --inputBVectors $estudo/*.bvec --inputBValues $estudo/*.bval

##3)Phillips, if not use the DWIconvert from DICOM
#'/home/lapsi/Documentos/Slicer-4.3.0-linux-amd64/Slicer' --launch '/home/lapsi/Documentos/Slicer-4.3.0-linux-amd64/lib/Slicer-4.3/cli-modules/DWIConvert' --conversionMode DicomToNrrd --inputDicomDirectory $4 --outputVolume $estudo/dwiBefore.nhdr
#unu crop -min 0 0 0 0 -max M M M M-1 -i input-dwi.nhdr -o output-dwi.nhdr


##correcao volumes DTI
$DTIPrepHome'/gtractCoregBvalues' --fixedVolume $estudo/dwi.nhdr --movingVolume $estudo/dwi.nhdr --outputVolume $estudo/dwi_ec.nhdr --eddyCurrentCorrection --maximumStepSize 0.1 --relaxationFactor 0.25 --outputTransform $estudo/ecTransform.tfm

##criar mask

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DiffusionWeightedVolumeMasking' --removeislands $estudo/dwi_ec.nhdr $estudo/basedti.nhdr $estudo/mask.nrrd

##processardti

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DWIToDTIEstimation' $estudo/dwi_ec.nhdr $estudo/dti.nhdr $estudo/basedti.nhdr -e WLS 

##mask a imagem DTI
##$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/MaskScalarVolume' $estudo/basedti.nhdr $estudo/mask.nrrd $estudo/base.nhdr

#converter aseg,brain com mri_convert (funcao do freeSurfer)
##
export FREESURFER_HOME=$FreeSurferHome
source $FREESURFER_HOME/SetUpFreeSurfer.sh

'/usr/local/freesurfer/bin/mri_convert' $FreeSurferHome/subjects/$sujeito/mri/brain.mgz $estudo/brain.nii.gz

'/usr/local/freesurfer/bin/mri_convert' $FreeSurferHome/subjects/$sujeito/mri/aseg.mgz $estudo/aseg.nii.gz

#'/usr/local/freesurfer/bin/mri_convert' $FreeSurferHome/subjects/$sujeito/mri/aparc.a2009s+aseg.mgz $estudo/aparc.a2009s+aseg.nii.gz

#coregisto (brainsfit, mask, brainsfit, resample)

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/BRAINSFit' --transformType ScaleSkewVersor3D,Affine --fixedVolume $estudo/basedti.nhdr --movingVolume $estudo/brain.nii.gz    --outputTransform $estudo/transform1.tfm --outputVolume $estudo/t1DTIunmasked.nhdr --initializeTransformMode useCenterOfHeadAlign --interpolationMode Linear

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/BRAINSResample' --inputVolume $estudo/aseg.nii.gz --outputVolume $estudo/asegFinal.nhdr --warpTransform $estudo/transform1.tfm --referenceVolume $estudo/mask.nrrd --interpolationMode NearestNeighbor --pixelType int


#processar metricas

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DiffusionTensorScalarMeasurements' $estudo/dti.nhdr $estudo/fa.nhdr -e FractionalAnisotropy

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DiffusionTensorScalarMeasurements' $estudo/dti.nhdr $estudo/trace.nhdr -e Trace

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DiffusionTensorScalarMeasurements' $estudo/dti.nhdr $estudo/pad.nhdr -e ParallelDiffusivity

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DiffusionTensorScalarMeasurements' $estudo/dti.nhdr $estudo/ped.nhdr -e PerpendicularDiffusivity

#criar o cc
$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/ThresholdScalarVolume' --thresholdtype Outside -l 251 -u 255 $estudo/asegFinal.nhdr $estudo/cc.nhdr

#processartractography $n>4 -> label numbers
i=1
for p in $*; do
if [ $i -gt 3 ]; then
$SlicerHome'/Slicer3' --launch $SlicerHome'/lib/Slicer3/Plugins/Seeding' $estudo/dti.nhdr $estudo/aseg$p.vtp  -a $estudo/asegFinal.nhdr -s 1 -f FractionalAnisotropy -o $p
fi
let i=i+1
done




######old#################################################
#corregisto da lhOCC, rhOcc, aparc+aseg

##$SlicerHome'/Slicer3' --launch $SlicerHome'/lib/Slicer3/Plugins/ResampleVolume2' /usr/local/freesurfer/subjects/$sujeito/mri/lhoccipital.nii.gz $estudo/lhocc.nhdr -f $estudo/transform2.tfm -R $estudo/mask.nrrd --bulk --transform_order output-to-input -i nn

##$SlicerHome'/Slicer3' --launch $SlicerHome'/lib/Slicer3/Plugins/ResampleVolume2' /usr/local/freesurfer/subjects/$sujeito/mri/rhoccipital.nii.gz $estudo/rhocc.nhdr -f $estudo/transform2.tfm -R $estudo/mask.nrrd --bulk --transform_order output-to-input -i nn

##$SlicerHome'/Slicer3' --launch $SlicerHome'/lib/Slicer3/Plugins/ResampleVolume2' /usr/local/freesurfer/subjects/$sujeito/mri/aparc.a2009s+aseg.nii.gz $estudo/aparc.a2009s+aseg.nhdr -f $estudo/transform2.tfm -R $estudo/mask.nrrd --bulk --transform_order output-to-input -i nn


#All fiberbundle

##'/home/lapsi/Documentos/Slicer3-3.6.3-2011-03-04-linux-x86_64/Slicer3' --launch '/home/lapsi/Documentos/Slicer3-3.6.3-2011-03-04-linux-x86_64/lib/Slicer3/Plugins/Seeding' /usr/local/Estudos/EstudoOCD/Analise_DTI_OCD/ControloDICOM/ANJOS_ANTONIO_MIGUEL_NEVES_FERREIRA/lili/dti.nhdr /usr/local/Estudos/EstudoOCD/Analise_DTI_OCD/ControloDICOM/ANJOS_ANTONIO_MIGUEL_NEVES_FERREIRA/lili/mask.nrrd /usr/local/Estudos/EstudoOCD/Analise_DTI_OCD/ControloDICOM/ANJOS_ANTONIO_MIGUEL_NEVES_FERREIRA/lili/allFB.vtp -s 2 -f FractionalAnisotropy -o 1





