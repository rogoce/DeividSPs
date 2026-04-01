-- Informaci¢n: para Panam  Asistencia Ramo Salud
-- Creado     : 13/08/2007 - Autor: Armando Moreno
-- Modificado : 11/09/2007 - RDAS - Preparaci¢n de la salida para Call Center - AHN Y Creaci¢n de File tmp_health

DROP PROCEDURE sp_pro290;

create procedure sp_pro290()

returning CHAR(50),  -- 1. Nombre del Titular
		  CHAR(20),  -- 2. N£mero de Documento
	      char(10),	 --	3. Vigencia Inicial de la P¢liza
		  char(10),	 -- 4. Vigencia Final de la P¢liza
		  CHAR(10),	 -- 5. Estado de la P¢liza
	   	  CHAR(2),	 -- 6. N£mero de P¢liza interno
		  char(30),  -- 7. Nombre del Asegurado Armando esta por verificar este punto , para los nombres de dependientes 
		  char(15),	 -- 8. Cantidad de Dependientes por asegurado
		  char(30),	 -- 9. C‚dula
		  CHAR(25),  --10. Nombre del Plan
		  CHAR(50);  --11. Subramo
		 
define _no_poliza         char(10);	 --
define _cod_ramo          char(3);   --
define _cod_subramo       char(3);   --
define _estatus_pol       smallint;  --
define _actualizado 	  smallint;  --
define _nombre_contra     char(30);  --
define _nombre_aseg	      char(50);  --
define v_no_unidad	   	  char(5);   --
define _cod_asegurado     char(10);	 --
define _no_documento      CHAR(20);  --
define _cod_producto   	  char(5);	 --
define _nombre_producto	  char(25);	 --
define _nombre_depen      char(30);  --   Nombre del dependiente
define _fecha_nac         date;	     --
define _edadcal		  	  smallint;	 --
define _prima             dec(16,2); --
define _cedula            char(30);	 --
define _cant 			  integer;   --
define _cant2 			  integer;   --
define _contratante       char(10);  --
define _codigoe		      char(2);   --
define _vigencia_inic     date;      --
define _vigencia_final    date;      --
define _nombre_subramo    char(50);	 --
define _cod_cltdepe       char(10);	 -- 
define _cod_parent        char(3);   -- 
define _tipo_parent       char(15);  --
define _fecha1_char       char(10);	 --
define _fecha2_char       char(10);	 --
define _fechaa            char(10);	 --
define _fechab            char(10);	 --
define _n_subramo         char(50);

DEFINE v_por_vencer       DEC(16,2);
DEFINE v_exigible         DEC(16,2);
DEFINE v_corriente        DEC(16,2);
DEFINE v_monto_30         DEC(16,2);
DEFINE v_monto_60         DEC(16,2);
DEFINE v_monto_90         DEC(16,2);
DEFINE v_saldo            DEC(16,2);

define _cedula_depen      char(30);	 --
define _fecha			  date;
define _periodo			  char(7);

SET ISOLATION TO DIRTY READ;

LET _cod_ramo 		= "018";
LET _cant2    		=     0;
LET _codigoe  		=  "15";
LET _tipo_parent 	= "";
LET _nombre_depen 	= "";
let _cod_cltdepe 	= "";
let _cod_parent 	= "";
let _n_subramo  	= "";
let _fecha          = today;
let _periodo        = sp_sis39(_fecha);

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud

