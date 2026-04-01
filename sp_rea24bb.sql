-- Procedimiento que carga los Saldos de las polizas por reaseguro
-- 25/11/2009 - Autor: Amado Perez.
-- 15/10/2010 - Modificado - Autor: Henry: Cambio del sp_sis21 a utilizar poliza a la fecha, por orden de Sr. Naranjo 
-- 10/04/2011 - Modificado - Autor: Henry: Arlena Gomez , tomar la parte de terremoto no se estaba calculando.
-- execute procedure sp_rea24("001","001","2010-12")

drop procedure sp_rea24bb;
create procedure "informix".sp_rea24bb(a_compania char(3), a_sucursal char(3), a_periodo char(7), a_periodo2 char(7))
returning	char(3),                  --1
			varchar(50);              --2

define _nombre_contratante	varchar(100);
define _nombre_reas			varchar(50);
define _descr_cia			varchar(50);
define _nombre				varchar(50);
define _doc_poliza			char(20);
define _cod_contratante		char(10);
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
define _porc_impuesto		dec(5,2);
define _porc_especial		dec(5,2);
define _porc_com_reas		dec(5,2);
define _porc_comision		dec(5,2);
define _porc_partic_coas	dec(7,4);
define _porc_partic_prima	dec(9,2);
define _porc_cont_partic	dec(9,6);
define _porc_partic_reas	dec(9,6);
define _saldo_contrato		dec(16,2);
define _saldo_reaseg		dec(16,2);
define _comision			dec(16,2);
define v_saldo_b			dec(16,2);
define _impuesto			dec(16,2);
define _com_reas			dec(16,2);
define _imp_reas			dec(16,2);
define v_saldo				dec(16,2);
define _es_terremoto		integer;
define _error				integer;
define _tipo_contrato		smallint;
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

--set debug file to "sp_rea24bb.trc";
--trace on ;

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
		
let _fecha = mdy(_mes, 1, _ano);

--**************************************************************************************************** poner en comentario el where
foreach
	select no_documento
	  into	_doc_poliza
	  from emipoliza

