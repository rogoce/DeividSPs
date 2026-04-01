----------------------------------------------------------
--Reporte de Garantia de Pagos de Pólizas Facultativas
--Creado : 08/03/2016 - Autor: Román Gordón
--ref. deivid: d_prod_sp_pro383_dw1
--SIS v.2.0 - DEIVID, S.A.
----------------------------------------------------------
drop procedure sp_pro383a;
create procedure sp_pro383a(a_reasegurador char(255) default '%;', a_periodo char(7), a_periodo2 char(7))
returning	char(20)		as Poliza,
			varchar(100)	as Cliente,
			date			as Vigencia_Incic,
			date			as Vigencia_Final,
			varchar(50)		as Cobertura_Reaseguro,
			char(10)		as No_Remesa,
			dec(16,2)		as Monto_Remesa,
			varchar(100)	as Descr_Remesa,
			date			as Fecha_Remesa,
			date			as Fecha_Transf_Remesa,
			date			as Fecha_pago,
			varchar(100)	as filtros,
			varchar(50)     as nombre,
			date            as Fecha_pag_rem,
			char(10)        as Factura;

define _error_desc			varchar(255);
define v_filtros			varchar(255);
define _nom_contratante		varchar(100);
define _descr_remesa		varchar(100);
define _nom_cober_reas		varchar(50);
define _suma_asegurada		dec(16,2);
define _monto_remesa		dec(16,2);
define _prima				dec(16,2);
define _porc_partic_reas	dec(9,6);
define _porc_comis_fac		dec(9,6);
define _porc_impuesto		dec(5,2);
define _no_chasis			char(30);
define _no_motor			char(30);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _no_remesa			char(10);
define _no_cesion			char(10);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _cod_modelo			char(5);
define _cod_marca			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur		char(3);
define _cod_impuesto		char(3);
define _cod_tipoveh			char(3);
define _cod_descuen			char(3);
define _cod_subramo			char(3);
define _cod_perfac			char(3);
define _cod_color			char(3);
define _cod_ramo			char(3);
define _uso_auto			char(1);
define _tipo				char(1);
define _null				char(1);
define _cant_garantia_pago	smallint;
define _dia_garantia		smallint;
define _iteracion			smallint;
define _no_cambio			smallint;
define _no_pago				smallint;
define _impreso				smallint;
define _orden				smallint;
define _cont				smallint;
define _ano					smallint;
define _mes					smallint;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _fecha_transf_remesa	date;
define _fecha_primer_pago	date;
define _fecha_impresion		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_remesa		date;
define _fecha_desde			date;
define _fecha_hasta			date;
define _fecha_pago,_fecha_pag_gar date;
define _nombre_cod_coasegur  varchar(50);
define _no_factura          char(10);
define _no_endoso           char(5);

--set debug file to "sp_pro383.trc";
--trace on;

drop table if exists tmp_emicoase;

select cod_coasegur
  from emicoase
  into temp tmp_emicoase;
  
drop table if exists tmp_codigos;
drop table if exists tmp_fecha_pago;

create temp table tmp_fecha_pago(
no_pago		smallint,
fecha_pago	date
) with no log;
--,primary key (no_pago,fecha_pago)) with no log;
  
let v_filtros = "";
let _cod_contrato = "";

if a_reasegurador <> '*' then
	let v_filtros = TRIM(v_filtros) ||" Reasegurador "||TRIM(a_reasegurador);
	let _tipo = sp_sis04(a_reasegurador); -- separa los valores del string   
	if _tipo = "E" then -- excluir los registros 
		delete from tmp_emicoase
		 where cod_coasegur in (select codigo from tmp_codigos);
	else
		delete from tmp_emicoase
		 where cod_coasegur not in(select codigo from tmp_codigos);
	end if
end if

let _ano = a_periodo[1,4];
let _mes = a_periodo[6,7];
let _nombre_cod_coasegur = "";

