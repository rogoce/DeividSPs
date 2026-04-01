-- Procedimiento que carga los Saldos de las polizas por reaseguro
-- 25/11/2009 - Autor: Amado Perez.
-- 15/10/2010 - Modificado - Autor: Henry: Cambio del sp_sis21 a utilizar poliza a la fecha, por orden de Sr. Naranjo 
-- 10/04/2011 - Modificado - Autor: Henry: Arlena Gomez , tomar la parte de terremoto no se estaba calculando.
-- execute procedure sp_pro494("001","001","2010-12")

drop procedure sp_pro494;
create procedure "informix".sp_pro494(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7))
returning CHAR(3),
		  varchar(50),
		  char(10),
		  char(20),
		  char(3),
		  varchar(50),
		  varchar(100),
		  date,
		  date,
		  DEC(16,2),
		  DEC(9,6),
		  DEC(9,6),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  varchar(50),
		  CHAR(7);

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
define _continuar         smallint;
define _bouquet           smallint;
define _error			  integer;
DEFINE _com_reas		  DEC(16,2);
DEFINE _imp_reas		  DEC(16,2);
define _es_terremoto	  integer;
define _porc_especial	  dec(5,2);
define _porc_com_reas	  dec(5,2);
define _periodo           char(7);

CREATE TEMP TABLE tmp_rea_saldo(
		cod_coasegur	CHAR(3)		NOT NULL,
		no_poliza       CHAR(10)	NOT NULL,
		saldo_tot       DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo_coasegur  DEC(16,2)	DEFAULT 0 NOT NULL,
		porc_partic_cont DEC(9,6)	DEFAULT 0 NOT NULL,
		porc_partic_reas DEC(9,6)	DEFAULT 0 NOT NULL,
		comision        DEC(16,2)	DEFAULT 0 NOT NULL,
		impuesto        DEC(16,2)	DEFAULT 0 NOT NULL,
		no_documento    CHAR(20)   	NOT NULL,
		cod_ramo       	CHAR(3)		NOT NULL,
		cod_contratante CHAR(10)	NOT NULL,
		vigencia_inic	DATE,
		vigencia_final	DATE,
		es_terremoto	integer     DEFAULT 0 NOT NULL,
		porc_com_reas   DEC(9,6)	DEFAULT 0 NOT NULL,
		PRIMARY KEY (cod_coasegur, no_poliza, es_terremoto)
		) WITH NO LOG;

SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_pro494.trc";

LET _descr_cia = sp_sis01(a_compania);

SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 1;	-- Sin Coaseguro

SELECT cod_tipoprod
  INTO _cod_tipoprod2
  FROM emitipro
 WHERE tipo_produccion = 2;	-- Coaseguro Mayoritario

let _fecha = sp_sis36(a_periodo);
--**************************************************************************************************** poner en comentario el where
foreach
 SELECT no_documento
   INTO	_doc_poliza
   FROM emipoliza
  --where no_documento[1,2] = '06' --= '0604-00127-01' --"0106-00342-01" --	"0106-00491-01" -- "0100-00010-02" --[1,2] = '02'   "0102-00088-01" --

