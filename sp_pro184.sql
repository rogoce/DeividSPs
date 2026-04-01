-- Informe para la Imprenta de P¢liza de vida vigentes para los carnets de saludo de todos los dependientes + conyugue
-- Creado    : 08-Mayo-2007 - Autor: Rub‚n Arn ez
-- SIS v.2.0 - DEIVID, S.A.

 DROP PROCEDURE sp_pro184;

create procedure sp_pro184()
returning CHAR(50),  -- 1.  Nombre del Subramo 
		  CHAR(50),  -- 2.  Nombre del Producto
		  CHAR(20),  -- 3.  Numero de Documento
	      CHAR(100), -- 4.  Nombre del Asegurado
	      CHAR(100), -- 5.  Nombre del Conyugue		1
	      CHAR(100), -- 6.  Nombre del Dependientes 2
	      CHAR(100), -- 7.  Nombre del Dependientes	3
	      CHAR(100), -- 8.  Nombre del Dependientes	4
	      CHAR(100), -- 9.  Nombre del Dependientes	5
	      CHAR(100), -- 10. Nombre del Dependientes	6
	      CHAR(100), -- 11. Nombre del Dependientes	7
	      CHAR(100), -- 12. Nombre del Dependientes	8
		  date,
		  char(50),
		  char(50),
		  dec(16,2),
		  dec(16,2);

define _no_poluni       char(10);
DEFINE v_filtros        CHAR(255);
define _no_poliza       char(10);
define _poldepen        char(10);
define _cod_ramo        char(3);
define _cod_subramo     char(3);
define _nombre_ramo		char(50);
define _nombre_subramo  char(50);     
define _estatus_pol     smallint;
define _actualizado 	smallint;
define _cod_parent      char(3);
define _activo          smallint;
define _cod_cltdepe     char(10);
define _cod_cliente     char(10);
define _compania	    char(3);
define _status          char(1);
define _cod_formapag    char(3);
define _nombre_contra   char(100);
define _nombre_aseg		char(100);
define _fecha     		date;
define _edad            integer;
define _codformapg      char(3);
define _nombrepago      char(50);
define _documento		char(20);
define _edadcal		  	smallint;
define v_no_unidad		char(5);
define _no_unidad		char(5);
define _cod_asegurado   char(10);
DEFINE _no_documento    CHAR(20);
DEFINE _fecha_efec     	date;
define _cod_producto	char(5);
define _nombre_producto	char(50);	

define _renglon			integer;

define _nombre_depend   char(50);
define _nombre_conyugue char(100); --Nombre del Conyugue
define _nombre_depend1  char(50);  --Nombre del Dependiente
define _nombre_depend2  char(50);
define _nombre_depend3  char(50);
define _nombre_depend4  char(50);
define _nombre_depend5  char(50);
define _nombre_depend6  char(50);
define _nombre_depend7  char(50);

define _cod_sucursal	char(3);
define _nombre_sucursal	char(50);
define _cod_agente		char(5);
define _nombre_agente	char(50);
define _dia_90			dec(16,2);
define _periodo			char(7);

DEFINE v_saldo             DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);

SET ISOLATION TO DIRTY READ;

LET _cod_ramo = "018";
let _periodo  = sp_sis39(today);

-- Seleccionamos todas las polizas vigentes del ramo de Salud

foreach 
 select no_poliza,
		 cod_ramo,
        cod_subramo,
        estatus_poliza,
        actualizado,
	    no_documento,
		sucursal_origen
   into _no_poliza,
 	    _cod_ramo,
        _cod_subramo,
	    _estatus_pol,
	    _actualizado,
	    _no_documento,
		_cod_sucursal
   from emipomae 
  where actualizado        = "1"
    and cod_ramo           = _cod_ramo
    and estatus_poliza     = "1"
