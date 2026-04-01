-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 18/11/2021 - Autor: Amado Perez 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_reainv12;		
create procedure sp_reainv12()
returning integer,char(100);
		  	
define _no_registro	char(10);
define _contador		smallint;
define _tipo_registro	smallint;
define _sac_notrx       integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


--set debug file to "sp_sac161cam.trc";
--trace on;

--return 1, "Inicio " || current with resume;

let _contador = 0;

-- produccion y cobros

let _sac_notrx = null;

foreach with hold
{	select distinct r.no_registro,
	       r.tipo_registro,
		   s.sac_notrx
	  into _no_registro,
	       _tipo_registro,
	       _sac_notrx
	  from sac999:reacomp r, sac999:reacompasie s, camrea c
	 where r.no_poliza    = c.no_poliza
	   and s.no_registro  = r.no_registro
	   and r.tipo_registro in (1,2,3)
	   and r.periodo >= '2022-11'
	   and r.periodo <= '2022-11'
	   and c.actualizado = 1
	   and s.sac_notrx is not null
	 order by r.no_registro}
{select distinct r.sac_notrx 
  into _sac_notrx
  from sac999:reacompasiau e, sac999:reacompasie r, sac999:reacomp p, camrea c
 where e.no_registro = r.no_registro
   and r.no_registro = p.no_registro
   and c.no_poliza = p.no_poliza
   and e.cuenta = r.cuenta
   and r.periodo = '2022-11'
   and e.cod_auxiliar = 'BQ147'	 }
   
 --cambio solicitado segun correo de Cesia 11/07/2023
{	 select distinct r.sac_notrx
	   into _sac_notrx
	   from sac999:reacompasiau e, sac999:reacompasie r, sac999:reacomp p, camrea c
	  where e.no_registro = r.no_registro
		and r.no_registro = p.no_registro
		and c.no_poliza = p.no_poliza
		and e.cuenta = r.cuenta
		and r.periodo = '2024-05'  
		and p.tipo_registro in (1,2)
		and r.sac_notrx is not null
}
   -- Cambio los que no están en camrea
	/*select distinct sac_notrx
	  into _sac_notrx
	  from sac999:reacompasie det
	inner join sac999:reacomp mae on mae.no_registro = det.no_registro
	where det.periodo = '2024-04'
	   and mae.no_documento[1,2] in ('02','20','23')
	   and tipo_registro in (1,2)
	   and sac_asientos = 2
	  */
	/*
	select distinct sac_notrx
	  into _sac_notrx
  from recasien
 where no_tranrec in (select distinct rea.no_tranrec
  from recrcmae rec
inner join emipomae emi on rec.no_poliza = emi.no_poliza
inner join rectrmae trx on trx.no_reclamo = rec.no_reclamo
inner join rectrrea rea on rea.no_tranrec = trx.no_tranrec
where emi.cod_ramo in ('002','020','023')
   and trx.periodo = '2024-04'
   and trx.actualizado = 1
   and rea.tipo_contrato = 1
--   and rea.cod_contrato = '00761'
    and rea.cod_contrato not in ('00765','00766')
union all

select distinct rea.no_tranrec
  from recrcmae rec
inner join emipomae emi on rec.no_poliza = emi.no_poliza
inner join rectrmae trx on trx.no_reclamo = rec.no_reclamo
inner join rectrrea rea on rea.no_tranrec = trx.no_tranrec
where emi.cod_ramo in ('002','020','023')
   and trx.periodo = '2024-04'
   and trx.actualizado = 1
   and rea.tipo_contrato = 5
--   and rea.cod_contrato = '00761'
    and rea.cod_contrato not in ('00767','00763'))*/
/*	
	select distinct det.sac_notrx
	  into _sac_notrx
  from sac999:reacomp mae
 inner join sac999:reacompasie det on det.no_registro = mae.no_registro
 where no_tranrec in (select distinct rea.no_tranrec
  from recrcmae rec
inner join emipomae emi on rec.no_poliza = emi.no_poliza
inner join rectrmae trx on trx.no_reclamo = rec.no_reclamo
inner join rectrrea rea on rea.no_tranrec = trx.no_tranrec
where emi.cod_ramo in ('002','020','023')
   and trx.periodo = '2024-04'
   and trx.actualizado = 1
   and rea.tipo_contrato = 1
--   and rea.cod_contrato = '00761'
    and rea.cod_contrato not in ('00765','00766')
union all

select distinct rea.no_tranrec
  from recrcmae rec
inner join emipomae emi on rec.no_poliza = emi.no_poliza
inner join rectrmae trx on trx.no_reclamo = rec.no_reclamo
inner join rectrrea rea on rea.no_tranrec = trx.no_tranrec
where emi.cod_ramo in ('002','020','023')
   and trx.periodo = '2024-04'
   and trx.actualizado = 1
   and rea.tipo_contrato = 5
--   and rea.cod_contrato = '00761'
    and rea.cod_contrato not in ('00767','00763'))
	*/
	
	/*select distinct sac_notrx
	  into _sac_notrx
  from sac999:reacompasie
 where sac_notrx is not null
   and no_registro in (
select mae.no_registro
  from emipomae emi
 inner join cobredet fac on fac.no_poliza = emi.no_poliza
 inner join cobreaco rea on rea.no_remesa  = fac.no_remesa and rea.renglon = fac.renglon
 inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato = 1
 inner join sac999:reacomp mae on mae.no_remesa = fac.no_remesa and mae.renglon = fac.renglon
 where emi.cod_ramo in ('002','020','023')
   and fac.periodo = '2024-04'
   and fac.actualizado = 1
   and rea.porc_partic_prima <> 5
union all

select mae.no_registro
  from emipomae emi
 inner join cobredet fac on fac.no_poliza = emi.no_poliza
 inner join cobreaco rea on rea.no_remesa  = fac.no_remesa and rea.renglon = fac.renglon
 inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato = 5
 inner join sac999:reacomp mae on mae.no_remesa = fac.no_remesa and mae.renglon = fac.renglon
 where emi.cod_ramo in ('002','020','023')
   and fac.periodo = '2024-04'
   and fac.actualizado = 1
   and rea.porc_partic_prima <> 95     )*/
   
/*   select distinct mae.sac_notrx
    into _sac_notrx
  from sac999:reacomp rea
 inner join deivid_tmp:det_reas_auto2024 det on det.no_poliza = rea.no_poliza and det.no_endoso = rea.no_endoso
 inner join sac999:reacompasie mae on mae.no_registro = rea.no_registro */
 
 /* select distinct mae.sac_notrx
  into _sac_notrx
  from sac999:reacomp rea
 inner join deivid_tmp:query_roman det on det.no_poliza = rea.no_poliza and det.no_endoso = rea.no_endoso
 inner join sac999:reacompasie mae on mae.no_registro = rea.no_registro
 where sac_notrx is not null */
 
select distinct det.sac_notrx
  into _sac_notrx
  from sac999:reacomp mae
inner join sac999:reacompasie det on det.no_registro = mae.no_registro
inner join sac999:reacompasiau aux on aux.no_registro = det.no_registro and aux.cuenta = det.cuenta
where mae.periodo = '2024-05'
   and det.cuenta = '231020203'
   and tipo_registro in (3)
   and aux.cod_auxiliar = '03203'
	
	if _sac_notrx is not null then
		call sp_sac77a(_sac_notrx) returning _error, _error_desc;
	end if
	
	let _sac_notrx = null;

end foreach
end 
let _error  = 0;
let _error_desc = "Proceso Completado ...";	
return _error, _error_desc;
end procedure;
