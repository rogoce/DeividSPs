-----------------------------------------------------------
--   TOTALES DE PRODUCCION POR CONTRATO DE REASEGURO     --
---  Realizado por: HERHY GIRON  01/10/2009
---  Ref. Power Builder - d_sp_pro40_crit      d_prod_sp_pr850_dw1
---  Modificado por Armando Moreno 19/01/2002;  la parte de los tipo de contratos
---  Modificado por Román Gordón 11/10/2013 ; Proceso de Devolución de Prima
--execute PROCEDURE sp_pr126b('001','001','2016-10','2016-10',"*","*","*","*","001,003,004,005,007,008,010,011,012,013,014,015,017,022;","*")
-----------------------------------------------------------
drop procedure sp_pr126bb;
create procedure sp_pr126bb(
a_compania		char(3),
a_agencia		char(3),
a_periodo1		char(7),
a_periodo2		char(7),
a_codsucursal	char(255) default "*",
a_codgrupo		char(255) default "*",
a_codagente		char(255) default "*",
a_codusuario	char(255) default "*",
a_codramo		char(255) default "*",
a_reaseguro		char(255) default "*")
returning	char(3),
			char(3),
			char(5),
			char(3),
			decimal(16,2),
			decimal(16,2),
			decimal(16,2),
			decimal(16,2),
			decimal(16,2),
			decimal(16,2),
			decimal(16,2),
			decimal(16,2),
			char(50),
			char(50),
			char(50),
			varchar(255);
BEGIN 

DEFINE _filtros				varchar(255);
DEFINE v_filtros			varchar(255);
DEFINE v_desc_cobertura		varchar(100);
DEFINE v_desc_contrato		CHAR(50);
DEFINE v_desc_ramo			CHAR(50);
DEFINE v_descr_cia			CHAR(50);
define _cuenta				char(25);
DEFINE v_nopoliza			CHAR(10);
DEFINE v_cod_contrato		CHAR(5);
DEFINE v_noendoso			CHAR(5);
DEFINE v_cobertura			CHAR(3);
DEFINE v_cod_ramo			CHAR(3);
DEFINE v_clase				CHAR(3);
DEFINE _tipo				smallint;
DEFINE v_prima				DEC(16,2);
DEFINE v_prima1				DEC(16,2);
DEFINE v_tipo_contrato		SMALLINT;
define _porc_impuesto		DEC(16,2);
define _porc_comision		DEC(16,2);
define _serie				smallint;
define _impuesto						DEC(16,2);
define _comision						DEC(16,2);
define _por_pagar						DEC(16,2);
define _siniestro_cp		DEC(16,2);
define _siniestro			DEC(16,2);

DEFINE _cod_traspaso	 				CHAR(5);
define _traspaso		 				smallint;
define _tiene_comis_rea				 	smallint;
define _cantidad						smallint;
define _tipo_cont                      	smallint;

define _porc_cont_partic 				DEC(5,2);
DEFINE _porc_comis_ase   				DEC(5,2);
define _monto_reas					 	DEC(16,2);
define v_prima_suscrita				 	DEC(16,2);
define _cod_coasegur	 				char(3);
define _nombre_coas					 	char(50);
define _nombre_cob					 	char(50);
define _nombre_con					 	char(50);
define _cod_subramo					 	char(3);
define _cod_origen						char(3);
define _prima_tot_ret                  	dec(16,2);
define _prima_sus_tot					dec(16,2);
define _prima_tot_ret_sum              	dec(16,2);
define _prima_tot_sus_sum              	dec(16,2);
define _no_cambio						smallint;
define _no_unidad						char(5);
define v_prima_cobrada           		dec(16,2);
define _porc_partic_coas				dec(7,4);
define _fecha						    date;
define _porc_partic_prima				dec(9,6);
define _p_sus_tot						DEC(16,2);
define _p_sus_tot_sum					DEC(16,2);
DEFINE _ano                           	SMALLINT;
define _tot_comision 					dec(16,2);
define _tot_impuesto 					dec(16,2);
define _tot_prima_neta					dec(16,2);
DEFINE _tiene_comision					SMALLINT;
define _p_c_partic					 	dec(5,2);
define _p_c_partic_hay				 	smallint;
define v_existe                       	smallint;

define nivel,_nivel                   	smallint;
define _xnivel                        	char(3);
define v_prima70, v_prima30           	dec(16,2);
define _comision70, _comision30       	dec(16,2);
define _impuesto70, _impuesto30       	dec(16,2);
define _por_pagar70, _por_pagar30     	dec(16,2);
define _siniestro70, _siniestro30     	dec(16,2);

define _porc_impuesto4				 	dec(7,4);
define _porc_comision4				 	dec(7,4);
define _cod_cober_r						char(3);
DEFINE _anio_reas						Char(9);
DEFINE _trim_reas,_cnt					Smallint;
DEFINE _borderaux						CHAR(2);
define _ramo_sis					    Smallint;
define _cod_contrato					char(5);
define _prima_devuelta					dec(16,2);
define _error							integer;
define _error_desc						char(50);

		SET ISOLATION TO DIRTY READ;

		LET _borderaux = "02";	    -- Run Off -- Prima suscrita
		let _porc_comis_ase = 0;
		select tipo into _tipo from reacontr where cod_contrato = _borderaux;
		CALL sp_rea002(a_periodo2,_tipo) RETURNING _anio_reas,_trim_reas; 

		--DELETE FROM reacoprs where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;   -- Elimina borderaux del trimestre
		--DELETE FROM temphg1 where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;    -- Elimina borderaux datos
		DELETE FROM reacoest where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;   -- Elimina borderaux del trimestre
		DELETE FROM temphg where anio = _anio_reas and trimestre = _trim_reas and borderaux = _borderaux;    -- Elimina borderaux datos

		
	  	if a_periodo2 >= '2013-07' then
			--Proceso de Devolución de Prima		
			call sp_pr860c1(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
						a_codagente,a_codusuario,a_codramo,a_reaseguro,'*',_borderaux)
			returning _error,_error_desc;
			
			if _error = 1 then
				drop table temp_produccion;
				RETURN	"",
						"",
						"",
						"",
						0.00, 
						0.00, 
						0.00, 
						0.00, 
						0.00, 
						0.00, 
						0.00, 
						0.00, 
						"No Existe Distribucion de Reaseguro",
						"",
						v_descr_cia,'';
			end if
			
			select * 
			  from temp_produccion
			  into temp temp_devpri;
			
			drop table temp_produccion;
		end if 
		
		LET _ano = a_periodo1[1,4];

		LET v_descr_cia = sp_sis01(a_compania);

		CALL sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,
		               a_codagente,a_codusuario,a_codramo,a_reaseguro) RETURNING _filtros;

		LET v_filtros = sp_rec708(
		 a_compania,
		 a_agencia,
		 a_periodo1,
		 a_periodo2,
		 a_codsucursal,
		 '*', 
		 a_codramo, --'*'
		 '*', 
		 '*', 
		 '*', 
		 '*',
		 '*'    ---a_contrato
		);

	 	update tmp_sinis
		   set seleccionado = 0
		 where doc_poliza in(select no_documento from reaexpol where activo = 1);  --Tabla para excluir polizas