{ SELECT no_documento 
   INTO	_doc_poliza 
   FROM emipomae  
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania 
    AND actualizado        = 1			   	   -- Poliza este actualizada 
	AND (cod_tipoprod      = _cod_tipoprod1 OR -- Sin Coaseguro 
	     cod_tipoprod      = _cod_tipoprod2)   -- Coaseguro Mayoritario  
 	and cod_ramo = '003' 
GROUP BY no_documento
}
--    LET _no_poliza = sp_sis21(_doc_poliza);	-- Henry: cambio por orden de Sr. Naranjo F.15/10/2010
	let _no_poliza      = "";

	foreach
	 SELECT d.no_poliza
	   INTO	_no_poliza
	   FROM emipomae d
	  WHERE d.cod_compania     = a_compania                           --'001'
	    AND d.no_documento     = _doc_poliza
	    AND (d.vigencia_final  >= _fecha                              --'31/12/2009'
	     OR d.vigencia_final   IS NULL)
	    AND d.fecha_suscripcion <= _fecha                             --'31/12/2009'
	    AND d.vigencia_inic     < _fecha                              --'31/12/2009'
	    AND d.actualizado = 1
	  exit foreach;
	end foreach

	if _no_poliza is null or _no_poliza = "" then
		continue foreach;
	end if

	CALL sp_cob223(
	a_compania,
	a_sucursal,
	_doc_poliza,
	a_periodo,
	_fecha
	) RETURNING	v_saldo, v_saldo_b;

   --	TRACE ON ;

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

    if _cod_tipoprod <> _cod_tipoprod1 And _cod_tipoprod <> _cod_tipoprod2 Then
		continue foreach;
	end if

    if _cod_tipoprod = _cod_tipoprod2 then
		SELECT porc_partic_coas
		  INTO _porc_partic_coas
		  FROM emicoama
		 WHERE no_poliza = _no_poliza
		   AND cod_coasegur = '036'; --> Aseguradora Ancon

		LET v_saldo = v_saldo * _porc_partic_coas / 100;
	end if

    let _continuar = 0; 

	foreach
  {		select a.cod_contrato,
			   a.cod_cober_reas,
			   a.porc_partic_prima,
			   a.no_cambio,
			   a.no_unidad
		  into _cod_contrato,
			   _cod_cober_reas,
			   _porc_partic_prima,
			   _no_cambio,
			   _no_unidad
		  from emireaco a, reacomae b
		 where no_poliza = _no_poliza
		   and no_cambio = (select max(no_cambio) from emireaco where no_poliza = _no_poliza )
		   and a.cod_contrato = b.cod_contrato
		   and b.tipo_contrato <> 1
 }
 		select cod_contrato,
			   cod_cober_reas,
			   porc_partic_prima,
			   no_cambio,
			   no_unidad
		  into _cod_contrato,
			   _cod_cober_reas,
			   _porc_partic_prima,
			   _no_cambio,
			   _no_unidad
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_cambio = (select max(no_cambio) from emireaco where no_poliza = _no_poliza)
--		 order by no_unidad, cod_contrato, cod_cober_reas

        if _continuar = 1 then
    		let _continuar = 0; 
			continue foreach;
		end if

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
			       _porc_comision,
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

			select es_terremoto
			  into _es_terremoto
			  from reacobre
			 where cod_ramo       = _cod_ramo
			   and cod_cober_reas = _cod_cober_reas;


			if _tiene_com = 1 then   --por contrato
				if _tipo_contrato = 3 then
					foreach
						select cod_coasegur,
							   porc_partic_reas,
							   porc_comis_fac,
							   porc_impuesto
						  into _cod_coasegur,
							   _porc_partic_reas,
							   _porc_comision,
							   _porc_impuesto
						  from emireafa
						 where cod_contrato   = _cod_contrato
						   and cod_cober_reas = _cod_cober_reas
						   and no_poliza	  = _no_poliza
						   and no_unidad      = _no_unidad
						   and no_cambio      = _no_cambio

                        let _saldo_reaseg = (_saldo_contrato * _porc_partic_reas / 100);
						let _saldo_reaseg =  _saldo_reaseg - ((_saldo_reaseg * _porc_comision / 100) + (_saldo_reaseg * _porc_impuesto / 100));

			  			if _saldo_reaseg = 0 then
			  				continue foreach;
			  			end if
						let _porc_com_reas = _porc_comision ;
					
						BEGIN
							ON EXCEPTION SET _error 
								IF _error <> -239 AND _error <> -268 THEN
								    let _continuar = 1; 
									exit foreach;
									
								 --	RETURN _error, "Error al INSERTAR tmp_rea_saldo";
								
								ELSE
								END IF	

							END EXCEPTION
							insert into tmp_rea_saldo(
								cod_coasegur,	
							    no_poliza,     
								saldo_tot,     
								saldo_coasegur,
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
							    porc_com_reas	
								)
								values(
								_cod_coasegur,
								_no_poliza,
								v_saldo,
								_saldo_reaseg,
								_porc_partic_prima,
								_porc_partic_reas,
								_saldo_contrato * _porc_partic_reas / 100 * _porc_comision / 100,
								_saldo_contrato * _porc_partic_reas / 100 * _porc_impuesto / 100,
								_doc_poliza,
								_cod_ramo,
								_cod_contratante,
								_vigencia_inic,
								_vigencia_final,
								_es_terremoto,
								_porc_com_reas
								);
						
						END

					end foreach
				else
					foreach

						select cod_coasegur,
						       porc_cont_partic
						  into _cod_coasegur,
						       _porc_cont_partic
						  from reacoase
						 where cod_contrato   = _cod_contrato
						   and cod_cober_reas = _cod_cober_reas
						   and contrato_xl    = 0

	                    let _saldo_reaseg = (_saldo_contrato * _porc_cont_partic / 100);
						let _saldo_reaseg =  _saldo_reaseg - ((_saldo_reaseg * _porc_comision / 100) + (_saldo_reaseg * _porc_impuesto / 100));

						if _saldo_reaseg = 0 then
							continue foreach;
						end if

						let _porc_com_reas = _porc_comision ;

						BEGIN
							ON EXCEPTION SET _error 
								IF _error <> -239 AND _error <> -268 THEN
								    let _continuar = 1; 
									exit foreach;
								-- 	RETURN _error, "Error al INSERTAR tmp_rea_saldo";								
								ELSE
								END IF	

							END EXCEPTION
							insert into tmp_rea_saldo(
								cod_coasegur,	
							    no_poliza,     
								saldo_tot,     
								saldo_coasegur,
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
							    porc_com_reas	
								)
								values(
								_cod_coasegur,
								_no_poliza,
								v_saldo,
								_saldo_reaseg,
								_porc_partic_prima,
								_porc_cont_partic,
								_saldo_contrato * _porc_cont_partic / 100 * _porc_comision / 100,
								_saldo_contrato * _porc_cont_partic / 100 * _porc_impuesto / 100,
								_doc_poliza,
								_cod_ramo,
								_cod_contratante,
								_vigencia_inic,
								_vigencia_final,
								_es_terremoto,
								_porc_com_reas
								);
						
						END
						
					end foreach

				 --	continue foreach;
				end if

			elif _tiene_com = 2 then --por reasegurador

				foreach
					select cod_coasegur,
					       porc_cont_partic,
						   porc_comision
					  into _cod_coasegur,
					       _porc_cont_partic,
						   _porc_comision
					  from reacoase
					 where cod_contrato   = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas
					   and contrato_xl    = 0

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

	                     let _saldo_reaseg = (_saldo_contrato * _porc_cont_partic / 100) * _porc_especial;
						 let _com_reas     = _saldo_reaseg * _porc_comision / 100;

					else

	                    let _saldo_reaseg = (_saldo_contrato * _porc_cont_partic / 100) * _porc_especial;
						let _com_reas = _saldo_reaseg * _porc_comision / 100;

					end if

					let _imp_reas =  (_saldo_contrato * _porc_cont_partic / 100 * _porc_impuesto / 100) * _porc_especial;
					let _saldo_reaseg =  _saldo_reaseg  - (_com_reas + (_saldo_reaseg * _porc_impuesto / 100));

 					if _saldo_reaseg = 0 then
 						continue foreach;
 					end if

						let _porc_com_reas = _porc_comision ;

					BEGIN
						ON EXCEPTION SET _error 
							IF _error <> -239 AND _error <> -268 THEN
							    let _continuar = 1; 
								exit foreach;
							-- 	RETURN _error, "Error al INSERTAR tmp_rea_saldo";							
							END IF	

						END EXCEPTION
						insert into tmp_rea_saldo(
							cod_coasegur,	
						    no_poliza,     
							saldo_tot,     
							saldo_coasegur,
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
						    porc_com_reas	
							)
							values(
							_cod_coasegur,
							_no_poliza,
							v_saldo,
							_saldo_reaseg,
							_porc_partic_prima,
							_porc_cont_partic,
							_com_reas,			-- _saldo_contrato * _porc_cont_partic / 100 * _porc_comision / 100 ,
							_imp_reas,          -- _saldo_contrato * _porc_cont_partic / 100 * _porc_impuesto / 100 ,
							_doc_poliza,
							_cod_ramo,
							_cod_contratante,
							_vigencia_inic,
							_vigencia_final,
							_es_terremoto,
							_porc_com_reas
							);						
					END			
				end foreach							
			end if
		end if
	end foreach