let _fecha_desde = mdy(_mes,1,_ano);
let _fecha_hasta = sp_sis36(a_periodo2);

{foreach
	select f.no_poliza,
		   f.no_unidad,
		   f.cod_cober_reas,
		   f.cod_contrato,
		   f.cod_coasegur,
		   f.porc_partic_reas,
		   f.porc_comis_fac,
		   f.porc_impuesto,
		   f.fecha_impresion,
		   f.no_cesion,
		   e.cod_contratante,
		   e.vigencia_inic,
		   e.vigencia_final,
		   e.no_documento,
		   e.cod_ramo,
		   sum(f.suma_asegurada),
		   sum(f.prima),
		   sum(f.monto_comision),
		   sum(f.monto_impuesto)
	  into _no_poliza,
		   _no_unidad,
		   _cod_cober_reas,
		   _cod_contrato,
		   _cod_coasegur,
		   _porc_partic_reas,
		   _porc_comis_fac,
		   _porc_impuesto,
		   _fecha_impresion,
		   _no_cesion,
		   _suma_asegurada,
		   _prima,
		   _monto_comision,
		   _monto_impuesto
	  from emifafac f, emipomae e
	 where f.no_poliza = e.no_poliza
	   and (vigencia_inic + dia garantia units day) between _fecha_desde and _fecha_hasta
	   and f.cod_coasegur in (select cod_coasegur from tmp_emicoase)
	 group by f.no_poliza,f.no_unidad,f.cod_cober_reas,f.cod_contrato,f.cod_coasegur,f.porc_partic_reas,f.porc_comis_fac,f.porc_impuesto,f.fecha_impresion,f.no_cesion,e.cod_contratante,e.vigencia_inic,e.vigencia_final,e.no_documento,e.cod_ramo}
	 
