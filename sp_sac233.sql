-- Procedure que realiza el validacion de cuadre de la 511

drop procedure sp_sac233;

create procedure "informix".sp_sac233()
returning	char(3),
			char(50),
			char(10),
			char(20),                   
			char(50),
			dec(16,2), 
			char(50),
			char(255),
			dec(16,2),
			char(7),
			char(15),
			dec(16,2),
			varchar(50),
			dec(16,2),
			dec(16,2),
			dec(16,2);

begin
	define n_contrato			varchar(50);
	define v_filtros			char(255);
	define v_desc_agente		char(50);
	define v_desc_ramo			char(50);
	define v_descr_cia			char(50);
	define v_desc_nombre		char(35);
	define v_nodocumento		char(20);
	define _res_comprobante		char(15);
	define v_cod_contratante	char(10);
	define _no_registro			char(10);
	define v_nofactura			char(10);
	define v_nopoliza			char(10);
	define v_cod_usuario		char(8);
	define _peri				char(7);
	define _cod_contrato		char(5);
	define v_cod_agente			char(5);
	define v_noendoso			char(5);
	define _cod_cober_reas		char(3);
	define v_cod_tipoprod		char(3);
	define v_cod_sucursal		char(3);
	define _cod_coasegur		char(3);
	define v_forma_pago			char(3);
	define v_cod_ramo			char(3);
	define _tipo				char(1);
	define _porc_cont_partic	dec(5,2);
	define _porc_partic_agt		dec(5,2);
	define _porc_comis_ase   	dec(5,2);
	define v_comision			dec(9,2);
	define v_suma_asegurada		dec(16,2);
	define v_prima_suscrita		dec(16,2);
	define _tot_prima_sus		dec(16,2);
	define _cedido_total		dec(16,2);
	define _cedido_reas			dec(16,2);
	define _monto_reas			dec(16,2);
	define _parti_reas			dec(16,2);
	define _cedido_fac			dec(16,2);
	define _cedido_xl			dec(16,2);
	define v_cedido				dec(16,2);
	define _monto				dec(16,2);
	define _tipo_contrato		smallint;
	define _contrato_xl			smallint;
	define v_cant_pagos			smallint;
	define v_estatus			smallint;
	define _cnt					integer;
	define _sac_notrx			integer;
	define _sac_asientos		integer;

	define _error				integer;
	define _error_desc          char(100);

	define _monto_asien			dec(16,2);

	define _ano_eval			char(4);
	define _ano_int				smallint;
	define _periodo_eval		char(7);
	define _fecha_eval			date;
	define a_periodo1			char(7);
	define a_periodo2			char(7);

	-- set debug file to "sp_sac233.trc";
	-- trace on;

	return	"",
			"",
			"",
			"",
			"",
			0,
			"",
			"",
			0,
			"",
			"",
			0,
			"",
			0,
			0,
			0;
	
	set isolation to dirty read;

	let v_prima_suscrita  = 0;
	let v_suma_asegurada  = 0;
	let _tot_prima_sus    = 0;
	let v_cant_pagos      = 0;
	let v_comision        = 0;
	let _sac_notrx        = 0;
	let v_cedido          = 0;
	let v_cod_contratante = null;
	let n_contrato        = null;
	let v_estatus         = null;
	
	call sp_sac104() returning _ano_int, _periodo_eval, _fecha_eval;

	if _periodo_eval < "2015-09" then
		let a_periodo1 = "2015-09";
	else
		let a_periodo1 = _periodo_eval;
	end if

	let a_periodo2 = _ano_int + 1 || "-12";

	create temp table tmp_reas_dif(
	no_poliza		char(10),
	no_endoso		char(5),
	no_factura		char(10),
	prima_suscrita	dec(16,2),
	prima_reas		dec(16,2)) with no log;

	let v_descr_cia = sp_sis01("001");

	call sp_pro34("001","001", a_periodo1, a_periodo2, "*", "*", "*", "*", "*", "*", "1") returning v_filtros;

	foreach with hold
		select cod_ramo,
			   no_factura,
			   no_documento,
			   cod_contratante,
			   estatus,
			   forma_pago,
			   cant_pagos,
			   suma_asegurada,
			   prima,
			   comision,
			   cod_agente,
			   no_poliza,
			   no_endoso
		  into v_cod_ramo,
			   v_nofactura,
			   v_nodocumento,
			   v_cod_contratante,
			   v_estatus,
			   v_forma_pago,
			   v_cant_pagos,
			   v_suma_asegurada,
			   v_prima_suscrita,
			   v_comision,
			   v_cod_agente,
			   v_nopoliza,
			   v_noendoso
		  from temp_det
		 where seleccionado = 1
		   and no_factura not in ("01-1626669", "01-1641578", "01-1698976")
		 order by cod_ramo,no_factura

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		select nombre
		  into v_desc_nombre
		  from cliclien
		 where cod_cliente = v_cod_contratante;
		
		let _cedido_total = 0.00;
		let _cedido_fac = 0.00;
		let _cedido_xl = 0.00;
		let v_cedido = 0.00;

		call sp_sis122b(v_nopoliza,v_noendoso) returning _error,_error_desc;

		foreach
			select e.cod_contrato,
				   e.cod_cober_reas,
				   t.tipo_contrato,
				   sum(e.prima_rea)
			  into _cod_contrato,
				   _cod_cober_reas,
				   _tipo_contrato,
				   _cedido_reas
			  from tmp_reas	e, endeduni r, reacomae t
			 where e.no_poliza = r.no_poliza
			   and e.no_endoso = r.no_endoso
			   and e.no_unidad = r.no_unidad
			   and e.cod_contrato = t.cod_contrato
			   and t.tipo_contrato <> 1
			   and e.no_poliza = v_nopoliza
			   and e.no_endoso = v_noendoso
			 group by e.no_poliza,e.no_endoso,e.cod_cober_reas,e.cod_contrato,tipo_contrato
			
			if _cedido_reas is null or _cedido_reas = 0 then
				continue foreach;
			end if
			
			let _cedido_total = _cedido_total + _cedido_reas;
			
			if _tipo_contrato = 3 then	--Facultativo
				let _cedido_fac = _cedido_fac + _cedido_reas;
			else
				foreach
					select porc_cont_partic,contrato_xl
					  into _porc_cont_partic,_contrato_xl
					  from reacoase
					 where cod_contrato = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas
					
					let _monto_reas = _cedido_reas * (_porc_cont_partic/100);
					
					if _contrato_xl = 0 then
						let v_cedido = v_cedido + _monto_reas;
					else
						let _cedido_xl = _cedido_xl + _monto_reas;
					end if
				end foreach
			end if

		end foreach

		drop table tmp_reas;

		if _cedido_total is null then
			let _cedido_total = 0;
		end if
		
		select porc_partic_agt
		  into _porc_partic_agt
		  from endmoage
		 where no_poliza  = v_nopoliza
		   and no_endoso  = v_noendoso
		   and cod_agente = v_cod_agente;

		let n_contrato   = "";

		foreach
			select distinct(t.nombre)
			  into n_contrato
			  from emifacon	e, endeduni r, reacomae t
			 where e.no_poliza = r.no_poliza
			   and e.no_endoso = r.no_endoso
			   and e.no_unidad = r.no_unidad
			   and e.cod_contrato = t.cod_contrato
			   and t.tipo_contrato <> 1
			   and e.no_poliza = v_nopoliza
			   and e.no_endoso = v_noendoso
			   and e.prima <> 0
			exit foreach;
		end foreach

		let _tot_prima_sus	= 0;
		let _monto			= 0;
		let _tot_prima_sus	= _cedido_total * _porc_partic_agt / 100;
		let v_cedido	    = v_cedido * _porc_partic_agt / 100;
		let _cedido_xl	    = _cedido_xl * _porc_partic_agt / 100;
		let _cedido_fac	    = _cedido_fac * _porc_partic_agt / 100;

		select periodo
		  into _peri
		  from endedmae
		 where no_poliza = v_nopoliza
		   and no_endoso = v_noendoso;

		let _parti_reas = 0;

		if  v_prima_suscrita <> 0 then
			let _parti_reas = (_tot_prima_sus / v_prima_suscrita) * 100;
		else
			let _parti_reas = 0;
		end if

		insert into tmp_reas_dif
		values (v_nopoliza, v_noendoso, v_nofactura, v_prima_suscrita, _tot_prima_sus - _cedido_xl); 

		{
		return	v_cod_ramo,
				v_desc_ramo,
				v_nofactura,
				v_nodocumento,
				v_desc_nombre,
				v_prima_suscrita,
				v_descr_cia,
				v_filtros,
				_tot_prima_sus,
				_peri,
				_res_comprobante,
				_parti_reas,
				n_contrato,
				_cedido_xl,
				v_cedido,
				_cedido_fac
				with resume;
		}
	end foreach

