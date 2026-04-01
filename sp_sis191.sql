-- Procedimiento que carga los Saldos de las polizas renovadas bajo el nuevo contrato de auto casco a junio 2013 sin impuesto
 
-- 17/10/2013 - Autor: Armando Moreno.

drop procedure sp_sis191;

create procedure "informix".sp_sis191(a_compania char(3), a_no_remesa CHAR(10))
returning CHAR(3),
		  varchar(50),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  varchar(50);

define v_saldo            DEC(16,2);
define v_saldo_b          DEC(16,2);

define _cod_ramo		  char(3);
define _cod_tipoprod1     char(3);
define _cod_tipoprod2     char(3);
define _fecha             date;
define _doc_poliza        char(20);
define _no_poliza		  char(10);
define _cod_contrato	  char(5);
define _cod_cober_reas    char(3);
define _porc_partic_prima DEC(9,2);
define _no_cambio		  smallint;
define _no_unidad         char(5);
define _tipo_contrato     smallint;
define _saldo_contrato    DEC(16,2);
define _saldo_reaseg      DEC(16,2);
define _cod_coasegur      char(3);
define _porc_partic_reas  DEC(9,6);
define _tiene_com		  smallint;
define _porc_comision     decimal(5,2);
define _porc_cont_partic  decimal(9,6);
define _nombre            varchar(50);
define _nombre_reas       varchar(50);
define _nombre_contratante varchar(100);
define _vigencia_inic	  date;
define _vigencia_final	  date;
define _cod_contratante   char(10);
define _descr_cia         varchar(50);
define _cod_tipoprod      char(3);
define _porc_impuesto     dec(5,2);
define _porc_partic_coas  dec(7,4);
define _comision      	  DEC(16,2);
define _impuesto      	  DEC(16,2);
define v_prima1      	  DEC(16,2);
define _continuar         smallint;
define _bouquet,_cnt      smallint;
define _nueva_renov       char(1);
define _mensaje           char(100);
define _ret_rc      	  DEC(16,2);
define _ret_casco      	  DEC(16,2);
define _porc_proporcion   dec(5,2);
define  v_tipo_contrato   SMALLINT;
define _serie             smallint;
define _tiene_comis_rea   smallint;
define _tipo_cont         smallint;
DEFINE _porc_comis_ase    DECIMAL(5,2);
define _monto_reas        DEC(16,2);
define _por_pagar         DEC(16,2);

define _error			  integer;

CREATE TEMP TABLE tmp_rea_saldo(
		no_documento     CHAR(20)	NOT NULL,
		no_poliza        CHAR(10)	NOT NULL,
		saldo_sin        DEC(16,2)	DEFAULT 0 NOT NULL,
		porc_proporcion	 DEC(16,2)	DEFAULT 0 NOT NULL,
		porc_partic_prima dec(16,2)	DEFAULT 0 NOT NULL,
		ret_rc           DEC(16,2)	DEFAULT 0 NOT NULL,
		ret_casco		 DEC(16,2)	DEFAULT 0 NOT NULL,
		porc_cont_partic  DEC(16,2)	DEFAULT 0 NOT NULL,
		contrato_bq		 DEC(16,2)	DEFAULT 0 NOT NULL,
		porc_comision     DEC(16,2)	DEFAULT 0 NOT NULL,
		comision         DEC(16,2)	DEFAULT 0 NOT NULL,
		porc_impuesto     DEC(16,2)	DEFAULT 0 NOT NULL,
		impuesto         DEC(16,2)	DEFAULT 0 NOT NULL,
		provision        DEC(16,2)	DEFAULT 0 NOT NULL,
		cod_contrato	 char(5)	not null,
		cod_coasegur	 char(5)	not null,
		cod_cober_reas	 char(3)	not null,
		seleccionado     SMALLINT   DEFAULT 1 NOT NULL
		) WITH NO LOG;

SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_sis191.trc";
--TRACE ON ;

LET _descr_cia = sp_sis01(a_compania);

SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 1;	-- Sin Coaseguro

SELECT cod_tipoprod
  INTO _cod_tipoprod2
  FROM emitipro
 WHERE tipo_produccion = 2;	-- Coaseguro Mayoritario

foreach
	select prima_neta,
	       doc_remesa,
		   no_poliza
	  into v_saldo,
	       _doc_poliza,
		   _no_poliza
	  from cobredet
	 where no_remesa       = a_no_remesa   --'660575'= Remesa de ajuste de centavo 2012-12
--	   and doc_remesa[1,2] = '03'

	 select max(no_cambio)
	   into _no_cambio
	   from emireaco
	  where no_poliza = _no_poliza;

	select min(no_unidad)
	  into _no_unidad
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_cambio = _no_cambio;
		
 	 --CALL sp_cob223(a_compania,a_sucursal,_doc_poliza,a_periodo,_fecha) RETURNING v_saldo, v_saldo_b;

	 select porc_partic_coas
	   into _porc_partic_coas 
	   from emicoama
	  where no_poliza    = _no_poliza
	    and cod_coasegur = "036"; 			

	 if _porc_partic_coas is null then
	 	let _porc_partic_coas = 100;
	 end if

	 let v_saldo = v_saldo * _porc_partic_coas / 100;