CREATE TEMP TABLE temp_produccion
(cod_ramo         CHAR(3),
cod_subramo		 char(3),
cod_origen		 char(3),
cod_contrato     CHAR(5),
desc_contrato    CHAR(50),
cod_cobertura    CHAR(3),
prima            DEC(16,2),
tipo             smallint default 0,
comision         DEC(16,2),
impuesto         DEC(16,2),
por_pagar        DEC(16,2),
desc_cob         CHAR(100),
serie 			 SMALLINT,
seleccionado     SMALLINT DEFAULT 1,
porc_comision 	 DECIMAL(16,2), 
porc_impuesto 	 DECIMAL(16,2), 
porc_cont_partic DECIMAL(16,2), 
cod_coasegur 	 CHAR(3),
tiene_comision   Smallint,
PRIMARY KEY(cod_ramo, cod_subramo, cod_origen, cod_contrato, cod_cobertura, desc_cob)) WITH NO LOG;

CREATE INDEX idx1_temp_produccion ON temp_produccion(cod_ramo);
CREATE INDEX idx2_temp_produccion ON temp_produccion(cod_subramo);
CREATE INDEX idx3_temp_produccion ON temp_produccion(cod_origen);
CREATE INDEX idx4_temp_produccion ON temp_produccion(cod_contrato);
CREATE INDEX idx5_temp_produccion ON temp_produccion(cod_cobertura);
CREATE INDEX idx6_temp_produccion ON temp_produccion(desc_cob);
CREATE INDEX idx7_temp_produccion ON temp_produccion(cod_coasegur);
CREATE INDEX idx8_temp_produccion ON temp_produccion(serie);

LET v_prima        	 = 0;
LET v_descr_cia    	 = sp_sis01(a_compania);
let _tipo_cont     	 = 0;
let v_desc_cobertura = "";

--set debug file to "sp_pr126.trc";
--trace on;

