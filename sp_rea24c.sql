-- Procedimiento que carga los Saldos de las polizas por reaseguro
-- 25/11/2009 - Autor: Amado Perez.
-- 15/10/2010 - Modificado - Autor: Henry: Cambio del sp_sis21 a utilizar poliza a la fecha, por orden de Sr. Naranjo 
-- 10/04/2011 - Modificado - Autor: Henry: Arlena Gomez , tomar la parte de terremoto no se estaba calculando.
-- execute procedure sp_rea24b('001','001','2016-01','2016-01')

drop procedure sp_rea24c;
create procedure 'informix'.sp_rea24c(a_compania char(3), a_sucursal char(3), a_periodo char(7), a_periodo2 char(7))
returning	integer,                  --1
			varchar(100);              --2

define _nombre_contratante	varchar(100);
define _nombre_reas			varchar(50);
define _error_desc			varchar(50);
define _descr_cia			varchar(50);
define _nombre				varchar(50);
define _doc_poliza			char(20);
define _cod_contratante		char(10);
define _no_poliza_ant		char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_tipoprod1		char(3);
define _cod_tipoprod2		char(3);
define _cod_coasegur		char(3);
define _cod_tipoprod		char(3);
define _cod_ramo			char(3);
define _porc_comision1		dec(5,2);
define _porc_comision2		dec(5,2);
define _porc_imp_ant		dec(5,2);
define _porc_imp_act		dec(5,2);
define _porc_impuesto		dec(5,2);
define _porc_especial		dec(5,2);
define _porc_com_reas		dec(5,2);
define _porc_com_ant		dec(5,2);
define _porc_com_act		dec(5,2);
define _porc_comision		dec(5,2);
define _porc_partic_coas	dec(7,4);
define _porc_reas_ant		dec(9,6);
define _porc_reas_act		dec(9,6);
define _porc_partic_prima	dec(9,6);
define _porc_coasegur_ant	dec(9,6);
define _porc_coasegur_act	dec(9,6);
define _porc_uni_ant		dec(9,6);
define _porc_uni_act		dec(9,6);
define _porc_partic_suma	dec(9,6);
define _porc_cont_partic	dec(9,6);
define _porc_partic_reas	dec(9,6);
define _saldo_contrato		dec(16,2);
define _saldo_reaseg		dec(16,2);
define _prima_bruta			dec(16,2);
define _saldo_ant			dec(16,2);
define _saldo_act			dec(16,2);
define _porc_ter          	dec(16,2);
define _porc_inc          	dec(16,2);
define _comision			dec(16,2);
define v_saldo_b			dec(16,2);
define _imp_ant				dec(16,2);
define _imp_act				dec(16,2);
define _impuesto			dec(16,2);
define _com_ant				dec(16,2);
define _com_act				dec(16,2);
define _com_reas			dec(16,2);
define _imp_reas			dec(16,2);
define v_saldo				dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _exigible			dec(16,2);
define _es_terremoto		integer;
define _error_isam			integer;
define _error				integer;
define _no_cambio_orig		smallint;
define _ult_no_cambio		smallint;
define _tipo_contrato		smallint;
define _cnt_no_unidad		smallint;
define _cantidad_uni		smallint;
define _cnt_existe			smallint;
define _cnt_verif			smallint;
define _no_cambio			smallint;
define _tiene_com			smallint;
define _continuar			smallint;
define _cantidad			smallint;
define _cnt_terr			smallint;
define _bouquet				smallint;
define _mes					smallint;
define _ano					smallint;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha				date;

set isolation to dirty read;

--set debug file to 'sp_rea24b.trc';
--trace on ;

begin
on exception set _error, _error_isam, _error_desc
	drop table if exists tmp_emireaco;
	begin
		on exception in(-255)
		end exception
		rollback work;
	end 
	return _error, _doc_poliza || trim(_error_desc);
end exception

drop table if exists tmp_emireaco;
drop table if exists tmp_poliza;

create temp table tmp_poliza(
no_poliza	char(10)  not null,
saldo		dec(16,2)) with no log;

let _descr_cia = sp_sis01(a_compania);

