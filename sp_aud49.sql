-- Procedure para auditoria interna - Archivo de Reclamo - Leyri Moreno
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud49;		

create procedure "informix".sp_aud49(a_periodo_hasta char(7)) 
returning integer, integer, varchar(100); 

define _fecha, _fecha_hoy			date;
define _transaccion		char(10);
define _cod_cliente		char(10);
define _monto			dec(16,2);
define _numrecla		char(20);
define _no_documento	char(20);
define _no_tranrec      char(10);

define _no_reclamo		char(10);
define _fecha_pagado    date;
define _no_unidad		char(5);
define _cod_asegurado	char(10);

define _user_added		  char(8);
define _vigencia_inic	  date;
define _vigencia_final	  date;
define _cod_evento        char(3);
define _causa             varchar(50);
define _fecha_siniestro	  date;
define _fecha_documento	  date;
define _pagado        	  smallint;
define _situacion         char(10);
define _cod_agente		  char(10);
define _no_poliza         char(10);

define _periodo           char(7);

define _ano                 integer;
define _mes                 smallint;
define _ramo				smallint;
define _tipo_sin            char(3);

define _cont_1            	integer;
define _cont_2            	integer;
define _cont_rea			smallint;
define _cont_rea_f			smallint;

define _tipo_contrato       smallint;
define _porc_partic_suma	dec(9,6);
define _orden				smallint;
define _tipo_cont_tt        char(1);
define _cod_coasegur        char(3);
define _porc_partic_reas	dec(9,6);
define _error_cod  			integer;
define _error_desc          varchar(50);
define _error_isam	        integer;
define _serie			    smallint;
define _ramo_sis			smallint;
define _cod_ramo			char(3);
define _cod_area_seguro		smallint;
define _cod_cober_reas		char(3);
define _cod_sucursal		char(3);
define _cod_tipotran	  	char(3);

set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_isam, trim(_error_desc) || " " || _transaccion;
end exception

--SET DEBUG FILE TO "sp_aud44.trc";
--trace on;

delete from deivid_ttcorp:movin_tecnico2;
delete from deivid_ttcorp:movim_reasegu2;

let _cont_1 = 0; 
let _cont_2 = 0; 
let _fecha_hoy = current;

foreach
 SELECT no_reclamo		
   INTO _no_reclamo	
   FROM rectrmae 
  WHERE periodo     <= a_periodo_hasta 
	AND actualizado  = 1
  GROUP BY no_reclamo
 HAVING SUM(variacion) > 0 

foreach 
	 select no_reclamo,
	        no_tranrec,
	        periodo,
	        fecha,
	        transaccion,
			cod_cliente,
	  		variacion,
			numrecla,
			pagado,
			fecha_pagado,
			user_added,
			cod_sucursal,
			cod_tipotran
	   into _no_reclamo,
	        _no_tranrec,
	        _periodo,
	        _fecha,
	        _transaccion,
			_cod_cliente,
	  		_monto,
			_numrecla,
			_pagado,
			_fecha_pagado,
			_user_added,
			_cod_sucursal,
			_cod_tipotran
	   from	rectrmae
	  where no_reclamo = _no_reclamo
	    and fecha >= '01/01/2012'
	    and actualizado   = 1
--		and cod_tipotran  = "004"
		and variacion        <> 0
	    and anular_nt     is null
	  order by fecha

--numrecla[1,2] in ('02','20')
--	    and 

	  if _periodo > a_periodo_hasta then  --a_periodo_hasta = periodo de corte
		continue foreach;
	  end if

	  let _tipo_sin = "PEN";