FOREACH WITH HOLD

 SELECT z.no_poliza,																	 
 		z.no_endoso																		 
   INTO v_nopoliza,
   		v_noendoso
   FROM temp_det z
  WHERE z.seleccionado = 1
   -- and no_poliza in ('171365','363310')
  group by 1, 2

 select cod_ramo,
        cod_subramo,
	    cod_origen
   into v_cod_ramo,
        _cod_subramo,
        _cod_origen
   from emipomae
  where no_poliza = v_nopoliza;

 FOREACH
    	SELECT cod_cober_reas,
    		   cod_contrato,
	    	   prima,
			   no_unidad
          INTO v_cobertura,
      	   	   v_cod_contrato,
      	   	   v_prima1,
			   _no_unidad
          FROM emifacon
         WHERE no_poliza = v_nopoliza
           AND no_endoso = v_noendoso
           AND prima <> 0

		select traspaso
		  into _traspaso
		  from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		Select cod_traspaso
	      Into _cod_traspaso
		  From reacomae
		 Where cod_contrato = v_cod_contrato;

		if _traspaso = 1 then
			let v_cod_contrato = _cod_traspaso;
		end if

        select tipo_contrato,
		       serie
          into v_tipo_contrato,
		       _serie
          from reacomae
         where cod_contrato = v_cod_contrato;

		if _serie < 2002 then
			foreach
				select distinct r.cod_contrato
				  into v_cod_contrato
				  from reacoase r, reacomae t
				 where r.cod_contrato = t.cod_contrato
				   and t.serie = 2007
				   and t.tipo_contrato in (v_tipo_contrato)
				   and r.cod_cober_reas = v_cobertura
				exit foreach;
			end foreach

			select cod_traspaso
			  into _cod_traspaso
			  from reacomae
			 where cod_contrato = v_cod_contrato;

			if _traspaso = 1 then
				let v_cod_contrato = _cod_traspaso;
			end if

			select tipo_contrato,
				   serie
			  into v_tipo_contrato,
				   _serie
			  from reacomae
			 where cod_contrato = v_cod_contrato;
		end if

		let _tipo_cont = 0;			  --otros contratos

        IF v_tipo_contrato = 3 THEN   --facultativos

			let _tipo_cont = 2;
					 
        elif v_tipo_contrato = 1 then --retencion

			let _tipo_cont = 1;

        end if

        let v_prima = v_prima1;

		let _cod_subramo = "001";

        SELECT nombre
          INTO v_desc_contrato
          FROM reacomae
         WHERE cod_contrato = v_cod_contrato;

		let v_desc_contrato = trim(v_desc_contrato) || " (" || v_cod_contrato || ")" || "  A: " || _serie;

		Select porc_impuesto,
		       porc_comision,
			   tiene_comision
		  Into _porc_impuesto,
			   _porc_comision,
			   _tiene_comis_rea
		  From reacocob
		 Where cod_contrato   = v_cod_contrato
		   And cod_cober_reas = v_cobertura;

		 let _cuenta = sp_sis15("PPRXP", "05", _cod_origen, v_cod_ramo, _cod_subramo);

	     SELECT nombre
	       INTO v_desc_ramo
	       FROM prdramo
	      WHERE cod_ramo = v_cod_ramo;

	     SELECT nombre
	       INTO _nombre_cob
	       FROM reacobre
	      WHERE cod_cober_reas = v_cobertura;

		 select count(*)
		   into _cantidad
		   from reacoase
		  where cod_contrato   = v_cod_contrato
		    and cod_cober_reas = v_cobertura;

		 if _tipo_cont = 0 then

		  if _cantidad = 0 then

			  let v_desc_contrato  = "******* NO EXISTE REGISTRO DE COMPANIAS " || v_cod_contrato;

			  select count(*)
			    into _cantidad
			    from temp_produccion
			   where cod_ramo      = v_cod_ramo
			     and cod_subramo   = _cod_subramo
			     and cod_origen    = _cod_origen
			     and cod_contrato  = v_cod_contrato
			     and cod_cobertura = v_cobertura
			     and desc_cob      = _nombre_cob;

			 	if _cantidad = 0 then

			 		INSERT INTO temp_produccion
			             VALUES(v_cod_ramo,
			 			        _cod_subramo,
			 					_cod_origen,
			                    v_cod_contrato,
			 					v_desc_contrato,
			                    v_cobertura,
			                    v_prima,
			                    _tipo_cont,
			                    0, 
			                    0, 
			                    0,
			                    _nombre_cob,
								_serie,
			                    1,
			                    0,
			                    0,
			                    0,
			                    '999',
			                    _tiene_comis_rea);
			 	end if
		  else

		 	 	foreach

		 			select porc_cont_partic,
		 				   porc_comision,
		 				   cod_coasegur
		 			  into _porc_cont_partic,
		 			   	   _porc_comis_ase,
		 				   _cod_coasegur
		 			  from reacoase
		 		     where cod_contrato   = v_cod_contrato
		 		       and cod_cober_reas = v_cobertura

		 				
		 			if _tipo_cont = 1 then
		 				let _cod_coasegur = '036'; --ancon
		 			end if

		 			select nombre
		 			  into _nombre_coas
		 			  from emicoase
		 			 where cod_coasegur = _cod_coasegur;

		 			-- La comision se calcula por reasegurador

		 			if _tiene_comis_rea = 2 then 
		 				let _porc_comision = _porc_comis_ase;
		 			end if

		 			let v_desc_cobertura = "";
		 			let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
		 			let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;

		 			let _monto_reas = v_prima     * _porc_cont_partic / 100;
		 			let _impuesto   = _monto_reas * _porc_impuesto / 100;
		 			let _comision   = _monto_reas * _porc_comision / 100;
		 			let _por_pagar  = _monto_reas - _impuesto - _comision;

		 			select count(*)
		 			  into _cantidad
		 			  from temp_produccion
		 			 where cod_ramo      = v_cod_ramo
		 			   and cod_subramo   = _cod_subramo
		 			   and cod_origen    = _cod_origen
		               and cod_contrato  = v_cod_contrato
		               and cod_cobertura = v_cobertura
		               and desc_cob      = v_desc_cobertura;

		 			if _cantidad = 0 then

		 				INSERT INTO temp_produccion
		 	                  VALUES(v_cod_ramo,
		 					         _cod_subramo,
		 							 _cod_origen,
		 	                         v_cod_contrato,
		 							 v_desc_contrato,
		 	                         v_cobertura,
		 	                         _monto_reas,
		 	                         _tipo_cont,
		 	                         _comision, 
		 	                         _impuesto, 
		 	                         _por_pagar,
		 	                         v_desc_cobertura,
									 _serie,
			                    	 1 ,
			                    	 _porc_comision,
		 	                         _porc_impuesto,
		 	                         _porc_cont_partic,
		 	                         _cod_coasegur,
		 	                         _tiene_comis_rea);
		 			else
		 			   
		                UPDATE temp_produccion
		                   SET prima       = prima + _monto_reas,
		                   	   comision    = comision  + _comision,
		 					   impuesto    = impuesto  + _impuesto,
		 					   por_pagar   = por_pagar + _por_pagar
		                 WHERE cod_ramo     = v_cod_ramo
		 				   and cod_subramo   = _cod_subramo
		 				   and cod_origen    = _cod_origen
		                   and cod_contrato  = v_cod_contrato
		                   and cod_cobertura = v_cobertura
		                   and desc_cob      = v_desc_cobertura;

		 			end if
		 			--let v_prima1 = 0;
		 		end foreach

		  end if

		 elif _tipo_cont = 1 then	  --Retencion

	 			let _cod_coasegur = '036'; --ancon

		 		select nombre
		 		  into _nombre_coas
		 		  from emicoase
		 		 where cod_coasegur = _cod_coasegur;

		 		-- La comision se calcula por reasegurador

		 		if _tiene_comis_rea = 2 then 
		 			let _porc_comision = _porc_comis_ase;
		 		end if

			    let _porc_impuesto = 0;
				let _porc_comision = 0;
		 		let v_desc_cobertura = "";
		 		let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
		 		let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comision;
				let _porc_cont_partic = 100;
		 		let _monto_reas = v_prima;
		 		let _impuesto   = _monto_reas * _porc_impuesto / 100;
		 		let _comision   = _monto_reas * _porc_comision / 100;
		 		let _por_pagar  = _monto_reas - _impuesto - _comision;

		 		select count(*)
		 		  into _cantidad
		 		  from temp_produccion
		 		 where cod_ramo      = v_cod_ramo
		 		   and cod_subramo   = _cod_subramo
		 		   and cod_origen    = _cod_origen
		           and cod_contrato  = v_cod_contrato
		           and cod_cobertura = v_cobertura
		           and desc_cob      = v_desc_cobertura;

		 		if _cantidad = 0 then

		 			INSERT INTO temp_produccion
		                   VALUES(v_cod_ramo,
		 				         _cod_subramo,
		 						 _cod_origen,
		                          v_cod_contrato,
		 						  v_desc_contrato,
		                          v_cobertura,
		                          _monto_reas,
		                          _tipo_cont,
		                          _comision, 
		                          _impuesto, 
		                          _por_pagar,
		                          v_desc_cobertura,
								  _serie,
			                      1,
			                      _porc_comision,
		 	                      _porc_impuesto,
		 	                      _porc_cont_partic,
		 	                      _cod_coasegur,
		 	                      _tiene_comis_rea);
		 		else
		 		   
		               UPDATE temp_produccion
		                  SET prima         = prima     + _monto_reas,
		                  	  comision      = comision  + _comision,
		 				      impuesto      = impuesto  + _impuesto,
		 				      por_pagar     = por_pagar + _por_pagar
		                WHERE cod_ramo      = v_cod_ramo
		 			  	  and cod_subramo   = _cod_subramo
			 			  and cod_origen    = _cod_origen
		                  and cod_contrato  = v_cod_contrato
		                  and cod_cobertura = v_cobertura
		                  and desc_cob      = v_desc_cobertura;

		 		end if

		 elif _tipo_cont = 2 then  --facultativos

		  select count(*)
		    into _cantidad
		    from emifafac
		   where no_poliza      = v_nopoliza
		     and no_endoso      = v_noendoso
	         and cod_contrato   = v_cod_contrato
		     and cod_cober_reas = v_cobertura
		     and no_unidad      = _no_unidad ;

			if _cantidad = 0 then

		    	let v_desc_contrato  = "******* NO EXISTE REGISTRO DE COMPANIAS " || v_cod_contrato;

			 	select count(*)
			 	  into _cantidad
			 	  from temp_produccion
			 	 where cod_ramo          = v_cod_ramo
			 	   and cod_subramo       = _cod_subramo
			 	   and cod_origen        = _cod_origen
			       and cod_contrato  = v_cod_contrato
			       and cod_cobertura = v_cobertura
			       and desc_cob      = _nombre_cob;