--	 where no_documento = '0103-00374-01'
		 
	let _no_poliza      = "";

    -- se incluyo las polizas con vigencia inicial menores y iguales al periodo solicitado
	call sp_sis21(_doc_poliza)returning _no_poliza;

	if _no_poliza is null or _no_poliza = "" then
		continue foreach;
	end if

	call sp_cob223(
	a_compania,
	a_sucursal,
	_doc_poliza,
	a_periodo,
	_fecha
	) returning	v_saldo, v_saldo_b;
	
    if v_saldo_b = 0 then
		continue foreach;
	end if

    if v_saldo = 0 then
		continue foreach;
	end if

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

	select max(no_cambio)
	  into _no_cambio 
	  from emireaco 
	 where no_poliza = _no_poliza;

	select min(no_unidad)
	  into _no_unidad
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_cambio = _no_cambio;
	   
	select * 
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_cambio = _no_cambio
	   and no_unidad = _no_unidad
	into temp tmp_emireaco;
	
	if _cod_ramo in ("001", "003") then
		let _cnt_terr = 0;
		
		select cod_cober_reas
		  into _cod_cober_reas
		  from reacobre
		 where cod_ramo     = _cod_ramo
		   and es_terremoto = 1;
		   
		select count(*)
		  into _cnt_terr
		  from tmp_emireaco
		 where cod_cober_reas = _cod_cober_reas;
		
		if _cnt_terr is null or _cnt_terr = 0 then			   
			insert into tmp_emireaco(no_poliza,no_unidad,no_cambio,cod_cober_reas,orden,cod_contrato,porc_partic_prima,porc_partic_suma)
			select no_poliza,
				   no_unidad,
				   no_cambio,
				   _cod_cober_reas,
				   orden,
				   cod_contrato,
				   porc_partic_prima,
				   porc_partic_suma
			  from emireaco 
			 where no_poliza = _no_poliza
			   and no_cambio = _no_cambio
			   and no_unidad = _no_unidad;
		end if		
	end if
	
	foreach
 		select cod_contrato,
			   cod_cober_reas,
			   porc_partic_prima
		  into _cod_contrato,
			   _cod_cober_reas,
			   _porc_partic_prima
		  from tmp_emireaco
		 where no_poliza = _no_poliza
		   and no_cambio = _no_cambio
		   and no_unidad = _no_unidad

		select tipo_contrato		  
		  into _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _tipo_contrato = 1 then --retencion
			continue foreach;
		else
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

			let _saldo_contrato = v_saldo * _porc_partic_prima / 100;
            let _saldo_reaseg = 0.00;
			let _es_terremoto = 0;

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

				-- Cambia para ramos incendio y multirriesgo. Arlena Gomez 4/4/2011
				let _com_reas      = 0.00;
				let _imp_reas      = 0.00;
				let _porc_especial = 1;

				if _cod_ramo in ("001", "003") then					  

					select es_terremoto
					  into _es_terremoto
					  from reacobre
					 where cod_ramo       = _cod_ramo
					   and cod_cober_reas = _cod_cober_reas;

					if _es_terremoto = 0 then
						let _porc_especial = 0.70;
					else
						let _porc_especial = 0.30;
					end if
				end if

                let _saldo_reaseg = (_saldo_contrato * _porc_cont_partic / 100) * _porc_especial;
				let _com_reas     = _saldo_reaseg * _porc_comision / 100;
				let _imp_reas     = _saldo_reaseg * _porc_impuesto / 100;
				let _saldo_reaseg = _saldo_reaseg - _com_reas - _imp_reas;

				if _saldo_reaseg = 0 then
					continue foreach;
				end if

				let _porc_com_reas = _porc_comision ;

				select count(*)
				  into _cantidad
				  from rea_saldo
			     where no_documento = _doc_poliza
				   and cod_coasegur = _cod_coasegur
				   and periodo      = a_periodo2;

				if a_periodo = a_periodo2 then -- Saldo Actual			
					if _cantidad = 0 then
						insert into rea_saldo(
							cod_coasegur,	
						    no_poliza,     
							saldo_tot, 
							saldo_ant,
							porc_partic_cont,
							porc_partic_reas,
							comision, 
							impuesto, 
						    no_documento,   
						    cod_ramo,      
						    cod_contratante,
						    vigencia_inic,	
						    vigencia_final,
						    es_terremoto,
						    porc_com_reas,
							periodo,
							saldo_coasegur
							)
						values(
							_cod_coasegur,
							_no_poliza,
							v_saldo,
							0,
							_porc_cont_partic,
							_porc_partic_prima,
							_com_reas,
							_imp_reas,
							_doc_poliza,
							_cod_ramo,
							_cod_contratante,
							_vigencia_inic,
							_vigencia_final,
							_es_terremoto,
							_porc_com_reas,
							a_periodo2,
							_saldo_reaseg
							);
					else
						update rea_saldo
						   set saldo_coasegur = saldo_coasegur + _saldo_reaseg
						 where periodo        = a_periodo2
						   and cod_coasegur   = _cod_coasegur
						   and no_documento   = _doc_poliza;							
					end if
				else -- Saldo Anterior
					if _cantidad = 0 then
						insert into rea_saldo(
							cod_coasegur,	
						    no_poliza,     
							saldo_tot, 
							saldo_ant,
							porc_partic_cont,
							porc_partic_reas,
							comision, 
							impuesto, 
						    no_documento,   
						    cod_ramo,      
						    cod_contratante,
						    vigencia_inic,	
						    vigencia_final,
						    es_terremoto,
						    porc_com_reas,
							periodo
							)
						values(
							_cod_coasegur,
							_no_poliza,
							0.00,
							_saldo_reaseg,
							0,
							0,
							0,--_saldo_contrato * _porc_partic_reas / 100 * _porc_comision / 100,
							0,--_saldo_contrato * _porc_partic_reas / 100 * _porc_impuesto / 100,
							_doc_poliza,
							_cod_ramo,
							_cod_contratante,
							_vigencia_inic,
							_vigencia_final,
							_es_terremoto,
							0,
							a_periodo2
							);
					else
						update rea_saldo
						   set saldo_ant    = saldo_ant + _saldo_reaseg
						 where periodo = a_periodo2
						   and cod_coasegur = _cod_coasegur
						   and no_documento = _doc_poliza;							
					end if				
				end if				
			end foreach
		end if
	end foreach
	
	drop table tmp_emireaco;
end foreach

return 0, "Exito";

end procedure 