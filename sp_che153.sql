--Ajuste de pólizas en adelanto
-- Creado    : 05/10/2016 - autor: Román Gordón


drop procedure sp_che153;
create procedure sp_che153() 
returning   integer			as cod_error,
			varchar(255)	as error_desc;   -- licencia

define _error_desc			varchar(255);
define _no_documento		char(21);
define _no_remesa			char(10);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _comision_adelanto	dec(16,2);
define _comis_saldo_ant		dec(16,2);
define _comis_saldo_act		dec(16,2);
define _comision_saldo		dec(16,2);
define _comision_cobro		dec(16,2);
define _monto_cobro			dec(16,2);
define _adelanto_comis		smallint;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;

begin
on exception set _error, _error_isam,_error_desc
	return _error, _error_desc;									   
end exception

set isolation to dirty read;

--set debug file to "sp_che04.trc";
--trace on;

drop table if exists temp_cobadeco;

select c.cod_agente,
	   d.doc_remesa,
	   d.no_poliza,
	   a.comision_saldo,
	   round((d.prima_neta * a.porc_comis_agt/100),2) as comision_cobro,
	   round((a.comision_saldo - (d.prima_neta * a.porc_comis_agt/100)),2) as comis_saldo_act,
	   d.no_remesa,
	   d.renglon,
	   d.no_recibo,
	   d.monto
  from cobredet d, cobadeco a, agtagent c
 where d.doc_remesa = a.no_documento
   and a.cod_agente = c.cod_agente
   and d.fecha >= (select fecha_desde from chqpagco where semana in (select min(semana) from chqpagco where generado = 0))
   and d.fecha <= (select fecha_hasta from chqpagco where semana in (select min(semana) from chqpagco where generado = 0))
   and d.tipo_mov in ('P','N')
   and (a.comision_saldo - (d.prima_neta * a.porc_comis_agt/100)) < 5
   and d.actualizado = 1
into temp temp_cobadeco;

foreach
	select cod_agente,
		   doc_remesa,
		   no_poliza,
		   comision_saldo,
		   comision_cobro,
		   comis_saldo_act,
		   no_remesa,
		   renglon,
		   no_recibo,
		   monto
	  into _cod_agente,
		   _no_documento,
		   _no_poliza,
		   _comis_saldo_ant,
		   _comision_cobro,
		   _comis_saldo_act,
		   _no_remesa,
		   _renglon,
		   _no_recibo,
		   _monto_cobro
	  from temp_cobadeco
	 order by cod_agente,comision_saldo
	

	if _comis_saldo_act >= 0 then
		continue foreach;
	end if

	select adelanto_comis
	  into _adelanto_comis
	  from agtagent
	 where cod_agente = _cod_agente;

	--if _adelanto_comis = 0 then
		update cobadeco
		   set no_recibo = _no_recibo,
			   comision_adelanto = _comis_saldo_act * -1,
			   comision_ganada = _comis_saldo_ant * -1,
			   comision_saldo = _comision_cobro
		 where no_documento = _no_documento
		   and cod_agente = _cod_agente;
	{else
		delete from cobadeco
		 where no_documento = _no_documento;

		call sp_che136a(_no_remesa,_renglon) returning _error,_error_desc;

		if _error <> 0 then
			return _error,_error_desc;
		end if

		select comision_adelanto
		  into _new_comis_adelanto
		  from cobadeco
		 where cod_agente = _cod_agente
		   and no_documento = _no_documento;
	end if	}
end foreach

return 0,'Actualización Exitosa';
end
end procedure;