-- 		           and no_unidad     = _no_unidad ;

			   	if _cantidad = 0 then

			 		INSERT INTO temp_produccion
                  	VALUES(v_cod_ramo,
			 			   _cod_subramo,
			 			   _cod_origen,
			               v_cod_contrato,
			 			   v_desc_contrato,
			               v_cobertura,
			               v_prima,
			               _tipo_cont,
			               0, 
			               0, 
			               0,
			               _nombre_cob,
						   _serie,
			               1,
			               0,
				           0,
				           0,
				           '999',
				           _tiene_comis_rea);
			 	end if

			else
		    	foreach
			 		select porc_partic_reas,
			 			   porc_comis_fac,
			 			   porc_impuesto,
			 			   cod_coasegur
			 		  into _porc_cont_partic,
			 		   	   _porc_comis_ase,
			 			   _porc_impuesto,
			 			   _cod_coasegur
			 		  from emifafac
			 	     where no_poliza      = v_nopoliza
					   and no_endoso      = v_noendoso
			 	       and cod_contrato   = v_cod_contrato
			 	       and cod_cober_reas = v_cobertura
		               and no_unidad     = _no_unidad 
			 			
			 		select nombre
			 		  into _nombre_coas
			 		  from emicoase
			 		 where cod_coasegur = _cod_coasegur;

			 		let v_desc_cobertura = trim(_nombre_cob) || "  " || trim(_cuenta) || "  " || trim(_nombre_coas);
			 		let v_desc_contrato  = trim(v_desc_contrato) || "  I:" || _porc_impuesto || "  C:" || _porc_comis_ase;

			 		let _monto_reas = v_prima     * _porc_cont_partic / 100;
			 		let _impuesto   = _monto_reas * _porc_impuesto / 100;
			 		let _comision   = _monto_reas * _porc_comis_ase / 100;
			 		let _por_pagar  = _monto_reas - _impuesto - _comision;

			 		select count(*)
			 		  into _cantidad
			 		  from temp_produccion
			 		 where cod_ramo      = v_cod_ramo
			 		   and cod_subramo   = _cod_subramo
			 		   and cod_origen    = _cod_origen
			           and cod_contrato  = v_cod_contrato
			           and cod_cobertura = v_cobertura
			           and desc_cob      = v_desc_cobertura;

			 		if _cantidad = 0 then

			 			INSERT INTO temp_produccion
			                  VALUES(v_cod_ramo,
			 				         _cod_subramo,
			 						 _cod_origen,
			                         v_cod_contrato,
			 						 v_desc_contrato,
			                         v_cobertura,
			                         _monto_reas,
			                         _tipo_cont,
			                         _comision, 
			                         _impuesto, 
			                         _por_pagar,
			                         v_desc_cobertura,
									 _serie,
			                    	 1,
									 _porc_comision,
		 	                         _porc_impuesto,
		 	                         _porc_cont_partic,
		 	                         _cod_coasegur,
		 	                         _tiene_comis_rea);
			 		else
						UPDATE temp_produccion
						   SET prima     = prima     + _monto_reas,
				 			      comision  = comision  + _comision,
				 				  impuesto  = impuesto  + _impuesto,
				 				  por_pagar = por_pagar + _por_pagar
			                WHERE cod_ramo  = v_cod_ramo
				 			  and cod_subramo	= _cod_subramo
				 			  and cod_origen    = _cod_origen
			                  and cod_contrato  = v_cod_contrato
			                  and cod_cobertura = v_cobertura
			                  and desc_cob      = v_desc_cobertura;

			 		end if
		        end foreach
			end if
		end if
	END FOREACH

END FOREACH

if a_periodo2 >= '2013-07' then
	FOREACH 
		select cod_ramo,
			   cod_subramo,
			   cod_origen,
			   cod_contrato,
			   desc_contrato,
			   cod_cobertura,
			   prima,
			   tipo,
			   comision,
			   impuesto,
			   por_pagar,
			   desc_cob,
			   porc_comision, 
			   porc_impuesto, 
			   porc_cont_partic, 
			   cod_coasegur,
			   serie,
			   tiene_comision
		  into v_cod_ramo, 
			   _cod_subramo,
			   _cod_origen,
			   v_cod_contrato,
			   v_desc_contrato,
			   v_cobertura,	  
			   _monto_reas,	   
			   _tipo_cont,		
			   _comision, 		 
			   _impuesto, 		  
			   _por_pagar,		   
			   v_desc_cobertura,		
			   _porc_comision,		 
			   _porc_impuesto,		  
			   _porc_cont_partic,		   
			   _cod_coasegur,
			   _serie,
			   _tiene_comis_rea
		  from temp_devpri
		 where seleccionado = 1
		
		let _monto_reas = _monto_reas * -1;
		--let _tipo_cont	= _tipo_cont * -1;
		let _comision	= _comision * -1;
		let _impuesto	= _impuesto * -1; 		  
		let _por_pagar	= _por_pagar  * -1;
		
		if _comision is null then
			let _comision = 0.00;
		end if
		
		if _impuesto is null then
			let _impuesto = 0.00;
		end if
		
		if _por_pagar is null then
			let _por_pagar = 0.00;
		end if
		
		if _monto_reas is null then
			let _monto_reas = 0.00;
		end if		
		
		select count(*)
		  into _cantidad
		  from temp_produccion
		 where cod_ramo      = v_cod_ramo
		   and cod_subramo   = _cod_subramo
		   and cod_origen    = _cod_origen
		   and cod_contrato  = v_cod_contrato
		   and cod_cobertura = v_cobertura
		   and desc_cob      = v_desc_cobertura
		   and serie         = _serie;

		if _cantidad = 0 then
			insert into temp_produccion
			values(	v_cod_ramo,
					_cod_subramo,
					_cod_origen,
					v_cod_contrato,
					v_desc_contrato,
					v_cobertura,
					_monto_reas,
					_tipo_cont,
					_comision,
					_impuesto,
					_por_pagar,
					v_desc_cobertura,
					_serie,
					1,
					_porc_comision,
					_porc_impuesto,
					_porc_cont_partic,
					_cod_coasegur,
					_tiene_comis_rea);
		else	   
			update temp_produccion
			   set prima         = prima     + _monto_reas,
				   comision      = comision  + _comision,
				   impuesto      = impuesto  + _impuesto,
				   por_pagar     = por_pagar + _por_pagar
			 where cod_ramo      = v_cod_ramo
			   and cod_subramo   = _cod_subramo
			   and cod_origen    = _cod_origen
			   and cod_contrato  = v_cod_contrato
			   and cod_cobertura = v_cobertura
			   and desc_cob      = v_desc_cobertura
			   and serie         = _serie;
		end if
	end foreach
