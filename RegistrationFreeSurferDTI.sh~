#!/bin/bash
##script para o coregisto da T1 em DTI gera ficheiro fa, trace, prependicular e parralel difusitivity; ainda gera um labelmap com o corpo caloso (partes)
##Version Slicer4.3

SlicerHome="/home/lapsi/Documentos/Slicer-4.3.0-linux-amd64"
DTIPrepHome="/home/lapsi/Documentos/extencoesSlicer/DTIPrep_1.1.6_linux64/"
FreeSurferHome="/usr/local/freesurfer"


estudo=$1
sujeito=$2


mkdir $study/$sujeito

estudo=$study/$sujeito


##convertToNrrd DTI - dicom diretory:$4 $SlicerHome/
##duas oportunidades: 1)com os DICOM 2)comFSL-NIFTI e depois 3)Phillips

##1)Dicom Siemens and Phillips
'/home/lapsi/Documentos/Slicer-4.3.0-linux-amd64/Slicer' --launch '/home/lapsi/Documentos/Slicer-4.3.0-linux-amd64/lib/Slicer-4.3/cli-modules/DWIConvert' --conversionMode DicomToNrrd --inputDicomDirectory $4 --outputVolume $estudo/dwi.nhdr

##2)FSL-NIFTI Siemens
#$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DWIConvert' --conversionMode FSLToNrrd --outputVolume $estudo/dwi.nhdr --inputVolume $estudo/*.nii --inputBVectors $estudo/*.bvec --inputBValues $estudo/*.bval

##3)Phillips, if not use the DWIconvert from DICOM
#'/home/lapsi/Documentos/Slicer-4.3.0-linux-amd64/Slicer' --launch '/home/lapsi/Documentos/Slicer-4.3.0-linux-amd64/lib/Slicer-4.3/cli-modules/DWIConvert' --conversionMode DicomToNrrd --inputDicomDirectory $4 --outputVolume $estudo/dwiBefore.nhdr
#unu crop -min 0 0 0 0 -max M M M M-1 -i input-dwi.nhdr -o output-dwi.nhdr

##convertToNrrd T2 - dicom diretory:$3

$DTIPrepHome'/DicomToNrrdConverter' --inputDicomDirectory $3 --outputVolume $estudo/t2.nhdr

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

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/BRAINSFit' --transformType ScaleSkewVersor3D,Affine --fixedVolume $estudo/basedti.nhdr --movingVolume $estudo/t2.nhdr    --outputTransform $estudo/transform1.tfm --outputVolume $estudo/t2DTIunmasked.nhdr --initializeTransformMode useGeometryAlign --interpolationMode Linear


$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/MaskScalarVolume' $estudo/t2DTIunmasked.nhdr $estudo/mask.nrrd $estut2do/t2Dti.nhdr

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/BRAINSFit' --transformType ScaleSkewVersor3D,Affine --fixedVolume $estudo/t2Dti.nhdr --movingVolume $estudo/brain.nii.gz --outputTransform $estudo/transform2.tfm --outputVolume $estudo/brainDTI.nhdr --initializeTransformMode useGeometryAlign --interpolationMode Linear

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/BRAINSResample' --inputVolume $estudo/aseg.nii.gz --outputVolume $estudo/asegFinal.nhdr --warpTransform $estudo/transform2.tfm --referenceVolume $estudo/mask.nrrd --interpolationMode NearestNeighbor --pixelType int


#processar metricas

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DiffusionTensorScalarMeasurements' $estudo/dti.nhdr $estudo/fa.nhdr -e FractionalAnisotropy

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DiffusionTensorScalarMeasurements' $estudo/dti.nhdr $estudo/trace.nhdr -e Trace

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DiffusionTensorScalarMeasurements' $estudo/dti.nhdr $estudo/pad.nhdr -e ParallelDiffusivity

$SlicerHome'/Slicer' --launch $SlicerHome'/lib/Slicer-4.3/cli-modules/DiffusionTensorScalarMeasurements' $estudo/dti.nhdr $estudo/ped.nhdr -e PerpendicularDiffusivity











