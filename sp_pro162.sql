-- Procedure que realiza el calculo de las tarifas nuevas de salud 
-- como el cambio de tarifa por el cambio de edad

-- Creado    : 23/08/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_pro30 - DEIVID, S.A.

drop procedure sp_pro162;

create procedure sp_pro162()
returning char(20),
          date,
		  date,
		  smallint,
		  date,
		  smallint,
		  char(5),
		  char(5),
		  dec(16,2),
		  dec(16,2),
		  char(50),
		  smallint,
		  smallint,
		  dec(16,2),
		  dec(16,2),
		  char(50);

define _no_poliza		char(10);
define _no_documento	char(20);
define _fecha_nac		date;
define _edad			smallint;
define _anos			smallint;
define _cod_cliente		char(10);
define _cod_producto	char(5);
define _producto_nuevo	char(5);
define _prima_total		dec(16,2);
define _prima_plan		dec(16,2);
define _prima_vida		dec(16,2);
define _cantidad		smallint;
define _prima_plan2		dec(16,2);
define _prima_vida2		dec(16,2);

define _porc_descuento  dec(5,2);
define _porc_recargo    dec(5,2);
define _porc_impuesto   dec(5,2);
define _porc_coas       dec(7,4);

define _vigencia_inic	date;
define _vigencia_final	date;
define _cod_tipoprod	char(3);

define _cod_perpago		char(3);
define _meses			smallint;

define _no_unidad		char(5);
define _prima			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _cambiar_tarifas	smallint;
define _nombre_prod		char(50);

define _facturar		smallint;
define _error			smallint;
define _mes				smallint;

define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_subra	char(50);
define _razon			char(50);
define _nombre_cliente	char(100);

define _cod_agente		char(5);
define _nombre_agente	char(50);
define _cant_reclamos	smallint;
define _cant_personas	smallint;
define _i				smallint;

--set debug file to "sp_pro30c.trc";
--trace on;

{
drop table prosalud;

create table prosalud(
no_documento	char(20),
nombre_subra	char(50),
nombre_prod		CHAR(50),
vigencia_inic	date,
vigencia_final	date,
mes				smallint,
fecha_nac		date,
edad			smallint,
cod_producto	char(5),
producto_nuevo	char(5),
prima_plan		dec(16,2),
prima_plan2		dec(16,2),
cambiar_tarifas	smallint,
facturar		smallint,
razon			char(50),
cod_cliente		char(10),
nombre_cliente	char(100)
);

alter table prosalud lock mode (row);
--}

delete from prosalud2;
delete from prosalud;

set isolation to dirty read;

FOREACH
 select no_documento,
        no_poliza,
 		vigencia_inic,
        vigencia_final,
	    cod_perpago,
	    cod_tipoprod,
		cod_ramo,
		cod_subramo
   into _no_documento,
        _no_poliza,
 		_vigencia_inic,
        _vigencia_final,
	    _cod_perpago,
	    _cod_tipoprod,
		_cod_ramo,
		_cod_subramo
   FROM emipomae
  WHERE cod_ramo       = "018"
    and cod_subramo    in ("007", "008")
    AND vigencia_final >= "01/01/2006"
    AND estatus_poliza IN (1,3)
    AND actualizado    = 1
    and colectiva      = "I"
--	and no_documento   = "1805-00618-01"

	let _mes = month(_vigencia_inic);

	select nombre
	  into _nombre_subra
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

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

foreach
 select cod_asegurado,
        cod_producto,
		prima_asegurado,
		no_unidad,
		cambiar_tarifas,
		prima_asegurado,
		prima_vida
   into _cod_cliente,
        _cod_producto,
		_prima_total,
		_no_unidad,
		_cambiar_tarifas,
		_prima_plan,
		_prima_vida
   from emipouni
  where no_poliza = _no_poliza

	let _facturar = 1;
	let _razon	  = "";	

	select count(*)
	  into _cant_reclamos
	  from recrcmae
	 where no_poliza   = _no_poliza
	   and no_unidad   = _no_unidad
	   and actualizado = 1;

	select count(*)
	  into _cant_personas
	  from emidepen
	 where no_poliza   = _no_poliza
	   and activo      = 1;

	let _cant_personas = _cant_personas + 1;

	select nombre
	  into _nombre_prod
	  from prdprod
	 where cod_producto = _cod_producto;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	if _cambiar_tarifas = 0 then
		let _facturar = 0;
		let _razon	  = "No Cambiar Tarifas";	
--		continue foreach;
	end if

	-- Verificacion si es Coaseguro Mayoritario

	IF _cod_tipoprod = "001" THEN

		SELECT porc_partic_coas
		  INTO _porc_coas
		  FROM emicoama
		 WHERE no_poliza    = _no_poliza
		   AND cod_coasegur = "036";

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 100;
		END IF

	ELSE
		LET _porc_coas = 100;
	END IF

	-- Este cambio es solo por un ano (01/09/2005 al 31/08/2006)

	let _producto_nuevo = null;

