--- Limpiar pool de renovaciones debido a que ya se han renovado.

--- Creado 17/04/2010 por Armando Moreno

drop procedure sp_pool02;

create procedure "informix".sp_pool02()
returning char(20);

begin

define v_documento  	char(20);
define v_factura    	char(10);
define v_renovar    	smallint;
define v_cod_renovar 	smallint;
define v_cod_no_renovar char(3);
define _cod_ramo        char(3);
define _no_poliza       char(10);
define v_vigencia_inic  date;
define _vig_inic_ult    date;
define v_vigencia_fin   date;
define v_tipo       	char(3);
define v_saldo      	decimal(16,2);
define v_cant       	smallint;
define v_cantidad   	smallint;
define v_incurrido  	decimal(16,2);
define v_pagos      	decimal(16,2);
define v_tot_pagos  	decimal(16,2);
define _suma_asegurada	decimal(16,2);
define _perd_total  	smallint;
define _todas_perdida  	smallint;
define _cod_compania   	char(3);
define _codigo_agencia	char(3);
define _cod_sucursal   	char(3);
define _centro_costo   	char(3);
define _usuario      	char(8);
define _cnt			  	smallint;
define _cantidad	  	smallint;
define _cod_agente      char(5);
define _porc_partic  	decimal(5,2);
define _vig_final		date;
define _cod_tipoprod    char(3);
define _cod_grupo       char(5);
define _salir           smallint;
define _cod_subramo     char(3);
define _fecha           date;
define _cod_manzana     char(15);
define _cod_asegurado   char(10);
define _fecha_aniversario date;
define _edad            integer;
define _no_unidad       char(5);
define _activo          smallint;
define _cod_acreedor    char(5);
define _ano_auto        smallint;
define _cod_cobertura   char(5);
define _estatus         smallint;
define _prima_bruta     decimal(16,2);
define _diezporc	    decimal(16,2);
define _saldo           decimal(16,2);
define _renglon         smallint;
define _reg             integer;
define _error           smallint;
define _usu_cob         char(8);
define _porcentaje      integer;
define _declarativa     smallint;
define _gerarquia       smallint;
define _cod_formapag    char(3);
define _tipo_forma      smallint;
define li_cnt           smallint;
define ls_usuario       char(8);
define _serie           integer;
define _no_p            char(10);
define _vig_ini         date;
define _vig_fin         date;
define _serie_ant,_serie_nue       integer;
define _estatus_poliza  smallint;
define _vigencia_final_ant date;
define _estatus_p smallint;
define _vigencia_final_nue date;
define _renovada smallint;


--SET DEBUG FILE TO "sp_pro316.trc"; 
--TRACE ON;                                                                

set isolation to dirty read;

let _fecha           = current;
let v_pagos          = 0;
let v_incurrido      = 0;
let v_cantidad       = 0;
let v_saldo          = 0;
let v_renovar        = 0;
let v_cod_renovar    = 0;
let _salir 			 = 0;
let v_factura        = NULL;
let v_cod_no_renovar = NULL;
let _prima_bruta     = 0;
let _ano_auto        = 0;
let _porcentaje      = 10;
let li_cnt           = 0;
let _estatus         = 0;
let _no_poliza       = "";
let _renovada        = 1;


foreach
	    select no_documento,
	    	   estatus_poliza,
		       serie,
			   vigencia_final,
			   no_poliza
		  into v_documento,
		  	   _estatus_poliza,
		       _serie_ant,
			   _vigencia_final_ant,
			   _no_p
		  from emipomae
		 where cod_ramo in("002","020")
		   and actualizado  = 1
		   and serie        = 2010
		   and nueva_renov  = 'R'

		 foreach

		    select renovada,
				   no_poliza
			  into _renovada,
 				   _no_poliza
			  from emipomae
			 where no_documento = v_documento
			   and actualizado  = 1
			   and serie        = 2009
			exit foreach;
		 end foreach

	 if _no_p > _no_poliza and _renovada = 0 then
	  
			update emipomae
			   set renovada  = 1
			 where no_poliza = _no_poliza;

			return v_documento WITH RESUME;

	 else
		continue foreach;
	 end if

end foreach

end
end procedure;
