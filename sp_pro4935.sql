-- Procedimiento que carga los Saldos de las polizas por reaseguro
-- 03/09/2010 - Autor: Henry Giron.
-- Modificado - Autor: Henry: Cambio del sp_sis21 a utilizar poliza a la fecha, por orden de Sr. Naranjo F.15/10/2010
-- executable sp_pro4935("001","001","2010-06")
-- Retencion luego se calcula el 50% de la prima. solo aseguradora ancon "036"

Drop procedure sp_pro4935;

create procedure "informix".sp_pro4935(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7))
returning CHAR(3),
		  varchar(50),
		  char(3),
		  varchar(50),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  varchar(50),
		  DEC(16,2),
		  DEC(16,2);

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
define _rcod_coasegur      char(3);
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
define _prima_ret      	  DEC(16,2);
define _continuar         smallint;
define _bouquet           smallint;
define _p_50_CP           decimal(5,2); -- Porcentaje 50% CP MAPFRE
define v_saldo_real		  decimal(16,2);
define _retencion         DEC(16,2);
define _saldo_com         DEC(16,2);
define _saldo_imp         DEC(16,2);
define _seleccionado      smallint;

define _error			  integer;

CREATE TEMP TABLE tmp_rea_saldo(
		cod_coasegur	 CHAR(3)	NOT NULL,
		no_poliza        CHAR(10)	NOT NULL,
		tipo_contrato    smallint   NOT NULL,
		cod_ramo         CHAR(3)    NOT NULL,
		saldo_tot        DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo_coasegur   DEC(16,2)	DEFAULT 0 NOT NULL,
		porc_partic_cont DEC(9,6)	DEFAULT 0 NOT NULL,
		porc_partic_reas DEC(9,6)	DEFAULT 0 NOT NULL,
		comision         DEC(16,2)	DEFAULT 0 NOT NULL,
		impuesto         DEC(16,2)	DEFAULT 0 NOT NULL,
		retencion        DEC(16,2)	DEFAULT 0 NOT NULL,
		seleccionado     SMALLINT   DEFAULT 1 NOT NULL,
		PRIMARY KEY (cod_coasegur, no_poliza, tipo_contrato)
		) WITH NO LOG;

SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_pro4935.trc";
--TRACE ON ;

LET _descr_cia = sp_sis01(a_compania);
LET _p_50_CP = 50/100 ;
LET v_saldo_real = 0.00;
LET _saldo_com = 0.00;
LET _saldo_imp = 0.00;
LET _retencion = 0;

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
--  where no_documento in ("0193-0459-01") --("0109-00700-01")  --'0308-00023-03','0307-00019-03','0310-00152-01')
--  where no_documento[1,2] = '03'
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

	CALL sp_cob223(a_compania,a_sucursal, _doc_poliza, a_periodo, _fecha)

	RETURNING v_saldo, v_saldo_b;

	if v_saldo <> 0 then
	else
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

	let v_saldo = v_saldo_b  / (1 + (_porc_impuesto / 100));  -- Convertir a prima neta, por la inclusion del impuesto en los registros de polizas.

    select cod_tipoprod,
	       cod_ramo
      into _cod_tipoprod,
           _cod_ramo
      from emipomae
     where no_poliza = _no_poliza;

