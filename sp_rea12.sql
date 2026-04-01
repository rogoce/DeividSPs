--------------------------------------------
--Detalle de Distribución de reaseguro de suma asegurada
--execute procedure sp_rea35()
--22/07/2016 - Autor: Román Gordón.
--------------------------------------------
--drop procedure sp_rea12;

create procedure sp_rea12(a_no_poliza char(10))
returning	char(20)		as Poliza,
			varchar(100)	as Contratante,
			date			as Vigencia_Inic,
			date			as Vigencia_Final,
			varchar(30)		as Ramo,
			varchar(30)		as SubRamo,			
			char(5)			as Unidad,
			dec(16,2)		as Suma_Asegurada,
			varchar(50)		as Cober_Reas,
			char(5)			as Cod_contrato,
			varchar(50)		as Contrato,
			smallint		as Serie_contrato,
			dec(16,2)		as Suma_Aseg_Ret,
			dec(9,6)		as Porc_partic_Retencion,
			dec(9,6)		as Porc_partic_Cesion,
			varchar(100)	as Mensaje;

define _error_desc			varchar(100);
define _nom_contratante		varchar(100);
define _nom_cober_reas		varchar(50);
define _nom_contrato		varchar(50);
define _nom_subramo			varchar(50);
define _nom_ramo			varchar(50);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _suma_asegurada		dec(16,2);
define _suma_retencion		dec(16,2);
define _max_suma_aseg		dec(16,2);
define _porc_partic_prima	dec(9,6);
define _porc_dist_cont		dec(9,6);
define _porc_dist_ret		dec(9,6);
define _estatus_poliza		smallint;
define _serie_contrato		smallint;
define _tipo_contrato		smallint;
define _no_cambio			smallint;
define _error_isam			integer;
define _notrx				integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;

--set debug file to 'sp_rea27.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return	'','',null,null,'','','',0.00,'','','',_error,0.00,0.00,0.00,_error_desc;
end exception  

set isolation to dirty read;

let _max_suma_aseg = 500000;

drop table if exists tmp_dist_rea;
create temp table tmp_dist_rea(
no_poliza		char(10),
no_unidad		char(5),
cod_cober_reas	char(3),
cod_contrato	char(5),
suma_retencion	dec(16,2),
porc_dist_ret	dec(9,6),
porc_dist_cont	dec(9,6)) with no log;


--foreach
--	select no_documento
	  --into _no_documento
	  --from emipoliza
	 --where no_documento = a_no_documento --''cod_ramo in ('004','019')

	let _no_poliza = a_no_poliza; --sp_sis21(_no_documento);

	select cod_ramo,
		   cod_subramo,
		   cod_contratante,
		   estatus_poliza,
		   vigencia_inic,
		   vigencia_final,
		   no_documento
	  into _cod_ramo,
		   _cod_subramo,
		   _cod_contratante,
		   _estatus_poliza,
		   _vigencia_inic,
		   _vigencia_final,
		   _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	{if _estatus_poliza <> 1 then
		continue foreach;
	end if}

	select nombre
	  into _nom_subramo
	  from prdsubra
	 where cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nom_contratante
	  from cliclien
	 where cod_cliente = _cod_contratante;

	foreach
		select no_unidad,
			   suma_asegurada
		  into _no_unidad,
			   _suma_asegurada
		  from emipouni
		 where no_poliza = _no_poliza

		{if _suma_asegurada <= _max_suma_aseg then
			continue foreach;
		end if}

		let _no_cambio = null;

		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _no_cambio is null then
			return	_no_documento,
					_nom_contratante,
					_vigencia_inic,
					_vigencia_final,
					_nom_ramo,
					_nom_subramo,
					_no_unidad,
					_suma_asegurada,
					_nom_cober_reas,
					_cod_contrato,
					_nom_contrato,
					_serie_contrato,
					0.00,
					0.00,
					0.00,
					'' with resume;
			--continue foreach;
		end if

		delete from tmp_dist_rea;
		foreach
			select r.cod_contrato,
				   r.porc_partic_prima,
				   r.cod_cober_reas,
				   c.tipo_contrato
			  into _cod_contrato,
				   _porc_partic_prima,
				   _cod_cober_reas,
				   _tipo_contrato
			  from emireaco r, reacomae c
			 where r.cod_contrato = c.cod_contrato
			   and no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and no_cambio = _no_cambio

			let _porc_dist_cont = 0.00;
			let _suma_retencion = 0.00;
			let _porc_dist_ret = 0.00;

			if _tipo_contrato = 1 then
				let _suma_retencion = _suma_asegurada * (_porc_partic_prima/100);
				let _porc_dist_ret = _porc_partic_prima;
			else
				let _porc_dist_cont = _porc_partic_prima;
				let _cod_contrato = '';
			end if

			insert into tmp_dist_rea(
					no_poliza,
					no_unidad,
					cod_cober_reas,
					cod_contrato,
					suma_retencion,
					porc_dist_ret,
					porc_dist_cont)
			values(	_no_poliza,
					_no_unidad,
					_cod_cober_reas,
					_cod_contrato,
					_suma_retencion,
					_porc_dist_ret,
					_porc_dist_cont);
		end foreach

		let _porc_dist_cont = 0.00;
		let _suma_retencion = 0.00;
		let _porc_dist_ret = 0.00;
		foreach
			select no_poliza,
				   no_unidad,
				   cod_cober_reas,
				   sum(suma_retencion),
				   sum(porc_dist_ret),
				   sum(porc_dist_cont)
			  into _no_poliza,
				   _no_unidad,
				   _cod_cober_reas,
				   _suma_retencion,
				   _porc_dist_ret,
				   _porc_dist_cont
			  from tmp_dist_rea
			 group by 1,2,3

			foreach
				select cod_contrato
				  into _cod_contrato
				  from tmp_dist_rea
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and cod_cober_reas = _cod_cober_reas
				   and cod_contrato <> ''
				exit foreach;
			end foreach

			select nombre
			  into _nom_cober_reas
			  from reacobre
			 where cod_cober_reas = _cod_cober_reas;

			select nombre,
				   serie
			  into _nom_contrato,
				   _serie_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;

			return	_no_documento,
					_nom_contratante,
					_vigencia_inic,
					_vigencia_final,
					_nom_ramo,
					_nom_subramo,
					_no_unidad,
					_suma_asegurada,
					_nom_cober_reas,
					_cod_contrato,
					_nom_contrato,
					_serie_contrato,
					_suma_retencion,
					_porc_dist_ret,
					_porc_dist_cont,
					'' with resume;
		end foreach
	end foreach
--end foreach

end
end procedure;