--	if _vigencia_final <= "31/08/2006" then

		select producto_nuevo
		  into _producto_nuevo
		  from prdnewpro
		 where cod_producto = _cod_producto;

		-- Tarifas Nuevas

{
		if _producto_nuevo is not null then
			let _cod_producto = _producto_nuevo;
		end if
}
--	else

--		let _facturar = 0;
--		let _razon	  = "Vigencia Mayor del 31/08/2006";	

--	end if

	select fecha_aniversario
	  into _fecha_nac
	  from cliclien
	 where cod_cliente = _cod_cliente;
	 
	let _edad = sp_sis78(_fecha_nac, today);

	if _edad is null then
		let _facturar = 0;
		let _razon	  = "No Tiene Fecha de Nacimiento";	
--		continue foreach;
	end if

	let _anos = (_vigencia_final - _vigencia_inic) / 365;

--	if _anos = 0 then
--		let _facturar = 0;
--		let _razon	  = "No Tiene Mas de 365 dias";	
--		continue foreach;
--	end if

	if month(_vigencia_inic) <> month(_vigencia_final) then
--		continue foreach;
	end if

	select prima,
           prima_vida
	  into _prima_plan2,
           _prima_vida2
	  from prdtaeda
	 where cod_producto = _producto_nuevo
	   and edad_desde   <= _edad
	   and edad_hasta   >= _edad;
	
	if _prima_plan2 is null then
		let _prima_plan2   = 0;
	end if 

	if _prima_vida2 is null then
		let _prima_vida2   = 0;
	end if 

	if _prima_plan is null then
		let _facturar = 0;
		let _razon	  = "No Encontro Plan";	
--		continue foreach;
	end if
	
	if (_prima_plan2 + _prima_vida2) <> 0 then
		if _prima_total >= (_prima_plan2 + _prima_vida2) then
			let _facturar = 0;
			let _razon	  = "Prima Nueva es Menor a Actual";	
	--		continue foreach;
		end if
	end if

	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	if _meses = 0 then
		let _meses = 1;
	end if

	-- Porcentaje de Impuesto
	
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = _no_poliza;

	let _porc_impuesto = _porc_impuesto / 100;

	-- Porcentaje de Descuento

	LET _porc_descuento = 0;

	SELECT SUM(porc_descuento)
	  INTO _porc_descuento
	  FROM emiunide
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = _no_unidad;

	IF _porc_descuento IS NULL THEN
		LET _porc_descuento = 0;
	END IF

	-- Porcentaje de Recargo

	LET _porc_recargo   = 0;

	SELECT SUM(porc_recargo)
	  INTO _porc_recargo
	  FROM emiunire
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = _no_unidad;

	IF _porc_recargo IS NULL THEN
		LET _porc_recargo = 0;
	END IF

	-- Calculos

	let _prima  		= _prima_plan * _meses;
	let _descuento 		= 0.00;
--		let _descuento  	= _prima / 100 * _porc_descuento;
	let _recargo		= 0.00;
--		let _recargo    	= (_prima - _descuento) / 100 * _porc_recargo;
	let _prima_neta 	= _prima - _descuento + _recargo;
	let _impuesto   	= _prima_neta * _porc_impuesto;
	let _prima_bruta	= _prima_neta + _impuesto;
	let _prima_suscrita = _prima_neta / 100 * _porc_coas;

	if _edad is null then
		let _facturar = 0;
		let _razon	  = "No Tiene Fecha de Nacimiento";	
--		continue foreach;
	end if

	if (_prima_plan2 + _prima_vida2) = 0 then
		let _prima_plan2 = _prima_plan;
		let _prima_vida2 = _prima_vida; 
	end if

	if _mes = 8 then
		let _prima_plan = _prima_plan2;
		let _prima_vida = _prima_vida2;
	end if
		
	insert into prosalud
	values(
	_no_documento,
	_nombre_subra,
	_nombre_prod,
	_vigencia_inic,
	_vigencia_final,
	_mes,
	_fecha_nac,
	_edad,
	_cod_producto,
	_producto_nuevo,
	_prima_plan  + _prima_vida,
	_prima_plan2 + _prima_vida2,
	_cambiar_tarifas,
	_facturar,
	_razon,
	_cod_cliente,
	_nombre_cliente,
	_nombre_agente,
	null,
	_cant_reclamos,
	_cant_personas
	);


	for _i = 1 to 12 
	
		insert into prosalud2
		values(
		_no_documento,
		_i,
		(_prima_plan + _prima_vida)
		);

	end for

	return _no_documento,
	       _vigencia_inic,
		   _vigencia_final,
		   _edad,
		   _fecha_nac,
		   _cambiar_tarifas,
		   _cod_producto,
		   _producto_nuevo,
		   _prima_plan,
		   _prima_vida,
		   _nombre_prod,
		   _facturar,
		   _mes,
		   _prima_plan2,
		   _prima_vida2,
		   _nombre_subra
		   with resume;

			
end foreach

end foreach

end procedure