{    if _cod_tipoprod <> _cod_tipoprod1 And _cod_tipoprod <> _cod_tipoprod2 Then
		continue foreach;
	end if }

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
		   let _rcod_coasegur = "063";	--MAPFRE
		   let _porc_partic_reas = 100;
		   let _saldo_contrato = 0;
		   let _saldo_reaseg = 0;
		   let _porc_impuesto = 2 ;
		   let _retencion = 0;

		   select porc_comision
			 into _porc_comision
			 from reacoase
			where cod_contrato   = '00595' 	                    -- Contrato de 50%RET_MAPFRE, no cambia a partir del 2008. Sr. Omar Wong,596,592
			  and cod_cober_reas = _cod_cober_reas ;

		   let _saldo_contrato = v_saldo * _porc_partic_prima / 100;
		   let _retencion      = v_saldo * _porc_partic_prima / 100;
		   let _saldo_reaseg   = _saldo_contrato - ((_saldo_contrato * _porc_comision / 100) + (_saldo_contrato * _porc_impuesto / 100));


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
					tipo_contrato,
				    cod_ramo,
					saldo_tot,
					saldo_coasegur,
					porc_partic_cont,
					porc_partic_reas,
					comision,
					impuesto,
					retencion,
					seleccionado
					)
					values(
					_rcod_coasegur,
					_no_poliza,
					_tipo_contrato,
					_cod_ramo,
					v_saldo,
					_saldo_reaseg,
					_porc_partic_prima,
					_porc_partic_reas,
					_saldo_contrato * _porc_partic_reas / 100 * _porc_comision / 100,	   -- _saldo_contrato * _porc_partic_reas / 100 ,
					_saldo_contrato * _porc_partic_reas / 100 * _porc_impuesto / 100,	   -- _saldo_contrato * _porc_partic_reas / 100 ,					
					_retencion,
					1
					);

			END
		   --continue foreach;
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

            if _bouquet <> 1 then
				continue foreach;
			end if

			let _saldo_contrato = v_saldo * _porc_partic_prima / 100;

            let _saldo_reaseg = 0.00;
			let _retencion = 0;
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
								tipo_contrato,
							    cod_ramo,
								saldo_tot,
								saldo_coasegur,
								porc_partic_cont,
								porc_partic_reas,
								comision,
								impuesto,
								retencion,
								seleccionado
								)
								values(
								_cod_coasegur,
								_no_poliza,
								_tipo_contrato,
								_cod_ramo,
								v_saldo,
								_saldo_reaseg,
								_porc_partic_prima,
								_porc_partic_reas,
								_saldo_contrato * _porc_partic_reas / 100 * _porc_comision / 100,
								_saldo_contrato * _porc_partic_reas / 100 * _porc_impuesto / 100,
								_retencion,
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
								tipo_contrato,
							    cod_ramo,
								saldo_tot,
								saldo_coasegur,
								porc_partic_cont,
								porc_partic_reas,
								comision,
								impuesto,
					            retencion,
								seleccionado
								)
								values(
								_cod_coasegur,
								_no_poliza,
								_tipo_contrato,
								_cod_ramo,
								v_saldo,
								_saldo_reaseg,
								_porc_partic_prima,
								_porc_cont_partic,
								_saldo_contrato * _porc_cont_partic / 100 * _porc_comision / 100,
								_saldo_contrato * _porc_cont_partic / 100 * _porc_impuesto / 100,
								_retencion,
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
							tipo_contrato,
						    cod_ramo,
							saldo_tot,
							saldo_coasegur,
							porc_partic_cont,
							porc_partic_reas,
							comision,
							impuesto,
							retencion,
							seleccionado
							)
							values(
							_cod_coasegur,
							_no_poliza,
							_tipo_contrato,
							_cod_ramo,
							v_saldo,
							_saldo_reaseg,
							_porc_partic_prima,
							_porc_cont_partic,
							_saldo_contrato * _porc_cont_partic / 100 * _porc_comision / 100,
							_saldo_contrato * _porc_cont_partic / 100 * _porc_impuesto / 100,
							_retencion,
							1
							);

					END

				end foreach

			end if


  		end if

	end foreach


end foreach

--TRACE OFF ;
{returning CHAR(3), CHAR(10),smallint,CHAR(3),DEC(16,2),DEC(16,2),DEC(9,6),DEC(9,6),DEC(16,2),DEC(16,2),DEC(16,2),SMALLINT;}
{foreach with hold
	select cod_coasegur,	 
		   no_poliza,        
		   tipo_contrato,    
		   cod_ramo,         
		   saldo_tot,        
		   saldo_coasegur,   
		   porc_partic_cont, 
           porc_partic_reas, 
	       comision,         
		   impuesto,         
		   retencion,        
		   seleccionado     		   
	  into _cod_coasegur,
		   _no_poliza,
		   _tipo_contrato,
		   _cod_ramo,
		   _saldo_contrato,
		   _saldo_reaseg,
		   _porc_partic_prima,
		   _porc_cont_partic,
		   _saldo_com,	       
           _saldo_imp,	       
	       _retencion,
		   _seleccionado   	       
	  from tmp_rea_saldo
	 where seleccionado = 1
	   and tipo_contrato = 1	-- RETENCION 50% CP
	   order by 1,2

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
		   _tipo_contrato,
		   _cod_ramo,
	       _saldo_contrato,
		   _saldo_reaseg,
		   _porc_partic_prima,
		   _porc_cont_partic,
		   _saldo_com,	       
		   _saldo_imp,	       
		   _retencion,
		   _seleccionado WITH RESUME;

end foreach	}

foreach with hold
	select cod_coasegur,
		   cod_ramo,
           SUM(saldo_tot),
	       SUM(saldo_coasegur),
		   SUM(retencion),
		   SUM(saldo_coasegur),
		   SUM(comision),
		   SUM(impuesto)
	  into _cod_coasegur,
	       _cod_ramo,
	       v_saldo_real,
	       v_saldo,
		   _retencion,
		   _saldo_reaseg,
		   _comision,
		   _impuesto
	  from tmp_rea_saldo
	 where seleccionado = 1
	   and tipo_contrato = 1	-- RETENCION 50% CP
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
		   _retencion*_p_50_CP,
		   _comision*_p_50_CP,
		   _impuesto*_p_50_CP,
		   _saldo_reaseg*_p_50_CP,
		   _descr_cia,
		   v_saldo_real,
		   _retencion WITH RESUME;

end foreach	

DROP TABLE tmp_rea_saldo;

end procedure				 