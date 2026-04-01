-- Informes de Detalle de Produccion por Grupo
-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 22/10/2000 - Autor: Yinia M. Zamora.
-- Modificado: 05/09/2001 - Autor: Amado Perez -- Inclusion del campo subramo
--execute procedure sp_tarifas_salud_n('2018-01','2018-12')

drop procedure sp_ajuste_rectrrea;
create procedure "informix".sp_ajuste_rectrrea()
returning	integer		as error,
			integer		as error_isam,
			varchar(50)	as _errore_desc;

define v_filtros			char(255);
define _error_desc			varchar(50);
define _asegurado			varchar(50);
define _dependiente		varchar(50);
define _numrecla			char(20);
define _no_poliza			char(10);
define _no_reclamo		char(10);
define _no_tranrec		char(10);
define _no_tranrec_23		char(10);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas	char(3);
define _porc_partic_prima	char(3);
define _error_isam		integer;
define _error				integer;
define _tipo_contrato		integer;

begin
on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error,_error_isam,_error_desc;
end exception


set isolation to dirty read;
--set debug file to "sp_par310.trc"; 
--trace on;

foreach
	select trx.numrecla,
		    trx.no_reclamo,
			cam.no_poliza,
			cam.no_unidad,
			cam.no_endoso
	  into _numrecla,
		   _no_reclamo,
		   _no_poliza,
		   _no_unidad,
		   _no_tranrec
	  from camrea2 cam
	 inner join rectrmae trx on trx.no_tranrec = cam.no_endoso and trx.numrecla[6,7] <> '24'
	 where no_endoso not in ('2849853','2866375','2882104','2875198','2869716','2883107','2883432','2857411','2869723','2883084')

	foreach
		select rea.no_tranrec
		  into _no_tranrec_23
		  from rectrmae rea
		 where rea.no_reclamo = _no_reclamo
		   and rea.periodo <= '2023-12'
		   and rea.actualizado = 1
		 order by no_tranrec desc

		exit foreach;
	end foreach
	
	foreach
		select cod_cober_reas,
			   cod_contrato,
			   porc_partic_prima,
			   tipo_contrato
		  into _cod_cober_reas,
			   _cod_contrato,
			   _porc_partic_prima,
			   _tipo_contrato
		  from rectrrea rea
		 where rea.no_tranrec = _no_tranrec_23

		update rectrrea
		   set cod_contrato = _cod_contrato,
			    porc_partic_prima = _porc_partic_prima,
				porc_partic_suma =  _porc_partic_prima
		 where no_tranrec = _no_tranrec
		   and cod_cober_reas = _cod_cober_reas
		   and tipo_contrato = _tipo_contrato;
	end foreach
	
	return 0,0,'Actualizacion Exitosa. ' || trim(_no_tranrec) with resume;
end foreach
end
end procedure;