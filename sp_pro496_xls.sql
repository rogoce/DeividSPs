-- Procedimiento que carga los Saldos de las polizas por reaseguro 
-- 25/11/2009 - Autor: Amado Perez.
-- Modificado - Autor: Henry: Cambio del sp_sis21 a utilizar poliza a la fecha, por orden de Sr. Naranjo F.15/10/2010
-- Se creo para bajar a Excel y comparar con sp_sac167 089 - PROVINCIAL DE REASEGURO C:A:.

--drop procedure sp_pro496_xls;
drop procedure sp_pro496_a;
create procedure "informix".sp_pro496_xls(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7))
returning CHAR(3),		
		  CHAR(10),	
		  CHAR(3),   
		  DEC(16,2),	
		  DEC(16,2),	
		  DEC(9,6),	
		  DEC(9,6),	
		  DEC(16,2),	
		  DEC(16,2),	
		  varchar(50),
		  varchar(50);  

{returning CHAR(3),
		  varchar(50),
		  char(3),
		  varchar(50),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  varchar(50);}

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

CREATE TEMP TABLE tmp_rea_saldo(
		cod_coasegur	CHAR(3)		NOT NULL,
		no_poliza       CHAR(10)	NOT NULL,
		cod_ramo        CHAR(3)     NOT NULL,
		saldo_tot       DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo_coasegur  DEC(16,2)	DEFAULT 0 NOT NULL,
		porc_partic_cont DEC(9,6)	DEFAULT 0 NOT NULL,
		porc_partic_reas DEC(9,6)	DEFAULT 0 NOT NULL,
		comision        DEC(16,2)	DEFAULT 0 NOT NULL,
		impuesto        DEC(16,2)	DEFAULT 0 NOT NULL,
		seleccionado    SMALLINT    DEFAULT 1 NOT NULL,
		PRIMARY KEY (cod_coasegur, no_poliza)
		) WITH NO LOG;

SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_pro494.trc";
--TRACE ON ;

LET _descr_cia = sp_sis01(a_compania);
LET _no_poliza ="";

SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 1;	-- Sin Coaseguro

SELECT cod_tipoprod
  INTO _cod_tipoprod2
  FROM emitipro
 WHERE tipo_produccion = 2;	-- Coaseguro Mayoritario

let _fecha = sp_sis36(a_periodo);

foreach
 SELECT no_documento
   INTO	_doc_poliza
   FROM emipoliza
