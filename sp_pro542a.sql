-- Reporte que 
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro542a;

create procedure sp_pro542a(a_dias_vencida smallint)
returning	char(10)	as no_poliza,
			char(20)	as Poliza,
			smallint	as Estatus_Poliza,
			date		as Periodo_Gracia,
			date		as Vigencia_Inicial,
			date		as Vigencia_Final,
			dec(16,2)	as Prima_Bruta,
			dec(16,2)	as Monto_Vencido,
			dec(16,2)	as Monto_Pendiente,
			smallint	as letra_pendiente,
			smallint	as no_letras,
			varchar(50)	as Corredor,
			char(1)		as Nueva_Renov;

define _nom_agente		varchar(50);
define _error_desc		char(50);
define _no_documento	char(20);
define _no_poliza		char(10);
define _periodo			char(7);
define _cod_agente		char(5);
define _cod_tipoprod	char(3);
define _nueva_renov		char(1);
define _monto_vencido	dec(16,2);
define _monto_letra		dec(16,2);
define _monto_pen		dec(16,2);
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
define _max_letra		smallint;
define _no_letra		smallint;
define _error_isam		integer;
define _error			integer;
define _periodo_gracia	date;
define _vigencia_final	date;
define _vigencia_inic   date;
define _fecha_hoy		date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || trim(_no_poliza);
	return '',_error_desc,_error,'01/01/1900','01/01/1900','01/01/1900',0,0.00,_error_isam,0,0,'','';
end exception

--set debug file to "sp_pro541.trc";
--trace on;

let _fecha_hoy = current;
let _periodo = sp_sis39(_fecha_hoy);

foreach
	select l.no_poliza,
		   l.periodo_gracia
	  into _no_poliza,
		   _periodo_gracia
	  from emiletra l, emipomae e
	 where e.no_poliza = l.no_poliza
	   and (e.estatus_poliza = 1 or (e.estatus_poliza = 3 and e.vigencia_final >= '01/01/2014'))
	   --and periodo_gracia < today
	   and today - l.vigencia_inic >= a_dias_vencida --between 45 and 49   -->= 60 between 50 and 59 --
	   and pagada = 0
	   and no_letra = 1
	   and l.monto_letra <> 0
	   and l.monto_pag <= 0
	 order by periodo_gracia desc

	let _no_letra = 1;
	{select no_poliza,
		   min(no_letra)
	  into _no_poliza,
		   _no_letra
	  from emiletra
	 where periodo_gracia < today
	   and pagada = 0
	 group by 1}
	 --order by periodo_gracia desc

	select monto_pen,
		   monto_pag
	  into _monto_vencido,
		   _monto_pag
	  from emiletra
	 where no_poliza = _no_poliza
	   and no_letra = _no_letra;

	if _monto_pag > 0 then
		continue foreach;
	end if

	select sum(monto_letra),
		   sum(monto_pen),
		   max(no_letra)
	  into _monto_letra,
		   _monto_pen,
		   _max_letra
	  from emiletra
	 where no_poliza = _no_poliza;

	select no_documento,
		   estatus_poliza,
		   vigencia_inic,
		   vigencia_final,
		   cod_tipoprod,
		   nueva_renov
	  into _no_documento,
		   _estatus_poliza,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_tipoprod,
		   _nueva_renov
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _estatus_poliza = 2 or _cod_tipoprod = '002' then
		continue foreach;
	end if
	
	call sp_cob33('001','001',_no_documento,_periodo,_fecha_hoy)
	returning   _por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo;

	if _saldo <> _monto_pen then
		{call sp_pro545(_no_documento) returning _error,_error_desc;
		
		if _error <> 0 then
			return '',_error_desc,_error,'01/01/1900','01/01/1900','01/01/1900',0,0.00,'',0,0,'','';
		else
			select no_documento
			  into _no_documento
			  from emipomae
			 where no_poliza = _no_poliza;

			call sp_cob346a(_no_documento) returning _error,_error_desc;
			
			if _error <> 0 then
				return '',_error_desc,_error,'01/01/1900','01/01/1900','01/01/1900',0,0.00,'',0,0,'','';
			end if
			
			call sp_pro544(_no_documento) returning _error,_error_desc;
			
			if _error <> 0 then
				return '',_error_desc,_error,'01/01/1900','01/01/1900','01/01/1900',0,0.00,'',0,0,'','';
			end if
		end if}
		let _max_letra = _max_letra* -1;
	end if

	if _max_letra <> -1 then
		--continue foreach;
	end if

	foreach
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

	--call sp_pro545(_no_documento) returning _error, _error_desc;
	--call sp_cob346a(_no_documento) returning _error, _error_desc;
	--call sp_pro544(_no_documento) returning _error, _error_desc;

	return	_no_poliza,
			_no_documento,
			_estatus_poliza,
			_periodo_gracia,
			_vigencia_inic,
			_vigencia_final,
			_monto_letra,
			_monto_vencido,
			_monto_pen,
			_no_letra,
			_max_letra,
			_nom_agente,
			_nueva_renov
			with resume;
end foreach
end
end procedure;