{      if _pagado = 0 then
		continue foreach;
--	  	let _tipo_sin = "PEN";
	  else
	  	let _tipo_sin = "PAG";
	  end if
}
      let _mes = _periodo[6,7];
      let _ano = _periodo[1,4];
	  let _ramo = _numrecla[1,2];
	  let _fecha_pagado = _fecha;


      select no_documento, 
             no_unidad, 
             fecha_siniestro, 
             fecha_documento, 
             cod_asegurado,
			 no_poliza,
			 cod_evento
	    into _no_documento, 
	         _no_unidad, 
	         _fecha_siniestro, 
	         _fecha_documento, 
	         _cod_asegurado,
			 _no_poliza,
			 _cod_evento
		from recrcmae
	   where no_reclamo = _no_reclamo;

      select vigencia_inic,
	         vigencia_final,
			 serie,
			 cod_ramo
	    into _vigencia_inic,
			 _vigencia_final,
			 _serie,
			 _cod_ramo
	    from emipomae
	   where no_poliza = _no_poliza;

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _ramo_sis = 1 then
		let _cod_area_seguro = 2; --Automovil
	elif _ramo_sis = 3 then
		let _cod_area_seguro = 7; --Fianza
	elif _ramo_sis = 5 then
		let _cod_area_seguro = 1; --Salud
	elif _ramo_sis in (6,7) then
		let _cod_area_seguro = 4; --Personas
	else
		let _cod_area_seguro = 9; --Patrimoniales
	end if


      if _vigencia_final is null then
		let _vigencia_final = _vigencia_inic + 1 units year;
      end if 

	  foreach
	   select cod_agente
	     into _cod_agente
		 from emipoagt
		where no_poliza = _no_poliza

	   exit foreach;
	  end foreach

	  
      select count(*)
	    into _cont_rea
		from rectrrea
	   where no_tranrec = _no_tranrec;

      if _cont_rea > 0 then


      foreach
	      select cod_cober_reas
		    into _cod_cober_reas
			from rectrrea
		   where no_tranrec = _no_tranrec
		  group by cod_cober_reas 

	  let _cont_1 = _cont_1 + 1;

	  insert into deivid_ttcorp:movin_tecnico2 (
		id_mov_tecnico,
		cod_empresa,
		num_ano,
		num_mes,
		num_serie,
		cod_area_seguro,
		cod_producto,
		cod_ramo,
		cod_ramorea,
		cod_moneda,
		por_tasa,
		tip_siniestro,
		id_poliza,
		id_recibo,
		id_siniestro,
		id_certificado,
		fec_ocurre,
		fec_notifica,
		fec_inivig,
		fec_finvig,
		cod_situacion,
		fec_situacion,
		fec_operacion,
		fec_registro,
		cod_usuario,
		mon_suma,
		mon_ajustado,
		mon_pagado,
		mon_reserva,
		id_relac_cliente,
		id_relac_productor,
		cod_causa,
		no_tranrec,
		cod_sucursal,
		cod_tipotran)
		values (
		_cont_1,
		11,
		_ano,
		_mes,
		_serie,
		_cod_area_seguro,
		_ramo,
		_ramo,
		_cod_cober_reas,
		"USD",
		1,
		_tipo_sin,
		_no_documento,
		_transaccion,
		_numrecla,
		_no_unidad,
		_fecha_siniestro,
		_fecha_documento,
		_vigencia_inic,
		_vigencia_final,
		1,
		_fecha_hoy,
		_fecha_pagado,
		_fecha,
		_user_added,
		0,
		0,
		0,
		_monto,
		_cod_asegurado,
		_cod_agente,
		_cod_evento,
		_no_tranrec,
		_cod_sucursal,
		_cod_tipotran);

      select count(*)
	    into _cont_rea
		from rectrrea
	   where no_tranrec = _no_tranrec;

      if _cont_rea > 0 then


	      foreach
		      select tipo_contrato,
		      		 porc_partic_suma,
					 orden
			    into _tipo_contrato,
					 _porc_partic_suma,
					 _orden
				from rectrrea
			   where no_tranrec = _no_tranrec
			     and cod_cober_reas = _cod_cober_reas 

	      	  if _tipo_contrato = 1 then	--Retencion
				let _tipo_cont_tt = "A";
			  elif _tipo_contrato = 2 then	--Fronting
				let _tipo_cont_tt = "Z";
			  elif _tipo_contrato = 3 then	--Facultativo
				let _tipo_cont_tt = "Z";
			  elif _tipo_contrato = 4 then	--Normal
				let _tipo_cont_tt = "F";
			  elif _tipo_contrato = 5 then	--Cuota Parte
				let _tipo_cont_tt = "B";
			  elif _tipo_contrato = 6 then	--Exceso de Perdida
				let _tipo_cont_tt = "M";
			  elif _tipo_contrato = 7 then	--Excedente
				let _tipo_cont_tt = "C";
			  end if

              if _tipo_contrato = 3 or _tipo_contrato = 2 then

			      select count(*)
				    into _cont_rea_f
					from rectrref
				   where no_tranrec = _no_tranrec;

			      if _cont_rea_f > 0 then

				    foreach
						select cod_coasegur,
						       porc_partic_reas
						  into _cod_coasegur,
							   _porc_partic_reas
						  from rectrref
						 where no_tranrec = _no_tranrec
						   and orden = _orden

			  			let _cont_2 = _cont_2 + 1; 

						  insert into deivid_ttcorp:movim_reasegu2 (
							id_mov_reas,
							tip_contrato,
							por_part_total,
							por_part_reaseg,
							id_mov_tecnico,
							fec_operacion,
							fec_registro,
							cod_usuario,
							id_relacionado,
							no_tranrec)
							values (
							_cont_2,
							_tipo_cont_tt,
							_porc_partic_suma,
							_porc_partic_reas,
							_cont_1,
							_fecha_pagado,
							_fecha,
							_user_added,
							_cod_coasegur,
							_no_tranrec
						    );

					end foreach
				 end if
			 else

		  		  let _cont_2 = _cont_2 + 1; 

				  insert into deivid_ttcorp:movim_reasegu2 (
					id_mov_reas,
					tip_contrato,
					por_part_total,
					por_part_reaseg,
					id_mov_tecnico,
					fec_operacion,
					fec_registro,
					cod_usuario,
					id_relacionado,
					no_tranrec)
					values (
					_cont_2,
					_tipo_cont_tt,
					_porc_partic_suma,
					_porc_partic_suma,
					_cont_1,
					_fecha_pagado,
					_fecha,
					_user_added,
					null,
					_no_tranrec
				    );

			 end if
		end foreach
	end if
	end foreach
	end if
	end foreach
    end foreach
   return 0, 0, "Exitoso";

end
end procedure

