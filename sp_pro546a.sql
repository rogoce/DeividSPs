-- Actualiza la tabla emiletra cuando la póliza recibe un pago
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro546a;
create procedure sp_pro546a()
returning	int,
			char(50);

define _error_desc		char(50);
define _no_documento	char(20);
define _no_poliza		char(10);
define _periodo			char(7);
define _cod_tipoprod	char(3);
define _monto_letra		dec(16,2);
define _sum_endoso		dec(16,2);
define _sum_cobros		dec(16,2);
define _por_vencer		dec(16,2);
define _corriente		dec(16,2);
define _monto_pen		dec(16,2);
define _monto_pag		dec(16,2);
define _monto_30		dec(16,2);
define _monto_60		dec(16,2);
define _monto_90		dec(16,2);
define _exigible		dec(16,2);
define _saldo			dec(16,2);
define _cnt_credito		smallint;
define _cnt_chq			smallint;
define _no_letra		smallint;
define _pagada			smallint;
define _error_isam		integer;
define _error			integer;
define _fecha			date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_pro546a.trc";
--trace on;

let _fecha = today;
let _periodo = sp_sis39(_fecha);

foreach with hold
	select distinct l.no_documento
	  into _no_documento
	  from emiletra l, emipomae e
	 where e.no_poliza = l.no_poliza
	   and (e.estatus_poliza = 1 or (e.estatus_poliza = 3 and e.vigencia_final >= '01/01/2013'))
	  --from emiletra
	 order by no_documento

	begin work;
	
	select count(*)
	  into _cnt_credito
	  from emiletra
	 where no_documento = _no_documento
	   and monto_letra < 0;

	if _cnt_credito is null then
		let _cnt_credito = 0;
	end if

	select count(*)
	  into _pagada
	  from emiletra
	 where no_documento = _no_documento
	   and monto_letra> 0
	   and pagada = 0;

	if _pagada is null then
		let _pagada = 0;
	end if

	if _pagada <> 0 and _cnt_credito <> 0 then
		
		foreach
			select cod_tipoprod
			  into _cod_tipoprod
			  from emipomae
			 where no_documento = _no_documento

			if _cod_tipoprod = '002' then
				exit foreach;
			end if
		end foreach
		
		if _cod_tipoprod = '002' then
			commit work;
			continue foreach;
		end if
	
		select count(*)
		  into _cnt_chq
		  from  chqchpol
		 where no_documento = _no_documento;

		if _cnt_chq is null then
			let _cnt_chq = 0;
		end if

		if _cnt_chq <> 0 then
			commit work;
			continue foreach;
		end if

		select sum(prima_bruta)
		  into _sum_endoso
		  from endedmae
		 where no_documento = _no_documento
		   and actualizado = 1
		   and activa = 1;

		select sum(d.monto)
		  into _sum_cobros
		  from cobremae m, cobredet d
		 where m.no_remesa = d.no_remesa
		   and d.doc_remesa = _no_documento
		   and m.actualizado = 1
		   and m.tipo_remesa in ('A','M','C','J','H','T')
		   and d.tipo_mov in ('P','N','X');
		
		select sum(monto_letra),
			   sum(monto_pen),
			   sum(monto_pag)
		  into _monto_letra,
			   _monto_pen,
			   _monto_pag
		  from emiletra
		 where no_documento = _no_documento;
		 
		call sp_cob33('001', '001', _no_documento, _periodo, _fecha)
		returning   _por_vencer,
					_exigible,
					_corriente,
					_monto_30,
					_monto_60,
					_monto_90,
					_saldo;

		if _monto_letra <> _sum_endoso or _monto_pen <> _saldo or _monto_pag <> _sum_cobros then
		{call sp_pro544(_no_documento) returning _error,_error_desc;
		
		if _error <> 0 then
			return _error,_error_desc;
		else}
			return 1,_no_documento with resume;
		end if		
	end if	
	
	commit work;
end foreach

--return 0,'Actualización Exitosa';
end
end procedure;