--- ****Renovacion Automatica. Proceso de excepciones ****
--- Creado 02/03/2009 por Armando Moreno
--- Modificado 17/06/2009 por Henry


drop procedure sp_pro315a;

create procedure "informix".sp_pro315a()
returning integer,char(50);

begin

define v_poliza     	char(10);
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
define _activo          smallint;
define _cod_acreedor    char(5);
define _cod_cobertura   char(5);
define _estatus         smallint;
define _prima_bruta     decimal(16,2);
define _diezporc	    decimal(16,2);
define _saldo           decimal(16,2);
define _renglon         smallint;
define _error2          smallint;
define _cnt,_cnt2       smallint;
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _usu_cob			char(8);
define _cnt3            smallint;
define _tipo_ramo       char(1);
define _vigencia_fin_pol date;
define _bandera         smallint;
define _tipo_agente     char(1);
define _renueva         smallint;
define _canti           smallint;


on exception set _error, _error_isam, _error_desc
   return _error, _error_desc;
end exception

set isolation to dirty read;

let _fecha           = current;
let v_pagos          = 0;
let v_incurrido      = 0;
let v_cantidad       = 0;
let v_saldo          = 0;
let v_renovar        = 0;
let v_cod_renovar    = 0;
let _salir 			 = 0;
let v_poliza         = NULL;
let v_factura        = NULL;
let v_cod_no_renovar = NULL;
let _prima_bruta     = 0;
let _bandera         = 0;
let _renueva         = 1;
let _canti           = 0;

--SET DEBUG FILE TO "sp_pro315.trc"; 
--TRACE ON;                                                                

foreach

	select no_poliza
	  into v_poliza
	  from emirepo
	 where no_documento[1,2] = '06'
	   and user_added = 'AUTOMATI'

	update emirepo
	   set user_added = 'GALEMAN'
	 where no_poliza  = v_poliza;

	INSERT INTO emideren(no_poliza,renglon) VALUES (v_poliza,'50');

end foreach

end
return 0,'Proceso Terminado';
end procedure;