end if 


-- trace on;
-- Carga Temporal contrato por ramos.
FOREACH 
	select cod_ramo,
	       cod_subramo,
		   cod_origen,
	       cod_contrato,
		   desc_contrato,
	       cod_cobertura,
		   prima,
		   tipo,
		   comision,
		   impuesto,
		   por_pagar,
		   desc_cob,
		   porc_comision, 
		   porc_impuesto, 
		   porc_cont_partic, 
		   cod_coasegur
	  into v_cod_ramo, 
	       _cod_subramo,
		   _cod_origen,
	       v_cod_contrato,
		   v_desc_contrato,
	       v_cobertura,	  
	       _monto_reas,	   
	       _tipo_cont,		
	       _comision, 		 
	       _impuesto, 		  
	       _por_pagar,		   
	       v_desc_cobertura,		
	       _porc_comision,		 
	       _porc_impuesto,
	       _porc_cont_partic,
	       _cod_coasegur
	  from temp_produccion
     Where cod_coasegur in("030","051","072","042","034","063",'036','117')

	 
		{-----Proceso de Devolución de Prima
		select prima
		  into _prima_devuelta
		  from temp_devpri
		 where cod_ramo			= v_cod_ramo
		   and cod_subramo		= _cod_subramo
		   and cod_origen		= _cod_origen
		   and cod_contrato		= v_cod_contrato
		   and cod_cobertura	= v_cobertura
		   and desc_cob			= v_desc_cobertura
		   and serie			= _serie1;
		
		if _prima_devuelta is null then
			let _prima_devuelta = 0.00;
		end if
		
		let _monto_reas = _monto_reas - _prima_devuelta;
		
		delete from temp_devpri
		 where cod_ramo			= v_cod_ramo
		   and cod_subramo		= _cod_subramo
		   and cod_origen		= _cod_origen
		   and cod_contrato		= v_cod_contrato
		   and cod_cobertura	= v_cobertura
		   and desc_cob			= v_desc_cobertura
		   and serie			= _serie1;}
	-----------------------------------------------------------------------------------
		
		let _p_c_partic = 0;
		let _p_c_partic_hay = 0;

		select traspaso,tiene_comision
		  into _traspaso,_tiene_comision
	      from reacocob
		 where cod_contrato   = v_cod_contrato
		   and cod_cober_reas = v_cobertura;

		Select tipo_contrato, serie
		  Into v_tipo_contrato,_serie
		  From reacomae
		 Where cod_contrato = v_cod_contrato;

        if _serie > 2007  then 
			CONTINUE FOREACH;
		end if

        if _cod_coasegur not in ("036","030","051","072","042","034","063",'117')  then
			CONTINUE FOREACH;
		end if

		if v_cod_ramo = "001" and v_tipo_contrato <> 7 then 
			CONTINUE FOREACH;
		end if

		{if v_cod_ramo = "006" and v_tipo_contrato <> 5 then 
			CONTINUE FOREACH;
		end if}

		--if v_cod_ramo in ("004",'006',"016","019")  and v_tipo_contrato not in (5) then -- Se eliminaron los ramos personales por instrucción del Depto. de Reaseguro 05/12/2016
		if v_cod_ramo in ('006')  and v_tipo_contrato not in (5) then 
			CONTINUE FOREACH;
		end if

		select ramo_sis
		  into _ramo_sis
		  from prdramo
		 where cod_ramo = v_cod_ramo;

		if _ramo_sis = 99 and v_tipo_contrato not in (7,5) then 
			CONTINUE FOREACH;
		end if

		if v_cod_ramo in ( "008","080")  and v_tipo_contrato not in (7,5) then 
			CONTINUE FOREACH;
		end if

		let _cantidad = 0;

		SELECT facilidad_car
		  INTO _cantidad
          FROM reacomae
         where cod_contrato = v_cod_contrato;

		if _cantidad is null then
		   let _cantidad = 0;
		end if

		if _cantidad <> 0 then 
			CONTINUE FOREACH;
		end if

		LET nivel = 1;

		if _porc_cont_partic = 100 then
			LET nivel = 2;
 		else
			LET nivel = 1;
		end if

		if v_tipo_contrato = 1 then 
			CONTINUE FOREACH;
		end if

	   	if _serie < 2007 then  --Si la serie es menor al 2007 y es alguno de esos ramos se le coloca 2007 por que tuvieron traspaso de cartera. Omar W.
			if v_cod_ramo in('001','003','004','005','007','010','011','012','015','017','022') then
				let _serie = 2007;
			end if
		end if
		INSERT INTO temphg
		VALUES (_cod_coasegur,
		        v_cod_ramo,
		        v_cod_contrato,
				v_desc_contrato,
		        v_cobertura,
		        _monto_reas,
		        _tipo_cont,
		        _comision, 
		        _impuesto, 
		        _por_pagar,
		        v_desc_cobertura,
		        _porc_comision,
		        _porc_impuesto,
		        _porc_cont_partic,
		        _serie,
		        v_tipo_contrato,
		        _tiene_comision,
		        nivel,
		        _anio_reas,
				_trim_reas,
				_borderaux);

END FOREACH

--trace on;
-- Carga reacoprs
-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,014),
--    5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)]
let v_prima1 = 0;

