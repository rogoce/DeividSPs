-- Informe para Listar las Cartera de P¢liza del Ramo Salud 
-- Creado    : 09-Julio-2007 - Autor: Rub‚n Arn ez
-- Modificado: 21-Agosto-007 - Adici¢n de campos nuevos solicitados por Nelda 
-- SIS v.2.0 - DEIVID, S.A. 

  DROP PROCEDURE sp_actuario8;

 create procedure sp_actuario8(a_ano  integer)

returning CHAR(20),
		  char(50),
	      integer, 
		  integer,
		  integer;

		  
define _no_poluni         char(10);
define v_filtros          char(255);
define _no_poliza         char(10);
define _poldepen          char(10);
define _cod_ramo          char(3);
define _cod_subramo       char(3);
define _nombre_ramo		  char(50);
define _nombre_subramo    char(50);     
define _estatus_pol       smallint;
define _actualizado 	  smallint;
define _cod_parent        char(3);
define _activo            smallint;
define _cod_cltdepe       char(10);
define _cod_cliente       char(10);
define _compania	      char(3);
define _status            char(1);
define _cod_formapag      char(3);
define _nombre_contra     char(100);
define _nombre_aseg	      char(100);
define _fecha     	   	  date;
define _edad              integer;
define _codformapg        char(3);
define _nombrepago        char(50);
define _documento		  char(20);
define v_no_unidad	   	  char(5);
define _no_unidad	   	  char(5);
define _cod_asegurado     char(10);
define _no_documento      CHAR(20);
define _fecha_efec        date;
define _cod_producto   	  char(5);
define _nombre_producto	  char(50);	
define _renglon			  integer;
define _nombre_depend     char(50);
define _nombre_conyugue   char(100); --Nombre del Conyugue
define _cod_cobertura     char(5);
define _nombre_cober      char(50);
define _nombre_parentesco char(50);   
define _cod_parentesco 	  char(3);
define _sexo         	  char(1);
define _fecha_nac         date;
define _edadcal		  	  smallint;
define _cant_dependientes smallint;
define _prima             dec(16,2);
define _nueva_renov    	  char(1);
define _cod_procedimiento char(5);
define _nom_procedimiento char(100);
define _cedula            char(10);
define _cant 			  integer;
define _cant2 			  integer;
define _contratante       char(10);
define _cant3             integer;
define _cant4             integer;
define _n_subramo         char(8);
define _cnt               integer;					  
						  
SET ISOLATION TO DIRTY READ;

LET _cod_ramo       = "018";
LET _cant2          = 0;
let _cant3          = 0;


foreach

	select no_documento
	  into _no_documento
	  from emipomae
	 where actualizado = 1
	   and cod_ramo    = '018'
	 group by no_documento
	 order by no_documento

	let _no_poliza = sp_sis21(_no_documento);

		SELECT count(*)
		  INTO _cnt
		  FROM endedmae
		 WHERE cod_compania  = '001'
		   AND actualizado   = 1
		   AND periodo       >= '2008-12'
		   AND periodo       <= '2009-07'
		   AND no_poliza     = _no_poliza;

		if _cnt > 0 then
		else
			continue foreach;
		end if


	select cod_ramo,
	       cod_subramo
	  into _cod_ramo,
		   _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

       SELECT nombre
         INTO _n_subramo
         FROM prdsubra
        WHERE cod_ramo    = '018'
          AND cod_subramo = _cod_subramo;


  {	if _cod_subramo in("003","011","013","009","016","007","017","018")	then
	else
		continue foreach;
	end if}

   	let _cant2 = 0;
   	let _cant3 = 0;
	let _cant4 = 0;

	foreach
		 select no_unidad,
		        cod_asegurado,
		        vigencia_inic,
		        cod_producto,
				prima
		   into v_no_unidad,
		        _cod_asegurado,
		        _fecha_efec,
		        _cod_producto,
		        _prima 
		   from emipouni
		  where no_poliza      = _no_poliza
		    and activo         = 1

		 select count(*)
	       into _cant
		   from emidepen
		  where activo         = "1"
		    and no_poliza      = _no_poliza
		    and no_unidad      = v_no_unidad;

		   	let _cant2 = _cant2 + _cant;
		   	let _cant3 = _cant3 + 1;
   
	end foreach;

	  let _cant4 = _cant2 + _cant3;

   	return _no_documento,
	       _n_subramo,
		   _cant2,
		   _cant3,
		   _cant4
	  with resume;

 	end foreach;
end procedure;

		   