select cod_tipoprod
  into _cod_tipoprod1
  from emitipro
 where tipo_produccion = 1;	-- sin coaseguro

select cod_tipoprod
  into _cod_tipoprod2
  from emitipro
 where tipo_produccion = 2;	-- coaseguro mayoritario

let _ano = a_periodo[1,4];
let _mes = a_periodo[6,7];
let _fecha = sp_sis36(a_periodo);

foreach with hold
	select no_documento
	  into _doc_poliza
	  from emipoliza
	 --where cod_ramo = '016'
	 --where no_documento in ('1614-00073-01')

	begin work;
	
	if _doc_poliza = '1614-00073-01' then
		commit work;
		continue foreach;
	end if

	let _no_poliza = '';

	call sp_sis21(_doc_poliza)returning _no_poliza;

	if _no_poliza is null or _no_poliza = '' then
		commit work;
		continue foreach;
	end if

	let _cnt_verif = 0;

	select count(*)
	  into _cnt_verif
	  from rea_saldo2
	 where no_documento = _doc_poliza
	   and periodo = a_periodo;

	if _cnt_verif is null then
		let _cnt_verif = 0;
	end if
	
	if _cnt_verif > 0 then
		commit work;
		continue foreach;
	end if
	
	--call sp_cob223(	a_compania,	a_sucursal,	_doc_poliza,a_periodo,_fecha) returning	v_saldo, v_saldo_b;
	call sp_cob33(a_compania,a_sucursal,_doc_poliza,a_periodo,_fecha)
	returning   _por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				v_saldo_b;

    if v_saldo_b = 0 then
		commit work;
		continue foreach;
	end if

    {if v_saldo = 0 then
		commit work;
		continue foreach;
	end if}

	insert into tmp_poliza
	values(	_no_poliza,
			v_saldo_b);

	let _prima_bruta = 0.00;

	select sum(prima_bruta)
	  into _prima_bruta
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_documento = _doc_poliza	-- facturas de la poliza
	   and actualizado = 1			    -- factura este actualizada
	   and periodo <= a_periodo	    -- no incluye periodos futuros
	   and activa = 1;

	let _no_poliza_ant = null;

	if v_saldo_b > _prima_bruta  then
		let _no_poliza_ant = sp_sis21a(_doc_poliza,_no_poliza);
		
		if _no_poliza_ant is null then
			let _no_poliza_ant = '';
		end if
		
		if _no_poliza_ant <> '' then
			let v_saldo_b = v_saldo_b - _prima_bruta;

			insert into tmp_poliza
			values(	_no_poliza_ant,
					v_saldo_b);

			update tmp_poliza
			   set saldo = _prima_bruta
			 where no_poliza = _no_poliza;
		end if
	end if

	let v_saldo_b = 0;
	let _no_poliza = '';

	foreach
		select no_poliza,
			   saldo
		  into _no_poliza,
			   v_saldo_b
		  from tmp_poliza

		select sum(i.factor_impuesto)
		  into _porc_impuesto
		  from emipolim p, prdimpue i
		 where p.cod_impuesto = i.cod_impuesto
		   and p.no_poliza    = _no_poliza;  

		if _porc_impuesto is null then
			let _porc_impuesto = 0.00;
		end if

		let v_saldo = v_saldo_b  / (1 + (_porc_impuesto / 100));  --convertir a prima neta, por la inclusion del impuesto en los registros de polizas.

		select cod_tipoprod,
			   cod_ramo,
			   cod_contratante,
			   vigencia_inic,
			   vigencia_final
		  into _cod_tipoprod,
			   _cod_ramo,
			   _cod_contratante,
			   _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza;

		if _cod_tipoprod = _cod_tipoprod2 then
			select porc_partic_coas
			  into _porc_partic_coas
			  from emicoama
			 where no_poliza = _no_poliza
			   and cod_coasegur = '036'; --> Aseguradora Ancon

			let v_saldo = v_saldo * _porc_partic_coas / 100;
		end if

		let _continuar = 0; 

		select count(*)
		  into _cnt_no_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		   and prima_neta <> 0.00;

		if _cnt_no_unidad is null then
			let _cnt_no_unidad = 0;
		end if
		
		if _cnt_no_unidad = 0 then
			--commit work;
			continue foreach;
		end if

		foreach
			select distinct no_unidad
			  into _no_unidad
			  from emipouni
			 where no_poliza = _no_poliza
			   and prima_neta <> 0.00

			let _no_cambio = null;

			select max(no_cambio)
			  into _no_cambio
			  from emireaco
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

			if _no_cambio is null then
				return 1,'No Existe emireaco para la Póliza: ' || trim(_no_poliza) || ' y la Unidad: ' || trim(_no_unidad) with resume;
				--continue foreach;
			end if

			{select count(*)
			  into _cnt_emireaco
			  from emireaco e, reacocob c, reacobre r
			 where e.cod_contrato = c.cod_contrato
			   and e.cod_cober_reas = c.cod_cober_reas
			   and e.cod_cober_reas = r.cod_cober_reas
			   and r.cod_ramo = _cod_ramo
			   and e.no_poliza = _no_poliza
			   and e.no_unidad = _no_unidad
			   and c.bouquet = 1
			   and (e.no_cambio <= (select min(no_cambio) from emireaco where no_poliza = _no_poliza and no_unidad = _no_unidad)
				or e.no_cambio >= (select max(no_cambio) from emireaco where no_poliza = _no_poliza and no_unidad = _no_unidad));

			if _cnt_emireaco is null then
				let _cnt_emireaco = 0;
			end if
			
			if _cnt_emireaco = 0 then
				commit work;
				return 1,'No Existe emireaco. no_poliza: ' || trim(_no_poliza) || ' no_unidad: ' || trim(_no_unidad) with resume;
				continue foreach;
			end if}

			begin
				on exception in(-958)
					insert into tmp_emireaco
					select distinct e.*,r.es_terremoto
					  from emireaco e, reacocob c, reacobre r
					 where e.cod_contrato = c.cod_contrato
					   and e.cod_cober_reas = c.cod_cober_reas
					   and e.cod_cober_reas = r.cod_cober_reas
					   and r.cod_ramo = _cod_ramo
					   and e.no_poliza = _no_poliza
					   and e.no_unidad = _no_unidad
					   and c.bouquet = 1
					   and (e.no_cambio <= (select min(no_cambio) from emireaco where no_poliza = _no_poliza and no_unidad = _no_unidad)
						or e.no_cambio >= (select max(no_cambio) from emireaco where no_poliza = _no_poliza and no_unidad = _no_unidad));
				end exception
				
				select distinct e.*,r.es_terremoto
				  from emireaco e, reacocob c, reacobre r
				 where e.cod_contrato = c.cod_contrato
				   and e.cod_cober_reas = c.cod_cober_reas
				   and e.cod_cober_reas = r.cod_cober_reas
				   and r.cod_ramo = _cod_ramo
				   and e.no_poliza = _no_poliza
				   and e.no_unidad = _no_unidad
				   and c.bouquet = 1
				   and (e.no_cambio <= (select min(no_cambio) from emireaco where no_poliza = _no_poliza and no_unidad = _no_unidad)
					or e.no_cambio >= (select max(no_cambio) from emireaco where no_poliza = _no_poliza and no_unidad = _no_unidad))
				  into temp tmp_emireaco;
			end
		end foreach

		if _cod_ramo in ('001', '003') then

			select cod_cober_reas
			  into _cod_cober_reas
			  from reacobre
			 where cod_ramo     = _cod_ramo
			   and es_terremoto = 1;

			foreach
				select distinct no_unidad,
					   cod_contrato,
					   no_cambio
				  into _no_unidad,
					   _cod_contrato,
					   _no_cambio
				  from tmp_emireaco
				 where no_poliza = _no_poliza
				 order by no_unidad, cod_contrato
			   
				if _cod_ramo = '001' then
					let _porc_inc = .70;
					let _porc_ter = .30;		
				else
					let _porc_inc = .90;
					let _porc_ter = .10;
				end if

				select count(*)
				  into _cnt_existe
				  from reacocob c, reacobre r
				 where c.cod_cober_reas = r.cod_cober_reas
				   and c.cod_contrato = _cod_contrato
				   and r.cod_ramo = _cod_ramo
				   and es_terremoto = 1;

				if _cnt_existe is null then			   
					let _cnt_existe = 0;
				end if

				if _cnt_existe > 0 then
					let _porc_inc = .70;
					let _porc_ter = .30; 
				end if

				update tmp_emireaco
				   set porc_partic_prima  = porc_partic_prima * _porc_inc
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and cod_contrato = _cod_contrato
				   and no_cambio = _no_cambio
				   and es_terremoto = 0;

				select count(*)
				  into _cnt_terr
				  from tmp_emireaco
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and cod_cober_reas = _cod_cober_reas
				   and no_cambio = _no_cambio;

				if _cnt_terr is null then			   
					let _cnt_terr = 0;
				end if

				if _cnt_terr = 0 and _cnt_existe > 0 then			   
				
					insert into tmp_emireaco(no_poliza,no_unidad,no_cambio,cod_cober_reas,orden,cod_contrato,porc_partic_prima,porc_partic_suma,es_terremoto)
					select no_poliza,
						   no_unidad,
						   no_cambio,
						   _cod_cober_reas,
						   orden,
						   _cod_contrato,
						   porc_partic_prima,
						   porc_partic_suma,
						   1
					  from emireaco 
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad
					   and cod_contrato = _cod_contrato
					   and no_cambio = _no_cambio;
				end if
				
				update tmp_emireaco
				   set porc_partic_prima  = porc_partic_prima * _porc_ter
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and cod_contrato = _cod_contrato
				   and no_cambio = _no_cambio
				   and es_terremoto = 1;
			end foreach
		end if			

		let _saldo_contrato = 0;
		let _cantidad_uni   = 0;

		foreach
			select no_unidad
			  into _no_unidad
			  from tmp_emireaco
			 where no_poliza = _no_poliza
			 group by no_unidad   

			select sum(prima)
			  into _saldo_reaseg
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

			if _saldo_reaseg is null then 
				let _saldo_reaseg = 0;
			end if

			let _saldo_contrato = _saldo_contrato + _saldo_reaseg;
			let _cantidad_uni   = _cantidad_uni   + 1;			
		end foreach

		foreach
			select no_unidad
			  into _no_unidad
			  from tmp_emireaco
			 where no_poliza = _no_poliza
			 group by no_unidad   

			select sum(prima)
			  into _saldo_reaseg
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

			if _saldo_reaseg is null then 
				let _saldo_reaseg = 0;
			end if

			if _saldo_contrato = 0 or abs(_saldo_contrato) < 1 then
				let _porc_partic_suma = (1 / _cantidad_uni) * 100; -- Por Unidades
			else
				let _porc_partic_suma = (_saldo_reaseg / _saldo_contrato) * 100; -- Por Prima
			end if

			update tmp_emireaco
			   set porc_partic_suma = _porc_partic_suma
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
		end foreach

		if _cod_ramo in ('002','020','023') then

			foreach
				select no_unidad
				  into _no_unidad
				  from tmp_emireaco
				 where no_poliza = _no_poliza
				 group by no_unidad   

				select sum(prima)
				  into _saldo_contrato
				  from emifacon
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;

				foreach
					select cod_cober_reas,
						   sum(prima)
					  into _cod_cober_reas,
						   _saldo_reaseg
					  from emifacon
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad
					 group by cod_cober_reas

					if _saldo_contrato = 0 then
						let _porc_partic_suma = 0;
					elif abs(_saldo_contrato) < 1 then
						let _porc_partic_suma = 0.5;
					else
						let _porc_partic_suma = (_saldo_reaseg / _saldo_contrato);
					end if

					update tmp_emireaco
					   set porc_partic_prima = porc_partic_prima * _porc_partic_suma
					 where no_poliza        = _no_poliza
					   and no_unidad        = _no_unidad
					   and cod_cober_reas   = _cod_cober_reas;				
				end foreach			
			end foreach		
		end if

		foreach
			select cod_contrato,
				   cod_cober_reas,
				   porc_partic_prima,
				   porc_partic_suma,
				   no_unidad,
				   no_cambio
			  into _cod_contrato,
				   _cod_cober_reas,
				   _porc_partic_prima,
				   _porc_partic_suma,
				   _no_unidad,
				   _no_cambio
			  from tmp_emireaco
			 where no_poliza = _no_poliza
			 order by no_poliza,no_cambio,no_unidad,cod_cober_reas

			select max(no_cambio)
			  into _ult_no_cambio
			  from tmp_emireaco
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

			select min(no_cambio)
			  into _no_cambio_orig
			  from tmp_emireaco
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

			if _no_cambio_orig = _ult_no_cambio then
				let _no_cambio = 2;
			elif _ult_no_cambio = _no_cambio then
				let _no_cambio = 1;
			else
				let _no_cambio = 0;
			end if

			select tipo_contrato		  
			  into _tipo_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;

			if _tipo_contrato = 1 then --retencion
				continue foreach;
			end if

			let _saldo_contrato = 0;

			select tiene_comision,
				   porc_comision,
				   porc_impuesto,
				   bouquet
			  into _tiene_com,
				   _porc_comision1,
				   _porc_impuesto,
				   _bouquet
			  from reacocob
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			if _bouquet = 0 then
				continue foreach;
			end if

			let _saldo_contrato = v_saldo * (_porc_partic_prima / 100) * (_porc_partic_suma / 100);
			let _saldo_reaseg   = 0.00;
			let _es_terremoto   = 0;

			foreach
				select cod_coasegur,
					   porc_cont_partic,
					   porc_comision
				  into _cod_coasegur,
					   _porc_cont_partic,
					   _porc_comision2
				  from reacoase
				 where cod_contrato   = _cod_contrato
				   and cod_cober_reas = _cod_cober_reas
				   and contrato_xl    = 0

				if _tiene_com = 1 then   -- por contrato
					let _porc_comision = _porc_comision1;
				else
					let _porc_comision = _porc_comision2;
				end if

				let _com_reas      = 0.00;
				let _imp_reas      = 0.00;
				let _porc_especial = 1;
				
				let _saldo_reaseg = (_saldo_contrato * _porc_cont_partic / 100) * _porc_especial;
				let _com_reas     = _saldo_reaseg    * _porc_comision    / 100;
				let _imp_reas     = _saldo_reaseg    * _porc_impuesto    / 100;
				let _saldo_reaseg = _saldo_reaseg    - _com_reas         - _imp_reas;

				if _saldo_reaseg = 0 then
					continue foreach;
				end if

				let _porc_com_reas = _porc_comision;
				
				let _porc_coasegur_ant = 0.00;
				let _porc_coasegur_act = 0.00;
				let _porc_reas_ant = 0.00;
				let _porc_reas_act = 0.00;
				let _porc_uni_ant = 0.00;
				let _porc_uni_act = 0.00;
				let _porc_com_ant = 0.00;
				let _porc_com_act = 0.00;
				let _porc_imp_ant = 0.00;
				let _porc_imp_act = 0.00;
				let _saldo_ant = 0.00;
				let _saldo_act = 0.00;
				let _com_ant = 0.00;
				let _com_act = 0.00;
				let _imp_ant = 0.00;
				let _imp_act = 0.00;

				if _no_cambio = 0 then --Saldo con la Distribución Inicial
					let _porc_uni_ant = _porc_partic_suma;
					let _porc_reas_ant = _porc_partic_prima;
					let _porc_coasegur_ant = _porc_cont_partic;
					let _porc_com_ant = _porc_com_reas;
					let _com_ant = _com_reas;
					let _porc_imp_ant = _porc_impuesto;
					let _imp_ant = _imp_reas;
					let _saldo_ant = _saldo_reaseg;
				elif _no_cambio = 1 then --Saldo con la Distribución Actual
					let _porc_uni_act = _porc_partic_suma;
					let _porc_reas_act = _porc_partic_prima;
					let _porc_coasegur_act = _porc_cont_partic;
					let _porc_com_act = _porc_com_reas;
					let _com_act = _com_reas;
					let _porc_imp_act = _porc_impuesto;
					let _imp_act = _imp_reas;
					let _saldo_act = _saldo_reaseg;
				else --No Hubo Cambio en la Distribución de Reaseguro 
					let _porc_uni_ant = _porc_partic_suma;
					let _porc_reas_ant = _porc_partic_prima;
					let _porc_coasegur_ant = _porc_cont_partic;
					let _porc_com_ant = _porc_com_reas;
					let _com_ant = _com_reas;
					let _porc_imp_ant = _porc_impuesto;
					let _imp_ant = _imp_reas;
					let _saldo_ant = _saldo_reaseg;

					let _porc_uni_act = _porc_partic_suma;
					let _porc_reas_act = _porc_partic_prima;
					let _porc_coasegur_act = _porc_cont_partic;
					let _porc_com_act = _porc_com_reas;
					let _com_act = _com_reas;
					let _porc_imp_act = _porc_impuesto;
					let _imp_act = _imp_reas;
					let _saldo_act = _saldo_reaseg;
				end if

				begin
					on exception in(-239,-268)
						update rea_saldo2
						   set saldo_actual = saldo_actual + _saldo_act,
							   saldo_anterior = saldo_anterior + _saldo_ant,
							   comision_a = comision_a + _com_ant,
							   impuesto_a = impuesto_a + _imp_ant,
							   comision = comision + _com_act,
							   porc_partic_cont_a = (porc_partic_cont_a + _porc_coasegur_ant)/2,
							   porc_partic_cont = (porc_partic_cont + _porc_coasegur_act)/2,
							   porc_partic_reas_a = (porc_partic_reas_a + _porc_reas_ant)/2,
							   porc_partic_uni_a = (porc_partic_uni_a + _porc_uni_ant)/2,
							   porc_partic_reas = (porc_partic_reas + _porc_reas_act)/2,
							   porc_com_reas_a = (porc_com_reas_a + _porc_com_ant)/2,
							   porc_imp_coas_a = (porc_imp_coas_a + _porc_imp_ant)/2,
							   porc_partic_uni = (porc_partic_uni + _porc_uni_act)/2,
							   porc_com_reas = (porc_com_reas + _porc_com_act)/2,
							   porc_imp_coas = (porc_imp_coas + _porc_imp_act)/2,
							   impuesto = impuesto + _imp_act
						 where periodo = a_periodo2
						   and no_documento = _doc_poliza
						   and no_unidad = _no_unidad
						   and cod_cober_reas = _cod_cober_reas
						   and cod_contrato = _cod_contrato
						   and cod_coasegur = _cod_coasegur;
					end exception
					
					insert into rea_saldo2(
							periodo,
							no_documento,
							cod_contratante,
							vigencia_inic,
							vigencia_final,
							cod_ramo,
							saldo_tot,
							no_poliza,
							no_unidad,
							porc_partic_uni,
							cod_cober_reas,
							porc_partic_reas,
							cod_contrato,
							cod_coasegur,
							porc_partic_cont,
							porc_com_reas,
							comision,
							porc_imp_coas,
							impuesto,
							saldo_actual,
							porc_partic_uni_a,
							porc_partic_reas_a,
							porc_partic_cont_a,
							porc_com_reas_a,
							comision_a,
							porc_imp_coas_a,
							impuesto_a,
							saldo_anterior)
					values(	a_periodo2,
							_doc_poliza,
							_cod_contratante,
							_vigencia_inic,
							_vigencia_final,
							_cod_ramo,
							v_saldo,
							_no_poliza,
							_no_unidad,
							_porc_uni_act,
							_cod_cober_reas,
							_porc_reas_act,
							_cod_contrato,
							_cod_coasegur,
							_porc_coasegur_act,
							_porc_com_act,
							_com_act,
							_porc_imp_act,
							_imp_act,
							_saldo_act,
							_porc_uni_ant,
							_porc_reas_ant,
							_porc_coasegur_ant,
							_porc_com_ant,
							_com_ant,
							_porc_imp_ant,
							_imp_ant,
							_saldo_ant);
				end 
			end foreach
		end foreach

		drop table if exists tmp_emireaco;		
	end foreach

	delete from tmp_poliza;

	commit work;
end foreach

end

return 0, 'Exito';

end procedure;