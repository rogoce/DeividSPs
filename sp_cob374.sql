-- Proceso de Ajuste de letras en Emiletra
-- Creado    : 17/07/2015 - Autor: Román Gordón
drop procedure sp_cob374;
create procedure sp_cob374()
returning	integer,
			varchar(100);

define _error_desc			varchar(100);
define _no_documento		char(19);
define _no_poliza			char(10);
define _no_poliza_c			char(10);
define _nueva_renov			char(1);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _monto_pendiente		dec(16,2);
define _letra_residuo		dec(16,2);
define _monto_residuo		dec(16,2);
define _monto_pagado		dec(16,2);
define _monto_letra			dec(16,2);
define _total_pen			dec(16,2);
define _monto_pen			dec(16,2);
define _residuo				dec(16,2);
define _porc_desc			dec(16,2);
define _letra_pagada		smallint;
define _no_letra_c			smallint;
define _no_letra			smallint;
define _no_pagos			smallint;
define _cnt_chq				smallint;
define _pagada				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_vencimiento	date;
define _fecha_venc			date;

define _nom_agente		varchar(50);
define _periodo			char(7);
define _cod_agente		char(5);
define _cod_tipoprod	char(3);
define _monto_vencido	dec(16,2);
define _monto_pag		dec(16,2);
define _resto           dec(16,2);
define _por_vencer		dec(16,2);
define _corriente		dec(16,2);
define _exigible		dec(16,2);
define _monto_30		dec(16,2);
define _monto_60		dec(16,2);
define _monto_90		dec(16,2);
define _saldo			dec(16,2);
define _estatus_poliza	smallint;
define _dias_atraso		smallint;
define _max_letra		smallint;
define _periodo_gracia	date;
define _vigencia_final	date;
define _vigencia_inic   date;
define _fecha_hoy	   date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || trim(_no_poliza);
	return _error,_error_desc;
end exception

--set debug file to "sp_pro541.trc";
--trace on;

let _fecha_hoy = current;
let _periodo = sp_sis39(_fecha_hoy);

foreach
	select distinct l.no_poliza
	  into _no_poliza
	  from emiletra l, emipomae e
	 where e.no_poliza = l.no_poliza
	   and (e.estatus_poliza = 1 or (e.estatus_poliza = 3 and e.vigencia_final >= '01/01/2014'))
	   --and periodo_gracia < today
	   --and today - l.vigencia_inic >= a_dias_vencida   -->= 60 -->= 60 between 50 and 59 --
	   and pagada = 0
	   and monto_letra <> 0

	let _monto_vencido = 0.00;
	let _monto_letra = 0.00;
	let _monto_pen = 0.00;

	{select no_poliza
	  into _no_poliza
	from emiletra l, emipomae e
	 where e.no_poliza = l.no_poliza
	   and (e.estatus_poliza = 1 or (e.estatus_poliza = 3 and e.vigencia_final >= '01/01/2014'))
	   and periodo_gracia < today
	   and pagada = 0}

	select min(no_letra),
		   sum(monto_pen)
	  into _no_letra,
		   _monto_vencido
	  from emiletra
	 where no_poliza = _no_poliza
	   and periodo_gracia < today
	   and pagada = 0;
	 --order by periodo_gracia desc

	{if _no_letra = 1 then
		let _monto_pag = 0;

		select sum(monto_pag)
		  into _monto_pag
		  from emiletra
		 where no_poliza = _no_poliza
		   and no_letra = _no_letra;

		if _monto_pag = 0 then
			continue foreach;
		end if
	end if}

	select no_documento,
		   estatus_poliza,
		   vigencia_inic,
		   vigencia_final,
		   cod_tipoprod
	  into _no_documento,
		   _estatus_poliza,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	select count(*)
	  into _cnt_chq
	  from chqchpol
	 where no_documento = _no_documento;

	if _cnt_chq is null then
		let _cnt_chq = 0;
	end if

	if _cnt_chq > 0 then
		continue foreach;
	end if

	if _estatus_poliza = 2 or _cod_tipoprod = '002' then
		continue foreach;
	end if

	select sum(monto_pen)
	  into _monto_pen
	  from emiletra
	 where no_documento = _no_documento;

	let _dias_atraso = 0;

	select periodo_gracia,
		   today - vigencia_inic
	  into _periodo_gracia,
		   _dias_atraso
	  from emiletra
	 where no_poliza = _no_poliza
	   and no_letra = _no_letra;

	select sum(monto_letra),
		   max(no_letra)
	  into _monto_letra,
		   _max_letra
	  from emiletra
	 where no_poliza = _no_poliza;

	call sp_cob33('001','001',_no_documento,_periodo,_fecha_hoy)
	returning   _por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo;

	if _saldo <> _monto_pen then
		call sp_pro545(_no_documento) returning _error,_error_desc;

		if _error <> 0 then
			return _error,_error_desc;
		else
			select no_documento
			  into _no_documento
			  from emipomae
			 where no_poliza = _no_poliza;

			call sp_cob346a(_no_documento) returning _error,_error_desc;
			
			if _error <> 0 then
				return _error,_error_desc;
			end if
			
			call sp_pro544(_no_documento) returning _error,_error_desc;
			
			if _error <> 0 then
				return _error,_error_desc;
			end if
		end if
		--let _max_letra = _max_letra* -1;
		return 1,_no_documento with resume;
	elif
		
	end if

	{foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 order by porc_partic_agt desc

		exit foreach;
	end foreach

	select nombre
	  into _nom_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	return	_no_poliza,
			_no_documento,
			_estatus_poliza,
			_periodo_gracia,
			_vigencia_inic,
			_vigencia_final,
			_monto_letra,
			_monto_vencido,
			_monto_pen,
			_saldo,
			_no_letra,
			_max_letra,
			_nom_agente,
			_dias_atraso
			with resume;}
end foreach
end
end procedure;