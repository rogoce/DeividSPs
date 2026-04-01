--*****************************************************************************************************
-- Reporte especial para fianza donde muestra el SECTOR y TIPO_FIANZA
-- REPORTE DE FIANZAS DESDE EL 01 DE ENERO DE 2018 AL 30 DE JUNIIO 2018 OTORGADAS AL SECTOR: ESTADO 
-- TIPO DE FIANZAS: (PROPUESTAS, CUMPLIMIENTO, PAGO ANTICIPADO, PAGOS A TERCEROS) 
-- CON LAS SIGUIENTES COLUMNAS: NRO. DE FIANZA, ASEGURADO, SUMA ASEGURADA, PRIMA TOTAL, % DE REASEGURO.
--*****************************************************************************************************
--execute procedure sp_pro414('001','001','2018-01','2018-12',"*","*","*","*","008;","*",'1',"*","*")
-- Creado    : 12/02/2019 - Autor: Henry Giron

drop procedure sp_pro414;
create procedure "informix".sp_pro414(
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
returning	char(3)			as cod_ramo,
			char(50)		as nom_ramo,
			char(10)		as factura,
			char(20)		as poliza,
			char(50)		as cliente,
			dec(16,2)		as prima_suscrita,
			char(50)		as compania,
			char(255)		as filtros,
			dec(16,2)		as cedido_total,
			char(7)			as periodo,
			char(15)		as comprobante,
			dec(16,2)		as porc_partic_res,
			varchar(50)		as contrato,
			dec(16,2)		as cedido_xl,
			dec(16,2)		as cedido_contrato,
			dec(16,2)		as cedido_facultativo,
			char(100)       as sector,
			char(100)       as tipo_fianza;

begin
define n_contrato			varchar(50);
define v_filtros			char(255);
define v_desc_agente		char(50);
define v_desc_ramo			char(50);
define v_descr_cia			char(50);
define v_desc_nombre		char(35);
--define _cuenta				char(25);
define v_nodocumento		char(20);
define _res_comprobante		char(15);
define v_cod_contratante	char(10);
define _no_registro			char(10);
define v_nofactura			char(10);
define v_nofactura_m		char(10);
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
define _dif_cedido			dec(16,2);
define _cuenta_cedido		dec(16,2);
define _tipo_contrato		smallint;
define _contrato_xl			smallint;
define v_cant_pagos			smallint;
define v_estatus			smallint;
define _cnt_reas			smallint;
define _flag				smallint;
define _cnt					integer;
define _sac_notrx			integer;
define _valor1              integer;
define _msg_valor           char(100);
define _SECTOR				smallint;
define _TIPO_FIANZA			integer;
define _DESC_SECTOR         char(100);
define _DESC_TIPO_FIANZA    char(100);
define v_cod_subramo		char(3);

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
LET _DESC_SECTOR      = null;
LET _DESC_TIPO_FIANZA = null;
drop table if exists temp_det;

let v_descr_cia = sp_sis01(a_compania);
--let a_codramo = '002,020,023;';

call sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro, a_tipopol)
returning	v_filtros;

--set debug file to "sp_pro414.trc"; 
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

let v_nofactura_m = '';
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
		   cod_agente,
		   no_poliza,
		   no_endoso,
		   cod_subramo
	  into v_cod_ramo,
		   v_nofactura,
		   v_nodocumento,
		   v_cod_contratante,
		   v_estatus,
		   v_forma_pago,
		   v_cant_pagos,
		   v_suma_asegurada,
		   v_prima_suscrita,
		   v_cod_agente,
		   v_nopoliza,
		   v_noendoso,
		   v_cod_subramo
	  from temp_det
	 where seleccionado = 1
	   {and no_factura in ('11-26444',
'11-26445',
'11-26446',
'11-26458',
'11-26464',
'11-26465',
'11-26466',
'11-26471',
'11-26472')}
	   --and cod_ramo in ('001','003')
	   --and no_factura = '01-2037832'
	 order by cod_ramo,no_factura

	if trim(v_nofactura_m) <> trim(v_nofactura) then
		let _flag = 0;
		let v_nofactura_m = v_nofactura;
	end if

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
		 order by e.cod_cober_reas,e.cod_contrato,tipo_contrato
		
		if _cedido_reas is null or _cedido_reas = 0 then
			continue foreach;
		end if
		
		let _cedido_total = _cedido_total + _cedido_reas;
		
		if _tipo_contrato = 3 then	--Facultativo
			let _cedido_fac = _cedido_fac + _cedido_reas;
		else
			{foreach
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
			end foreach}
			select count(*)
			  into _cnt_reas
			  from reacoase
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			if _cnt_reas is null then
				let _cnt_reas = 0;
			end if
			
			if _cnt_reas = 0 then
				let v_cedido = v_cedido + _cedido_reas;
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
		end if
	end foreach

	let _dif_cedido = 0;
	
	if _cedido_total is null then
		let _cedido_total = 0;
	end if

	if _flag = 0 then
		let _cuenta_cedido = 0;

		select sum(debito)- sum(credito)
		  into _cuenta_cedido
		  from sac999:reacomp c, sac999:reacompasie a
		 where a.no_registro = c.no_registro
		   and c.no_poliza = v_nopoliza
		   and c.no_endoso = v_noendoso
		   and a.cuenta like '511%';

		if _cuenta_cedido is null then
			let _cuenta_cedido = 0;
		end if
		
		let _dif_cedido = (v_cedido + _cedido_fac) - _cuenta_cedido;
		{let _tot_prima_sus = _tot_prima_sus - _dif_cedido;
		let v_cedido = v_cedido - _dif_cedido;
		
		let _flag = 1;}
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

	if _flag = 0 then
		let _tot_prima_sus = _tot_prima_sus - _dif_cedido;
		let v_cedido = v_cedido - _dif_cedido;
		
		let _flag = 1;
	end if

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
	
	let v_nofactura = v_nofactura;
	let v_nopoliza = v_nopoliza;
	let v_noendoso = v_noendoso;
	
	foreach
	SELECT distinct c.sector, c.tipo_fianza
	  INTO _SECTOR, _TIPO_FIANZA
	  FROM endedmae a, endeduni b , emifian1 c
	 WHERE a.no_poliza = b.no_poliza
  	   AND a.no_endoso = b.no_endoso
	   AND a.no_poliza = c.no_poliza	   
  	   AND b.no_unidad = c.no_unidad
  	   AND a.no_factura = v_nofactura
	  exit foreach;	   
	   end foreach
	   
	if _SECTOR is null then
	   let _SECTOR = 0;
	end if	 	   
	if _SECTOR = 0 then
	   let _DESC_SECTOR = '';
	end if		
	if _SECTOR = 1 then
	   let _DESC_SECTOR = 'ESTADO';
	end if		
	if _SECTOR = 2 then
	   let _DESC_SECTOR = 'PRIVADO';
	end if	
	
	if _TIPO_FIANZA is null then
	   let _TIPO_FIANZA = 0;
	end if		
	
	 select distinct upper(nombre)
	   into _DESC_TIPO_FIANZA
	   from prdsubra 
	  where cod_ramo = v_cod_ramo
	    and cod_subramo = v_cod_subramo;	
	
		if _DESC_TIPO_FIANZA is null then
		   let _DESC_TIPO_FIANZA = '';
		end if	       
		
    let _SECTOR = 0; 
    let _TIPO_FIANZA = 0;

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
			_cedido_fac,
			_DESC_SECTOR,
			_DESC_TIPO_FIANZA
			with resume;
end foreach
--trace off;
--
end
end procedure;