end foreach


{ foreach with hold
	select cod_coasegur,	
		   no_poliza,     
		   saldo_tot, 
		   porc_partic_cont,
		   porc_partic_reas,    
		   saldo_coasegur,
		   comision,
		   impuesto,
		   no_documento,
		   cod_ramo,
		   cod_contratante,
		   vigencia_inic,
		   vigencia_final,
		   es_terremoto,
		   porc_com_reas
	  into _cod_coasegur,
		   _no_poliza,
		   v_saldo,
		   _porc_partic_prima,
		   _porc_partic_reas,
		   _saldo_reaseg,
		   _comision,
		   _impuesto,
		   _doc_poliza,
		   _cod_ramo,
		   _cod_contratante,
		   _vigencia_inic,
		   _vigencia_final,
		   _es_terremoto,
		   _porc_com_reas
	  from tmp_rea_saldo
	  order by cod_coasegur, es_terremoto }

foreach with hold
	select cod_coasegur,	
		   no_poliza,     
		   saldo_tot, 
		   porc_partic_cont,
		   porc_partic_reas,    
		   sum(saldo_coasegur),
		   sum(comision),
		   sum(impuesto),
		   no_documento,
		   cod_ramo,
		   cod_contratante,
		   vigencia_inic,
		   vigencia_final
	  into _cod_coasegur,
		   _no_poliza,
		   v_saldo,
		   _porc_partic_prima,
		   _porc_partic_reas,
		   _saldo_reaseg,
		   _comision,
		   _impuesto,
		   _doc_poliza,
		   _cod_ramo,
		   _cod_contratante,
		   _vigencia_inic,
		   _vigencia_final
	  from tmp_rea_saldo
  group by cod_coasegur,	
		   no_poliza,     
		   saldo_tot, 
		   porc_partic_cont,
		   porc_partic_reas, 
		   no_documento,
		   cod_ramo,
		   cod_contratante,
		   vigencia_inic,
		   vigencia_final  

    select trim(nombre)
	  into _nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;

	  {	if _es_terremoto = 1 then
		   let _nombre = _nombre||" - % "||_porc_partic_reas;
		else
		   let _nombre = _nombre||" - % "||_porc_partic_reas;
	   end if }

    select nombre
	  into _nombre_reas
	  from emicoase
	 where cod_coasegur = _cod_coasegur;

    select nombre
	  into _nombre_contratante
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select periodo into _periodo from emipomae where no_poliza = _no_poliza;

	return _cod_coasegur,
	       _nombre_reas,
		   _no_poliza,
		   _doc_poliza,
		   _cod_ramo,
		   _nombre,
		   _nombre_contratante,
		   _vigencia_inic,
		   _vigencia_final,
		   v_saldo,
		   _porc_partic_prima,
		   _porc_partic_reas,    --	_porc_com_reas,		  -- 
		   _comision,
		   _impuesto,
		   _saldo_reaseg,
		   _descr_cia,
		   _periodo WITH RESUME;


end foreach

DROP TABLE tmp_rea_saldo;

end procedure


 