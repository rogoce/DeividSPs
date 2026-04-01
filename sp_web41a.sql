-- Concurso PR
-- 
-- Creado    : 15/03/2017 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_web41a;
CREATE procedure "informix".sp_web41a()
RETURNING varchar(20)	as Categoria,
		  varchar(50)	as Corredor,
		  dec(16,2)		as prima_cobrada_ap,
		  smallint		as polizas_nuevas,
		  dec(16,2)		as prima_cobrada;


define _zona_ventas			varchar(50);
define _error_desc			varchar(50);
define _formapago			varchar(50);
define _corredor			varchar(50);
define _perpago				varchar(50);
define _subramo				varchar(50);
define _ramo				varchar(50);
define _categoria			varchar(20);
define _no_documento		char(20);
define _cod_agente_tmp		char(5);
define _cod_agente			char(5);
define _cod_formapag		char(3);
define _cod_subramo			char(3);
define _cod_perpago			char(3);
define _cod_ramo			char(3);
define _cod_vendedor		char(3);
define _porc_partic_agt		dec(9,6);
define _vigencia_inic		date;
define _vigencia_final		date;
define _polizas_nuevas		smallint;
define _error_isam			smallint;
define _meses				smallint;
define _error				smallint;
define _prima_cobrada_ap	dec(16,2);
define _suma_asegurada		dec(16,2);
define _prima_cobrada		dec(16,2);
define _prima_neta			dec(16,2);
define _saldo				dec(16,2);

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_web41.trc";
--trace on;
BEGIN

drop table if exists tmp_miniconv; 
create temp table tmp_miniconv(
categoria			varchar(20),
cod_agente			char(5),
polizas_nuevas		smallint,
prima_cob_ap		dec(16,2),
prima_cobr_conv		dec(16,2),
primary key(cod_agente)) with no log;

foreach
	select zon.cod_vendedor,
		   zon.nombre,
		   agt.cod_agente,
		   agt.nombre,
		   mae.porc_partic_agt,
		   emi.no_documento,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   ram.cod_ramo,
		   ram.nombre,
		   sub.cod_subramo,
		   sub.nombre,
		   emi.cod_formapag,
		   pag.nombre,
		   per.cod_perpago,
		   per.nombre,
		   per.meses,
		   emi.suma_asegurada,
		   emi.prima_neta,
		   emi.saldo,
		   case 
				when emi.cod_formapag in ('003','005') and  emi.cod_ramo <> '018' then emi.prima_neta
				when emi.cod_formapag in ('003','005') and  emi.cod_ramo = '018' and per.meses <> 0 then emi.prima_neta * per.meses
				when emi.cod_formapag in ('003','005') and  emi.cod_ramo = '018' and per.meses = 0 then emi.prima_neta
				else cob.prima_cob
		   end
	  into _cod_vendedor,	
	       _zona_ventas,
	       _cod_agente_tmp,
	       _corredor,
	       _porc_partic_agt,
	       _no_documento,
	       _vigencia_inic,
	       _vigencia_final,
	       _cod_ramo,
	       _ramo,
	       _cod_subramo,
	       _subramo,
	       _cod_formapag,
	       _formapago,
	       _cod_perpago,
	       _perpago,
	       _meses,
	       _suma_asegurada,
	       _prima_neta,
	       _saldo,
	       _prima_cobrada
	  from emipomae emi
	 inner join emipoagt mae on mae.no_poliza = emi.no_poliza
	 inner join agtagent agt on agt.cod_agente = mae.cod_agente and agt.tipo_agente = 'A'
	 inner join agtvende zon on zon.cod_vendedor = agt.cod_vendedor
	 inner join cobforpa pag on pag.cod_formapag = emi.cod_formapag
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join cobperpa per on per.cod_perpago = emi.cod_perpago
	  left join (select pol.no_poliza,sum(det.prima_neta) as prima_cob
				   from emipomae pol
				  inner join cobredet det on det.no_poliza = pol.no_poliza and det.tipo_mov in ('P','N') and det.fecha >= '15/08/2022' and det.actualizado = 1
				  where pol.fecha_suscripcion >= '15/08/2022'
					and pol.nueva_renov = 'N'
					and ((pol.cod_ramo = '019')
					  or (pol.cod_ramo = '018' and pol.cod_subramo not in ('010','012'))
					  or (pol.cod_ramo in ('001','003')))-- and pol.suma_asegurada <= 500000))
				   group by pol.no_poliza
				)  cob on emi.no_poliza = cob.no_poliza
	 where emi.fecha_suscripcion >= '15/08/2022'
	   and emi.nueva_renov = 'N'
	   and emi.actualizado = 1
	   and ((emi.cod_ramo = '019')
		 or (emi.cod_ramo = '018' and emi.cod_subramo not in ('010','012'))
		 or (emi.cod_ramo in ('001','003')))-- and emi.suma_asegurada <= 500000))
	 order by 2,6

	call sp_che168(_cod_agente_tmp) returning _error,_cod_agente;
	
	if _prima_cobrada is null then
		let _prima_cobrada = 0.00;
	end if
	
	begin
		on exception in(-239,-268)
			update tmp_miniconv
			   set	polizas_nuevas = polizas_nuevas + 1,
					prima_cobr_conv = prima_cobr_conv + _prima_cobrada
			 where cod_agente = _cod_agente;
		end exception

		insert into tmp_miniconv
				(cod_agente,
				polizas_nuevas,
				prima_cobr_conv
				)
		values( _cod_agente,
				1,
				_prima_cobrada
			  );
	end	
end foreach;

foreach
	select tmp.cod_agente,
		   agt.nombre,
		   tmp.polizas_nuevas,
		   tmp.prima_cobr_conv
	  into _cod_agente,
		   _corredor,
		   _polizas_nuevas,
		   _prima_cobrada
	  from tmp_miniconv tmp
	 inner join agtagent agt on agt.cod_agente = tmp.cod_agente
	 --where tmp.cod_agente = tmp_miniconv;

	select sum(pri_can_ap)
	  into _prima_cobrada_ap
	  from milan08
	 where cod_agente = _cod_agente;

	if _prima_cobrada_ap is null then
		let _prima_cobrada_ap = 0.00;
	end if

	if _prima_cobrada_ap > 250000 then
		let _categoria = 'CATEGORIA I';
	else
		let _categoria = 'CATEGORIA II';
	end if

		return _categoria,
			   _corredor,
			   _prima_cobrada_ap,
			   _polizas_nuevas,
			   _prima_cobrada with resume; 
end foreach
end
end procedure;