foreach
	select no_poliza,
		   no_endoso,
		   no_factura,
		   sum(prima_suscrita),
		   sum(prima_reas)
	  into v_nopoliza,
		   v_noendoso,
		   v_nofactura,
		   v_prima_suscrita,
		   _tot_prima_sus
	  from tmp_reas_dif
	 group by 1, 2, 3 
	 order by 3

	let _no_registro = null;

--	foreach
	select no_registro,
	       sac_asientos,
		   periodo
	  into _no_registro,
	       _sac_asientos,
		   _peri
	  from sac999:reacomp
	 where no_poliza     = v_nopoliza
	   and no_endoso     = v_noendoso
	   and tipo_registro = 1;
--		exit foreach;
--	end foreach

	if _no_registro is not null then
		if _sac_asientos = 2 then

			 select sum(debito - credito)
			   into _monto_asien
			   from sac999:reacompasie
			  where no_registro = _no_registro
			    and cuenta[1,3] = "511";

			if _monto_asien is null then
				let _monto_asien  = 0;
			end if
		else
			continue foreach;
		end if
	else
		continue foreach;
	end if


	if abs(_monto_asien - _tot_prima_sus) > 0.1 then
		let v_cod_ramo = "*";
	else
		let v_cod_ramo = "";
	end if

	if v_cod_ramo = "*" then
		 
		{
		update sac999:reacomp
		   set sac_asientos  = 0
		 where no_poliza     = v_nopoliza
		   and no_endoso     = v_noendoso
		   and tipo_registro = 1;
		--}

		return	v_cod_ramo,
				"",
				v_nofactura,
				_no_registro,
				"",
				v_prima_suscrita,
				"",
				"",
				_tot_prima_sus,
				_peri,
				"",
				0,
				"",
				_monto_asien,
				0,
				_tot_prima_sus - _monto_asien
				with resume;

	end if

end foreach

drop table temp_det;
drop table tmp_reas_dif;

end

return	"",
		"",
		"",
		"",
		"",
		0,
		"",
		"",
		0,
		"",
		"",
		0,
		"",
		0,
		0,
		0;
		
end procedure;