--  where no_documento[1,2] = '03' 

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
	    LET _no_poliza = "";
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

	let v_saldo = v_saldo_b  / (1 + (_porc_impuesto / 100));  --convertir a prima neta, por la inclusion ddel impuesto en los registros de polizas.

    select cod_tipoprod,
	       cod_ramo
      into _cod_tipoprod,
           _cod_ramo   
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

							
			  			if trim(_cod_coasegur) <> '089' then
			  				continue foreach;
			  			end if


                        let _saldo_reaseg = (_saldo_contrato * _porc_partic_reas / 100);
						let _saldo_reaseg =  _saldo_reaseg - ((_saldo_reaseg * _porc_comision / 100) + (_saldo_reaseg * _porc_impuesto / 100));

			  			if _saldo_reaseg = 0 then
			  				continue foreach;
			  			end if
					
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
							    cod_ramo,    
								saldo_tot,     
								saldo_coasegur,
								porc_partic_cont,
								porc_partic_reas,
								comision, 
								impuesto, 
								seleccionado  
								)
								values(
								_cod_coasegur,
								_no_poliza,
								_cod_ramo,
								v_saldo,
								_saldo_reaseg,
								_porc_partic_prima,
								_porc_partic_reas,
								_saldo_contrato * _porc_partic_reas / 100 * _porc_comision / 100,
								_saldo_contrato * _porc_partic_reas / 100 * _porc_impuesto / 100,
								1 
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

			  			if trim(_cod_coasegur) <> '089' then
			  				continue foreach;
			  			end if


	                    let _saldo_reaseg = (_saldo_contrato * _porc_cont_partic / 100);
						let _saldo_reaseg =  _saldo_reaseg - ((_saldo_reaseg * _porc_comision / 100) + (_saldo_reaseg * _porc_impuesto / 100));

						if _saldo_reaseg = 0 then
							continue foreach;
						end if

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
							    cod_ramo, 
								saldo_tot,     
								saldo_coasegur,
								porc_partic_cont,
								porc_partic_reas,
								comision, 
								impuesto, 
								seleccionado  
								)
								values(
								_cod_coasegur,
								_no_poliza,
								_cod_ramo,
								v_saldo,
								_saldo_reaseg,
								_porc_partic_prima,
								_porc_cont_partic,
								_saldo_contrato * _porc_cont_partic / 100 * _porc_comision / 100,
								_saldo_contrato * _porc_cont_partic / 100 * _porc_impuesto / 100,
								1 
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

			  			if trim(_cod_coasegur) <> '089' then
			  				continue foreach;
			  			end if


                    let _saldo_reaseg = (_saldo_contrato * _porc_cont_partic / 100);
					let _saldo_reaseg =  _saldo_reaseg - ((_saldo_reaseg * _porc_comision / 100) + (_saldo_reaseg * _porc_impuesto / 100));

 					if _saldo_reaseg = 0 then
 						continue foreach;
 					end if

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
						    cod_ramo,    
							saldo_tot,     
							saldo_coasegur,
							porc_partic_cont,
							porc_partic_reas,
							comision, 
							impuesto, 
							seleccionado  
							)
							values(
							_cod_coasegur,
							_no_poliza,
							_cod_ramo,
							v_saldo,
							_saldo_reaseg,
							_porc_partic_prima,
							_porc_cont_partic,
							_saldo_contrato * _porc_cont_partic / 100 * _porc_comision / 100,
							_saldo_contrato * _porc_cont_partic / 100 * _porc_impuesto / 100,
							1 
							);
					
					END
					
				end foreach

			end if


  		end if

	end foreach


end foreach

{foreach with hold
	select cod_coasegur,
		   cod_ramo,
	       SUM(saldo_tot),	
		   SUM(saldo_coasegur),
		   SUM(comision),
		   SUM(impuesto)
	  into _cod_coasegur,
	       _cod_ramo,
	       v_saldo,
		   _saldo_reaseg,
		   _comision,
		   _impuesto
	  from tmp_rea_saldo
	 where seleccionado = 1
  group by 1, 2
   
    select nombre
	  into _nombre_reas
	  from emicoase
	 where cod_coasegur = _cod_coasegur;

    select nombre
	  into _nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;

	return _cod_coasegur,
	       _nombre_reas,
		   _cod_ramo,
		   _nombre,
		   v_saldo,
		   _comision,
		   _impuesto,
		   _saldo_reaseg,
		   _descr_cia WITH RESUME;


end foreach}

foreach with hold
	select cod_coasegur,	
		   no_poliza, 
		   cod_ramo,    
		   saldo_tot,     
		   saldo_coasegur,
		   porc_partic_cont,
		   porc_partic_reas,
		   comision, 
	       impuesto
		into _cod_coasegur,
			 _no_poliza,
			 _cod_ramo,
			 v_saldo,
			 _saldo_reaseg,
			 _porc_partic_prima,
			 _porc_cont_partic,
 			_comision,
		   	_impuesto
	  from tmp_rea_saldo
	 where seleccionado = 1

   
    select nombre
	  into _nombre_reas
	  from emicoase
	 where cod_coasegur = _cod_coasegur;

    select nombre
	  into _nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;

	return _cod_coasegur,
		   _no_poliza,
		   _cod_ramo,
		   v_saldo,
		   _saldo_reaseg,
		   _porc_partic_prima,
		   _porc_cont_partic,
		   _comision,
		   _impuesto,
		   _nombre_reas,
		   _nombre WITH RESUME;

end foreach


DROP TABLE tmp_rea_saldo;

end procedure