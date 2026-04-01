--se uso este procedure para cambiar el usuario en emirepol para el arranque del programa de renovaciones.
--06/04/2005. 

drop procedure sp_pro28d;

create procedure "informix".sp_pro28d()

--- Renovacion de Polizas Opciones
--- Creado 06/04/2005 por Armando Moreno

begin

define v_poliza     	char(10);
define v_documento  	char(20);
define v_factura    	char(10);
define v_renovar    	smallint;
define v_cod_renovar 	smallint;
define v_cod_no_renovar char(3);
define _cod_ramo        char(3);
define _periodo	        char(7);
define v_vigencia_inic  date;
define v_vigencia_fin   date;
define v_tipo       	char(3);
define v_saldo      	decimal(16,2);
define v_cant       	smallint;
define v_cantidad   	smallint;
define v_incurrido  	decimal(16,2);
define v_pagos      	decimal(16,2);
define v_tot_pagos  	decimal(16,2);
define _porc_partic  	decimal(5,2);
define _perd_total  	smallint;
define _todas_perdida  	smallint;
define _cod_compania   	char(3);
define _codigo_agencia	char(3);
define _cod_sucursal   	char(3);
define _centro_costo   	char(3);
define _usuario      	char(8);
define _cod_agente     	char(5);
define _cnt			  	smallint;
define _cantidad	  	smallint;
DEFINE _mes_char        CHAR(2);
DEFINE _ano_char		CHAR(4);

set isolation to dirty read;

let v_pagos          = 0;
let v_incurrido      = 0;
let v_cantidad       = 0;
let v_saldo          = 0;
let v_renovar        = 0;
let v_cod_renovar    = 0;
let v_poliza         = NULL;
let v_factura        = NULL;
let v_cod_no_renovar = NULL;

-- Armar varibale que contiene el periodo(aaaa-mm)

foreach
	 select no_poliza
	   into v_poliza
	   from emirepol
	  where cod_agente is null

	 let _porc_partic = 0.00;

 foreach

	select porc_partic_agt,
		   cod_agente
	  into _porc_partic,
	       _cod_agente
	  from emipoagt
	 where no_poliza = v_poliza
	 order by porc_partic_agt desc

	exit foreach;

 end foreach

	 update emirepol
	    set cod_agente = _cod_agente
	  where no_poliza  = v_poliza;

end foreach

{foreach
 select no_poliza,
		vigencia_final
   into v_poliza,
        v_vigencia_fin 
   from emireren

	IF  MONTH(v_vigencia_fin) < 10 THEN
		LET _mes_char = '0'|| MONTH(v_vigencia_fin);
	ELSE
		LET _mes_char = MONTH(v_vigencia_fin);
	END IF

	LET _ano_char = YEAR(v_vigencia_fin);
	LET _periodo  = _ano_char || "-" || _mes_char;

	update emireren
	   set periodo = _periodo
	 where no_poliza = v_poliza;

end foreach}

{	-- centro de costo, para determinar el usuario(emireusu)

	 select centro_costo
	   into _centro_costo
	   from insagen
	  where codigo_agencia  = _cod_sucursal
		and codigo_compania = _cod_compania;

	 select count(*)
	   into _cnt
	   from emireusu
	  where cod_sucursal = _centro_costo
	    and cod_ramo     = _cod_ramo;

	 if _cnt = 0 Then
	 	continue foreach;
	 end If
	 if _cnt = 1 then
		 select usuario
		   into _usuario
		   from emireusu
		  where cod_sucursal = _centro_costo
		    and cod_ramo     = _cod_ramo;
	 end if
	 if _cnt > 1 then
		foreach
		 select	usuario
		   into	_usuario
		   from emireusu
		  where cod_sucursal = _centro_costo
		    and cod_ramo     = _cod_ramo

			select count(*)
			  into _cantidad
			  from emirepol
			 where user_added = _usuario;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			insert into tmp_reno
			values (_usuario, _cantidad);

		end foreach

		foreach
		 select cantidad,
		        usuario
		   into _cantidad,
		        _usuario
		   from tmp_reno
		  order by 1, 2

			exit foreach;

		end foreach

		delete from tmp_reno;
	 end if

	update emirepol
	   set user_added = _usuario
	 where no_poliza = v_poliza;

end foreach
drop table tmp_reno;}

end

end procedure;
