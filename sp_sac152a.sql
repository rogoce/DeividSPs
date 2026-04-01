-- Consulta de Movimientos de Cuentas Sac x Remesa
-- Creado    : 29/12/2008 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac152('121020402','COB12091','18/12/2009')

DROP PROCEDURE sp_sac152a;
CREATE PROCEDURE sp_sac152a(a_fecha date, a_fecha2 date)
RETURNING	smallint,
			char(15);

DEFINE i_cuenta			char(12);
DEFINE i_origen			char(12);
DEFINE i_comprobante	CHAR(15);
DEFINE i_fechatrx		DATE;
DEFINE i_notrx			INTEGER;
DEFINE i_debito			DEC(15,2);
DEFINE i_credito		DEC(15,2);
DEFINE i_neto           DEC(15,2);

DEFINE d_remesa			CHAR(10);
DEFINE d_debito			DEC(15,2);
DEFINE d_credito		DEC(15,2);
DEFINE a_comp           CHAR(15);

SET ISOLATION TO DIRTY READ;

--  set debug file to "sp_sac152a.trc";	
--  trace on;

delete from deivid_ttcorp:tmpcobasien;

select *
  from deivid_ttcorp:tmpcobasien
 where 1=2
  into temp prueba;

FOREACH
	select res_comprobante
	  into a_comp
	  from cglresumen
	 where res_fechatrx >= a_fecha
	   and res_fechatrx <= a_fecha2
	   and res_tipcomp <> '016'
	   and res_origen = 'COB'
	   group by res_comprobante
	   order by res_comprobante

    insert into prueba
	select c.*,t.no_recibo,'0'
	  from cobasien c, cglresumen r, cobredet t
	 where c.sac_notrx       = r.res_notrx
	   and c.cuenta          = r.res_cuenta
	   and c.no_remesa       = t.no_remesa
	   and c.renglon         = t.renglon
	   and r.res_comprobante = a_comp
	   and r.res_origen      = 'COB'
	 order by c.no_remesa,c.renglon;

END FOREACH

insert into deivid_ttcorp:tmpcobasien
select * from prueba;

DROP TABLE prueba;

return 0,  "Exitoso";

END PROCEDURE					 