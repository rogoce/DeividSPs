-- Carta de Cambio de Tarifa por Siniestralidad Septiembre 2005

-- Creado    : 15/08/2005 - Autor: Demetrio Hurtado Almanza 
-- Modif.      08/04/2006 -        Armando, incluir la direccion y los telefonos.
-- SIS v.2.0 - d_prod_sp_pro155_dw1 - DEIVID, S.A.

drop procedure sp_pro155;

create procedure sp_pro155(
a_compania	char(3),
a_sucursal	char(3),
a_fecha		date,
a_periodo 	char(7)
) returning date,
		    char(100),
		    char(20),
		    char(100),
		    dec(16,2),
		    date,
		    char(50),
		    char(50),
		    smallint,
		    char(100),
		    char(10),
		    char(10),
		    char(10);

define _cantidad		smallint;
define _no_poliza		char(10);
define _cod_cliente		char(10);
define _cod_producto	char(5);
define _prima_total		dec(16,2);
define _fecha_nac	  	date;
define _edad		  	smallint;
define _prima_plan	  	dec(16,2);
define _prima_vida	  	dec(16,2);
define _vigencia_inic 	dec(16,2);
define _vigencia_final	dec(16,2);
define _no_documento  	char(20);
define _producto_nuevo	char(5);
define _nombre_cliente	char(100);
define _anos			smallint;
define _fecha_cambio	date;
define _forma_pago		char(100);
define _nombre_perpago	char(50);
define _tipo_forma		smallint;
define _cod_formapag	char(3);
define _cod_perpago		char(3);
define _cod_agente		char(5);
define _nombre_agente	char(50);
define _prima_nueva	  	dec(16,2);
define _meses			smallint;
define _cod_pagador		char(10);
define _porc_impuesto	dec(16,2);
define _fecha_carta		date;
define _fecha_chequeo	date;
DEFINE _dir1 			CHAR(50);
DEFINE _dir2		 	CHAR(50);
define _tel_pag1		CHAR(10);
define _tel_pag2		CHAR(10);
define _cel_pag			CHAR(10);
define _dir				char(100);

set isolation to dirty read;

--let _fecha_cambio = today;

--let _fecha_carta   = mdy(a_periodo[6,7], 1, a_periodo[1,4]);
--let _fecha_carta   = _fecha_carta - 1 units month;
let _fecha_carta   = a_fecha;
let _fecha_chequeo = sp_sis36(a_periodo);

foreach
 SELECT no_poliza,
		vigencia_inic,
		vigencia_final,
		no_documento,
		cod_formapag,
		cod_perpago,
		cod_pagador
   INTO _no_poliza,
		_vigencia_inic,
		_vigencia_final,
		_no_documento,
		_cod_formapag,
		_cod_perpago,
		_cod_pagador
   FROM emipomae
  WHERE cod_ramo       = "018"	-- Salud
    AND estatus_poliza = 1      -- Vigentes
    AND actualizado    = 1      -- Actualizado
	and cod_tipoprod   in ("001", "005")
    and vigencia_final <= _fecha_chequeo
--	and no_documento   = "1898-00012-01"

--	and month(vigencia_final) = a_pe
--	and year(vigencia_final) = 2005
--	and cod_subramo in ("007", "008")
--    AND vigencia_final >= "01/08/2005"
--    AND vigencia_final <= "31/08/2005"

	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad > 1 then
		continue foreach;
	end if

	foreach
	 select cod_asegurado,
	        cod_producto,
			prima_asegurado
	   into _cod_cliente,
	        _cod_producto,
			_prima_total
	   from emipouni
	  where no_poliza = _no_poliza

		select producto_nuevo
		  into _producto_nuevo
		  from prdnewpro
		 where cod_producto = _cod_producto;

		if _producto_nuevo is null then
			continue foreach;
		end if

		select fecha_aniversario
		  into _fecha_nac
		  from cliclien
		 where cod_cliente = _cod_cliente;
		 
		let _edad = sp_sis78(_fecha_nac, today);
		let _anos = (_vigencia_final - _vigencia_inic) / 365;

		if _edad is null then
			continue foreach;
		end if

		if _anos = 0 then
			continue foreach;
		end if

		if month(_vigencia_inic) = a_periodo[6,7] and
		   year(_vigencia_final) = a_periodo[1,4] then
		else
			continue foreach;
		end if

		let _cod_producto = _producto_nuevo;
		let _prima_plan   = 0;
		let _prima_vida   = 0;

		select prima,
	           prima_vida
		  into _prima_plan,
	           _prima_vida
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

		if _prima_plan is null then
			continue foreach;
		end if
		
		if _prima_total >= (_prima_plan + _prima_vida) then
			continue foreach;
		end if

		LET _dir = "";

		select nombre,
			   telefono1,
			   telefono2,
			   celular,
			   direccion_1,
			   direccion_2
		  into _nombre_cliente,
			   _tel_pag1,
			   _tel_pag2,
			   _cel_pag,
			   _dir1,
			   _dir2
		  from cliclien
		 where cod_cliente = _cod_pagador;
		 
		let _dir1 = trim(_dir1);
		let _dir2 = trim(_dir2);
		if _dir1 is null then
			let _dir1 = "";
		end if
		if _dir2 is null then
			let _dir2 = "";
		end if
		let _dir  = _dir1 || _dir2;

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

		let _nombre_agente = "c.c.: " || trim(_nombre_agente);
				
		-- Forma de Pago

		let _forma_pago = "";

		select tipo_forma
		  into _tipo_forma
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		if _tipo_forma = 2 then
			let _forma_pago = "TARJETA DE CREDITO";
		elif _tipo_forma = 3 then 
			let _forma_pago = "DESCUENTO SALARIAL";
		elif _tipo_forma = 4 then 
			let _forma_pago = "DESCUENTO BANCARIO";
		else
			let _forma_pago = "VOLUNTARIO";
		end if

		select nombre,
		       meses
		  into _nombre_perpago,
		       _meses
		  from cobperpa
		 where cod_perpago = _cod_perpago;

		let _forma_pago = trim(_forma_pago) || " - " || trim(_nombre_perpago);

		-- Prima Nueva
		
		select sum(factor_impuesto)
		  into _porc_impuesto
		  from emipolim p, prdimpue i
		 where p.cod_impuesto = i.cod_impuesto
		   and p.no_poliza    = _no_poliza;

		let _porc_impuesto = 1 + _porc_impuesto/100;

		if _meses = 0 then
			let _meses = 1;
		end if

		let _prima_nueva  = _prima_plan  * _meses;
		let _prima_nueva  = _prima_nueva * _porc_impuesto;
		let _fecha_cambio = _vigencia_final;

		return _fecha_carta,
			   _nombre_cliente,
			   _no_documento,
			   _forma_pago,
			   _prima_nueva,
			   _fecha_cambio,
			   _nombre_agente,
			   _cod_producto,
			   _edad,
			   _dir,
			   _tel_pag1,
			   _tel_pag2,
			   _cel_pag
			   with resume;

	end foreach

end foreach

end procedure