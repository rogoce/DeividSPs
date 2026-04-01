rem Batch que se encarga de Unir Todos los archivos pdf que se encuentran en una carpeta especifica.
rem	Requerimientos:	-Instalación de GhostScript 9.14
rem %1: Ruta y nombre del archivo pdf resultante **** Ejem: \\ruta_destino_archivo\nombre del archivo
rem %2: Ruta temporal donde se encuentra la instalación de ghostscript y donde se copiarán las imagenes con las que se creará el pdf **** Ejem: \\ruta_origen_archivos\
rem %3: Ruta de destino de los archivos finales. Ejem: \\ruta_destino\
rem Ejemplo de ejecución del batch jpg2pdf.bat C:\Temp_Image\jpg_orig C:\0054S145931\ C:\Temp_Image\

@echo off

set nombre_fotos=
set "str1= ("
set "str2=) << /PageSize 2 index viewJPEGgetsize 2 array astore  >> setpagedevice viewJPEG showpage"
set "str3= C:\gswin32.exe"

setlocal enabledelayedexpansion

rem *********** Crea la carpeta temporal en donde se copiaran las imagenes y el Ghostscript *********** 
if not exist %3 mkdir %3

C:
cd\
cd %3

rem *********** Listado de Archivos de la carpeta original ***********
dir %2*.jpg /b /s > %2files.lst

rem *********** Copiar el Ejecutable de GhostScript a la Ruta Temporal ***********
xcopy /-y !str3! %3

rem *********** Mover las imagenes de la carpeta original a la carpeta Temporal ***********
For /f "delims=<^>" %%a in (%2files.lst) do xcopy /-y "%%a" %3

rem *********** Listado de Imagenes de la carpeta temporal ***********
dir %3*.jpg /b /n > %3jpg.lst

rem *********** Arma la Cadena con la lista de Imagenes que se insertarán en el pdf *********** 
For /f "delims=<^>" %%a in (%3jpg.lst) do set nombre_fotos= !nombre_fotos!!str1!%%a!str2!
set nombre_fotos= !nombre_fotos:~1!

rem *********** Crear el pdf con todas las imagenes encontradas en la Carpeta Temporal *********** 
gswin32.exe -sDEVICE=pdfwrite -o %1.pdf viewjpeg.ps -c "!nombre_fotos!" 

rem *********** Eliminar los archivos con las listas de Imagenes *********** 
del %2files.lst

rem *********** Salir de la Carpeta Temporal*********** 
cd..
cd..

rem *********** Esperar 3 segundos y borrar la carpeta temporal *********** 
timeout 3
RD /S /Q %3