--	 call sp_sis188(_no_poliza) returning _error,_mensaje;

	 let v_prima1   = 0;
	 let _ret_rc    = 0;
	 let _ret_casco = 0;

	 foreach
		select cod_contrato,
			   cod_cober_reas,
			   porc_partic_prima,
			   no_unidad
		  into _cod_contrato,
			   _cod_cober_reas,
			   _porc_partic_prima,
			   _no_unidad
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_cambio = _no_cambio
		   and no_unidad = _no_unidad

--		select porc_cober_reas
--		  into _porc_proporcion
--		  from tmp_dist_rea
--		 where cod_cober_reas = _cod_cober_reas;

		let _porc_proporcion = 100.00;

		if _doc_poliza[1,2] = '01' then
			
			if _cod_cober_reas = "001" then
				let _porc_proporcion = 70;
			else
				let _porc_proporcion = 30;
			end if

		end if

		if _doc_poliza[1,2] = '03' then
			
			if _cod_cober_reas = "003" then
				let _porc_proporcion = 70;
			else
				let _porc_proporcion = 30;
			end if

		end if

		Select tipo_contrato,
			   serie
		  Into v_tipo_contrato,
			   _serie
		  From reacomae
		 Where cod_contrato = _cod_contrato;

		if v_tipo_contrato = 1 then
			continue foreach;
		end if

		Select porc_impuesto,
		       porc_comision,
			   tiene_comision,
			   bouquet
		  Into _porc_impuesto,
			   _porc_comision,
			   _tiene_comis_rea,
			   _bouquet
		  From reacocob
		 Where cod_contrato   = _cod_contrato
		   And cod_cober_reas = _cod_cober_reas;
		
		if _bouquet = 0 then
			continue foreach;
		end if

		let _tipo_cont = 0;

        IF v_tipo_contrato = 3 THEN

			let _tipo_cont = 2;

        elif v_tipo_contrato = 1 then --retencion

			let _tipo_cont = 1;

        END IF

		let v_prima1 = v_saldo * (_porc_partic_prima / 100) * (_porc_proporcion / 100);

   	     let _ret_rc = _ret_rc + v_prima1;

--	    if _cod_cober_reas = '002' then
--		else
--		     let _ret_casco = _ret_casco + v_prima1;
--		end if


		if _tipo_cont = 0 then

	 	 	foreach
	 			select porc_cont_partic,
	 				   porc_comision,
	 				   cod_coasegur
	 			  into _porc_cont_partic,
	 			   	   _porc_comis_ase,
	 				   _cod_coasegur
	 			  from reacoase
	 		     where cod_contrato   = _cod_contrato
	 		       and cod_cober_reas = _cod_cober_reas
				   and contrato_xl    = 0
	 				
	 			-- La comision se calcula por reasegurador

	 			if _tiene_comis_rea = 2 then 
	 				let _porc_comision = _porc_comis_ase;
	 			end if

	 			let _monto_reas = v_prima1    * _porc_cont_partic / 100;
	 			let _impuesto   = _monto_reas * _porc_impuesto / 100;
	 			let _comision   = _monto_reas * _porc_comision / 100;

	 			let _por_pagar  = _monto_reas - _impuesto - _comision;

				insert into tmp_rea_saldo(
					no_documento,
				    no_poliza,   
					saldo_sin,
					porc_proporcion,
					porc_partic_prima,   
					ret_rc,     
					ret_casco,
					porc_cont_partic,	
					contrato_bq,
					porc_comision,
					comision,    
					porc_impuesto,	
					impuesto,    
					provision,
					cod_contrato,
					cod_coasegur,
					cod_cober_reas,   
					seleccionado
					)
					values(
					_doc_poliza,
					_no_poliza,
					v_saldo,
					_porc_proporcion,
					_porc_partic_prima,
					_ret_rc,
					_ret_casco,
					_porc_cont_partic,
					_monto_reas,
					_porc_comision,
					_comision,
					_porc_impuesto,
					_impuesto,
					_por_pagar,
					_cod_contrato,
					_cod_coasegur,
					_cod_cober_reas,
					1 
					);

			end foreach

		end if

	 end foreach

--	 drop table tmp_dist_rea;

end foreach

return '','', 0, 0, 0, 0, '';


{
foreach with hold
	select cod_coasegur,
	       SUM(saldo_tot),	
		   SUM(saldo_coasegur),
		   SUM(comision),
		   SUM(impuesto)
	  into _cod_coasegur,
	       v_saldo,
		   _saldo_reaseg,
		   _comision,
		   _impuesto
	  from tmp_rea_saldo
  group by 1
   
    select nombre
	  into _nombre_reas
	  from emicoase
	 where cod_coasegur = _cod_coasegur;

	return _cod_coasegur,
	       _nombre_reas,
		   v_saldo,
		   _comision,
		   _impuesto,
		   _saldo_reaseg,
		   _descr_cia WITH RESUME;


end foreach	 }

--DROP TABLE tmp_rea_saldo;

end procedure








