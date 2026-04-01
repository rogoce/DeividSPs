-- Simulacion del Pago Adelantado de Comision
-- 
-- Creado     : 08/10/2012 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob308;

create procedure "informix".sp_cob308()
returning smallint,
          char(50);

define _no_remesa			char(10);
define _renglon				smallint;
define _no_documento		char(20);
define _no_recibo			char(10);
define _fecha				date;
define _monto				dec(16,2);
define _periodo				char(7);
define _monto_descontado	dec(16,2);

define _no_poliza			char(10);
define _no_endoso			char(5);
define _cod_ramo			char(3);
define _ramo				char(50);
define _cod_formapag		char(3);
define _forma_pago			char(50);
define _cod_perpago			char(3);
define _per_pago			char(50);
define _vigencia_inic		date;
define _meses_por			smallint;

define _prima_suscrita		dec(16,2);
define _prima_neta_pro		dec(16,2);
define _prima_neta_cob		dec(16,2);
define _comision_adelanto	dec(16,2);
define _comision_ganada		dec(16,2);
define _comision_saldo		dec(16,2);

define _cod_agente			char(5);
define _tipo_agente			char(1);
define _estatus_licencia	char(1);
define _porc_comis_agt   	dec(5,2);
define _porc_partic_agt	 	dec(5,2);


define _aplica 				smallint;
define _cantidad			smallint;
define _cantidad_NC			smallint;
define _insertar			smallint;

set isolation to dirty read;

{
create table tmp_cobadeco( 
cod_agente			char(5),
no_documento		char(20),
no_recibo			char(10)	not null,
fecha				date		not null,
monto_recibo		dec(16,2)	not null,
prima_suscrita		dec(16,2)	not null default 0,
prima_neta			dec(16,2)	not null default 0,
comision_adelanto	dec(16,2)	not null default 0,
comision_ganada		dec(16,2)	not null default 0,
comision_saldo		dec(16,2)	not null default 0,
poliza_cancelada	smallint	not null default 0,
comision_cancelada	dec(16,2)	not null default 0,
porc_comis_agt		dec(5,2)	not null default 0,
porc_partic_agt		dec(5,2)	not null default 0,
cant_pagos			smallint	not null default 0,
primary key (cod_agente, no_documento)
);
}

{
drop table tmp_cobadeflu;

create table tmp_cobadeflu( 
cod_agente			char(5),
no_documento		char(20),
periodo				char(7),
prima_neta			dec(16,2)	not null default 0,
comision_ganada		dec(16,2)	not null default 0,
flujo_caja			dec(16,2)	not null default 0,
prima_neta_n		dec(16,2)	not null default 0,
comision_ganada_n	dec(16,2)	not null default 0,
flujo_caja_n		dec(16,2)	not null default 0,
ramo				char(50),
forma_pago			char(50),
per_pago			char(50)
);
--}

create temp table tmp_poliza(
no_poliza	char(10),
cod_ramo	char(3)
) with no log; 


--{
foreach
 select no_poliza,
        cod_ramo
   into _no_poliza,
        _cod_ramo
   from emipomae
  where actualizado     = 1
    and periodo        >= "2012-01"
--	and estatus_poliza <> 2
	and cod_ramo       <> "018"

	insert into tmp_poliza(no_poliza, cod_ramo)
	values (_no_poliza, _cod_ramo);

end foreach
--}

let _cod_ramo = "018";

foreach
 select no_poliza
   into _no_poliza
   from endedmae
  where actualizado     = 1
    and periodo        >= "2012-01"
	and cod_endomov     = "014"
--	and no_documento    in ("1800-00436-01", "1806-00040-01")
  group by no_poliza

	insert into tmp_poliza(no_poliza, cod_ramo)
	values (_no_poliza, _cod_ramo);

end foreach

-- Inicio del Proceso

delete from tmp_cobadeco;
delete from tmp_cobadeflu;

foreach
 select no_poliza,
        cod_ramo
   into _no_poliza,
        _cod_ramo
   from tmp_poliza
--  where cod_ramo = "018"
	
	let _aplica = sp_cob309(_no_poliza);
--	let _aplica = 1;

	if _aplica = 0 then
		continue foreach;
	end if

	{
	 select count(*)
	   into	_cantidad_NC
	   from cobredet
	  where periodo         >= "2012-01"
	    and tipo_mov         = "N"
		and actualizado      = 1
		and no_poliza        = _no_poliza;

	if _cantidad_NC <> 0 then
		continue foreach;
	end if
	}

	select cod_formapag,
	       cod_perpago,
		   vigencia_inic
	  into _cod_formapag,
	       _cod_perpago,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;

--	if _cod_perpago <> "002" then
--		continue foreach;
--	end if

	select nombre 
	  into _ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _forma_pago
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	select nombre
	  into _per_pago
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	foreach
	 select doc_remesa,
			no_recibo,
			fecha,
			monto,
			no_remesa,
			renglon,
			prima_neta,
			periodo,
			monto_descontado
	   into	_no_documento,
			_no_recibo,
			_fecha,
			_monto,
			_no_remesa,
			_renglon,
			_prima_neta_cob,
			_periodo,
			_monto_descontado
	   from cobredet
	  where periodo         >= "2012-01"
	    and tipo_mov         = "P"
		and actualizado      = 1
