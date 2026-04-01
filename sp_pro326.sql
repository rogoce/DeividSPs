--- ****Renovacion Automatica. Proceso de excepciones ****
--- Creado 02/03/2009 por Armando Moreno
-- si la poliza tiene corredor directo oficina, no debe ir al pool de impresion se debe eliminar.
drop procedure sp_pro326;

create procedure "informix".sp_pro326(v_poliza char(10), a_usuario char(8))
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
define _cod_cobertura   char(5);
define _estatus         smallint;
define _prima_bruta     decimal(16,2);
define _diezporc	    decimal(16,2);
define _saldo           decimal(16,2);
define _renglon         smallint;
define _cnt,_cnt2       smallint;
define _reemplaza_poliza char(20);
define _no_documento    char(20);
define _valor           smallint;

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
let _reemplaza_poliza = null;

select count(*)
  into _cantidad
  from emirepo
 where no_poliza = v_poliza;

select cod_ramo,reemplaza_poliza,no_documento
  into _cod_ramo,_reemplaza_poliza,_no_documento
  from emipomae
 where no_poliza = v_poliza;

let _valor = sp_sis196(v_poliza);

if _valor > 0 and _cod_ramo <> '008' then

		delete from emirepo
		 where no_documento = _no_documento;

		delete from emirepol
		 where no_documento = _no_documento;
		 
	return 0;
end if

if _cod_ramo = '020' then

   if _reemplaza_poliza is not null or _reemplaza_poliza <> "" then

	   let v_poliza  = sp_sis21(_reemplaza_poliza);
	   let _cantidad = 0;
   end if
	
end if

if _cantidad = 0 then

	 select no_documento, 
			no_factura,
	        renovada, 
	        no_renovar, 
	        cod_no_renov,
	        vigencia_inic, 
	        vigencia_final, 
	        saldo,
			cod_compania,
			cod_sucursal,
			cod_ramo,
			cod_tipoprod,
			cod_grupo,
			cod_subramo,
			suma_asegurada,
			prima_bruta
	   into v_documento,
	 	    v_factura,
	 	    v_renovar, 
	 	    v_cod_renovar,
	        v_cod_no_renovar, 
	        v_vigencia_inic, 
	        v_vigencia_fin, 
	        v_saldo,
			_cod_compania,
			_cod_sucursal,
			_cod_ramo,
			_cod_tipoprod,
			_cod_grupo,
			_cod_subramo,
			_suma_asegurada,
			_prima_bruta
	   from emipomae
	  where no_poliza = v_poliza;

	 select centro_costo
	   into _centro_costo
	   from insagen
	  where codigo_agencia  = _cod_sucursal
		and codigo_compania = _cod_compania;

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = v_poliza

		exit foreach;
	end foreach

			INSERT INTO emirepo(
			no_poliza,
			user_added,
			cod_no_renov,
			no_documento,
			renovar,
			no_renovar,
			fecha_selec,
			vigencia_inic,
			vigencia_final,
			saldo,
			cant_reclamos,
			no_factura,
			incurrido,
			pagos,
			porc_depreciacion,
			cod_agente,
			estatus,
			cod_sucursal
			)
			VALUES(
			v_poliza,
			a_usuario,
			v_cod_no_renovar,
		    v_documento,
		    1,
		    v_renovar,
			today,
		    v_vigencia_inic, 
		    v_vigencia_fin,
		    v_saldo,
			0,
		    v_factura, 
		    0,
		    0,
			0.00,
			_cod_agente,
			5,
			_centro_costo
		    );
else

	update emirepo
	   set estatus = 5,
	       renovar = 1
	 where no_poliza = v_poliza;

end if

end
return 0;
end procedure;
