--Reporte para ver los registros de las tablas de estados de cuenta.REAESTCT1 Y REAESTCT2

DROP PROCEDURE sp_pr1006bk;

CREATE PROCEDURE "informix".sp_pr1006bk(a_compania CHAR(03), a_bx VARCHAR(255) DEFAULT "*",a_reas VARCHAR(255) DEFAULT "*", a_periodo1 char(7), a_periodo2 char(7),a_trim smallint default 0)
returning char(7),char(7),smallint,varchar(50),char(3),varchar(50),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),varchar(50),varchar(50),varchar(255),DECIMAL(16,2);

-- Procedimiento para ver los registros de los Estados de Cuenta de Reaseguro
-- Creado    : 08/11/2012 - Armando Moreno
-- execute procedure sp_pr1006("001","2012-04","2012-06","063;","01")

BEGIN
		DEFINE _ramo_reas         CHAR(3);
		DEFINE v_filtros          CHAR(255);
		DEFINE v_desc_ramo        CHAR(50);
		DEFINE v_descr_cia        CHAR(50);

		DEFINE  t_tipo    			CHAR(10);
		DEFINE  s_cod_coasegur      CHAR(3);
		DEFINE  s_cod_clase,v_clase CHAR(3); 
		DEFINE  s_cod_contrato      CHAR(5);
		DEFINE  _renglon			Smallint;
		DEFINE  m_contrato			CHAR(50);
		DEFINE  m_concepto1			CHAR(255);
		DEFINE  m_concepto2			CHAR(255);

		DEFINE _anio_reas			Char(9);
		DEFINE _trim_reas			Smallint;
		define _cnt                 integer;
		DEFINE  t_reasegurador		CHAR(50);
		DEFINE _cta_tec				DECIMAL(16,2);
		DEFINE _saldo_inicial       DECIMAL(16,2);
		DEFINE _saldo_final			DECIMAL(16,2);
		DEFINE _saldo_trim			DECIMAL(16,2);
		define _tipo2		        smallint;
		define _remesa_env			DECIMAL(16,2);
		define _remesa_rec,_valor   DECIMAL(16,2);
		define _periodo1            char(7);
		define _periodo3			char(7);
		define t_descripcion        char(50);
		define a_tipo,_contrato     char(2);
		define _tipo                char(1);
		define _remesa_otr          DECIMAL(16,2); 

SET ISOLATION TO DIRTY READ;

LET v_descr_cia = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_estado
				(periodo1      char(7),
				 periodo2      char(7),
				 trimestre     smallint,
				 ano           char(9),
				 reasegurador  CHAR(3),
				 contrato	   CHAR(10),
				 saldo_ant	   DECIMAL(16,2),
				 remesa_rec    DECIMAL(16,2),
				 remesa_env    DECIMAL(16,2),
				 remesa_otr    DECIMAL(16,2),
				 cta_tec       DECIMAL(16,2),
				 saldo_trim    DECIMAL(16,2), 
				 renglon       smallint,
				 seleccionado  smallint default 1);

--CREATE INDEX id1_tmp_estado ON tmp_estado(periodo1,periodo2,cod_ramo,cod_clase,reasegurador,contrato,p_partic,renglon);


--set debug file to "sp_pr1006.trc";	
--trace on;

let _remesa_otr = 0;