--	and no_documento       = "1800-00035-01" 
				   
	select descripcion
	  into _nombre_sucursal
	  from insagen
	 where codigo_agencia = _cod_sucursal;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
		exit foreach;
	end foreach

	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo            = _cod_ramo
	   and cod_subramo         = _cod_subramo;

	CALL sp_cob33(
		 "001",
		 "001",	
		 _no_documento,
		 _periodo,
		 today
		 ) RETURNING v_por_vencer,       
    				 v_exigible,         
    				 v_corriente,        
    				 v_monto_30,         
    				 v_monto_60,         
    				 v_monto_90,
					 v_saldo;         
	

	foreach
	 select no_unidad,
	        cod_asegurado,
	        vigencia_inic,
	        cod_producto 
	   into v_no_unidad,
	        _cod_asegurado,
	        _fecha_efec,
	        _cod_producto 
	   from emipouni
	  where no_poliza   = _no_poliza
	    and activo      = 1

		select nombre
		  into _nombre_aseg
		  from cliclien 
		 where cod_cliente = _cod_asegurado;

		select nombre
		  into _nombre_producto
		  from prdprod 
		 where cod_producto = _cod_producto;

		select cod_cliente
		  into _cod_cltdepe
		  from emidepen
		 where activo         = "1"
		   and no_poliza      = _no_poliza
		   and no_unidad      = v_no_unidad
		   and cod_parentesco = "001";

		select nombre
		  into _nombre_conyugue
		  from cliclien 
		 where cod_cliente   = _cod_cltdepe;
	

		if _nombre_conyugue is null then
			let _nombre_conyugue = "";
		end if
			
		let _renglon = 0;

		let _nombre_depend1  = "";
		let _nombre_depend2  = "";
		let _nombre_depend3  = "";
		let _nombre_depend4  = "";
		let _nombre_depend5  = "";
		let _nombre_depend6  = "";
		let _nombre_depend7  = "";

		foreach
		 select cod_cliente
		   into _cod_cltdepe
		   from emidepen
		  where activo         = "1"
		    and no_poliza      = _no_poliza
		    and no_unidad      = v_no_unidad
		    and cod_parentesco <> "001"

			select nombre
			  into _nombre_depend
			  from cliclien 
			 where cod_cliente   = _cod_cltdepe;

		   let _renglon = _renglon + 1;

		    if   _renglon = 1  then
		         let _nombre_depend1  = _nombre_depend;
		    elif _renglon = 2  then
		         let _nombre_depend2  = _nombre_depend;
		    elif _renglon = 3  then
			     let _nombre_depend3  = _nombre_depend;
		    elif _renglon = 4  then
			     let _nombre_depend4  = _nombre_depend;
		    elif _renglon = 5  then
			     let _nombre_depend5  = _nombre_depend;
		    elif _renglon = 6  then
			     let _nombre_depend6  = _nombre_depend;
		    elif _renglon = 7  then
			     let _nombre_depend7  = _nombre_depend;
			end if
					 
		end foreach;

		return  _nombre_subramo,  -- 1.Nombre del Subramo 
				_nombre_producto, -- 2.Nombre del Producto 
				_no_documento,	  -- 3.Numero de Documento
				_nombre_aseg,	  -- 4.Nombre del Asegurado
				_nombre_conyugue, -- 5.Nombre del Conyugue 
				_nombre_depend1,  -- 6.Nombre del Dependiente 1 
				_nombre_depend2,  -- 7.Nombre del Dependiente 2 
				_nombre_depend3,  -- 8.Nombre del Dependiente 3 
				_nombre_depend4,  -- 9.Nombre del Dependiente 4 
				_nombre_depend5,  -- 10.Nombre del Dependiente5 
				_nombre_depend6,  -- 11.Nombre del Dependiente6 
				_nombre_depend7,  -- 12.Nombre del Dependiente7 
				_fecha_efec,       -- 13Fecha efectiva
				_nombre_sucursal,
				_nombre_agente,
				v_saldo,
				v_monto_90
				with resume;

	end foreach;

end foreach;

end procedure;


