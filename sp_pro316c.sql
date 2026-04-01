--- Renovacion Automatica. Proceso de excepciones
--- Creado 02/03/2009 por Armando Moreno

drop procedure sp_pro316c;

create procedure "informix".sp_pro316c(a_poliza char(10))
returning integer;

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
define _bandera         smallint;
define _usu_cob_f       char(8);
define _tipo_agente     char(1);
define _renueva         smallint;
define _sis_renglon		smallint;
define _bander          smallint;
define _cod_contr       char(10);
define _ano				smallint;
define _mes				smallint;
define _mes_char		char(2);
define _fecha_aa        date;
define _no_pagos        smallint;
define _flag_moro       smallint;
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define v_monto_90       DEC(16,2);
define _tipo            smallint;


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
let _bandera         = 0;
let _renueva         = 1;
let _sis_renglon     = 12;
let _bander          = 0;
let _flag_moro       = 0;



  --Polizas con Reclamos
 let v_cantidad = 0;

 select cod_ramo,
        no_documento
   into _cod_ramo,
        v_documento
   from emipomae
  where no_poliza   = a_poliza
    and actualizado = 1;

  select count(*) 
    into v_cantidad 
    from recrcmae
   where actualizado = 1
     and cod_evento  = '016'
     and no_poliza = a_poliza
     and estatus_audiencia not in(1,0,7,8);

  if v_cantidad > 0 then

	if _cod_ramo in('002') then --AUTO

		let _no_unidad = null;
		let _bandera = 0;

		foreach
			select no_unidad
			  into _no_unidad
			  from recrcmae
			 where actualizado = 1
			   and cod_evento  = '016'
			   and no_poliza   = a_poliza
			   and estatus_audiencia not in(1,0,7,8)

			 let _tipo = sp_proe75(a_poliza, _no_unidad);
			 if _tipo in(1,2,3) then
				let _bandera = 1;
				exit foreach;
			 end if
		end foreach

		if _bandera = 1 and _no_unidad is not null then
			return 1;
		end if
	end if
  end if

end
return 0;

end procedure;