foreach 
	 select no_poliza,
	        cod_subramo,
	        estatus_poliza,
	        actualizado,
		    no_documento,
			vigencia_inic,  
			vigencia_final
	  into _no_poliza,
	        _cod_subramo,
		    _estatus_pol,
		    _actualizado,
		    _no_documento,
			_fecha1_char,
			_fecha2_char
	   from emipomae
	  where actualizado    = 1
	    and cod_ramo       = _cod_ramo
	    and estatus_poliza = 1

	let _no_documento = trim(_no_documento);

	CALL sp_cob33(
		 "001",
		 "001",	
		 _no_documento,
		 _periodo,
		 _fecha
		 ) RETURNING v_por_vencer,       
    				 v_exigible,         
    				 v_corriente,        
    				 v_monto_30,         
    				 v_monto_60,         
    				 v_monto_90,
					 v_saldo;
					 
	if (v_monto_30 + v_monto_60 + v_monto_90) > 10.00 then --if (v_monto_30 + v_monto_60 + v_monto_90) > 0.00 then
		continue foreach;
	end if
				          
	 select nombre
	   into _n_subramo
	   from prdsubra
	  where cod_ramo    = _cod_ramo
	    and cod_subramo = _cod_subramo;

	 let _n_subramo = trim(_n_subramo);

    foreach
		 select no_unidad,
		        cod_asegurado,
		        cod_producto
		   into v_no_unidad,
		        _cod_asegurado,
		        _cod_producto
		   from emipouni
		  where no_poliza   = _no_poliza
		    and activo      = 1
		   order by 2

		 select nombre,
		        fecha_aniversario,
		        cedula
		   into _nombre_aseg,
		        _fecha_nac,
			    _cedula
	   	   from cliclien 
		  where cod_cliente = _cod_asegurado;

		 select nombre
		   into _nombre_producto
		   from prdprod 
		  where cod_producto  = _cod_producto;

		let _nombre_aseg     = trim(_nombre_aseg);
		let _nombre_producto = trim(_nombre_producto);
		let _cedula          = trim(_cedula);
		let _fechaa          = REPLACE(trim(_fecha1_char),"/","");
		let _fechab          = REPLACE(trim(_fecha2_char),"/","");

		 
	     select count(*)
	       into _cant
		   from emidepen
		  where activo         = "1"
		    and no_poliza      = _no_poliza
		    and no_unidad      = v_no_unidad;

	     foreach
		     select cod_cliente,
		            cod_parentesco
		       into _cod_cltdepe,
			        _cod_parent
		       from emidepen
		      where activo     = "1"
		        and no_poliza  = _no_poliza
		        and no_unidad  = v_no_unidad

			 select nombre, cedula
			   into _nombre_depen, _cedula_depen  --> Se agrego el campo cedula de dependiente ya que se estaba mandando por error la del asegurado. CASO: 10764 USER: KCESAR
			   from cliclien 					  --> Amado 21/06/2011
			  where cod_cliente = _cod_cltdepe;

			 select nombre
			   into _tipo_parent
			   from emiparen  
			  where cod_parentesco = _cod_parent;
				 
			   	return  _nombre_aseg,	   			-- 1. Nombre del Titular 
			   			_no_documento,	   			-- 2. N£mero de P¢liza 
						_fechaa,     				-- 3. Vigencia Inicial
						_fechab,	    	     	-- 4. Vigencia Final
						'VIGENTE',					-- 5. Estado de la P¢liza
						_codigoe,					-- 6. N£mero de P¢liza Interno
						_nombre_depen,				-- 7. Nombre del Contratante
						_tipo_parent,		  		-- 8. Tipo Parent
						trim(_cedula_depen),		-- 9. C‚dula
						_nombre_producto,  			--10. Nombre del Plan
						_n_subramo
				  with resume;
		   
		  end foreach;

	 --	  If _cant = 0	 then	--> Lo puse en comentario para que se envie los datos del asegurado (Cedula)
			  LET _tipo_parent = "";
			  LET _nombre_depen = "";

			 return _nombre_aseg,	   		    -- 1. Nombre del Titular 
		   			_no_documento,	   			-- 2. N£mero de P¢liza 
					_fechaa,     				-- 3. Vigencia Inicial
					_fechab,	    	     	-- 4. Vigencia Final
					'VIGENTE',					-- 5. Estado de la P¢liza
					_codigoe,					-- 6. N£mero de P¢liza Interno
					_nombre_depen,				-- 7. Nombre del Contratante
					_tipo_parent,		  		-- 8. Tipo de Parent
					_cedula,					-- 9. C‚dula
					_nombre_producto,  			--10. Nombre del Plan
					_n_subramo
			  with resume;
	 --	  end if

		end foreach;
   end foreach;
   end procedure;