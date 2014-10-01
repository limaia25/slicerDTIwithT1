@limaia25

# slicer DTI with T1

Este script serve para o corregisto da T1 no espaço DTI. Ver a página Wiki:
https://github.com/limaia25/slicerDTIwithT1/wiki

## Alterar a localização dos ficheiros dos programas necessários
No ficheiro *SlicerWithStudy* alterar as variaveis:
* FreeSurferHome
* SlicerHome
* DtiPrepHome

##Como executar
* Para executar o corregisto:
```bash
RegistrationFreeSurferDTI.sh name studyDirectory T2DicomDirectory DTIDicomDirectory
```
em que:
  1.  **name** é o nome do sujeito que se encontra na directoria dos sujeitos
  2.  **studyDirectory** é a directoria onde será criada uma directoria *name* e dentro desta serão guardados os outputs do pro grama
  3.  **T2DicomDirectory** é a directoria T2 onde estão todos os ficheiros DICOM da T2 do scan.
  4.  **DTIDICOMDirectory** é a directroria T1 onde estão todos os ficheiros DICOM da acquisição DTI do scan

* Para executar as opções:
Ver na [página wiki](github.com/limaia25/slicerDTIwithT1/wiki) as opções, e colocar em comentário as que não são necessárias.
```bash
extras.sh name studyDirectory label1 label2 ...
```
em que:
  1.  **label1** **label2** ... são as labels do ficheiro aseg que o utilizador quer a tractografia computarizada.
  
* Para executar o corregisto sem T2:
```bash
RegistrationFreeSurferDTIWithoutT2.sh name studyDirectory label1 label2 ...
```
