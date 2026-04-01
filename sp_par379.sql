-- Reversar el cambio de corredores

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par379;

create procedure "informix".sp_par379()
returning integer,
          char(50);

define _nom_agente	varchar(50);
define _no_documento	char(20);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _cod_agente	char(5);
define _cod_ramo		char(3);
define _prima_neta	dec(16,2);
define _monto			dec(16,2);
define _porc_comis_agt	dec(5,2);
define _renglon		integer;
define _fecha_cob		date;

foreach
	select cor.cod_agente,
			cor.nombre,
			ram.cod_ramo,
			emi.no_documento,
			cob.fecha,
			cob.no_remesa,
			cob.renglon,
			cob.no_poliza,
			cob.prima_neta,
			cob.monto
	   into _cod_agente,
			_nom_agente,
			_cod_ramo,
			_no_documento,
			_fecha_cob,
			_no_remesa,
			_renglon,
			_no_poliza,
			_prima_neta,
			_monto
  from emipomae emi
  inner join cligrupo grp on grp.cod_grupo = emi.cod_grupo
 inner join emipoagt agt on agt.no_poliza = emi.no_poliza
 inner join agtagent cor on cor.cod_agente = agt.cod_agente
 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
 inner join cobredet cob on cob.no_poliza = emi.no_poliza and cob.actualizado = 1
 inner join cobreagt mae on mae.no_remesa = cob.no_remesa and mae.renglon = cob.renglon and agt.porc_comis_agt = 0
  left join chqcomis com on com.no_poliza = cob.no_poliza and com.fecha = cob.fecha and com.no_recibo = cob.no_recibo --and com.monto = cob.monto
 where emi.cod_grupo in ('00068','77978','77973','77979','77974','77980')
   and emi.vigencia_inic >= '01/07/2022'
   and emi.actualizado = 1
   and cob.fecha >= '10/01/2023'
   and cob.tipo_mov in ('P','N')
   and com.no_poliza is null
 order by fecha

	if _cod_ramo = '002' then
		let _porc_comis_agt = 20;
	else
		let _porc_comis_agt = 15;
	end if

	update cobreagt
	   set porc_comis_agt = _porc_comis_agt
	 where no_remesa  = _no_remesa
	   and renglon    = _renglon
	   and cod_agente = _cod_agente;
	
	update emipoagt
	   set porc_comis_agt = _porc_comis_agt
	 where no_poliza  = _no_poliza
	   and cod_agente = _cod_agente;
	   
end foreach

return 0, "Actualizacion Exitosa";

end procedure