--FOREACH
-- select serie,cod_ramo,cod_contrato,tipo_contrato,sum(prima)
--   into _serie,v_cod_ramo,v_cod_contrato,v_tipo_contrato,v_prima1

  FOREACH
   select serie,cod_ramo,cod_cobertura,cod_contrato,tipo_contrato,porc_comision,porc_impuesto,sum(prima)
     into _serie,v_cod_ramo,v_cobertura,v_cod_contrato,v_tipo_contrato,_porc_comision,_porc_impuesto,v_prima1
	 from temphg
	Where serie <= 2007 and cod_coasegur in("030","051","072","042","034","063",'036') 
	  and anio      = _anio_reas
	  and trimestre = _trim_reas
	  and borderaux = _borderaux 
  group by 1,2,3,4,5,6,7 
  order by 1,2,3,4,5,6,7

			if v_cod_ramo = '001' or v_cod_ramo = '003' then 
				 let v_clase = '001' ;
			else
				 let v_clase = v_cod_ramo;
			end if
			let _siniestro = 0;					

			FOREACH
			    select cod_coasegur,porc_cont_partic
				  into _cod_coasegur,_porc_cont_partic
				  from temphg
		         Where serie <= 2007 and cod_coasegur in ("030","051","072","042","034","063",'036')  
		           and cod_ramo      = v_cod_ramo
		           and porc_comision = _porc_comision
		           and porc_impuesto = _porc_impuesto
		           and cod_cobertura = v_cobertura
		           and cod_contrato  = v_cod_contrato
		           and tipo_contrato = v_tipo_contrato
				   and anio          = _anio_reas
				   and trimestre     = _trim_reas
				   and borderaux     = _borderaux 
		         order by cod_coasegur, porc_cont_partic

					let v_prima = v_prima1 * _porc_cont_partic/100 ;

					if _porc_comision is null or _porc_comision = 0 then
					   LET _porc_comision4 = 0;
					else
					   LET _porc_comision4 = _porc_comision/100;
					end if
					if _porc_impuesto is null or _porc_impuesto = 0 then
					   LET _porc_impuesto4 = 0;
					else
					   LET _porc_impuesto4 = _porc_impuesto/100;
					end if

					LET _comision  = v_prima * _porc_comision4 ;
					LET _impuesto  = v_prima * _porc_impuesto4 ;
				
					LET _por_pagar = v_prima - _comision - _impuesto ;

					if v_tipo_contrato = 7 then
					   let _xnivel    = 'EXC';
  				    else
					   let _xnivel    = 'CP';
				    end if 

					if v_cod_ramo in ("001","003") then
						if v_cod_ramo in ("003") and v_cobertura = "003" then
							let v_clase = "001";
						else
							if v_cod_ramo in ("001") and v_cobertura = "001" then
								let v_clase = "001";
							else
								let v_clase = "003";						
							end if
						end if
					end if
					if v_clase = "001'" then

						LET v_prima70 = v_prima * 0.70 ;
						LET v_prima30 =	v_prima * 0.30 ;

						LET _comision70 = v_prima70 * _porc_comision4 * 1 ;
						LET _comision30 = v_prima30 * _porc_comision4 * 1 ;

						LET _impuesto70 = _impuesto * 0.70 ;
						LET _impuesto30 = _impuesto * 0.30 ;
						LET _por_pagar70 = _por_pagar * 0.70 ;
						LET _por_pagar30 = _por_pagar * 0.30 ;
						LET _siniestro70 = _siniestro * 1 ;
						LET _siniestro30 = _siniestro * 0 ;	 

						LET _por_pagar70 = v_prima70 - _comision70 - _impuesto70 ;
						LET _por_pagar30 = v_prima30 - _comision30 - _impuesto30 ;

						BEGIN
						ON EXCEPTION IN(-239)
							UPDATE reacoest
							   SET prima         = prima      + v_prima70, 
							       comision      = comision   + _comision70, 
							       impuesto      = impuesto   + _impuesto70, 
							       prima_neta    = prima_neta + _por_pagar70, 
							       siniestro     = siniestro  + _siniestro70 
							 WHERE cod_coasegur	 = _cod_coasegur
							   AND cod_contrato  = _serie
							   AND cod_cobertura = _xnivel
							   AND p_partic      = _porc_cont_partic
							   AND cod_ramo      = v_cod_ramo 
							   and cod_clase 	 = '001'
							   and anio      	 = _anio_reas
							   and trimestre 	 = _trim_reas
							   and borderaux 	 = _borderaux;


						END EXCEPTION 	

					    INSERT INTO reacoest(
								cod_coasegur,
								cod_ramo,
								cod_contrato,
								cod_cobertura,
								prima,
								comision,
								impuesto,
								prima_neta,
								siniestro,
								resultado,
								participar,
								p_partic,
								cod_clase,
								anio,
								trimestre,
								borderaux)
						VALUES (_cod_coasegur,
						        v_cod_ramo,
								_serie,
								_xnivel,
								v_prima70, 
								_comision70, 
								_impuesto70, 
								_por_pagar70,
								_siniestro70,
								0,
								v_prima1,
								_porc_cont_partic,
								'001',
								_anio_reas,
								_trim_reas,
								_borderaux);
						END

						BEGIN
						ON EXCEPTION IN(-239)
							UPDATE reacoest
							   SET prima         = prima + v_prima30, 
							       comision      = comision + _comision30, 
							       impuesto      = impuesto + _impuesto30, 
							       prima_neta    = prima_neta + _por_pagar30, 
							       siniestro     = siniestro + _siniestro30 
							 WHERE cod_coasegur	 = _cod_coasegur
							   AND cod_contrato  = _serie
							   AND cod_cobertura = _xnivel
							   AND p_partic      = _porc_cont_partic
							   AND cod_ramo      = v_cod_ramo 
							   AND cod_clase     = '003' 
							   and anio          = _anio_reas
							   and trimestre     = _trim_reas
							   and borderaux     = _borderaux;


						END EXCEPTION 	

					    INSERT INTO reacoest(
								cod_coasegur,
								cod_ramo,
								cod_contrato,
								cod_cobertura,
								prima,
								comision,
								impuesto,
								prima_neta,
								siniestro,
								resultado,
								participar,
								p_partic,
								cod_clase,
								anio,
								trimestre,
								borderaux)
						VALUES (_cod_coasegur,
						        v_cod_ramo,
								_serie,
								_xnivel,
								v_prima30, 
								_comision30, 
								_impuesto30, 
								_por_pagar30,
								_siniestro30,
								0,
								v_prima1,
								_porc_cont_partic,
								'003',
								_anio_reas,
								_trim_reas,
								_borderaux);
						END

					else

					   	BEGIN
						ON EXCEPTION IN(-239)
							UPDATE reacoest
							   SET prima         = prima      + v_prima, 
								   comision      = comision   + _comision, 
								   impuesto      = impuesto   + _impuesto, 
								   prima_neta    = prima_neta + _por_pagar, 
								   siniestro     = siniestro  + _siniestro 
							 WHERE cod_coasegur	 = _cod_coasegur
							   AND cod_contrato  = _serie
							   AND cod_cobertura = _xnivel
							   AND p_partic      = _porc_cont_partic
							   AND cod_ramo      =  v_cod_ramo
							   AND cod_clase     = v_clase 
							   and anio          = _anio_reas
							   and trimestre     = _trim_reas
							   and borderaux     = _borderaux;

						END EXCEPTION 	

					    INSERT INTO reacoest(
								cod_coasegur,
								cod_ramo,
								cod_contrato,
								cod_cobertura,
								prima,
								comision,
								impuesto,
								prima_neta,
								siniestro,
								resultado,
								participar,
								p_partic,
								cod_clase,
								anio,
								trimestre,
								borderaux)
						VALUES (_cod_coasegur,
						        v_cod_ramo,
								_serie,
								_xnivel,
								v_prima, 
								_comision, 
								_impuesto, 
								_por_pagar,
								_siniestro,
								0,
								v_prima1, 
								_porc_cont_partic,
						        v_clase,
								_anio_reas,
								_trim_reas,
								_borderaux);
					  	END
					end if

			END FOREACH
