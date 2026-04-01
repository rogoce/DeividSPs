-- Procedimeinto para actualizar el monto de la visa o ach en mantenimiento de visa/ach cuando la vigencia entre en vigor.
-- Creado    : 15/08/2017 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis238;
create procedure sp_sis238(a_periodo_ini char(8), a_periodo char(8))
returning	char(5)			as cod_agente,
			varchar(30)		as nom_agente,
			smallint		as retroactivo,
			varchar(30)		as forma_pago,
			char(20)		as poliza,
			dec(16,2)		as prima_neta_cobrada,
			dec(16,2)		as saldo_pxc,
			dec(16,2)		as por_vencer_pxc,
			dec(16,2)		as exigible_pxc,
			dec(16,2)		as corriente_pxc,
			dec(16,2)		as monto_30_pxc,
			dec(16,2)		as monto_60_pxc,
			dec(16,2)		as monto_90_pxc,
			dec(16,2)		as monto_120_pxc,
			dec(16,2)		as monto_150_pxc,
			dec(16,2)		as monto_180_pxc;

define _nom_formapag		varchar(30);
define _nom_agente			varchar(30);
define _error_desc			varchar(30);
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _cod_agente			char(5);
define _cod_formapag		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _porc_partic_agt		dec(5,2);
define _porc_partic_cob		dec(5,2);
define _por_vencer_pxc		dec(16,2);
define _prima_neta_cob		dec(16,2);
define _corriente_pxc		dec(16,2);
define _monto_180_pxc		dec(16,2);
define _monto_150_pxc		dec(16,2);
define _monto_120_pxc		dec(16,2);
define _monto_90_pxc		dec(16,2);
define _monto_60_pxc		dec(16,2);
define _monto_30_pxc		dec(16,2);
define _exigible_pxc		dec(16,2);
define _saldo_pxc			dec(16,2);
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _retroactivo			smallint;
define _declarativa			smallint;
define _concurso			smallint;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return _cod_agente,_no_documento,_error,_error_desc,'',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00;
end exception 

foreach
	{select cod_agente,
		   nombre
	  into _cod_agente,
		   _nom_agente
	  from agtagent
	 where cod_agente not in (select cod_agente from deivid_tmp:corredores_remesa)
	   and cod_cobrador <> '217'
	   and tipo_agente = 'A'}

	select cod_agente,
		   nom_agente
	  into _cod_agente,
		   _nom_agente
	  from deivid_tmp:corredores_remesa
	 where nuevo = 1	 

	select retroactivo
	  into _retroactivo
	  from chqboagt
	 where cod_agente = _cod_agente;

	if _retroactivo is null then
		let _retroactivo = 0;
	end if

	foreach
		select distinct e.no_documento,
			   e.cod_formapag,
			   e.cod_ramo,
			   e.cod_subramo,
			   e.declarativa
		  into _no_documento,
			   _cod_formapag,
			   _cod_ramo,
			   _cod_subramo,
			   _declarativa
		  from emipomae e, emipoagt a 
		 where e.no_poliza = a.no_poliza
		   and a.cod_agente = _cod_agente
		   and (e.cod_ramo not in ('019','018','016','008'))
		   and e.cod_tipoprod not in ('002','004')
		   and e.actualizado = 1

		if _cod_formapag not in ('006','008') then
			continue foreach;
		end if

		if _cod_ramo = '001' and _cod_subramo = '006' then
			continue foreach;
		end if

		if _cod_ramo = '009' and _declarativa = 1 then
			continue foreach;
		end if

		select concurso
		  into _concurso
		  from prdsubra
		 where cod_ramo = _cod_ramo
		   and cod_subramo = _cod_subramo;

		if _concurso is null then
			let _concurso = 0;
		end if

		if _concurso = 0 then
			continue foreach;
		end if

		select nombre
		  into _nom_formapag
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		let _no_poliza = sp_sis21(_no_documento);

		select porc_partic_agt
		  into _porc_partic_agt
		  from emipoagt
		 where cod_agente = _cod_agente
		   and no_poliza = _no_poliza;

		if _porc_partic_agt is null then
			let _porc_partic_agt = 0.00;
		end if

		select nvl(saldo_pxc * (_porc_partic_agt/100) ,0.00),
			   nvl(por_vencer_pxc * (_porc_partic_agt/100),0.00),
			   nvl(exigible_pxc * (_porc_partic_agt/100),0.00),
			   nvl(corriente_pxc * (_porc_partic_agt/100),0.00),
			   nvl(monto_30_pxc * (_porc_partic_agt/100),0.00),
			   nvl(monto_60_pxc * (_porc_partic_agt/100),0.00),
			   nvl(monto_90_pxc * (_porc_partic_agt/100),0.00),
			   nvl(dias_120_pxc * (_porc_partic_agt/100),0.00),
			   nvl(dias_150_pxc * (_porc_partic_agt/100),0.00),
			   nvl(dias_180_pxc * (_porc_partic_agt/100),0.00)
		  into _saldo_pxc,
			   _por_vencer_pxc,
			   _exigible_pxc,
			   _corriente_pxc,
			   _monto_30_pxc,
			   _monto_60_pxc,
			   _monto_90_pxc,
			   _monto_120_pxc,
			   _monto_150_pxc,
			   _monto_180_pxc
		  from deivid_cob:cobmoros
		 where no_documento = _no_documento
		   and periodo = a_periodo;

		let _prima_neta_cob = 0.00;

		if _retroactivo = 0 then
			select sum(d.prima_neta * (c.porc_partic_agt/100))
			  into _prima_neta_cob				   
			  from cobredet d, cobremae m, cobreagt c
			 where d.no_remesa = m.no_remesa
			   and d.no_remesa = c.no_remesa
			   and d.renglon = c.renglon
			   and d.doc_remesa = _no_documento
			   and d.actualizado = 1
			   and (month(d.fecha) >= a_periodo_ini[6,7]
			   and month(d.fecha) <= a_periodo[6,7])
			   and year(d.fecha)  = a_periodo[1,4]
			   and d.tipo_mov in ('P','N')
			   and m.tipo_remesa in ('A','M','C')
			   and c.cod_agente = _cod_agente;

			if _prima_neta_cob is null then
				let _prima_neta_cob = 0.00;
			end if
		end if
		
		return	_cod_agente,
				_nom_agente,
				_retroactivo,
				_nom_formapag,
				_no_documento,
				_prima_neta_cob,
				_saldo_pxc,
				_por_vencer_pxc,
				_exigible_pxc,
				_corriente_pxc,
				_monto_30_pxc,
				_monto_60_pxc,
				_monto_90_pxc,
				_monto_120_pxc,
				_monto_150_pxc,
				_monto_180_pxc with resume;
	end foreach
end foreach
end
end procedure;