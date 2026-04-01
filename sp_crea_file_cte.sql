-- Procedure para crear archivo de clientes para ser enviado a MKIT-DATAQUALITY
--
-- Creado    : 17/09/2007 - Autor: Lic. Armando Moreno 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_crea_file_cte;

CREATE PROCEDURE "informix".sp_crea_file_cte()
RETURNING char(10),varchar(100),varchar(100),varchar(50),char(1),varchar(30),char(10),char(10),date,char(1),char(100),char(2),char(2),char(6),char(6),char(6),char(100),char(40),char(40),char(40),smallint,smallint,char(10);

define _cod_cliente 	  varchar(10)	   ;
define _nombre 			  varchar(100) ;
define _nombre_razon 	  varchar(100) ;
define _direccion_1 	  varchar(50,0);
define _tipo_persona 	  char(1)	   ;
define _cedula 			  varchar(30,0);
define _telefono1 		  char(10)	   ;
define _telefono2 		  char(10)	   ;
define _fecha_aniversario date		   ;
define _sexo 			  char(1)	   ;
define _nombre_original   char(100)	   ;
define _ced_provincia 	  char(2)	   ;
define _ced_inicial 	  char(2)	   ;
define _ced_tomo 		  char(7)	   ;
define _ced_folio 		  char(7)	   ;
define _ced_asiento 	  char(7)	   ;
define _aseg_primer_nom   char(100)	   ;
define _aseg_primer_ape   char(40)	   ;
define _aseg_segundo_ape  char(40)	   ;
define _aseg_casada_ape   char(40)	   ;
define _ced_correcta 	  smallint	   ;
define _pasaporte 		  smallint	   ;
define _celular 		  char(10) 	   ;
define _flag              integer;

SET ISOLATION TO DIRTY READ;		   

let _flag = 0;

FOREACH WITH HOLD

	SELECT cod_cliente,
	       nombre,
		   nombre_razon,
		   direccion_1,
		   tipo_persona,
		   cedula,
		   telefono1,
		   telefono2,
		   fecha_aniversario,
		   sexo,
		   nombre_original,
		   ced_provincia,
		   ced_inicial,
		   ced_tomo,
		   ced_folio,
		   ced_asiento,
		   aseg_primer_nom,
		   aseg_primer_ape,
		   aseg_segundo_ape,
		   aseg_casada_ape,
		   ced_correcta,
		   pasaporte,
		   celular
	  INTO _cod_cliente,
		   _nombre,
		   _nombre_razon,
		   _direccion_1,
		   _tipo_persona,
		   _cedula,
		   _telefono1,
		   _telefono2,
		   _fecha_aniversario,
		   _sexo,
		   _nombre_original,
		   _ced_provincia,
		   _ced_inicial,
		   _ced_tomo,
		   _ced_folio,
		   _ced_asiento,
		   _aseg_primer_nom,
		   _aseg_primer_ape,
		   _aseg_segundo_ape,
		   _aseg_casada_ape,
		   _ced_correcta,
		   _pasaporte,
		   _celular
	  FROM cliclien
	  	  	  	
		return _cod_cliente,
			   _nombre,
			   _nombre_razon,
			   _direccion_1,
			   _tipo_persona,
			   _cedula,
			   _telefono1,
			   _telefono2,
			   _fecha_aniversario,
			   _sexo,
			   _nombre_original,
			   _ced_provincia,
			   _ced_inicial,
			   _ced_tomo,
			   _ced_folio,
			   _ced_asiento,
			   _aseg_primer_nom,
			   _aseg_primer_ape,
			   _aseg_segundo_ape,
			   _aseg_casada_ape,
			   _ced_correcta,
			   _pasaporte,
			   _celular
		       with resume;
	  	  
END FOREACH  

END PROCEDURE;