END FOREACH		

foreach

		SELECT r.serie,t.cod_ramo,t.cod_contrato,sum(t.pagado_neto)
		  into _serie,v_cod_ramo,_cod_contrato,_siniestro_cp
		  FROM tmp_sinis t, reacomae r
		 where r.cod_contrato = t.cod_contrato
		   and t.seleccionado = 1
		   and t.tipo_contrato in('5')
	       and r.serie <= 2007
	     group by r.serie,t.cod_ramo,t.cod_contrato

		let _siniestro = 0;

		if _siniestro_cp is null then
		   let _siniestro_cp = 0;
	    end if

		if v_cod_ramo = '016' then
			let _cod_cober_r = '015';
		elif v_cod_ramo = '015' then
			let _cod_cober_r = '016';
		elif v_cod_ramo = '017' then
			let _cod_cober_r = '018';
		elif v_cod_ramo = '019' then
			let _cod_cober_r = '020';
		elif v_cod_ramo = '022' then
			let _cod_cober_r = '028';
		else
			let _cod_cober_r = v_cod_ramo;
		end if

		select traspaso
		  into _traspaso
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_r;

		Select cod_traspaso
	      Into _cod_traspaso
		  From reacomae
		 Where cod_contrato = _cod_contrato;

		if _traspaso = 1 then
			let _cod_contrato = _cod_traspaso;
		end if

        select serie
          into _serie
          from reacomae
         where cod_contrato = _cod_traspaso;
		 
		if v_cod_ramo = '008' then
			select serie
			  into _serie
			  from reacomae
			 where cod_contrato = _cod_contrato;
		end if

	   	if _serie < 2007 then  --Si la serie es menor al 2007 y es alguno de esos ramos se le coloca 2007 por que tuvieron traspaso de cartera. Omar W.
			if v_cod_ramo in('001','003','004','005','007','010','011','012','015','017','022') then
				let _serie = 2007;
				foreach
					select distinct r.cod_contrato
					  into _cod_contrato
					  from reacoase r, reacomae t
	 				 where r.cod_contrato = t.cod_contrato
					   and t.serie = 2007
					   and t.tipo_contrato in('5')
					   and r.cod_cober_reas = _cod_cober_r
					exit foreach;
			   end foreach
			end if
		end if

		select count(*)
		  into _cnt
		  from reacoest
		 where cod_contrato  = _serie
		   AND cod_cobertura = 'CP'
		   AND cod_ramo      = v_cod_ramo
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux;

         if _cnt = 0 then

		   --Para Agregar las cias de reacoase que no estan en reacoest
		   foreach
				select cod_coasegur,porc_cont_partic
				  into _cod_coasegur,_porc_cont_partic
				  from reacoase
				 where cod_contrato   = _cod_contrato
				   and cod_cober_reas = _cod_cober_r

				select count(*)
				  into _cnt
				  from reacoest
				 where cod_contrato  = _serie
				   AND cod_cobertura = 'CP'
				   AND cod_ramo      = v_cod_ramo
				   and cod_coasegur  = _cod_coasegur
				   and anio          = _anio_reas
				   and trimestre     = _trim_reas
				   and borderaux     = _borderaux;

                if _cnt = 0 then

				    INSERT INTO reacoest(
							cod_coasegur,
							cod_ramo,
							cod_contrato,
							cod_cobertura,
							prima,
							comision,
							impuesto,
							prima_neta,
							siniestro,
							resultado,
							participar,
							p_partic,
							cod_clase,
							anio,
							trimestre,
							borderaux)
					VALUES (_cod_coasegur,
					        v_cod_ramo,
							_serie,
							'CP',
							0, 
							0,
							0,
							0,
							_siniestro_cp * _porc_cont_partic /100,
							0,
							0, 
							_porc_cont_partic,
					        v_cod_ramo,
							_anio_reas,
							_trim_reas,
							_borderaux);

				else
					continue foreach;
				end if
		   end foreach
		 else

			UPDATE reacoest
			   SET siniestro     = siniestro + (_siniestro_cp * p_partic /100)
			 WHERE cod_contrato  = _serie
			   AND cod_cobertura = 'CP'
			   AND cod_ramo      =  v_cod_ramo
			   and anio          = _anio_reas
			   and trimestre     = _trim_reas
			   and borderaux     = _borderaux;
		 end if

end foreach