FOREACH

	select cod_contrato,
	       tipo
	  into a_tipo,
	  	   _tipo2
	  from reacontr
	 where activo = 1

	FOREACH

		select ano,
		       trimestre,
			   reasegurador,
		       saldo_inicial,
			   saldo_final,
			   saldo_trim
		  into _anio_reas,
		       _trim_reas,
		  	   s_cod_coasegur,
		       _saldo_inicial,
			   _saldo_final,
			   _saldo_trim
		  from reaestct1 
		 where contrato = a_tipo
	     order by ano,trimestre

	    select periodo1,
			   periodo3
		  into _periodo1,
			   _periodo3
		  from reatrim
		 where ano       = _anio_reas
		   and trimestre = _trim_reas;

		 SELECT sum(monto)
		   INTO _remesa_env
	       FROM reatrx1
		  WHERE cod_contrato = a_tipo
	        and periodo BETWEEN _periodo1 AND _periodo3
	        and cod_coasegur = s_cod_coasegur
		    and actualizado  = 1
	        and tipo = '01';	   --remesa enviada
		
		 SELECT sum(monto)
		   INTO _remesa_rec
	       FROM reatrx1
		  WHERE cod_contrato = a_tipo
	        and periodo BETWEEN _periodo1 AND _periodo3
	        and cod_coasegur = s_cod_coasegur
		    and actualizado  = 1
	        and tipo = '02';	   --remesa recibida

		 SELECT sum(monto)
		   INTO _remesa_otr
	       FROM reatrx1
		  WHERE cod_contrato = a_tipo
	        and periodo BETWEEN _periodo1 AND _periodo3
	        and cod_coasegur = s_cod_coasegur
		    and actualizado  = 1
	        and tipo not in('01','02');	   --remesa enviada


		 --Este select debo cambiarlo para sacar de reaestct2
		 select sum(participar)
		   into _cta_tec
		   from reacoest
		  where anio         = _anio_reas
		    and trimestre    = _trim_reas
		    and borderaux    = a_tipo
	        and cod_coasegur = s_cod_coasegur;

		INSERT INTO tmp_estado (periodo1,periodo2,trimestre,ano,reasegurador,contrato,saldo_ant,remesa_rec,remesa_env,cta_tec,saldo_trim,renglon,seleccionado,remesa_otr)
	                	VALUES(_periodo1,_periodo3,_trim_reas,_anio_reas,s_cod_coasegur,a_tipo,_saldo_inicial,_remesa_rec,_remesa_env,_cta_tec,_saldo_final,0,1,_remesa_otr);

	END FOREACH

	FOREACH

		select distinct trimestre,ano,contrato
		  into _trim_reas,_anio_reas,_contrato
		  from tmp_estado
		 where seleccionado = 1

        foreach

	   		 select cod_coasegur,
	   		        sum(participar)
			   into s_cod_coasegur,
			        _cta_tec
			   from reacoest
			  where anio         = _anio_reas
			    and trimestre    = _trim_reas
			    and borderaux    = _contrato
	            and cod_coasegur <> '036'
	          group by 1

			 select count(*)
			   into _cnt
			   from tmp_estado
			  where seleccionado = 1
			    and ano          = _anio_reas
				and trimestre    = _trim_reas
				and reasegurador = s_cod_coasegur;

		    select periodo1,
				   periodo3
			  into _periodo1,
				   _periodo3
			  from reatrim
			 where ano       = _anio_reas
			   and trimestre = _trim_reas;

			 if _cnt = 0 then
						INSERT INTO tmp_estado (periodo1,periodo2,trimestre,ano,reasegurador,contrato,saldo_ant,remesa_rec,remesa_env,cta_tec,saldo_trim,renglon,seleccionado,remesa_otr)
	                	VALUES(_periodo1,_periodo3,_trim_reas,_anio_reas,s_cod_coasegur,_contrato,0,0,0,_cta_tec,0,0,1,0);
			 end if
        
        end foreach 

	END FOREACH

	if a_trim = 0 then
		CALL sp_rea002(a_periodo2,_tipo2) RETURNING _anio_reas,_trim_reas;
		    select periodo1,
				   periodo3
			  into _periodo1,
				   _periodo3
			  from reatrim
			 where ano       = _anio_reas
			   and trimestre = _trim_reas;

		foreach
	   		 select cod_coasegur,
	   		        sum(participar)
			   into s_cod_coasegur,
			        _cta_tec
			   from reacoest
			  where anio         = _anio_reas
			    and trimestre    = _trim_reas
			    and borderaux    = a_tipo
	            and cod_coasegur <> '036'
	          group by 1

			select count(*)
			  into _cnt
			  from tmp_estado
			 where trimestre  = _trim_reas
			   and ano        = _anio_reas
			   and contrato   = a_tipo;

			if _cnt = 0 then
				INSERT INTO tmp_estado (periodo1,periodo2,trimestre,ano,reasegurador,contrato,saldo_ant,remesa_rec,remesa_env,cta_tec,saldo_trim,renglon,seleccionado,remesa_otr)
	           	VALUES(_periodo1,_periodo3,_trim_reas,_anio_reas,s_cod_coasegur,a_tipo,0,0,0,_cta_tec,0,0,1,0);
			end if

        end foreach
        
    else
       foreach
   		 select distinct anio,trimestre
		   into _anio_reas,_trim_reas
		   from reacoest
		  where borderaux = a_tipo

		select count(*)
		  into _cnt
		  from tmp_estado
		 where trimestre  = _trim_reas
		   and ano        = _anio_reas
		   and contrato   = a_tipo;

          if _cnt = 0 then

   		    select periodo1,
				   periodo3
			  into _periodo1,
				   _periodo3
			  from reatrim
			 where ano       = _anio_reas
			   and trimestre = _trim_reas;

			foreach
		   		 select cod_coasegur,
		   		        sum(participar)
				   into s_cod_coasegur,
				        _cta_tec
				   from reacoest
				  where anio         = _anio_reas
				    and trimestre    = _trim_reas
				    and borderaux    = a_tipo
		            and cod_coasegur <> '036'
		          group by 1

				INSERT INTO tmp_estado (periodo1,periodo2,trimestre,ano,reasegurador,contrato,saldo_ant,remesa_rec,remesa_env,cta_tec,saldo_trim,renglon,seleccionado,remesa_otr)
	           	VALUES(_periodo1,_periodo3,_trim_reas,_anio_reas,s_cod_coasegur,a_tipo,0,0,0,_cta_tec,0,0,1,0);
			end foreach

		  end if

	   end foreach
	end if