--		and monto_descontado = 0
		and no_poliza        = _no_poliza
	--	and doc_remesa  = "0208-00449-01"
	  order by doc_remesa, fecha

		foreach
		 select cod_agente,
		 		porc_comis_agt,
				porc_partic_agt
		   into _cod_agente,
		        _porc_comis_agt,
				_porc_partic_agt
		   from cobreagt
		  where no_remesa = _no_remesa
		    and renglon   = _renglon

			select tipo_agente,
			       estatus_licencia
			  into _tipo_agente,
				   _estatus_licencia
			  from agtagent
			 where cod_agente = _cod_agente;

			if _tipo_agente <> "A" then -- Agente 
				continue foreach;
			end if

			if _estatus_licencia <> "A" then -- Activas
				continue foreach;
			end if

			select count(*)
			  into _cantidad
			  from tmp_cobadeco
			 where cod_agente   = _cod_agente
			   and no_documento = _no_documento;

			let _insertar = 1;

			if _cantidad = 0 then

				if _cod_ramo = "018" then

					if month(_fecha) >= month(_vigencia_inic) then					

						select max(no_endoso)
						  into _no_endoso
						  from endedmae
						 where no_poliza   = _no_poliza
						   and cod_endomov = "014"
						   and actualizado = 1
						   and periodo    >= "2012-01";

						select sum(prima_neta),
						       sum(prima_suscrita)
						  into _prima_neta_pro,
						       _prima_suscrita
						  from endedmae
						 where no_poliza   = _no_poliza
						   and no_endoso   = _no_endoso;
						
						if _cod_perpago = "002" then
							let _meses_por = 12;
						elif _cod_perpago = "003" then
							let _meses_por = 6;
						elif _cod_perpago = "004" then
							let _meses_por = 4;
						elif _cod_perpago = "005" then
							let _meses_por = 3;
						elif _cod_perpago = "006" then
							let _meses_por = 12;
						elif _cod_perpago = "007" then
							let _meses_por = 2;
						elif _cod_perpago = "008" then
							let _meses_por = 1;
						elif _cod_perpago = "009" then
							let _meses_por = 3;
						end if

						let _prima_neta_pro = _prima_neta_pro * _meses_por;
						let _prima_suscrita = _prima_suscrita * _meses_por;
					
					else

						let _insertar = 0;

					end if

				else
				
					select sum(prima_neta),
					       sum(prima_suscrita)
					  into _prima_neta_pro,
					       _prima_suscrita
					  from endedmae
					 where no_poliza   = _no_poliza
					   and actualizado = 1;

				end if

				if _insertar = 1 then

					let _comision_adelanto = _prima_neta_pro * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);
					let _comision_ganada   = _prima_neta_cob * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);
					let _comision_saldo    = _comision_adelanto - _comision_ganada;

					insert into tmp_cobadeco(
					cod_agente, 
					no_documento, 
					no_recibo, 
					fecha, 
					monto_recibo, 
					prima_suscrita, 
					prima_neta, 
					comision_adelanto, 
					comision_ganada, 
					comision_saldo,
					porc_comis_agt,
					porc_partic_agt,
					cant_pagos
					)
					values (
					_cod_agente, 
					_no_documento, 
					_no_recibo, 
					_fecha, 
					_monto, 
					_prima_suscrita, 
					_prima_neta_pro, 
					_comision_adelanto, 
					_comision_ganada, 
					_comision_saldo,
					_porc_comis_agt,
					_porc_partic_agt,
					1
					);

					insert into tmp_cobadeflu(
					cod_agente, 
					no_documento, 
					periodo,
					prima_neta, 
					comision_ganada, 
					flujo_caja,
					prima_neta_n, 
					comision_ganada_n, 
					flujo_caja_n,
					ramo,
					forma_pago,
					per_pago
					)
					values (
					_cod_agente, 
					_no_documento, 
					_periodo, 
					_prima_neta_cob, 
					_comision_adelanto, 
					_prima_neta_cob - _comision_adelanto,
					_prima_neta_cob, 
					_comision_ganada,
					_prima_neta_cob - _comision_ganada,
					_ramo,
					_forma_pago,
					_per_pago
					);

				end if

			else

				let _comision_ganada   = _prima_neta_cob * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);

				update tmp_cobadeco
				   set comision_ganada = comision_ganada + _comision_ganada,
					   comision_saldo  = comision_saldo  - _comision_ganada,
					   cant_pagos      = cant_pagos      + 1
				 where cod_agente      = _cod_agente
				   and no_documento    = _no_documento;

				insert into tmp_cobadeflu(
				cod_agente, 
				no_documento, 
				periodo,
				prima_neta, 
				comision_ganada, 
				flujo_caja,
				prima_neta_n, 
				comision_ganada_n, 
				flujo_caja_n,
				ramo,
				forma_pago,
				per_pago
				)
				values (
				_cod_agente, 
				_no_documento, 
				_periodo, 
				_prima_neta_cob, 
				0, 
				_prima_neta_cob,
				_prima_neta_cob, 
				_comision_ganada,
				_prima_neta_cob - _comision_ganada,
				_ramo,
				_forma_pago,
				_per_pago
				);

			end if

		end foreach

	end foreach

end foreach

drop table tmp_poliza;

return 0, "Actualizacion Exitosa";

end procedure

		
