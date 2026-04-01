-- Informaci¢n: para Panam  SEMM 
-- Creado     : 16/04/2009 - Autor: Amado Perez

DROP PROCEDURE sp_pro866;

create procedure sp_pro866(a_cod_ramo CHAR(3))

returning CHAR(50),  -- 1. Nombre del Titular
		  CHAR(20),  -- 2. N£mero de Documento
		  char(30),  -- 7. Nombre del Asegurado Armando esta por verificar este punto , para los nombres de dependientes 
		  char(30),	 -- 9. C‚dula
		  varchar(100);
		 
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
define _desc_limite1      varchar(50); 
define _desc_limite2      varchar(50); 
define _descripcion       varchar(100);

DEFINE v_por_vencer        	DEC(16,2);
DEFINE v_exigible          	DEC(16,2);
DEFINE v_corriente         	DEC(16,2);
DEFINE v_monto_30          	DEC(16,2);
DEFINE v_monto_60          	DEC(16,2);
DEFINE v_monto_90          	DEC(16,2);
DEFINE v_saldo             	DEC(16,2);

define _fecha				date;
define _periodo				char(7);

SET ISOLATION TO DIRTY READ;

--LET _cod_ramo 		= "018";
LET _cant2    		= 0;
LET _codigoe  		= "15";
LET _tipo_parent 	= "";
LET _nombre_depen 	= "";
let _cod_cltdepe 	= "";
let _cod_parent 	= "";
let _n_subramo  	= "";
--let _fecha          = today;
--let _periodo        = sp_sis39(_fecha);

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
	    and cod_ramo       = a_cod_ramo
	    and estatus_poliza = 1				          

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

          select desc_limite1, desc_limite2
		    into _desc_limite1, _desc_limite2
		    from prdcobpd
		   where cod_producto  = _cod_producto
		     and cod_cobertura = '00566';

         if _desc_limite1 is null then
			let _desc_limite1 = "";
		 end if

         if _desc_limite2 is null then
			let _desc_limite2 = "";
		 end if

         let _descripcion = trim(_desc_limite1) || " " || trim(_desc_limite2); 

		 select nombre,
		        fecha_aniversario,
		        cedula
		   into _nombre_aseg,
		        _fecha_nac,
			    _cedula
	   	   from cliclien 
		  where cod_cliente = _cod_asegurado;
		 
	     select count(*)
	       into _cant
		   from emidepen
		  where activo         = "1"
		    and no_poliza      = _no_poliza
		    and no_unidad      = v_no_unidad;

		 If _cant > 0 then

		     foreach
			     select cod_cliente,
			            cod_parentesco
			       into _cod_cltdepe,
				        _cod_parent
			       from emidepen
			      where activo     = "1"
			        and no_poliza  = _no_poliza
			        and no_unidad  = v_no_unidad

				 select nombre
				   into _nombre_depen
				   from cliclien 
				  where cod_cliente = _cod_cltdepe;

{				 select nombre
				   into _tipo_parent
				   from emiparen  
				  where cod_parentesco = _cod_parent;
}					 
				   	return  _nombre_aseg,	   			-- 1. Nombre del Titular 
				   			_no_documento,	   			-- 2. N£mero de P¢liza 
							_nombre_depen,				-- 7. Nombre del Contratante
							_cedula,					    -- 9. C‚dula
							_descripcion
					  with resume;
			   
			  end foreach;

		  Else
			  LET _tipo_parent = "";
			  LET _nombre_depen = "";

			 return _nombre_aseg,	   		    -- 1. Nombre del Titular 
		   			_no_documento,	   			-- 2. N£mero de P¢liza 
					_nombre_depen,				-- 7. Nombre del Contratante
					_cedula,					    -- 9. C‚dula
					_descripcion
			  with resume;
		  end if

		end foreach;
   end foreach;

   end procedure;

		   