END FOREACH


--Filtros
let v_filtros = "";

IF a_bx <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || "Borderaux "||TRIM(a_bx);
	LET _tipo = sp_sis04(a_bx); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_estado
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND contrato NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE tmp_estado
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND contrato IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF

IF a_reas <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Reasegurador "||TRIM(a_reas);
	LET _tipo = sp_sis04(a_reas); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_estado
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND reasegurador NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE tmp_estado
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND reasegurador IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF

if a_trim = 1 then --todos
else

	UPDATE tmp_estado
       SET seleccionado = 0
     WHERE seleccionado = 1
       AND (periodo1  <> a_periodo1
       AND periodo2   <> a_periodo2);

end if

let _valor = 0;
foreach
	select periodo1,
	       periodo2,
		   trimestre,
		   ano,
		   reasegurador,
		   contrato,
		   saldo_ant,
		   remesa_rec,
		   remesa_env,
		   cta_tec,
		   saldo_trim,
		   remesa_otr
	  into _periodo1,
		   _periodo3,
		   _trim_reas,
		   _anio_reas,
		   s_cod_coasegur,
		   a_tipo,
		   _saldo_inicial,
		   _remesa_rec,
		   _remesa_env,
		   _cta_tec,
		   _saldo_final,
		   _remesa_otr
	  from tmp_estado
	 where seleccionado = 1

	 if _remesa_rec is null then
	    let _remesa_rec = 0;
	 end if
	 if _cta_tec is null then
	    let _cta_tec = 0;
	 end if
     if _saldo_final is null then
	    let _saldo_final = 0;
	 end if
     if _saldo_inicial is null then
	    let _saldo_inicial = 0;
	 end if
	 if _remesa_env is null then
	    let _remesa_env = 0;
	 end if
	 if _remesa_otr is null then
	    let _remesa_otr = 0;
	 end if

	 let _valor = _saldo_inicial + _cta_tec + (_remesa_rec + _remesa_env + _remesa_otr);

	 if _valor > 0 then
		let _valor = _valor * -1;
	 else
		let _valor = _valor * -1;
	 end if

     let _saldo_final = _valor;

     if _saldo_inicial > 0 then
		let _saldo_inicial = _saldo_inicial * -1;
	 else
		let _saldo_inicial = _saldo_inicial * -1;
	 end if
	 if _remesa_rec < 0 then
		let _remesa_rec = _remesa_rec * -1;
	 else
		let _remesa_rec = _remesa_rec * -1;
	 end if
	 if _remesa_env < 0 then
		let _remesa_env = _remesa_env * -1;
	 else
		let _remesa_env = _remesa_env * -1;
	 end if

	 if _cta_tec > 0 then
		let _cta_tec = _cta_tec * -1;
	 else
		let _cta_tec = _cta_tec * -1;
	 end if

	select nombre
	  into t_reasegurador
	  from emicoase
	 where cod_coasegur = s_cod_coasegur;

	select descripcion
	  into t_descripcion
	  from reatrim
	 where ano       = _anio_reas
	   and trimestre = _trim_reas;

	select nombre
	  into m_contrato
	  from reacontr
	 where activo = 1
	   and cod_contrato = a_tipo;


    RETURN _periodo1,	   
		   _periodo3,	   
		   _trim_reas,	   
		   t_reasegurador,
		   s_cod_coasegur,
		   m_contrato,	   
		   _saldo_inicial,  
		   _remesa_rec,  
		   _remesa_env,  
		   _cta_tec,  
		   _saldo_final,  
		   v_descr_cia,
		   t_descripcion,
		   v_filtros,
		   _remesa_otr
    	   WITH RESUME;

end foreach

--drop table tmp_estado;

END
END PROCEDURE;	 