foreach

		SELECT r.serie,t.cod_ramo,t.cod_contrato,sum(t.pagado_neto)
		  into _serie,v_cod_ramo,_cod_contrato,_siniestro_cp
		  FROM tmp_sinis t, reacomae r
		 where r.cod_contrato = t.cod_contrato
		   and t.seleccionado = 1
		   and t.tipo_contrato in('7')
	       and r.serie <= 2007
	     group by r.serie,t.cod_ramo,t.cod_contrato

		let _siniestro = 0;

		if _siniestro_cp is null then
		   let _siniestro_cp = 0;
	    end if

		if v_cod_ramo = '016' then
			let _cod_cober_r = '015';
		elif v_cod_ramo = '015' then
			let _cod_cober_r = '016';
		elif v_cod_ramo = '017' then
			let _cod_cober_r = '018';
		elif v_cod_ramo = '019' then
			let _cod_cober_r = '020';
		elif v_cod_ramo = '022' then
			let _cod_cober_r = '028';
		else
			let _cod_cober_r = v_cod_ramo;
		end if

	   	if _serie < 2007 then  --Si la serie es menor al 2007 y es alguno de esos ramos se le coloca 2007 por que tuvieron traspaso de cartera. Omar W.
			if v_cod_ramo in('001','003','004','005','007','010','011','012','015','017','022')	then
			   let _serie = 2007;
			   foreach
					select distinct r.cod_contrato
					  into _cod_contrato
					  from reacoase r, reacomae t
	 				 where r.cod_contrato = t.cod_contrato
					   and t.serie = 2007
					   and t.tipo_contrato in ('7')
					   and r.cod_cober_reas = _cod_cober_r
					exit foreach;
			   end foreach
			end if
		end if

		select count(*)
		  into _cnt
		  from reacoest
		 where cod_contrato  = _serie
		   AND cod_cobertura = 'EXC'
		   AND cod_ramo      = v_cod_ramo
		   and anio          = _anio_reas
		   and trimestre     = _trim_reas
		   and borderaux     = _borderaux;

         if _cnt = 0 then

		   --Para Agregar las cias de reacoase que no estan en reacoest
		   foreach
				select cod_coasegur,porc_cont_partic
				  into _cod_coasegur,_porc_cont_partic
				  from reacoase
				 where cod_contrato   = _cod_contrato
				   and cod_cober_reas = _cod_cober_r

				select count(*)
				  into _cnt
				  from reacoest
				 where cod_contrato  = _serie
				   AND cod_cobertura = 'EXC'
				   AND cod_ramo      = v_cod_ramo
				   and cod_coasegur  = _cod_coasegur
				   and anio          = _anio_reas
				   and trimestre     = _trim_reas
				   and borderaux     = _borderaux;

                if _cnt = 0 then

				    INSERT INTO reacoest(
							cod_coasegur,
							cod_ramo,
							cod_contrato,
							cod_cobertura,
							prima,
							comision,
							impuesto,
							prima_neta,
							siniestro,
							resultado,
							participar,
							p_partic,
							cod_clase,
							anio,
							trimestre,
							borderaux)
					VALUES (_cod_coasegur,
					        v_cod_ramo,
							_serie,
							'EXC',
							0, 
							0,
							0,
							0,
							_siniestro_cp * _porc_cont_partic /100,
							0,
							0, 
							_porc_cont_partic,
					        v_cod_ramo,
							_anio_reas,
							_trim_reas,
							_borderaux);

				else
					continue foreach;
				end if
		   end foreach

		 else

			UPDATE reacoest
			   SET siniestro     = siniestro + (_siniestro_cp * p_partic /100)
			 WHERE cod_contrato  = _serie
			   AND cod_cobertura = 'EXC'
			   AND cod_ramo      =  v_cod_ramo
			   and anio          = _anio_reas
			   and trimestre     = _trim_reas
			   and borderaux     = _borderaux
			   and cod_clase	 = _cod_cober_r;
		 end if

end foreach

Update reacoest
   set resultado  = prima_neta - siniestro,
       participar = prima_neta - siniestro
 where anio      = _anio_reas
   and trimestre = _trim_reas
   and borderaux = _borderaux;

delete from reacoest
 where cod_coasegur = '036'
   and borderaux = _borderaux;	--Excluir Aseguradora Ancon Omar 05/03/2013

foreach

	 SELECT cod_cobertura,
			sum(prima),
			sum(comision),
			sum(impuesto),
			sum(prima_neta),
			sum(siniestro),
			cod_contrato,
			cod_clase
	   into v_cobertura,
	        v_prima, 
			_comision, 
			_impuesto, 
			_por_pagar,
			_siniestro,
			v_cod_contrato,
			v_cod_ramo
       FROM reacoest
	  where anio      = _anio_reas
	    and trimestre = _trim_reas
	    and borderaux = _borderaux
	  group by cod_contrato,cod_clase,cod_cobertura
	  order by cod_contrato,cod_clase,cod_cobertura

     foreach 

	     SELECT distinct cod_coasegur,p_partic,resultado,participar
		   into	_cod_coasegur,_porc_cont_partic,_prima_tot_ret,_prima_sus_tot
	       FROM reacoest
		  where anio      = _anio_reas
		    and trimestre = _trim_reas
		    and borderaux = _borderaux
			and cod_cobertura = v_cobertura
			and cod_contrato  = v_cod_contrato
			and cod_clase     = v_cod_ramo


        SELECT nombre
          INTO v_desc_ramo
          FROM prdramo
         WHERE cod_ramo = v_cod_ramo;

-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%,3-Terremoto(001,003)30%,4-Ramos Tecnicos(010,011,014),
--    5-Fianzas(008,080),6-Acc. Personales(004),7-Vida Ind/Col(016,019)]

			if v_cod_ramo = '001' then
			   LET v_desc_ramo = 'INCENDIO';
			end if
			if v_cod_ramo = '003' then
			   LET v_desc_ramo = 'TERREMOTO';
			end if
		    LET v_desc_ramo = v_desc_ramo;


			select nombre
			  into v_desc_contrato
			  from emicoase
			 where cod_coasegur = _cod_coasegur;

			--let _prima_tot_ret = _por_pagar - _siniestro;
			--let _prima_sus_tot = _prima_tot_ret * _porc_cont_partic /100;

	         RETURN _cod_coasegur,	  --01
			        v_cod_ramo,		  --02
					v_cod_contrato,	  --03
					v_cobertura,	  --04
					v_prima, 		  --05
					_comision, 		  --06
					_impuesto, 		  --07
					_por_pagar,		  --08
					_siniestro,		  --09
					_prima_tot_ret,	  --10
					_prima_sus_tot,	  --11
					_porc_cont_partic,--12
					v_desc_ramo,	  --13
					v_desc_contrato,  --14
					v_descr_cia,	  --15
					_filtros
	                WITH RESUME;
	end foreach
end foreach

drop table if exists temp_produccion;
--drop table if exists temp_det;
--drop table if exists tmp_sinis;
--drop table if exists temp_devpri;

end

end procedure;