foreach	
	select no_poliza,
		   no_unidad,
		   cod_cober_reas,
		   cod_coasegur,
		   cod_contrato,
		   max(no_cambio)
	  into _no_poliza,
		   _no_unidad,
		   _cod_cober_reas,
		   _cod_coasegur,
		   _cod_contrato,
		   _no_cambio
	  from emireafa
	 where cod_coasegur in (select cod_coasegur from tmp_emicoase)
	 group by no_poliza,no_unidad,cod_cober_reas,cod_coasegur,cod_contrato
	 order by 1,2,3

	foreach
		select orden,
			   porc_partic_reas,			   
			   porc_comis_fac,  
			   porc_impuesto
		  into _orden,
			   _porc_partic_reas,
			   _porc_comis_fac,
			   _porc_impuesto
		  from emireafa
		 where no_poliza		= _no_poliza
		   and no_unidad		= _no_unidad
		   and no_cambio		= _no_cambio
		   and cod_cober_reas	= _cod_cober_reas
		   and cod_coasegur     = _cod_coasegur
		   and cod_contrato		= _cod_contrato

		foreach
			select impreso,
				   fecha_impresion,
				   no_cesion,
				   cant_garantia_pago,
				   cod_perfac,
				   fecha_primer_pago,
				   no_endoso
			  into _impreso,
				   _fecha_impresion,
				   _no_cesion,
				   _cant_garantia_pago,
				   _cod_perfac,
				   _fecha_primer_pago,
				   _no_endoso
			  from emifafac
			 where no_poliza		= _no_poliza
			   and no_unidad		= _no_unidad
			   and cod_cober_reas	= _cod_cober_reas
			   and orden			= _orden
			   and cod_contrato		= _cod_contrato
			   and cod_coasegur		= _cod_coasegur
			   and cant_garantia_pago is not null

			if _cant_garantia_pago is null then
				let _cant_garantia_pago = 0;
			end if
			
			if _cant_garantia_pago < 1 then
				continue foreach;
			end if

			select sum(a.suma_asegurada),
				   sum(a.prima)
			  into _suma_asegurada,
				   _prima
			  from emifafac a, endedmae	b
			 where a.no_poliza      = b.no_poliza
			   and a.no_endoso      = b.no_endoso
			   and b.actualizado    = 1
			   and a.no_poliza		= _no_poliza
			   and a.no_unidad		= _no_unidad
			   and a.cod_cober_reas	= _cod_cober_reas
			   and a.cod_contrato	= _cod_contrato
			   and a.cod_coasegur	= _cod_coasegur;

			select no_documento,
				   cod_contratante,
				   vigencia_inic,
				   vigencia_final
			  into _no_documento,
				   _cod_contratante,
				   _vigencia_inic,
				   _vigencia_final
			  from emipomae
			 where no_poliza = _no_poliza;
			 
			select no_factura
			  into _no_factura
			  from endedmae
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;

			select dias
			  into _dia_garantia
			  from reaperfac
			 where cod_perfac = _cod_perfac;

			let _cont = 1;

			if _cant_garantia_pago > 1 then
				insert into tmp_fecha_pago(
						no_pago,
						fecha_pago)
				values(	_cont,
						_fecha_primer_pago);

				let _cont = 2;
			end if

			for _iteracion = _cont to _cant_garantia_pago
				let _fecha_pago = _fecha_primer_pago + _dia_garantia units day;
				
				insert into tmp_fecha_pago(
						no_pago,
						fecha_pago)
				values(	_iteracion,
						_fecha_pago);

				let _fecha_primer_pago = _fecha_pago; 
			end for
			foreach
				select no_pago,
					   fecha_pago
				  into _no_pago,
					   _fecha_pago
				  from tmp_fecha_pago

				if _fecha_pago between _fecha_desde and _fecha_hasta then
					select nombre
					  into _nom_contratante
					  from cliclien
					 where cod_cliente = _cod_contratante;

					select nombre
					  into _nom_cober_reas
					  from reacobre
					 where cod_cober_reas = _cod_cober_reas;
					 
					let _no_remesa = null;
					
					select nombre 
					  into _nombre_cod_coasegur
					  from emicoase
					 where cod_coasegur = _cod_coasegur;
					 
					foreach 
						select d.no_remesa,
							   m.monto,
							   m.descrip,
							   m.fecha,
							   m.fecha_transf,
							   m.fecha_pag_gar
						  into _no_remesa,
							   _monto_remesa,
							   _descr_remesa,
							   _fecha_remesa,
							   _fecha_transf_remesa,
							   _fecha_pag_gar
						  from reatrx1 m, reatrx3 d
						 where m.no_remesa = d.no_remesa
						   and d.no_poliza = _no_poliza
						   and d.no_factura = _no_factura
						   and m.cod_coasegur = _cod_coasegur
						   and m.anular_remesa is null
						   and m.fecha_pag_gar between _fecha_desde and _fecha_hasta				 

					   return	_no_documento,			--1
								_nom_contratante,		--2
								_vigencia_inic,			--3
								_vigencia_final,		--4
								_nom_cober_reas,		--5
								_no_remesa,				--6
								_monto_remesa,			--7
								_descr_remesa,			--8
								_fecha_remesa,			--9
								_fecha_transf_remesa,	--10
								_fecha_pago,            --11
								v_filtros,              --12
								_nombre_cod_coasegur,    --13
								_fecha_pag_gar,
								_no_factura
						with resume;
					end foreach
					if _no_remesa is null then
						return	_no_documento,			--1
								_nom_contratante,		--2
								_vigencia_inic,			--3
								_vigencia_final,		--4
								_nom_cober_reas,		--5
								"",				--6
								0,			--7
								"",			--8
								null,			--9
								null,	--10
								_fecha_pago,            --11
								v_filtros,              --12
								_nombre_cod_coasegur,    --13
								null,
								_no_factura
						with resume;
					end if
				end if
			end foreach
			delete from tmp_fecha_pago;
		end foreach
	end foreach
	--delete from tmp_fecha_pago;
end foreach
end procedure;