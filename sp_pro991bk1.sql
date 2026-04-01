--execute procedure sp_pro991('001','001','2013-12','2013-12',"*","*","*","*","001;","*",'1',"*","*")
drop procedure sp_pro991bk1;
create procedure "informix".sp_pro991bk1(
	a_compania		char(3),
	a_agencia		char(3),
	a_periodo1		char(7),
	a_periodo2		char(7),
	a_codsucursal	char(255) default "*",
	a_codgrupo		char(255) default "*",
	a_codagente		char(255) default "*",
	a_codusuario	char(255) default "*",
	a_codramo		char(255) default "*",
	a_reaseguro		char(255) default "*",
	a_tipopol		char(1),
	a_cod_cliente	char(255) default "*",
	a_no_documento	char(255) default "*")
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
	define _valor1              integer;
	define _msg_valor           char(100);

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

	let v_descr_cia = sp_sis01(a_compania);

	call sp_pro34(	a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
					a_codusuario,a_codramo,a_reaseguro, a_tipopol) returning v_filtros;

--set debug file to "sp_pro991.trc"; 
--trace on;
					
	--Filtro de Cliente
	if a_cod_cliente <> "*" then
		let v_filtros = trim(v_filtros) ||"Usuario "||trim(a_cod_cliente);
		let _tipo = sp_sis04(a_cod_cliente); -- separa los valores del string

		if _tipo <> "E" then -- incluir los registro
			update temp_det
			   set seleccionado = 0
			 where seleccionado = 1
			   and cod_contratante not in(select codigo from tmp_codigos);
		else
			update temp_det
			   set seleccionado = 0
			 where seleccionado = 1
			   and cod_contratante in(select codigo from tmp_codigos);
		end if		
		drop table tmp_codigos;
	end if

	--Filtro de Poliza
	if a_no_documento <> "*" and a_no_documento <> "" then
		let v_filtros = trim(v_filtros) ||"Documento: "||trim(a_no_documento);
		
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and no_documento <> a_no_documento;
	end if

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
		
		call sp_sis122(v_nopoliza, v_noendoso) returning _valor1,_msg_valor;
		
		foreach
			select e.cod_contrato,
				   e.cod_cober_reas,
				   t.tipo_contrato,
				   sum(e.prima_rea)
			  into _cod_contrato,
				   _cod_cober_reas,
				   _tipo_contrato,
				   _cedido_reas
			  from tmp_reas	e, reacomae t
			 where e.cod_contrato = t.cod_contrato
			   and t.tipo_contrato <> 1
			 group by e.cod_cober_reas,e.cod_contrato,tipo_contrato
			
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
					 where cod_contrato   = _cod_contrato
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

		let _no_registro = null;

		foreach
			select no_registro
			  into _no_registro
			  from sac999:reacomp
			 where no_poliza = v_nopoliza
			   and no_endoso = v_noendoso
			exit foreach;
		end foreach

		if _no_registro is not null then
			select count(*)
			into _cnt
			from sac999:reacompasie
			where no_registro = _no_registro;

			if _cnt > 0 then
				foreach
					select sac_notrx
					  into _sac_notrx
					  from sac999:reacompasie
					 where no_registro = _no_registro
					exit foreach;
				end foreach
				if _sac_notrx is not null then
					foreach
						select res_comprobante
						  into _res_comprobante
						  from cglresumen
						 where res_notrx = _sac_notrx
						exit foreach;
					end foreach
				end if
			else
				let _res_comprobante = '';
			end if
		end if
		
		let _parti_reas = 0;

		if  v_prima_suscrita <> 0 then
			let _parti_reas = (_tot_prima_sus / v_prima_suscrita) * 100;
		else
			let _parti_reas = 0;
		end if

		return	v_cod_ramo,
				v_desc_ramo,
				v_nofactura,
				v_nodocumento,
				v_desc_nombre,
				v_prima_suscrita,
				v_descr_cia,
				v_filtros,
				_tot_prima_sus, 	--reas cedido total
				_peri,
				_res_comprobante,
				_parti_reas,
				n_contrato,
				_cedido_xl,
				v_cedido,			--cedido cont
				_cedido_fac
				with resume;
	end foreach

	drop table temp_det;
end
end procedure;