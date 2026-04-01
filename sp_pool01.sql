--- Limpiar pool de renovaciones debido a que ya se han renovado.

--- Creado 17/04/2010 por Armando Moreno

drop procedure sp_pool01;
create procedure sp_pool01()
returning char(20),char(10);

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
define _no_poliza_act            char(10);
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


foreach
	select no_poliza,
	       no_documento,
		   estatus
	  into _no_poliza,
	       v_documento,
		   _estatus
	  from emirepo
	 where estatus in(5)
	   and year(vigencia_inic) = 2023
	   and no_documento[1,2] in('20','02','23')
	   order by no_documento

	let _no_poliza_act = sp_sis21(v_documento);
	
	select estatus_poliza
 	  into _estatus
	  from emipomae
	 where no_poliza = _no_poliza_act;
	
	if _estatus = 1 then
		delete from emideren
		where no_poliza = _no_poliza;
		
		delete from emirepo
		where no_poliza = _no_poliza;
		
		return v_documento,_no_poliza WITH RESUME;
	end if

end foreach

end
end procedure;
